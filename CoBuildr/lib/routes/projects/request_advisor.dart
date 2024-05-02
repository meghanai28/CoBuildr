import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RequestAdvisorPage extends StatefulWidget {
  final String projectId;
  final Function reloadRequestedContainer; // Define the reloadRequestedContainer function as a parameter

  const RequestAdvisorPage({Key? key, required this.projectId, required this.reloadRequestedContainer}) : super(key: key);

  @override
  State<RequestAdvisorPage> createState() => _RequestAdvisorPageState();
}

class _RequestAdvisorPageState extends State<RequestAdvisorPage> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Advisor'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .where('userType', isEqualTo: 'Advisor')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final advisors = snapshot.data!.docs;
            return ListView.builder(
              itemCount: advisors.length,
              itemBuilder: (context, index) {
                final userProfile = advisors[index].data() as Map<String, dynamic>;
                bool normal = true;
                if (userProfile['seenProjects'].contains(widget.projectId))
                {
                  normal = false;
                }
                return ListTile(
                  title: Text(userProfile['email']),
                  subtitle: Text(userProfile['name'] ?? ''),
                  trailing: normal ? ElevatedButton(
                    onPressed: () {
                      _requestAdvisor(userProfile['uid'], widget.projectId);
                      Navigator.pop(context);
                    },
                    child: Text('Request'),
                  ): Text('Rejected'),
                  onTap: () {
                    _showProfile(context, userProfile);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  void _requestAdvisor(String advisorId, String projectId) async {

    
    print("Requesting advisor...");

    // Add advisor to the project's advisors list
    await FirebaseFirestore.instance
        .collection('published_projects')
        .doc(projectId)
        .update({
      'advisors': FieldValue.arrayUnion([advisorId]),
    });

    // Add projectId to the advisor's advisorRequests list
    await FirebaseFirestore.instance
        .collection('users')
        .doc(advisorId)
        .update({
      'advisorRequests': FieldValue.arrayUnion([projectId]),
    });

    widget.reloadRequestedContainer();

    print("Advisor requested successfully.");
  
  } 

  void _showProfile(BuildContext context, Map<String, dynamic> val) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('${val['email']}'), // show the email as title
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, 
          children: [
            Text('Name: ${val['name']}'), // show the name
            Text('User Type: ${val['userType']}'), // show the user type
            Text('University: ${val['school']}'), // show university
            Text('Field of Study: ${val['major']}'), // show the major
            Text('Roles/Jobs: ${val['skills']}'), // show the skills
            Text('Biography: ${val['bio']}'), // show the bio
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context), // when they exit just exit the popup dialog
            child: Text("Close"),
          ),
        ],
      );
    },
  );
}

}
