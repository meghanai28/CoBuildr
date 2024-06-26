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
  title: Center(
    child: Text(
      'Your Projects',
      style: TextStyle(color: Colors.purple), // Making text purple
    ),
  ),
        automaticallyImplyLeading: false, // get rid of back button for now (so buggy)
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
  padding: const EdgeInsets.all(8.0),
  child: Text(
    'Currently Advising',
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple), // Making text purple
  ),
),


          Expanded(
            child: _buildProjectList(),
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


 Widget _buildProjectList(){
   
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
                  .collection('published_projects')
                  .snapshots(), // dynamic list values change over time
      builder: (context, snapshot){
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // show any errors
        }


        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(''); // show loading if the data is still being loaded in
        }


        final projects = snapshot.data!.docs; //get published projects
        return ListView.builder( // build a list of all projects (like how we see in imessages)
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final projectData = projects[index].data()! as Map<String, dynamic>; // get each project data
            final advisors = projectData['advisors'];
            final projectId = projects[index].id;
            final active = projectData['advisorActive'];
           
            if(advisors != null && advisors.contains(_auth.currentUser!.uid) && active )
            {
              return ListTile(
               title: _buildProjectTile(projectData['title'], 'Currently Advising',projectId), // the title of the list will be the project name
               
              );
            }
            else
            {
                return Container();
            }
           
          }
        );


      }
       
    );
  }




 


    Widget _buildProjectTile(String projectName, String projectDescription, String projectId) {
    return ListTile(
      leading: _buildLightBulb(), // Add lightbulb
      title: Text(
        projectName,
        style: TextStyle(fontWeight: FontWeight.bold), // Make "Project" bold
      ),
      subtitle: Text(projectDescription), // Add project description
      onTap: () {
        Navigator.push(
                  context, // push to the project details page
                  MaterialPageRoute(
                    builder: (context) => ProjectDetails(
                      projectId: projectId,
                      owner: false,
                      published: true
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


  Widget _buildLightBulb() {
    return Icon(
      Icons.lightbulb, // Lightbulb icon
      color: Colors.yellow, // Set lightbulb color
    );
  }
}



