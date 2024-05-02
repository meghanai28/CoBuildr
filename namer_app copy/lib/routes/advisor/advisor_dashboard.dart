import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AdvisorDashboardPage extends StatefulWidget {
  const AdvisorDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdvisorDashboardPage> createState() => _AdvisorDashboardPageState();
}

class _AdvisorDashboardPageState extends State<AdvisorDashboardPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<DocumentSnapshot> _projects = [];
  late int _currentProjectIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final seenProjects = userDoc.get('seenProjects') ?? []; // Get seenProjects array from user document
      final advisorRequests = userDoc.get('advisorRequests') ?? []; // Get advisorRequests array from user document
      final snapshot = await _firestore.collection('published_projects').get();
      setState(() {
        _projects = snapshot.docs.where((project) => project.get('userId') != user.uid && !seenProjects.contains(project.id) && advisorRequests.contains(project.id)).toList();
      });
    }
  }

  void _handleDislike() {
    final currentProject = _projects[_currentProjectIndex];
    final projectId = currentProject.id; // Assuming projectId is the ID of the project in Firestore

    // Update seenProjects array in Firestore
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);
      userRef.update({
        'seenProjects': FieldValue.arrayUnion([projectId]),
      });
    }

    final projectRef = _firestore.collection('published_projects').doc(projectId);
      if (user != null) {
        final projectRef = _firestore.collection('published_projects').doc(projectId);
          projectRef.update({
            'advisors': FieldValue.arrayRemove([user.uid]),
          });
      }


    setState(() {
      if (_currentProjectIndex < _projects.length - 1) {
        _currentProjectIndex++;
      } else {
        _projects = []; // Clear projects list
      }
    });
  }

  void _handleLike() {
    final currentProject = _projects[_currentProjectIndex];
    final projectId = currentProject.id;

    final user = _auth.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);
      userRef.update({
        'likedProjects': FieldValue.arrayUnion([projectId]),
      });

      final projectRef = _firestore.collection('published_projects').doc(projectId);
      projectRef.update({
        'advisorActive': true,
      });
    }

    // Implement logic to add user as a teammate to the project
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Liked project with ID: $projectId')),
    );

    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);
      userRef.update({
        'seenProjects': FieldValue.arrayUnion([projectId]),
      });
    }

    setState(() {
      if (_currentProjectIndex < _projects.length - 1) {
        _currentProjectIndex++;
      } else {
        _projects = []; // Clear projects list
      }
    }); // Move to the next project
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        automaticallyImplyLeading: false, // get rid of back button for now (so buggy)
      ),
      body: _projects.isEmpty
          ? Center(
              child: Text('No projects available'),
            )
          : Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8, // Adjust the height as needed
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              _projects[_currentProjectIndex]['title'],
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            children: _buildTags(),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(15.0),
                                bottomRight: Radius.circular(15.0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Project Description:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  _projects[_currentProjectIndex]['description'],
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: _handleDislike,
                              child: Text('Decline'),
                            ),
                            ElevatedButton(
                              onPressed: _handleLike,
                              child: Text('Accept'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // Handle bottom navigation bar taps
          if (index == 1) {
            // Navigate to Project page
            Navigator.pushNamed(context, '/advisor/project_tab');
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

  List<Widget> _buildTags() {
    final tags = _projects[_currentProjectIndex]['tags'] as List<dynamic>;
    return tags.map((tag) {
      return Container(
        margin: EdgeInsets.only(right: 10.0),
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(tag.toString()),
      );
    }).toList();
  }
}
