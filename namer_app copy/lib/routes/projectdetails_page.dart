import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProjectDetailsPage extends StatefulWidget {
  final String projectId; 
   ProjectDetailsPage({required this.projectId}); //currently project should use projectId/ some type of identifier to make sure the project is correct

  @override
  _ProjectDetailsPageState createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _projectStream; 

  @override
  void initState() {
    super.initState(); 
    _projectStream = FirebaseFirestore.instance
      .collection('published_projects')
      .doc(widget.projectId)
      .snapshots();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar (
        title: Text('Project Details'), 
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>> (
        stream: _projectStream,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); 
          }

          if(!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(child: Text('Project not found.')); 
          }

          final projectData = snapshot.data!.data()!; 
          return SingleChildScrollView(
            padding:EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  projectData['title'],
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold), 
                  
                ), 

                SizedBox(height: 16.0),
                  Text(
                  'Tags: ${projectData['tags'].join(', ')}', 
                  style: TextStyle(fontStyle: FontStyle.italic), 
                ), 

                // SizedBox(height: 16.0), //originally for 
                // if (projectData.containsKey('imageURL'))
                //   Image.network(
                //     projectData['imageUrl'], 
                //     height: 200, 
                //     width: 200, 
                //     fit: BoxFit.cover, 
                //   ), 
                SizedBox(height: 16.0),
                Text(
                  'Groupmates',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  _buildGroupmatesRow(),
                SizedBox(height: 32.0),

                SizedBox(height: 16.0),
                Text(
                  projectData['description'], 
                  style: TextStyle(fontSize: 16.0), 
                ),
                SizedBox(height: 32.0),
                Text(
                  'Created By: ${projectData['userId']}',
                    style: TextStyle(fontSize: 16.0), 
                ),
              ],
            ),
          );
        },
      ),
    ); 
   }

   Widget _buildGroupmatesRow() {
    // tester data for groupmates (replace with actual data)
    List<String> groupmates = ['John', 'Alice', 'Bob', 'Emma'];

    return Row(
      children: groupmates.map((mate) {
        return Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: CircleAvatar(
            child: Text(mate[0]),
            // profile pictures with person's first letter of their name 
            backgroundColor: Colors.grey,
            radius: 32.0,
          ),
        );
      }).toList(),
    );
   }
  
  }