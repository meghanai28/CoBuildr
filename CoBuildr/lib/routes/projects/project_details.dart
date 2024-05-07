import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/routes/projects/request_advisor.dart';
import 'package:namer_app/services/chat_service.dart';

class ProjectDetails extends StatefulWidget {
  
  final String projectId; //get projectId
  final bool owner; // get if owner or not
  final bool published; // check if its a published or draft
  const ProjectDetails({
    super.key,
    required this.projectId,
    required this.owner,
    required this.published,
  });

  @override
  State<ProjectDetails> createState() => _ProjectDetailsState(); // call this state

}

class _ProjectDetailsState extends State<ProjectDetails> {

  final TextEditingController _titleController = TextEditingController(); // title controller
  final TextEditingController _filtersController = TextEditingController(); // tags controller
  final TextEditingController _descriptionController = TextEditingController(); //descrition controller

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // instantiate firebase authentication

  @override
  void initState() {
    super.initState();
    _getAndSetProject(); // when we initalize we also want to intalize w the data of the project
  }

  // get/set the data of the project
  void _getAndSetProject() async {
    print(widget.owner);
    String list = 'draft_projects';
    if(widget.published)
    {
      list = 'published_projects'; // get the correct list
    }

    DocumentSnapshot doc = await FirebaseFirestore.instance // get the data
      .collection(list)
      .doc(widget.projectId)
      .get(); 

    var projectProfile = doc.data() as Map<String, dynamic>; // set it as a map
      
      setState(() { // makes updates to ui by recreating the widget
        _titleController.text = projectProfile['title']; // get title
        _filtersController.text = (projectProfile['tags'] as List<dynamic>).join(', '); // get the tags
        _descriptionController.text = projectProfile['description']; // get the description
        
      });
    
  }

  Future<DocumentSnapshot> _getProjectData() async {
    String list = 'draft_projects'; // get the correct list to save to
    if (widget.published) {
      list = 'published_projects';
    }

    return FirebaseFirestore.instance // get the data
      .collection(list)
      .doc(widget.projectId)
      .get();
  }

  Future<DocumentSnapshot> _getUserData(String id) async {
    return FirebaseFirestore.instance.collection('users').doc(id).get(); // get user data
  }

  void reloadContainer() {
    setState(() {
    });
  }

