import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/services/chat_service.dart';
import 'package:intl/intl.dart';

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
      
      appBar: AppBar(
        title: Text(widget.recieverUserEmail),// get rid of back button for now (so buggy)
      ), // title will be name of the recieverUserId
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
    CrossAxisAlignment.end: CrossAxisAlignment.start; // select alignment based on if the senderId is the current viewer in session or not 
    // this helps us determine if the user is a reciever or sender in each specific chatroom (this is for each message in the chat)

    var color = (data['senderId'] == _firebaseAuth.currentUser!.uid) ? 
    Colors.purple : Colors.grey; // select color based on that

    return Container( // create container for message
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0), // add padding
      child: Column(
        crossAxisAlignment: align, // align left or right
        children: [
          Container(
            decoration: BoxDecoration(
              color: color, // color based on sender/reciever
              borderRadius: BorderRadius.circular(8.0), // make circle like messages
            ),
            padding: EdgeInsets.all(12.0), // add padding
            child: Text(
              data['message'], // the message 
              style: TextStyle(color: Colors.white), // in white
            ),
          ),
          SizedBox(height: 4.0), // spacing
          Text(
            data['senderEmail'], // the email
            style: TextStyle(color: Colors.black), // black
          ),
          SizedBox(height: 1.0),
          Text(
            DateFormat.yMd().add_jm().format(data['timestamp'].toDate()),
            style: TextStyle(color: Colors.black, fontSize: 10), // black
          ),
        ],
      ),
    );

  }


  // build message input
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // add padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // align
        children: [
          Expanded(
            child: LimitedBox(
              maxHeight: 60, // set the height to 60
              child: TextField(
                controller: _messageController,
                maxLines: 3, // limit the number of lines to 3 so that the scrolling is aparent
                decoration: InputDecoration(
                  labelText: 'Message', // label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0), // circle radius
                  ),
                  contentPadding: EdgeInsets.all(12.0), // add padding
                ),
              ),
            ),
          ),
          SizedBox(width: 8.0), // ad a box between text message and the send button
          Material(
            color: Colors.transparent, // make transparent
            child: InkWell(
              onTap: sendMessage, // send message on icon click
              borderRadius: BorderRadius.circular(20.0), // make circle
              child: Container(
                padding: EdgeInsets.all(12.0), // add padding
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0), // make circle
                  color: Colors.purple, // add color
                ),
                child: Icon(
                  Icons.arrow_upward, // up arrow (show eneter)
                  size: 24, // nice size
                  color: Colors.white, // make white inside the purple
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}