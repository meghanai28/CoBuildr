import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namer_app/routes/projects/project_details.dart';

class AdvisorProjectsPage extends StatefulWidget {
  @override
  _AdvisorProjectsPageState createState() => _AdvisorProjectsPageState();
}

class _AdvisorProjectsPageState extends State<AdvisorProjectsPage> {
  int _currentIndex = 2; // Default selected index
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Projects'),
        automaticallyImplyLeading: false, // get rid of back button for now (so buggy)
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Currently Advising',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _buildCurrentlyAdvisingProjects(),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Previously Advised',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _buildPreviouslyAdvisedProjects(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Handle bottom navigation bar taps
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            // Navigate to Dashboard page
            Navigator.pushNamed(context, '/advisor/advisor_dashboard');
          } else if (index == 2) {
            // Navigate to Messages page
            Navigator.pushNamed(context, '/advisor/advisor_chat');
          } else if (index == 3) {
            // Navigate to Settings page
            Navigator.pushNamed(context, '/advisor/advisor_setting');
          }
        },
        items: [
          _buildNavItem(Icons.dashboard, 'Dashboard'),
          _buildNavItem(Icons.list, 'Your Projects'),
          _buildNavItem(Icons.message, 'Messages'),
          _buildNavItem(Icons.settings, 'Settings'),
        ],
        type: BottomNavigationBarType.fixed, // Ensure icons remain visible even when not selected
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

  Widget _buildCurrentlyAdvisingProjects() {
    return ListView(
      children: [
        _buildProjectTile('Project 1', 'Project 1 Description'),
        _buildProjectTile('Project 2', 'Project 2 Description'),
      ],
    );
  }

  Widget _buildPreviouslyAdvisedProjects() {
    return ListView(
      children: [
        _buildProjectTile('Project 3', 'Project 3 Description'),
        _buildProjectTile('Project 4', 'Project 4 Description'),
        _buildProjectTile('Project 5', 'Project 5 Description'),
      ],
    );
  }

  Widget _buildProjectTile(String projectName, String projectDescription) {
    return ListTile(
      leading: _buildSquare(), // Add light purple square
      title: Text(
        projectName,
        style: TextStyle(fontWeight: FontWeight.bold), // Make "Project" bold
      ),
      subtitle: Text(projectDescription), // Add project description
      onTap: () {
        // Handle onTap by navigating to project details page
        Navigator.pushNamed(context, '/project_details');
      },
    );
  }

  Widget _buildSquare() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.purple[200],
    );
  }
}
