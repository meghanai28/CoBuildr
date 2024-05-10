import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState(); // create the state
}

class _EditProfileState extends State<EditProfile> {
  bool hasNewNotification = false; //variable to track unread notifications
  bool isProfileComplete = false;
  
  final _nameController = TextEditingController(); // where name is inputted
  final _schoolController = TextEditingController(); // where school is inputed
  final _majorController = TextEditingController(); // where major is inputted
  final _bioController = TextEditingController(); // where the bio for person is inputted
  final _skillsController = TextEditingController(); // where the skills is inputed

  String _email = ""; // this is where we keep the email
  String _userType = ""; // this is where we store the user type

  @override
  void initState() {
    super.initState();
    _getAndSetUser(); // when we initalize we also want to intalize w the data of the user
    _listenForNotifications(); 
  }

  // get/set the data of the user
  void _getAndSetUser() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get(); // get a snapshot of the user data currently

      var userProfile = doc.data() as Map<String, dynamic>; // set it as a map
      
      setState(() { // makes updates to ui by recreating the widget
        _email = userProfile['email']; // get email
        _userType = userProfile['userType']; // get the usertpe
        _nameController.text = userProfile['name'] ?? ''; // set the name if the name has been updated before
        _schoolController.text = userProfile['school'] ?? ''; // set the school if the school has been added before
        _majorController.text = userProfile['major'] ?? ''; // set the major if the major has been set before
        _skillsController.text = userProfile['skills'] ?? ''; // set the skills if it has been set before (i.e not empty in db)
        _bioController.text = userProfile['bio'] ?? ''; // set the bio if it has been set before
        
        // Check if all required fields are filled
      isProfileComplete = _nameController.text.isNotEmpty &&
          _schoolController.text.isNotEmpty &&
          _majorController.text.isNotEmpty &&
          _skillsController.text.isNotEmpty &&
          _bioController.text.isNotEmpty;
    });
  }
  
  // save changes to data
  void _saveEdits() async {
    String newName = _nameController.text.trim();
    String newSchool = _schoolController.text.trim();
    String newMajor = _majorController.text.trim();
    String newSkills = _skillsController.text.trim();
    String newBio = _bioController.text.trim();

    if (newName.isEmpty ||
        newSchool.isEmpty ||
        newMajor.isEmpty ||
        newSkills.isEmpty ||
        newBio.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill out all required fields'),
        duration: Duration(seconds: 2),
      ));
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update({
      'name': newName,
      'school': newSchool,
      'major': newMajor,
      'bio': newBio,
      'skills': newSkills,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Profile updated successfully'),
      duration: Duration(seconds: 2),
    ));

    setState(() {
      isProfileComplete = true; // Mark profile as complete after saving edits
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // get rid of back button for now (so buggy)
         title: Center(
          child: Text(
            'Settings',
            style: TextStyle(
              color: const Color.fromARGB(255, 111, 15, 128), 
            ),
          ),
        ), // name of the page
      ),
      body: SingleChildScrollView( // this is what we use to let the user scroll
        child: Form( // we r basically creting a form
          child: Column( // a column of all the stuf we r creating (vertical layout)
            children: [
              Container(
                color: Color.fromARGB(255, 228, 188, 255), // purple background!
                width: double.infinity, // width to both sides
                padding: const EdgeInsets.all(19.0), // add padding
                child: Stack( // stack w different elements
                  children: [
                    Align( // aligned to the right
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.logout), // Logout button
                        onPressed: () {
                          Navigator.pushNamed(context, '/welcome'); // Navigates to the login button
                        },
                      ),
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Stack(
                          children: [
                            IconButton( // Creates notifications button 
                              icon: Icon(Icons.notifications),  
                              onPressed: () {
                                _showNotificationsDialog(context); // Calls function that shows notifications list 
                                setState(() {
                                    hasNewNotification = false; 
                                  }
                                );
                              },
                            ),
                           if(hasNewNotification) // Adds indicator to notification button if there's a new notification
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red, 
                                ),
                              ),
                            ),
                          ],
                        ),
                    ),

                    Center( // Aligned to the center
                      child: Column( //Create a vertical column
                        children: [
                          _createPFP(), // pfp created
                          const SizedBox(height: 10), // pfp needs 19 space (my age!)
                          Text('Email: $_email'), // email
                          const SizedBox(height: 9.0), // 19-10 = 9!
                          Text('User Type: $_userType'), // user type
                          const SizedBox(height: 9.0), // 19-10 = 9!
                          ElevatedButton(
                            onPressed: () {
                              _changePassword(); // change password button
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, // style the button
                            ),
                            child: Text(
                              'Change Password',
                              style: TextStyle(color: Colors.purple), // style the color of text button
                           ),
                          ),
                        ],
                      )
                    )
                  ],
                ), 
              ),
              
              Padding( // padding so that the header touches both ends but the form doesn't so it doesn't look weird
                padding: const EdgeInsets.all(19.0), // add the padding
                  child: Column ( // multiple children in the form so we create another child element
                    crossAxisAlignment: CrossAxisAlignment.start, // align labels to the left
                    children: [
                      _buildInputLabel('Name'), // text label for Name
                      TextFormField( // name field in the form
                        controller: _nameController,
                      ),

                      const SizedBox(height: 9.0),
                      _buildInputLabel('University'), // text label for University
                      TextFormField( // school field in the form
                        controller: _schoolController,
                      ),

                      const SizedBox(height: 9.0),
                      _buildInputLabel('Major'), // text label for Major
                      TextFormField( // field for major
                        controller: _majorController,
                      ),

                      const SizedBox(height: 9.0),
                      _buildInputLabel('Skills (comma separated)'), // text label for Skills
                      TextFormField( // field for skills
                        controller: _skillsController,
                      ),

                      const SizedBox(height: 9.0),
                      Text(
                        'Bio',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 111, 15, 128),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox( // styled bio input field
                        height: 80,
                        child: Scrollbar(
                          thumbVisibility: true,
                          thickness: 4.0,
                          radius: Radius.circular(6.0),
                          child: TextFormField(
                            controller: _bioController,
                            maxLines: null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Center(
                        child:Column(
                          children: [
                            ElevatedButton(
                              onPressed:() async{
                                _saveEdits();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 111, 15, 128),
                              ),
                              child: const Text(
                                'Save Edits',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ) 
              ),
            ],
          ),
        ),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        onTap: (index) {
          
          if (!isProfileComplete) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Please fill out your profile before accessing other tabs'),
              duration: Duration(seconds: 1), 
            ));
            return;
          }

          // nav bar
          if (index == 0) {
            // dashboard page
            Navigator.pushNamed(context, '/dashboard');
          } else if (index == 1) {
            // create project page
            Navigator.pushNamed(context, '/createProject');
          } else if (index == 2) {
            // projects page
            Navigator.pushNamed(context, '/yourProjects');
          } else if (index == 3) {
            // settings page
            Navigator.pushNamed(context, '/chat');
          }
        },
        items: [
          _buildNavItem(Icons.dashboard, 'Dashboard'),
          _buildNavItem(Icons.add, 'Create'),
          _buildNavItem(Icons.list, 'Projects'),
          _buildNavItem(Icons.message, 'Messages'),
          _buildNavItem(Icons.settings, 'Settings'),
        ],
        type: BottomNavigationBarType.fixed, // make sure its fixed
      ),
    );
  }

