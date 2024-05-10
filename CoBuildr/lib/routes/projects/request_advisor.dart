import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RequestAdvisorPage extends StatefulWidget {
  final String projectId;
  final Function reloadRequestedContainer; // function reloadRequestedContainer function as a parameter, so the moment someone is requested the reload occurs, and avoids bugs

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
            .get(), // get all advisors
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text ("")); // show empty text 
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // show error
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
                  title: 
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            _showProfile(context, userProfile); // _showProfile when the button is clicked
                          },
                          child: Icon(Icons.remove_red_eye),
                        ),
                        SizedBox(width: 10),
                        Text(userProfile['email']), // show the email
                      ],
                    ),
                  subtitle: Text(userProfile['name'] ?? ''),
                  trailing: normal ? ElevatedButton(
                    onPressed: () {
                      _requestAdvisor(userProfile['uid'], widget.projectId);
                      Navigator.pop(context);
                    },
                    child: Text('Request'),
                  ): Text('Rejected'),
                  onTap: () {
                    _showProfile(context, userProfile); // in some cases make sure that advisor who already requested is not allowed
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

    // add advsior project's advisors list
    await FirebaseFirestore.instance
        .collection('published_projects')
        .doc(projectId)
        .update({
      'advisors': FieldValue.arrayUnion([advisorId]),
    });

    // add projectId to the advisor
    await FirebaseFirestore.instance
        .collection('users')
        .doc(advisorId)
        .update({
      'advisorRequests': FieldValue.arrayUnion([projectId]),
    });

    widget.reloadRequestedContainer(); // reload the container

    print("Advisor requested successfully."); // print + debug statement
  
  } 

  void _showProfile(BuildContext context, Map<String, dynamic> val) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          title: Text('${val['email']}'), // show the email as title
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, 
            children: [
              SizedBox(height: 16),
              CircleAvatar(
                backgroundImage: NetworkImage(val['profilePictureUrl']),
                radius: 30,
              ),
              SizedBox(height: 16),
              _buildProfileItem('Name', '${val['name']}' == 'null' ? '' : '${val['name']}'), // show the name
              _buildProfileItem('User Type', '${val['userType']}' == 'null' ? '' : '${val['userType']}'), // show the user type
              _buildProfileItem('University', '${val['school']}' == 'null' ? '' : '${val['school']}'), // show university
              _buildProfileItem('Field of Study', '${val['major']}' == 'null' ? '' : '${val['major']}'), // show the major
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Roles/Jobs:',
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  ..._buildTags('${val['skills']}'  == 'null' ? '' : '${val['skills']}'),
                ],
              ),
              _buildProfileItem('Biography', '${val['bio']}' == 'null' ? '' : '${val['bio']}'), // show the bio
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

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Text(
              '$label:',
              style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(width: 8),
            Text(
              value,
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTags(String skillsText) {
    final tags = skillsText.split(',').map((tag) => tag.trim()).toList();
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
