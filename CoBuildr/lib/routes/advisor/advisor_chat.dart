import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namer_app/routes/chat/chat_details.dart';
import 'package:namer_app/services/chat_service.dart';
import 'package:intl/intl.dart';


class AdvisorChatPage extends StatefulWidget {
  const AdvisorChatPage({Key? key}) : super(key: key);


  @override
  State<AdvisorChatPage> createState() => _AdvisorChatPageState(); // create the state
}


class _AdvisorChatPageState extends State<AdvisorChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // create instance of authentication to be used to get current user


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // get rid of back button for now (so buggy)
        title: Center(
          child: Text(
            'Messages',
            style: TextStyle(
              color: const Color.fromARGB(255, 111, 15, 128),
            ),
          ),
        ), // name of the page
      ),


      body: Column( // show the list of the users that the current user has messages with
        children: [
          Expanded(
            child: _buildUserList(), // call the buildUserList method
          ),
        ],
      ),


      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 111, 15, 128),
        onPressed: () {
          _createNewChatDialog(context);
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          // Handle bottom navigation bar taps
          if (index == 0) {
            // Navigate to Dashboard page
            Navigator.pushNamed(context, '/advisor/advisor_dashboard');
          } else if (index == 1) {
            // Navigate to Your Projects page
            Navigator.pushNamed(context, '/advisor/project_tab');
          } else if (index == 3) {
            // Navigate to Settings page
            Navigator.pushNamed(context, '/advisor/advisor_setting');
          }
        },
        items: [
          _buildNavItem(Icons.dashboard, 'Dashboard'),
          _buildNavItem(Icons.list, 'Projects'),
          _buildNavItem(Icons.message, 'Messages'),
          _buildNavItem(Icons.settings, 'Settings'),
        ],
        type: BottomNavigationBarType.fixed, // Ensure icons remain visible even when not selected
      ),
    );
  }


  // build list of users that user is currently chatting with
  Widget _buildUserList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add horizontal padding
      child : Container( // create container widget
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0), // padding
        decoration: BoxDecoration( // color decoration
          color: Colors.purple[50], // light purple
          borderRadius: BorderRadius.circular(8.0), // more circular cornoers
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10.0), // padding
              child: Text(
                'Contacts', // name of the pae
                style: TextStyle(
                  fontWeight: FontWeight.bold, // make it bold
                  fontSize: 20.0,
                  color: const Color.fromARGB(255, 111, 15, 128),  // bigger size
                ),
              ),
            ),
         
            Expanded(
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbVisibility: MaterialStateProperty.all<bool>(true),// Adjust the thickness of the scrollbar
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('chat_rooms').orderBy('chatTimestamp', descending: true).snapshots(), // value that changes over time so we use stream builder (a dynamic list)
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}'); // show any errors
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text(''); // show loading if the data is still being loaded in
                    }


                    final chatRooms = snapshot.data!.docs; // get the users
       
                    return ListView.builder( // build a list of all users (like how we see in imessages)
                   
                      padding: EdgeInsets.only(right: 16.0),
                      itemCount: chatRooms.length,
                      itemBuilder: (context, index) {
                        final chatDataId = chatRooms[index].id;
                        final chatData = chatRooms[index].data()! as Map<String, dynamic>; // get each users data
                        final timestamp = chatData['chatTimestamp'].toDate();
                        final formattedDate = DateFormat.yMd().add_jm().format(timestamp);
                        if (chatDataId.contains(_auth.currentUser!.uid)) { // go through all emails that are not the current user
                          String otherUserId = chatDataId.split('_').firstWhere((id) => id != _auth.currentUser!.uid);
                          return FutureBuilder<String?>(
                             future: _getUserEmailByUid(otherUserId),
                             builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Text('');
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              final email = snapshot.data.toString();
                              return Material( // material so the flutter animation when hover shows up
                                color: Colors.transparent, // make transparent
                                child: Column(
                                  children: [
                                    ListTile(  
                                      title: Text(email),
                                      subtitle: Text(formattedDate, style:
                                        TextStyle(
                                          fontSize: 10
                                        ),
                                      ), // the title of the list will be the email
                                      onTap: () { // if they tap on the chat (on pressed used with buttons as done in my chatDetails page)
                                        Navigator.push(
                                          context, // push to the chat details page
                                            MaterialPageRoute(
                                              builder: (context) => ChatDetails(
                                                recieverUserEmail: email, // push the email and uid, as wanted in the chatDetails page
                                                recieverUserID: otherUserId,
                                              ),
                                            ),
                                          );
                                        },
                                        trailing: Icon(
                                          Icons.arrow_forward, // arrow icon
                                          color: Colors.purple,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // add more padding
                                      ),
                                      Divider( // add a divider
                                        color: Colors.white,
                                        thickness: 1.0,
                                        height: 0.0,
                                      ),
                                    ]
                                  )
                                );
                             }
                          );
                        }
                        else { // if the user is the current user than just return empty (we dont want to message ourselves)
                          // empty
                          return Container();
                        }
                      },
                    );
                  },
                )
              )
            )
          ]
        )
      )
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
                if (_messageController.text.isEmpty || _emailController.text.isEmpty) // before anything check if user is trying to send empty chat
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill all fields.'), // give them an error message
                    ),
                  );
                }
                else // if the message controler has content then check validty of email
                {
                  final recipientUserId = await _getUserUidByEmail(_emailController.text); // get reciepent id
                  if (recipientUserId != null && recipientUserId != _auth.currentUser!.uid) { // if the userId exists
                    await _chatService.sendMessage(recipientUserId, _messageController.text); // send the message using chatService
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/chat');
                  }
                   
                  else { // if it doesnt exist
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Invalid email.'), // show the error message
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


  // given uid get email
  Future<String?> _getUserEmailByUid(String id) async {
    final querySnapshot = await FirebaseFirestore.instance // get the query of the userId
        .collection('users')
        .where('uid', isEqualTo: id)
        .get();
   
    return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first.get('email') : null; // check if the query exists, if it doesnt return null if it does return the query snapshot of the first id
  }


  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: Colors.purple,
      ),
      label: label,
    );
  }
}