Widget _buildInputLabel(String labelText) {
  return Text(
    labelText,
    style: TextStyle(
      color: const Color.fromARGB(255, 111, 15, 128), // set label text color to purple
      fontSize: 16, // adjust font size as needed
      fontWeight: FontWeight.bold, // make it bold
    ),
  );
}

  // create the pfp (i orginally did another query here which is why I created a helper method!)
  Widget _createPFP() {
    return CircleAvatar(
      radius: 50,
      backgroundColor:  const Color.fromARGB(255, 111, 15, 128), // set background color
      child: Icon(
        Icons.person,
        size: 60, // adjust icon size as needed
        color: Colors.white, // set icon color
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


 Future<List<Map<String, dynamic>>> _fetchNotifications() async { // Fetches notifications from firebase based on the user's ID
    final userId = FirebaseAuth.instance.currentUser?.uid?? ' ';
    final QuerySnapshot<Map<String,dynamic>> snapshot = await FirebaseFirestore.instance
      .collection('notifications')
      .where('recipientId', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .get(); 

      await _updateNotificationReadStatus(snapshot.docs); 

      return snapshot.docs.map((doc) => doc.data()).toList();
 }

  void _changePassword() async {
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Password Reset"),
          content: Text("Do you want to send a password reset email to $_email?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // cancel all changes
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _sendResetEmail(); 
                Navigator.of(context).pop(); // finish the dialog/send email
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendResetEmail() async
  {

    try
    {
      // success
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
     
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password reset email sent. Please check your inbox.'),
        duration: Duration(seconds: 3),
      ));
    }
    
    catch (e)
    {
      // failed 
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send password reset email. Please try again later.'),
        duration: Duration(seconds: 3),
      ));
    }
     
  }



void _showNotificationsDialog(BuildContext context) { //Function that creates the notifications list UI dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Notifications'),
        content: Container(
          width: double.maxFinite,
          height: 200,
          child: FutureBuilder(
            future: _fetchNotifications(),
            builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}'); // If there's an error show error 
              } else if (snapshot.data == null || snapshot.data!.isEmpty) { // If no notifications are present 
                return Text('No notifications found.');
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final notification = snapshot.data![index];
                    final timestamp = notification['timestamp'].toDate(); // Converts firestore timestamp to datetime
                    final formattedTimestamp = DateFormat('h:mm a').format(timestamp); // Converts the timestamp into HH:MM AM/PM time
                    final bool isRead = notification['read'] ?? false;  
                    final Color circleColor = isRead ? Colors.grey : Colors.red; // Indicates if the message has been read yet
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4.0), 
                      child: ListTile(
                        title: Text(notification['message'] ?? ''),
                        subtitle: Text(formattedTimestamp),
                        leading: Icon(Icons.circle, color: circleColor),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}

  Future<void> _updateNotificationReadStatus(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async { // Updates if a notification has been read 
    final List<Future<void>> updates = [];
    for(final doc in docs) {
      if(!(doc.data()['read'] ?? false)) {
        updates.add(doc.reference.update({'read': true})); 
      }
    }

  await Future.wait(updates); 
  }

  void _listenForNotifications() { // Listeners for notifications from project_details class logic to see if an new notfification has been added
    _fetchNotifications().then((notifications) {
      final hasUnreadNotifications = notifications.any((notification) => !notification['read']); 
      setState(() {
        hasNewNotification = hasUnreadNotifications; 
      }); 
    }); 
  }

  
}