import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

//Scoll behavior class to handle scrolling in the app
class CustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

//StatefulWidget for create project page
class CreateProjectPage extends StatefulWidget {
  @override
  _CreateProjectPageState createState() => _CreateProjectPageState();
}


class _CreateProjectPageState extends State<CreateProjectPage> {
  // Controllers for text fields and scrolling behavior
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _filtersController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Function to publish a project (either as a draft or final)
  void publishProject(BuildContext context, bool isDraft, User user) async {
    //Checks if all fields are filled
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _filtersController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter all fields')),
      );
      return;
    }


  // Saves the project data to the database using what the user typed in the text fields 
    try {
      final projectData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'tags': _filtersController.text.split(',').map((tag) => tag.trim()).toList(),
        'userId': user.uid,
        'teammates': [],
        'likers': [],
        'advisors': [],
        'advisorActive': false,
      };

      if (!isDraft) {
        // Publish project to the database
        await FirebaseFirestore.instance.collection('published_projects').add(projectData);
      } else {
        // Save project to drafts in the database
        await FirebaseFirestore.instance.collection('draft_projects').add(projectData);
      }

      // Success message and navigates to the Projects page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project ${isDraft ? 'saved' : 'published'} successfully')),
      );
      
      Navigator.pushNamed(context, '/yourProjects');
    } catch (e) {
      // Show error message if app fails to publish/save project
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error ${isDraft ? 'saving' : 'publishing'} project')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gets the current user
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
        //App bar title and styling
        title: Center(
          child: Text(
            'Create Project',
            style: TextStyle(
              color: const Color.fromARGB(255, 111, 15, 128), 
            ),
          ),
        ),
        automaticallyImplyLeading: false, 
      ),
      // Styling for the page 
      body: ScrollConfiguration(
        behavior: CustomScrollBehavior(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                // Text field for Project Title
                'Project Title',
                style: TextStyle(
                  color: const Color.fromARGB(255, 111, 15, 128),
                ),
              ),
              TextFormField(
                controller: _titleController,
              ),
              SizedBox(height: 20.0),
              
              // Text field for project tags
              Text(
                'Project Tags (comma-separated)',
                style: TextStyle(
                  color: const Color.fromARGB(255, 111, 15, 128),
                ),
              ),
              TextFormField(
                controller: _filtersController,
              ),
              SizedBox(height: 20.0), 

              // Text field for Project Description
              Text(
                'Description',
                style: TextStyle(
                  color: const Color.fromARGB(255, 111, 15, 128), 
                ),
              ),
              // Description field to be able to scroll if description is long
              SizedBox(
                height: 150, 
                child: Scrollbar(
                  controller: _scrollController, 
                  thumbVisibility: true, 
                  thickness: 4.0,
                  radius: Radius.circular(6.0),
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: null, 
                  ),
                ),
              ),
              SizedBox(height: 20.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Button to save project as a draft
                  ElevatedButton(
                    onPressed: () => publishProject(context, true, user), // Save as draft
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 111, 15, 128), 
                      minimumSize: Size(120, 48), 
                    ),
                    child: Text('Save'),
                  ),

                  // Button to publish project
                  ElevatedButton(
                    onPressed: () => publishProject(context, false, user), // Publish
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 111, 15, 128), 
                      minimumSize: Size(120, 48),
                    ),
                    child: Text('Publish'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // Navigation bar shown at the bottom of page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          // Navigate to other tabs/pages using the navigation bar
          if (index == 0) {
            Navigator.pushNamed(context, '/dashboard');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/yourProjects');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/chat');
          } else if (index == 4) {
            Navigator.pushNamed(context, '/editProfile');
          }
        },
        
        //Builds the icons and labels shown at the bottom navigation bar
        items: [
          _buildNavItem(Icons.dashboard, 'Dashboard'),
          _buildNavItem(Icons.add, 'Create'),
          _buildNavItem(Icons.list, 'Projects'),
          _buildNavItem(Icons.message, 'Messages'),
          _buildNavItem(Icons.settings, 'Settings'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  //Builds the navigation icons and items for the nav bar
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
