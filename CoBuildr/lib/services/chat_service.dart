import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namer_app/models/message.dart';

class ChatService extends ChangeNotifier{

  // get instance of auth and firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  // send message
  Future<void> sendMessage(String recieverId, String message) async
  {
    // get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      recieverId: recieverId,
      timestamp: timestamp,
      message: message,);

    // construct a chatroom id from current user id and reciever id( sort to ensure uniqueness)
    List<String> ids = [currentUserId, recieverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    

    await _fireStore.collection('chat_rooms').doc(chatRoomId).collection('messages').add(newMessage.toMap());
    await _fireStore.collection('chat_rooms').doc(chatRoomId).set({
    'chatTimestamp': timestamp, 
    });
    // add new message to database

    
  }

  // get message
  Stream <QuerySnapshot> getMessages(String userId, String otherUserId){
    // construct chat room id from users
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    // get the message from the given chat room id
    return _fireStore.collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots();

  }

  // check if the current user is chatting w a given user (this method is why we use futureBuilder)
  Future<bool> hasChatMessages(String otherUserId) async {
    final currentUserUid = _firebaseAuth.currentUser!.uid; // get the current user id
    final chatRoomId = [currentUserUid, otherUserId]; //get the chat room id
    chatRoomId.sort(); // sort as it is sorted when the chat is created
    final chatRoomIdString = chatRoomId.join('_'); // join the sorted room ids to get the actual chat room id
    final querySnapshot = await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomIdString)
        .collection('messages')
        .get(); // query all the messages

    return querySnapshot.docs.isNotEmpty; // determine if its true or false (our Future)
  }

  Future<Map<String, dynamic>> getRecentMessage(String userId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final recentMessage = querySnapshot.docs.first.data();
      return {
        'message': recentMessage['message'],
        'timestamp': recentMessage['timestamp'],
      };
    }
    return {}; 
  }



}