  // advisor get
  Widget _getAdvisor() {
    return FutureBuilder<DocumentSnapshot>(
      future: _getProjectData(), // get the project data
      builder: (context, projectSnapshot) {
        if (projectSnapshot.connectionState == ConnectionState.waiting) {
        return Text(""); 
        } 

        else if (projectSnapshot.hasError) {
          return Text('Error: ${projectSnapshot.error}');
        }

        var projectProfile = projectSnapshot.data!.data() as Map<String, dynamic>;
        final advisors = projectProfile['advisors'];
        final active = projectProfile['advisorActive'];
        if (advisors.length == 0) {
          if(widget.owner)
          {
            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RequestAdvisorPage(projectId: widget.projectId, reloadRequestedContainer: reloadContainer),
                    
                  ),
              ) ;
              },
              style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 151, 36, 171)
                    ),
                  child: Text('Request Advisor', style: TextStyle(color: Colors.white)),
            );
          }
          else{
            return Text('No current advisor', style: TextStyle(fontWeight: FontWeight.bold, 
                        color: const Color.fromARGB(255, 111, 15, 128),));
          }
        } 
        else {
          return FutureBuilder<DocumentSnapshot>(
              future: _getUserData(advisors[0]), // get user data for advisor requested
              builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Text(""); 
              } 
              else if (userSnapshot.hasError) {
                return Text('Error: ${userSnapshot.error}');
              } 
              else {
                var userProfile = userSnapshot.data!.data() as Map<String, dynamic>;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(active ? "Current Advisor:" : "Request Advisor (waiting for response):", style: TextStyle(fontWeight: FontWeight.bold, 
                        color: const Color.fromARGB(255, 111, 15, 128),)),
                      ListTile(
                        title: Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                _showProfile(context, userProfile); // Call _showProfile on eye icon tap
                              },
                              child: Icon(Icons.remove_red_eye),
                            ),
                            SizedBox(width: 10),
                            Text(userProfile['email']),
                          ],
                        ),
                        onTap: () {
                          _showProfile(context, userProfile);
                        }
                      ),
                    ],
                  );
                }
              }
          );
        }
      },
    );
  }

  // save changes to data
  void _saveEdits() async {
    
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _filtersController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter all fields')), // make sure they dont try to save empty edits
      );
      return;
    }

    String newTitle = _titleController.text.trim(); // the newtitle
    List<dynamic> newFilter = _filtersController.text.split(',').map((tag) => tag.trim()).toList(); // the new filters
    String newDescription = _descriptionController.text.trim(); // the new description

    String list = 'draft_projects'; // get the correct list to save to
    if(widget.published)
    {
      list = 'published_projects';
    }
                        
    await FirebaseFirestore.instance
    .collection(list)
    .doc(widget.projectId)
    .update({
      'title': newTitle,
      'tags': newFilter,
      'description': newDescription,
    }); // update the current projects's stuff accordingly
    
    // show message if they did update
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Project updated successfully'),
      duration: Duration(seconds: 2),
    ));

    setState(() {});
                        
  }

  // delete project 
  void _deleteProject() async {
    String list = 'draft_projects'; // check which one to delete from
    if(widget.published)
    {
      list = 'published_projects';
    }

    DocumentSnapshot doc = await FirebaseFirestore.instance // get project data
      .collection(list)
      .doc(widget.projectId)
      .get(); 

    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance // get collection of users
      .collection('users')
      .get();

    await doc.reference.delete(); // delete project

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successful Deletion')),
    ); // show sucessfull deletion

    Navigator.pushNamed(context, '/yourProjects'); // go back to prev page
    
  }

  // publish the draft if the user wants too
  void _publishProject() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _filtersController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter all fields')),
      );
      return; // make sure all fields r field
    }

    _saveEdits(); // save edits

    DocumentSnapshot doc = await FirebaseFirestore.instance
      .collection("draft_projects")
      .doc(widget.projectId)
      .get();  // get the doc

    var projectProfile = doc.data() as Map<String, dynamic>; // set it as a map
     
    await FirebaseFirestore.instance.collection('published_projects').add(projectProfile); //add to published projects
      
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Project published successfully')),
    ); // show ur project published message

    await doc.reference.delete(); // delete
    Navigator.pushNamed(context, '/yourProjects'); // navigate back
      
    
  }

