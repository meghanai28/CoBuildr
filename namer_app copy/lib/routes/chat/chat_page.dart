import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/routes/chat/chat_details.dart';
import 'package:namer_app/services/chat_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState(); // create the state
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // create instance of authentication to be used to get current user

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // get rid of back button for now (so buggy)
        title: const Text('Chat Page'), // name of the page
      ),

      body: Column( // show the list of the users that the current user has messages with
        children: [
          Expanded(
            child: _buildUserList(), // call the buildUserList method
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 219, 110, 255),
        onPressed: () {
          _createNewChatDialog(context);
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // build list of users that user is currently chatting with
  Widget _buildUserList() {
    ChatService _chatService = ChatService();
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(), // value that changes over time so we use stream builder (a dynamic list)
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // show any errors
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading'); // show loading if the data is still being loaded in
        }

        final users = snapshot.data!.docs; // get the users
        
        return ListView.builder( // build a list of all users (like how we see in imessages)
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index].data()! as Map<String, dynamic>; // get each users data
            if (_auth.currentUser!.email != userData['email'] && userData['uid'] != null) { // go through all emails that are not the current user
              return FutureBuilder<bool>(
                future: _chatService.hasChatMessages(userData['uid']),  // wait for this method to bring a result
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}'); // show any errors
                  }
                  
                  if (snapshot.connectionState == ConnectionState.waiting) { // get connection state
                    return const Text('Loading'); // show loading if its loading
                  }

                  final hasChatMessages = snapshot.data ?? false; // check if there is any data
                  if (hasChatMessages) { // if there are chat messages show this on our chat page
                    return ListTile(
                      title: Text(userData['email']), // the title of the list will be the email
                      onTap: () { // if they tap on the chat (on pressed used with buttons as done in my chatDetails page)
                        Navigator.push(
                          context, // push to the chat details page
                          MaterialPageRoute(
                            builder: (context) => ChatDetails(
                              recieverUserEmail: userData['email'], // push the email and uid, as wanted in the chatDetails page
                              recieverUserID: userData['uid'],
                            ),
                          ),
                        );
                      },
                    );
                  } 
                  
                  else { // if there is no chat messages just return empty (we dont want to see it in our list)
                    // empty
                    return Container(); 
                  }
                },
              );
            } 
            
            else { // if the user is the current user than just return empty (we dont want to message ourselves)
              // empty
              return Container();
            }
          },
        );
      },
    );
  }

  // popup dialog for creating a new chat
  void _createNewChatDialog(BuildContext context) {
    TextEditingController _emailController = TextEditingController(); // give a place for email controller to be used
    TextEditingController _messageController = TextEditingController(); // give a place for message to be also used
    ChatService _chatService = ChatService(); // use chat services since we are sending a message

    showDialog( // show Dialog method helps us do a popup on creen
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog( // use alert dialog to get it one screen w the needed buttons and actions
          title: Text("Create Chat Message"), // name of the popup
          content: Column( // use column like I did in the chat details page
            children: [
              //text field
              Expanded(
                child: TextField( // textfield for user
                  controller: _emailController, // let user input the email
                  obscureText: false, // let them see it
                  decoration: InputDecoration(
                      labelText: 'User Email', // tell them to input the user email
                  ),
                ),
          
              ),
              
              Expanded(
                child: TextField(
                  controller: _messageController, // let user input their message
                  obscureText: false, // let them see it
                  decoration: InputDecoration(
                      labelText: 'Message', // tell them this is where they input the user message
                  ),
                ),
          
              ),
  
            ]
          ),
          
          actions: <Widget>[
            TextButton( // button where user can exit the widget
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
        
            TextButton( // button where user can send their message
              onPressed: () async { // cause we call an async method
                if (_messageController.text.isEmpty) // before anything check if user is trying to send empty chat
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please type a message before sending.'), // give them an error message
                    ),
                  );
                }
                else // if the message controler has content then check validty of email
                {
                  final recipientUserId = await _getUserUidByEmail(_emailController.text); // get reciepent id
                  if (recipientUserId != null) { // if the userId exists
                    await _chatService.sendMessage(recipientUserId, _messageController.text); // send the message using chatService
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/chat');
                  }
                    
                  else { // if it doesnt exist
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Email does not exist.'), // show the error message
                      ),
                    );
                  }
                }
                
              },
              child: Text("Send"), // this is the send button which does all of the stuff above when pressed
            ),
          ],
        );   
      },
    );
  }

  // given email get uid
  Future<String?> _getUserUidByEmail(String email) async {
    final querySnapshot = await FirebaseFirestore.instance // get the query of the userId
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    
    return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first.id : null; // check if the query exists, if it doesnt return null if it does return the query snapshot of the first id
  }
}

