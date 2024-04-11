import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:namer_app/services/chat_service.dart';

class ChatDetails extends StatefulWidget {
  final String recieverUserEmail;
  final String recieverUserID;
  const ChatDetails({
    super.key,
    required this.recieverUserEmail,
    required this.recieverUserID,
  });

  @override
  State<ChatDetails> createState() => _ChatDetailsState();

}

class _ChatDetailsState extends State<ChatDetails> {

  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty){
      await _chatService.sendMessage(widget.recieverUserID,_messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.recieverUserEmail)),
      body: Column(
        children:[
          Expanded(
            child: _buildMessageList(),
            ),

            _buildMessageInput(),
        ],
      ),
      
      
      );
      
  }

  // build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.recieverUserID, _firebaseAuth.currentUser!.uid),
      builder: (context,snapshot) {
        if (snapshot.hasError)
        {
          return Text('Error${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting)
        {
          return const Text('loading');
        }

        return ListView(
          children: snapshot.data!.docs.map((document)=> _buildMessageItem(document)).toList(),
        );
      }
      
      );
  }



  // build message item
  Widget _buildMessageItem(DocumentSnapshot document){
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    // align 

    var align = (data['senderId'] == _firebaseAuth.currentUser!.uid) ? 
    Alignment.centerRight: Alignment.centerLeft;

    return Container(
      alignment: align,
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
            controller: _messageController,
            obscureText: false,
          ),
          
        ),

        // send button
        IconButton(
          onPressed: sendMessage, 
          icon: const Icon(
            Icons.arrow_upward,
            size:40,
            )
          ),
      ],

    );
  }
}