@override
Widget build(BuildContext context) {
  return Scrollbar(
    thumbVisibility: true,
    thickness: 10,
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          _titleController.text,
          style: TextStyle(
            color: const Color.fromARGB(255, 111, 15, 128),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widget.owner
                ? TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Project Title',
                      labelStyle: TextStyle(
                        color: const Color.fromARGB(255, 111, 15, 128),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : SizedBox(height: 0), // Hide Project Title for teammates

            !widget.owner
              ? FutureBuilder<DocumentSnapshot>(
                  future: _getProjectData(), // Fetch project data
                  builder: (context, projectSnapshot) {
                    if (projectSnapshot.connectionState == ConnectionState.waiting) {
                      return Text('');
                    } else if (projectSnapshot.hasError) {
                      return Text('Error: ${projectSnapshot.error}');
                    } else {
                      var projectProfile = projectSnapshot.data!.data() as Map<String, dynamic>;
                      final ownerUserId = projectProfile['userId'];
                      return FutureBuilder<DocumentSnapshot>(
                        future: _getUserData(ownerUserId), // Fetch owner's data
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return Text('');
                          } else if (userSnapshot.hasError) {
                            return Text('Error: ${userSnapshot.error}');
                          } else {
                            var ownerProfile = userSnapshot.data!.data() as Map<String, dynamic>;
                            final ownerName = ownerProfile['name'] ?? ''; // Get owner's name
                            return Row(
                              children: [
                                Text(
                                  'Project Owner: ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: const Color.fromARGB(255, 111, 15, 128),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ownerName,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(width: 8), // Add spacing between name and icon
                                GestureDetector( // Eye icon for viewing owner's profile
                                  onTap: () async {
                                    _showProfile(context, ownerProfile); // Show owner's profile
                                  },
                                  child: Icon(Icons.remove_red_eye, color: Colors.black),
                                ),
                              ],
                            );
                          }
                        },
                      );
                    }
                  },
                )
              : Container(),

            SizedBox(height: 20.0),

            !widget.owner
                ? Text(
                    'Project Tags:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 111, 15, 128),
                    ),
                  )
                : Container(),

            widget.owner
                ? TextFormField(
                    controller: _filtersController,
                    decoration: InputDecoration(
                      labelText: 'Project Tags',
                      labelStyle: TextStyle(
                        color: const Color.fromARGB(255, 111, 15, 128),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _buildTags(),
                  ),
            SizedBox(height: 20.0),
            widget.owner
                ? Scrollbar(
                    thumbVisibility: true,
                    thickness: 10,
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(
                          color: const Color.fromARGB(255, 111, 15, 128),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      maxLines: 3,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description:',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 111, 15, 128),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _descriptionController.text,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

            SizedBox(height: 20.0),

            widget.published
                ? Text(
                    'Teammates:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 111, 15, 128),
                    ),
                  )
                : Container(),

            widget.published ? _buildTeammatesList() : Container(),

            widget.published && widget.owner ? SizedBox(height: 20.0) : Container(),

            widget.published && widget.owner
                ? Text(
                    'Teammate Requests:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 111, 15, 128),
                    ),
                  )
                : Container(),

            widget.published && widget.owner ? _buildLikersList() : Container(),

            SizedBox(height: 15.0),

            widget.published ? _getAdvisor() : Container(),
            widget.published ? SizedBox(height: 20.0) : Container(),

            widget.published ? SizedBox(height: 20.0) : Container(),

            widget.owner
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _saveEdits(),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(120, 48),
                          backgroundColor: const Color.fromARGB(255, 111, 15, 128),
                        ),
                        child: Text('Save Edits', style: TextStyle(color: Colors.white)),
                      ),
                      !widget.published
                          ? ElevatedButton(
                              onPressed: () => _publishProject(),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(120, 48),
                                backgroundColor: const Color.fromARGB(255, 111, 15, 128),
                              ),
                              child: Text('Publish', style: TextStyle(color: Colors.white)),
                            )
                          : Container(),
                      ElevatedButton(
                        onPressed: () => _deleteDialog(context),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(120, 48),
                          backgroundColor: const Color.fromARGB(255, 111, 15, 128),
                        ),
                        child: Text('Delete', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    ),
  );
}

  // popup dialog for creating a new chat
  void _deleteDialog(BuildContext context) {

    showDialog( // show Dialog method helps us do a popup on creen
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog( // use alert dialog to get it one screen w the needed buttons and actions
          title: Text("Confirm Deletion"), // name of the popup
          content: Column( // use column like I did in the chat details page
            children: [
              //text field
                Text('Warning! Once you delete, neither you, your teamates, nor your advisor will be able to see this page.'),
                Text('All data will be lost for this project when deleted.'),
            ]
          ),
          
          actions: <Widget>[
            TextButton( // button where user can exit the widget
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
        
            TextButton( // button where user can send their message
              onPressed: () => _deleteProject(),
              child: Text("Confirm Delete"), // this is the send button which does all of the stuff above when pressed
            ),
          ],
        );   
      },
    );
  }

Widget _buildTeammatesList() {
  final docRef = FirebaseFirestore.instance.collection('published_projects').doc(widget.projectId);
  return Container(
    height: 150,
    child: Scrollbar(
      thumbVisibility: true,
      thickness: 10,
      child: FutureBuilder<DocumentSnapshot>(
        future: docRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('');
          } else {
            final projectData = snapshot.data!.data()! as Map<String, dynamic>;
            final teammates = projectData['teammates'] as List<dynamic>;

            return ListView.separated( // Using ListView.separated to add dividers
              itemCount: teammates.length,
              separatorBuilder: (context, index) => Divider(), // Divider between each item
              itemBuilder: (context, index) {
                final teammateId = teammates[index];
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(teammateId).get(),
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return Text('');
                    } else {
                      final userData = userSnapshot.data!.data()! as Map<String, dynamic>;
                      final name = userData['name'] ?? ''; // Use name instead of email
                      return ListTile(
                          title: Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                _showProfile(context, userData); // Call _showProfile on eye icon tap
                              },
                              child: Icon(Icons.remove_red_eye),
                            ),
                            SizedBox(width: 5),
                            Text(name),
                          ],
                        ),
                        onTap: () {
                          _showProfile(context, userData);
                        }
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    ),
  );
}

