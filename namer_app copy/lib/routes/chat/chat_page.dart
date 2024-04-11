import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/routes/chat/chat_details.dart';
import 'package:namer_app/services/chat_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Chat Page'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildUserList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewChatDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // build list of users that user is currently chatting with
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading');
        }

        final users = snapshot.data!.docs;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final userData = users[index].data()! as Map<String, dynamic>;
            if (_auth.currentUser!.email != userData['email'] && userData['uid'] != null) {
              return FutureBuilder<bool>(
                future: _hasChatMessages(userData['uid']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading');
                  }
                  final hasChatMessages = snapshot.data ?? false;
                  if (hasChatMessages) {
                    return ListTile(
                      title: Text(userData['email']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetails(
                              recieverUserEmail: userData['email'],
                              recieverUserID: userData['uid'],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    // empty
                    return Container();
                  }
                },
              );
            } else {
              // empty
              return Container();
            }
          },
        );
      },
    );
  }

  // Check if the current user has chat messages with a specific user
  Future<bool> _hasChatMessages(String otherUserId) async {
    final currentUserUid = _auth.currentUser!.uid;
    final chatRoomId = [currentUserUid, otherUserId];
    chatRoomId.sort();
    final chatRoomIdString = chatRoomId.join('_');
    final querySnapshot = await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomIdString)
        .collection('messages')
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  // Show a popup dialog for creating a new chat
  void _showNewChatDialog(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController messageController = TextEditingController();
    ChatService service = ChatService();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Create New Chat'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Recipient Email',
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      labelText: 'Message',
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final recipientUserId = await _getUserUidByEmail(emailController.text);
                    if (recipientUserId != null) {
                      await service.sendMessage(recipientUserId, messageController.text);
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/chat');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('User does not exist!'),
                        ),
                      );
                    }
                  },
                  child: Text('Send'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Get user UID by email
  Future<String?> _getUserUidByEmail(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first.id : null;
  }
}

