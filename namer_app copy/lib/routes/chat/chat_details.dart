import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/services/chat_service.dart';

class ChatDetails extends StatefulWidget {
  final String recieverUserEmail; //get recieverUserEmail
  final String recieverUserID; // get recieverUserID
  const ChatDetails({
    super.key,
    required this.recieverUserEmail,
    required this.recieverUserID,
  });

  @override
  State<ChatDetails> createState() => _ChatDetailsState(); // call this state

}

class _ChatDetailsState extends State<ChatDetails> {

  final TextEditingController _messageController = TextEditingController(); // get a text editor
  
  final ChatService _chatService = ChatService(); // get chat services for message/chatroom retrieval 

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // instantiate firebase authentication

  ScrollController _scrollController = ScrollController(); // control scroller for user to scroll

  // send message using chatService sendMessage method
  void sendMessage() async {
    if (_messageController.text.isNotEmpty){
      await _chatService.sendMessage(widget.recieverUserID,_messageController.text);
      _messageController.clear();
    }
  }

  // build the layout for the chat room (this is the chat details page)
  @override
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.recieverUserEmail)), // title will be name of the recieverUserId
      body: Column(
        children:[
          Expanded(
            child: _buildMessageList(), // build the message list and show on UI
          ),

          _buildMessageInput(), // where the user will input their new message
        ],
      ),
      
      
      );
      
  }

  // build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.recieverUserID, _firebaseAuth.currentUser!.uid), // this is the stream of data this page will listen to
      builder: (context,snapshot) {
        if (snapshot.hasError)
        {
          return Text('Error${snapshot.error}'); // show any possible errors that may occur
        }

        if (snapshot.connectionState == ConnectionState.waiting)
        {
          return const Text('loading'); // load while getting the data 
        }

        WidgetsBinding.instance.addPostFrameCallback((_)  // scroll to the bottom of the chat, so user sees most recent messages
        {
          _scrollController.animateTo
          (
            _scrollController.position.maxScrollExtent, // max extent that can be scrolled
            duration: const Duration(milliseconds: 100), // duration that scroll happens (make it 100 milliseconds)
            curve: Curves.easeOut, // easy on the eyes during scrolling
          );
        });

        return ListView( // display all the data
          controller: _scrollController,  // use the controller with the animation done above
          children: snapshot.data!.docs.map((document)=> _buildMessageItem(document)).toList(), // fetch chat room messages as a collection and return/convert to a list
        );
      }
      
      );
  }



  // build message item
  Widget _buildMessageItem(DocumentSnapshot document){
    Map<String, dynamic> data = document.data() as Map<String, dynamic>; // get the data as a map given the documentSnapShot
    // align 

    var align = (data['senderId'] == _firebaseAuth.currentUser!.uid) ? 
    Alignment.centerRight: Alignment.centerLeft; // select alignment based on if the senderId is the current viewer in session or not 
    // this helps us determine if the user is a reciever or sender in each specific chatroom (this is for each message in the chat)

    return Container(
      alignment: align, // align based on this
      child: Column(
        children: [
          Text(data['senderEmail']),
          Text(data['message'])
        ],
        ),
    );

  }


  // build message input
  Widget _buildMessageInput()
  {
    return Row(
      children: [
        //text field
        Expanded(
          child: TextField(
            controller: _messageController, // let user input their message
            obscureText: false, // let them see it
            decoration: InputDecoration(
                      labelText: 'Message',
            ),
          ),
          
        ),

        // send button
        IconButton(
          onPressed: sendMessage, // call sendMessage method when the arrow is pressed
          icon: const Icon(
            Icons.arrow_upward,
            size:40,
            )
          ),
      ],

    );
  }
}