import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState(); // create the state
}

class _EditProfileState extends State<EditProfile> {
  bool showNotification = false; 
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
                        icon: Icon(Icons.logout), // logout button
                        onPressed: () {
                          Navigator.pushNamed(context, '/welcome'); // navigate to the login button
                        },
                      ),
                    ),

                    Align(
                        alignment: Alignment.topLeft,
                        child: Stack(
                          children: [
                            IconButton(
                              icon: Icon(Icons.notifications), 
                              onPressed: () {
                                _showNotificationsDialog(context); 
                              },
                            ),
                          if(showNotification)
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

                    Center( // aligned to the center
                      child: Column( // create a vertical column
                        children: [
                          _createPFP(), // pfp created
                          const SizedBox(height: 10), // pfp needs 19 space (my age!)
                          Text('Email: $_email'), // email
                          const SizedBox(height: 9.0), // 19-10 = 9!
                          Text('User Type: $_userType'), // user type
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

          // Handle bottom navigation bar taps
          if (index == 0) {
            // Navigate to Dashboard page
            Navigator.pushNamed(context, '/dashboard');
          } else if (index == 1) {
            // Navigate to Create Project page
            Navigator.pushNamed(context, '/createProject');
          } else if (index == 2) {
            // Navigate to Your Projects page
            Navigator.pushNamed(context, '/yourProjects');
          } else if (index == 3) {
            // Navigate to Settings page
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
        type: BottomNavigationBarType.fixed,
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

  void _handleNewNotification() {
    setState(() {
      showNotification = true; 
    });
  }

 Future<List<Map<String, dynamic>>> _fetchNotifications() async {
  try {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('recipientId', isEqualTo: currentUserId)
        .get(); // Query only notifications intended for the current user
    List<Map<String, dynamic>> notifications = [];
    querySnapshot.docs.forEach((doc) {
      print('Notification data: ${doc.data()}');
      notifications.add({
        'message': doc['message'],
        'read': doc['read'],
        'recipientId': doc['recipientId'],
        'timestamp': doc['timestamp'],
      });
    });
    return notifications.isNotEmpty ? notifications : [];
  } catch (e) {
    print('Error fetching notifications: $e');
    return [];
  }
}

//   void _showNotificationsDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       Future<List<Map<String, dynamic>>> notificationsFuture = _fetchNotifications();

//       return StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             title: Text('Notifications'),
//             content: Container(
//               width: double.maxFinite, // Ensure content takes up full width
//               height: 200, // Specify a fixed height for the content area
//               child: FutureBuilder(
//                 future: notificationsFuture,
//                 builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (snapshot.hasError) {
//                     return Text('Error: ${snapshot.error}');
//                   } else if (snapshot.data == null || snapshot.data!.isEmpty) {
//                     return Text('No notifications found.');
//                   } else {
//                     return SingleChildScrollView( // Use SingleChildScrollView for scrolling
//                       child: SizedBox(
//                         height: 180, // Adjust height to accommodate content
//                         child: Column(
//                           children: snapshot.data!.map((notification) {
//                             return ListTile(
//                               title: Text(notification['message'] ?? ''),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                     );
//                   }
//                 },
//               ),
//             ),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: Text('Close'),
//               ),
//             ],
//           );
//         },
//       );
//     },
//   );
// }



// Assuming this function is inside your StatefulWidget class
void _showNotificationsDialog(BuildContext context) {
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
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                return Text('No notifications found.');
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final notification = snapshot.data![index];
                    final timestamp = notification['timestamp'].toDate(); // converts firestore timestamp to datetime
                    //final formattedTime = '${timestamp.hour}:${timestamp.minute}'; 
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4.0), 
                      child: ListTile(
                        title: Text(notification['message'] ?? ''),
                        subtitle: Text('${timestamp.hour}:${timestamp.minute}'),
                        leading: Icon(Icons.notifications),
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



}