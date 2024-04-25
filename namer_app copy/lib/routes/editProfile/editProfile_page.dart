import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as Path;
import 'package:flutter/foundation.dart' show kIsWeb;

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState(); // create the state
}

class _EditProfileState extends State<EditProfile> {

  ImagePicker _imagePicker = ImagePicker();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
    );
  }


  Widget _createPFP() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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
}







