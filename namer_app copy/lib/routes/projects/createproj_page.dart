import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateProjectPage extends StatefulWidget {
  @override
  _CreateProjectPageState createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _filtersController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 100,
      maxWidth: 100,
    );

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  void publishProject(BuildContext context, bool isDraft, User user) async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _filtersController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter all fields')),
      );
      return;
    }

    try {
      final projectData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'tags': _filtersController.text.split(',').map((tag) => tag.trim()).toList(),
        'userId': user.uid,
        'teammates' : [],
      };

      if (!isDraft) {
        // Publish project
        await FirebaseFirestore.instance.collection('published_projects').add(projectData);
      } else {
        // Save project to drafts
        await FirebaseFirestore.instance.collection('draft_projects').add(projectData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project ${isDraft ? 'saved' : 'published'} successfully')),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error ${isDraft ? 'saving' : 'publishing'} project')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle case where user is not logged in
      return Scaffold(
        body: Center(
          child: Text('User not logged in'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Project'),
        automaticallyImplyLeading: false, // get rid of back button for now (so buggy)
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Project Title'),
            ),
            SizedBox(height: 20.0),
            Text('Tags (comma-separated)'),
            TextFormField(
              controller: _filtersController,
              decoration: InputDecoration(labelText: 'Project Filters'),
            ),
            SizedBox(height: 20.0),
            _image == null
                ? ElevatedButton(
              onPressed: _getImage,
              child: Text('Add Project Image'),
            )
                : Image.file(
              _image!,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 5,
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => publishProject(context, true, user), // Save as draft
                  child: Text('Save'),
                ),
                ElevatedButton(
                  onPressed: () => publishProject(context, false, user), // Publish
                  child: Text('Publish'),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          // Handle bottom navigation bar taps
          if (index == 0) {
            // Navigate to Dashboard page
            Navigator.pushNamed(context, '/dashboard');
          } else if (index == 2) {
            // Navigate to Your Projects page
            Navigator.pushNamed(context, '/yourProjects');
          } else if (index == 3) {
            // Navigate to Messages page
            Navigator.pushNamed(context, '/chat');
          } else if (index == 4) {
            // Navigate to Settings page
            Navigator.pushNamed(context, '/editProfile');
          }
        },
        items: [
          _buildNavItem(Icons.dashboard, 'Dashboard'),
          _buildNavItem(Icons.add, 'Create Project'),
          _buildNavItem(Icons.list, 'Your Projects'),
          _buildNavItem(Icons.message, 'Messages'),
          _buildNavItem(Icons.settings, 'Settings'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
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
