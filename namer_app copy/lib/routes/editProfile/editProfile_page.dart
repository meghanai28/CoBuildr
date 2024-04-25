import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState(); // create the state
}

class _EditProfileState extends State<EditProfile> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // get rid of back button for now (so buggy)
        title: const Text('Edit Profile Page'), // name of the page
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0),
            child: _createPFP(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        onTap: (index) {
          // Handle bottom navigation bar taps
          if (index == 0) {
            // Navigate to Dashboard page
            Navigator.pushNamed(context, '/dashboard');
          } else if (index == 1) {
            // Navigate to Create Project page
            Navigator.pushNamed(context, '/createProject');
          } else if (index == 2) {
            // Navigate to Your Projects page
            Navigator.pushNamed(context, '/yourProjects');
          } else if (index == 3) {
            // Navigate to Settings page
            Navigator.pushNamed(context, '/chat');
          }
        },
        items: [
          _buildNavItem(Icons.dashboard, 'Dashboard'),
          _buildNavItem(Icons.add, 'Create Project'),
          _buildNavItem(Icons.list, 'Your Projects'),
          _buildNavItem(Icons.message, 'Messages'),
          _buildNavItem(Icons.settings, 'Settings'),
        ],
        type: BottomNavigationBarType.fixed, // Ensure icons remain visible even when not selected
      ),
    );
  }


  Widget _createPFP() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if(snapshot.hasData)
        {
          var userProfile = snapshot.data!.data() as Map<String, dynamic>;
          return CircleAvatar(
            radius: 90,
            backgroundImage: NetworkImage(userProfile['profilePictureUrl']),
          ); 
        }
        else
        {
          return CircleAvatar(
            radius: 90,
          );
        } 
      },
    );
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







