import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namer_app/routes/projects/project_details.dart';


class YourProjectsPage extends StatefulWidget {
  @override
  _YourProjectsPageState createState() => _YourProjectsPageState();
}

class _YourProjectsPageState extends State<YourProjectsPage> {
  int _currentIndex = 2; // index 2
  final FirebaseAuth _auth = FirebaseAuth.instance; // create instance of authentication to be used to get current user

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
              'Published Projects',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
          ),
          Expanded(
            child: _buildProjectList(true),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Drafts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
          ),
          Expanded(
            child: _buildProjectList(false),
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
        color: Colors.purple,
      ),
      label: label,
    );
  }



  Widget _buildProjectList(bool published){
    String list = 'draft_projects';
    if(published)
    {
      list = 'published_projects';
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
                  .collection(list)
                  .snapshots(), // dynamic list values change over time
      builder: (context, snapshot){
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // show any errors
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(''); // show loading if the data is still being loaded in
        }

        final projects = snapshot.data!.docs; //get published projects
        return ScrollbarTheme(
          data: ScrollbarThemeData(
                  thumbVisibility: MaterialStateProperty.all<bool>(true),// Adjust the thickness of the scrollbar
                ),
          child : ListView.builder( // build a list of all projects (like how we see in imessages)
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final projectData = projects[index].data()! as Map<String, dynamic>; // get each project data
              final teammates = projectData['teammates'];
              final projectId = projects[index].id;
              if(projectData['userId'] == _auth.currentUser!.uid)
              {
                return Column (
                  children: [
                    ListTile(
                      title:  _buildProjectTile(projectData['title'], 'Owner',projectId, true,published), // the title of the list will be the project name 
                    ),
                    Divider(
                      color: Colors.grey[400],
                      height: 0,
                      thickness: 0.5,
                      indent: 16,
                      endIndent: 16,
                    ),
                  ]
                );
              }
              else if(teammates != null && teammates.contains(_auth.currentUser!.uid))
              {
                return Column(
                  children: [
                    ListTile(
                      title:  _buildProjectTile(projectData['title'], 'Teammate',projectId, false, published), // the title of the list will be the project name
                    ),
                    Divider(
                      color: Colors.grey[400],
                      height: 0,
                      thickness: 0.5,
                      indent: 16,
                      endIndent: 16,
                    ),
                  ]
                );
              }
              else 
              {
                return Container(); 
              }
            }
          )
        );
      }    
    );
  }

    Widget _buildProjectTile(String projectName, String projectDescription, String projectId, bool owned, bool published) {
    return ListTile(
      leading: _buildSquare(), // Add light purple square
      title: Text(
        projectName,
        style: TextStyle(fontWeight: FontWeight.bold), // Make "Project" bold
      ),
      subtitle: Text(projectDescription), // Add project description
      onTap: () {
        Navigator.push(
                  context, // push to the chat details page
                  MaterialPageRoute(
                    builder: (context) => ProjectDetails(
                      projectId: projectId, 
                      owner: owned, 
                      published: published
                    )
                  ),
                );
      },
      trailing: Icon(
        Icons.arrow_forward, // arrow icon
        color: Colors.purple,
      ),
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
