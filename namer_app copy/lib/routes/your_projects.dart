import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namer_app/routes/projectdetails_page.dart';

class YourProjectsPage extends StatefulWidget {
  @override
  _YourProjectsPageState createState() => _YourProjectsPageState();
}

class _YourProjectsPageState extends State<YourProjectsPage> {
  int _currentIndex = 2; // Default selected index

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

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
              'Your Projects',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('published_projects')
                  .where('userId', isEqualTo: user?.uid ?? '')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final publishedProjects = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: publishedProjects.length,
                  itemBuilder: (context, index) {
                    final projectData = publishedProjects[index].data() as Map<String, dynamic>;
                    
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 28, 
                          backgroundColor: Color.fromARGB(255, 114, 113, 113),
                          ), 
                        title: Text(projectData['title']),
                        //subtitle: Text(projectData['description']),
                        trailing: const Icon(Icons.arrow_forward), 
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProjectDetailsPage(projectId: '',), //takes you to proj page 
                            )); 
                        }
                       )
                    ); 

                    // return ListTile(
                    //   title: Text(projectData['title']),
                    //   subtitle: Text(projectData['description']),
                    //   // Display other project details as needed
                    // );
                  },
                );
              },
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Drafts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('draft_projects')
                  .where('userId', isEqualTo: user?.uid ?? '')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final draftProjects = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: draftProjects.length,
                  itemBuilder: (context, index) {
                    final projectData = draftProjects[index].data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 28, 
                          backgroundColor: Color.fromARGB(255, 114, 113, 113),
                          ), 
                          title: Text(projectData['title']),
                          //subtitle: Text(projectData['description']),
                          trailing: const Icon(Icons.arrow_forward), 
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProjectDetailsPage(projectId: '',), // need to make it so it takes you to the project's page 
                            )); 
                        }
                       )
                    ); 
                    // return ListTile(
                    //   title: Text(projectData['title']),
                    //   subtitle: Text(projectData['description']),
                    //   // Display other project details as needed
                    // );
                  },
                );
              },
            ),
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
            Navigator.pushNamed(context, '/dashboard');
          } else if (index == 1) {
            // Navigate to Create Project page
            Navigator.pushNamed(context, '/createProject');
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
        type: BottomNavigationBarType.fixed, // Ensure icons remain visible even when not selected
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: _currentIndex == 2 ? Colors.purple : Colors.white,
      ),
      label: label,
    );
  }
}
