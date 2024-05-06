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
    print('wtf');
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
              child: Text('Request Advisor'),
            );
          }
          else{
            Text('No current advisor');
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
                      Text(active ? "Current Advisor" : "Request Advisor (waiting for response)"),
                      ListTile(
                        title: Text(userProfile['email']), // tite
                        onTap: () async {
                          _showProfile(context, userProfile); // call show profile here
                        },
                      ),
                    ],
                  );
                }
              }
    
          );
        }
        return Text('');
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



  // build the layout for the chat room (this is the chat details page)
  @override
  Widget build (BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text(_titleController.text),// get rid of back button for now (so buggy)
      ), // title will be name of the recieverUserId


      body: SingleChildScrollView( // scrollable
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            widget.owner ? TextFormField(
              controller: _titleController, // title text field
              decoration: InputDecoration(labelText: 'Project Title'),
            ) : Text('Project Title: ${_titleController.text}'),

            SizedBox(height: 20.0),
            !widget.owner ? Text('Filters') : Container(),
            
            widget.owner ? TextFormField(
              controller: _filtersController, // filters text field
              decoration: InputDecoration(labelText: 'Project Filters'),
            ): Row( children: _buildTags(), ),
            
            SizedBox(height: 20.0),
            widget.owner ? TextFormField(
              controller: _descriptionController, // description text field
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 5,
            ) : Text('Description: ${_descriptionController.text}'),

            SizedBox(height: 20.0),
            widget.published ? Text('Teammates'): Container(),
            widget.published ?_buildTeammatesList(): Container(),
            
            widget.published && widget.owner ? SizedBox(height: 20.0) : Container(),
            widget.published && widget.owner ? Text('Requests') : Container(),
            widget.published && widget.owner ?_buildLikersList(): Container(),

            widget.published ? _getAdvisor(): Container(),
            widget.published ? SizedBox(height: 20.0) : Container(),

            widget.owner ? SizedBox(height: 20.0) : Container(),
            widget.owner ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton( // save edits button
                  onPressed: () => _saveEdits(), 
                  child: Text('Save Edits'),
                ),
                
                !widget.published ? ElevatedButton( // publish drafts button only if its draft
                  onPressed: () => _publishProject(), 
                  child: Text('Publish'),
                ) : Container(),

                ElevatedButton(
                  onPressed: () => _deleteDialog(context), // delete button
                  child: Text('Delete'),
                ),

              ],
            ): Container(),
          ],
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
  final docRef = FirebaseFirestore.instance.collection('published_projects').doc(widget.projectId); // get the project
  return Container( // return a container
    height: 90,
    child: FutureBuilder<DocumentSnapshot>( // just get the data once
      future: docRef.get(), // get the data
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(""); // show nothing when loading
        } 
        else {
          final projectData = snapshot.data!.data()! as Map<String, dynamic>; // get the project data
          final teammates = projectData['teammates'] as List<dynamic>; //get the list
          
          return ListView.builder( // create list
            itemCount: teammates.length, // length of likers
            itemBuilder: (context, index) {
              final teammateId = teammates[index]; // get the id
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(teammateId).get(), // get user data once
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Text(""); // show nothing when loading
                  } 
                  else {
                    final userData = userSnapshot.data!.data()! as Map<String, dynamic>;
                    final email = userData['email'];
                    return ListTile(
                      title: Text(email), // make the title the email
                      onTap: () async {
                        _showProfile(context, userData); // do a pop up dialog to show the data of the person requested
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
  );
}


// build the request list (those who liked the project)
Widget _buildLikersList() {
  final docRef = FirebaseFirestore.instance.collection('published_projects').doc(widget.projectId); // get the project
  return Container( // return a container
    height: 90,
    child: FutureBuilder<DocumentSnapshot>( // just get the data once
      future: docRef.get(), // get the data
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(""); // show nothing when loading
        } 
        else {
          final projectData = snapshot.data!.data()! as Map<String, dynamic>; // get the project data
          final likers = projectData['likers'] as List<dynamic>; //get the list
          
          return ListView.builder( // create list
              itemCount: likers.length, // length of likers
              itemBuilder: (context, index) {
                final likerId = likers[index]; // get the id
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(likerId).get(), // get user data once
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return Text(""); // show nothing when loading
                    } 
                    else {
                      final userData = userSnapshot.data!.data()! as Map<String, dynamic>;
                      final email = userData['email'];
                      return ListTile(
                        title: Text(email), // make the title the email
                        trailing: Row(  // at the end create a row of two buttons to accept and decline the user
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _acceptRequest(likerId, projectData); // accept button
                              },
                              child: Text('Accept'),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                _declineRequest(likerId, projectData); // decline button
                              },
                              child: Text('Decline'),
                            ),
                          ],
                        ),
                        onTap: () async {
                          _showProfile(context, userData); // do a pop up dialog to show the data of the person requested
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
        title: Text('${val['email']}'), // show the email as title
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, 
          children: [
            Text('Name: ${val['name']}'), // show the name
            Text('User Type: ${val['userType']}'), // show the user type
            Text('University: ${val['school']}'),
            Text('Major: ${val['major']}'), // show the major
            Text('Skills: ${val['skills']}'), // show the skills
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