Widget _buildLikersList() {
  final docRef = FirebaseFirestore.instance.collection('published_projects').doc(widget.projectId);
  return Container(
    height: 100,
    child: Scrollbar(
      thumbVisibility: true,
      thickness: 10,
      child: FutureBuilder<DocumentSnapshot>(
        future: docRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('');
          } else {
            final projectData = snapshot.data!.data()! as Map<String, dynamic>;
            final likers = projectData['likers'] as List<dynamic>;

            return ListView.builder(
              itemCount: likers.length,
              itemBuilder: (context, index) {
                final likerId = likers[index];
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(likerId).get(),
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return Text('');
                    } else {
                      final userData = userSnapshot.data!.data()! as Map<String, dynamic>;
                      final name = userData['name'] ?? '';
                      return ListTile(
                        title: Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                _showProfile(context, userData); // Show profile on eye icon tap
                              },
                              child: Icon(Icons.remove_red_eye), // Eye icon
                            ),
                            SizedBox(width: 5),
                            Text(name),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _acceptRequest(likerId, projectData);
                              },
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green, // Green circle
                                ),
                                child: Icon(Icons.check, size: 20, color: Colors.white), // Checkmark icon
                              ),
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                _declineRequest(likerId, projectData);
                              },
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red, // Red circle
                                ),
                                child: Icon(Icons.clear, size: 20, color: Colors.white), // X icon
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          _showProfile(context, userData);
                        },
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    ),
  );
}


void _acceptRequest(String userId, Map<String, dynamic> projectData) async {
  
  projectData['teammates'].add(userId); // add to the teamates -> the userid

  projectData['likers'].remove(userId); // remove from the likers list

  await FirebaseFirestore.instance
      .collection('published_projects')
      .doc(widget.projectId)
      .set(projectData);   // all data should be updated in the firebase
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Request accepted')), // confirm
  );

  setState(() {}); // refresh the container after ever change

}

void _declineRequest(String userId, Map<String, dynamic> projectData) async {

  projectData['likers'].remove(userId); // remove from the likers list

  await FirebaseFirestore.instance
      .collection('published_projects')
      .doc(widget.projectId)
      .set(projectData); // all data should be updated in the firebase

 
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Request declined')), // confirm
  );

  setState(() {}); // refresh the container after ever change

}


void _showProfile(BuildContext context, Map<String, dynamic> val) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        title: Center(
          child: Text('${val['name']}', style: TextStyle(color: const Color.fromARGB(255, 111, 15, 128))),
        ),
        content: Scrollbar(
          thumbVisibility: true, // Ensure the scrollbar is always visible
          thickness: 8, // Set the thickness of the scrollbar
          radius: Radius.circular(4), // Set the radius of the scrollbar
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16),
                CircleAvatar(
                  backgroundImage: NetworkImage(val['profilePictureUrl']),
                  radius: 30,
                ),
                SizedBox(height: 16),
                _buildProfileItem('Email', '${val['email']}' == 'null' ? '' : '${val['email']}'),
                _buildProfileItem('University', '${val['school']}' == 'null' ? '' : '${val['school']}'),
                _buildProfileItem('Major', '${val['major']}' == 'null' ? '' : '${val['major']}'),
                _buildProfileItem('Skills', '${val['skills']}' == 'null' ? '' : '${val['skills']}'), 
                _buildProfileItem('Biography', '${val['bio']}' == 'null' ? '' : '${val['bio']}', isBiography: true), 
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      );
    },
  );
}



Widget _buildProfileItem(String label, String value, {bool isBiography = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    child: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label == 'Skills')
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$label:',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 111, 15, 128),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 4),
                Wrap(
                  alignment: WrapAlignment.start,
                  children: _buildTagsSkill(value),
                ),
              ],
            )
          else if (isBiography)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$label:',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 111, 15, 128),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 4),
                Container(
                  height: 150,
                  child: Scrollbar(
                    thumbVisibility: true, // Ensure the scrollbar is always visible
                    thickness: 8, // Set the thickness of the scrollbar
                    radius: Radius.circular(4), // Set the radius of the scrollbar
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text(
                        value,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 111, 15, 128),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}


  List<Widget> _buildTagsSkill(String skillsText) {
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

  List<Widget> _buildTags() {
    final tags = _filtersController.text.split(',').map((tag) => tag.trim()).toList();
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