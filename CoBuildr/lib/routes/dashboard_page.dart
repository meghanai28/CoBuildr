import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<DocumentSnapshot> _projects = [];
  late int _currentProjectIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  // Method to fetch unseen projects from DB to display them for the UI
  Future<void> _fetchProjects() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final seenProjects = userDoc.get('seenProjects') ?? [];
      final snapshot = await _firestore.collection('published_projects').get();
      setState(() {
        _projects = snapshot.docs
            .where((project) =>
                project.get('userId') != user.uid &&
                !seenProjects.contains(project.id))
            .toList();
      });
    }
  }

  // Method to handle when a user dislikes a project
  void _handleDislike() {
    //Gets project id and info of the current project that is being displayed
    final currentProject = _projects[_currentProjectIndex];
    final projectId = currentProject.id;

    // Update seenProjects array in Firestore
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);
      userRef.update({
        'seenProjects': FieldValue.arrayUnion([projectId]),
      });
    }

    // Update the state to move to the next project or clear the list if there are no more projects
    setState(() {
      if (_currentProjectIndex < _projects.length - 1) {
        _currentProjectIndex++;
      } else {
        _projects = []; // Clear projects list
      }
    });
  }

  // Method to handle when a user likes / wants to be a teammate of a project
  void _handleLike() {
    final currentProject = _projects[_currentProjectIndex];
    final projectId = currentProject.id;

    final user = _auth.currentUser;
    if (user != null) {
      // This adds the project to the likedProjects array field in the database for users
      final userRef = _firestore.collection('users').doc(user.uid);
      userRef.update({
        'likedProjects': FieldValue.arrayUnion([projectId]),
      });

      // This updates the project's likers field in the database to include the user that liked the project
      final projectRef =
          _firestore.collection('published_projects').doc(projectId);
      projectRef.update({
        'likers': FieldValue.arrayUnion([user.uid]),
      });
    }

    // Shows a popup message to show that the user liked the project
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Liked Project ${currentProject['title']}'),
          duration: Duration(seconds: 1)),
    );
    _handleDislike(); // Move to the next project
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Dashboard',
            style: TextStyle(
              color: const Color.fromARGB(255, 111, 15, 128),
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: _projects.isEmpty
          ? Center(
              // Handles if there are no projects left to be shown
              child: Text('No projects available'),
            )
          // Handles if there are projects to be shown
          : Center(
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(40.0, 20.0, 40.0, 45.0),
                    child: Dismissible(
                      key: Key(_projects[_currentProjectIndex].id),
                      // Creates a swiping mechanism to handle Dislike/Liking a project
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          _handleDislike();
                        } else if (direction == DismissDirection.startToEnd) {
                          _handleLike();
                        }
                      },
                      // Handles swiping UI when liking a project
                      background: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                        color: Colors.green,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Icon(Icons.check,
                            color: Colors.white, size: 40.0),
                        )
                      ),
                      // Handles swiping UI when disliking a project
                      secondaryBackground: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)
                        ),
                        color: Colors.red,
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.close,
                            color: Colors.white, size: 40.0
                          ),
                        )
                      ),
                      // Creates a card to show Projects and their information for users to view and decide whether they Dislike/Like it
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                        elevation: 5,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: SingleChildScrollView(
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
                                  padding:
                                    EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Wrap(
                                    children: _buildTags(),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(15.0),
                                      bottomRight: Radius.circular(15.0),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                      CrossAxisAlignment.start,
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
                                        _projects[_currentProjectIndex] ['description'],
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Displays and handles Dislike BUtton
                  Positioned(
                    bottom: 20.0,
                    left: 20.0,
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: IconButton(
                        iconSize: 30.0,
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: _handleDislike,
                      ),
                    ),
                  ),

                  // Displays and handles Like Button
                  Positioned(
                    bottom: 20.0,
                    right: 20.0,
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      child: IconButton(
                        iconSize: 30.0,
                        icon: Icon(Icons.check, color: Colors.white),
                        onPressed: _handleLike,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      // Navigation bar shown at the bottom of page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          //Navigate to other tabs using the navigation bar
          if (index == 1) {
            Navigator.pushNamed(context, '/createProject');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/yourProjects');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/chat');
          } else if (index == 4) {
            Navigator.pushNamed(context, '/editProfile');
          }
        },
        items: [
          
          //Builds the icons and labels for the icons shown at the bottom navigation bar
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
        color: const Color.fromRGBO(156, 39, 176, 1),
      ),
      label: label,
    );
  }

  //Handles building the tags of Projects to show on the Project card
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