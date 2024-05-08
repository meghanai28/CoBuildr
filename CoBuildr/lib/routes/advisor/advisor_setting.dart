import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdvisorEditProfile extends StatefulWidget {
  const AdvisorEditProfile({Key? key}) : super(key: key);

  @override
  State<AdvisorEditProfile> createState() =>  _AdvisorEditProfileState(); // create the state
}

class _AdvisorEditProfileState extends State<AdvisorEditProfile> {
  bool isProfileComplete = false;

  final _nameController = TextEditingController(); // where name is inputted
  final _schoolController = TextEditingController(); // where school is inputed
  final _majorController = TextEditingController(); // where major is inputted
  final _bioController = TextEditingController(); // where the bio for person is inputted
  final _skillsController = TextEditingController(); // where the skills is inputed

  String _email = ""; // this is where we keep the email
  String _userType = ""; // this is where we store the user type
  String _pfp = ""; // for the pfp

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
        _pfp = userProfile['profilePictureUrl']; // get the profile picture
        _nameController.text = userProfile['name'] ?? ''; // set the name if the name has been updated before
        _schoolController.text = userProfile['school'] ?? ''; // set the school if the school has been added before
        _majorController.text = userProfile['major'] ?? ''; // set the major if the major has been set before
        _skillsController.text = userProfile['skills'] ?? ''; // set the skills if it has been set before (i.e not empty in db)
        _bioController.text = userProfile['bio'] ?? ''; // set the bio if it has been set before
        

        isProfileComplete = _nameController.text.isNotEmpty &&
          _schoolController.text.isNotEmpty &&
          _majorController.text.isNotEmpty &&
          _skillsController.text.isNotEmpty &&
          _bioController.text.isNotEmpty;
    });
  }


  // save changes to data
  void _saveEdits() async {
    String newName = _nameController.text.trim(); // the newname
    String newSchool = _schoolController.text.trim(); // the newschool
    String newMajor = _majorController.text.trim(); // the new major
    String newSkills = _skillsController.text.trim(); // the new skills
    String newBio = _bioController.text.trim(); // new bio


     if (newName.isEmpty ||
        newSchool.isEmpty ||
        newMajor.isEmpty ||
        newSkills.isEmpty ||
        newBio.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill out all required fields'),
        duration: Duration(seconds: 1),
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
    }); // update the current user's stuff accordingly
    
    // show message if they did update
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
        title: const Text('Edit Profile'), // name of the page
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
              
              Padding( // padding so that the header touches both ends but the form doesnt so it doesnt look weird
                padding:  const EdgeInsets.all(19.0), // add the padding
                child: Column ( // multiple children in the form so we create another child element
                  children: [
                    const SizedBox(height: 15.0), 
                    TextFormField( // name field in the form
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),

                    const SizedBox(height: 9.0),
                    TextFormField( // school field in the form
                      controller: _schoolController,
                      decoration: const InputDecoration(labelText: 'University'),
                    ),

                    const SizedBox(height: 9.0),
                    TextFormField( // field for major
                      controller: _majorController,
                      decoration: const InputDecoration(labelText: 'Field of Study'),
                    ),

                    const SizedBox(height: 9.0),
                    TextFormField( // field for skills
                      controller: _skillsController,
                      decoration: const InputDecoration(labelText: 'Roles/Jobs (comma separated)'),
                    ),

                    const SizedBox(height: 9.0),
                    TextFormField( // field for bio
                      controller: _bioController,
                      decoration: const InputDecoration(labelText: 'Bio'),
                      maxLines: 5, // let it go for 5 lines instead of doing the weird sliding thing to the right. (do it vertically)
                    ),

                    const SizedBox(height: 25.0),
                    ElevatedButton( // save all the users edits button
                      onPressed: () async {
                          _saveEdits(); // call the save edits so changes r saved
                        },
                    child: const Text('Save Edits'),
                    ),
                  ],
                ) 
              ),
                
            ],
          ),
        ),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: (index) {

          if (!isProfileComplete) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Please fill out your profile before accessing other tabs'),
              duration: Duration(seconds: 2),
            ));
            return;
          }

          // Handle bottom navigation bar taps
          if (index == 0) {
            // Navigate to Dashboard page
            Navigator.pushNamed(context, '/advisor/advisor_dashboard');
          } else if (index == 1) {
            // Navigate to Your Projects page
            Navigator.pushNamed(context, '/advisor/project_tab');
          } else if (index == 2) {
            // Navigate to chat page
            Navigator.pushNamed(context, '/advisor/advisor_chat');
          }
        },
        items: [
          _buildNavItem(Icons.dashboard, 'Dashboard'),
          _buildNavItem(Icons.list, 'Your Projects'),
          _buildNavItem(Icons.message, 'Messages'),
          _buildNavItem(Icons.settings, 'Settings'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }


  // create the pfp (i orginally did another query here which is why I created a helper method!)
  Widget _createPFP() {
    return CircleAvatar(
      radius: 50,
      backgroundImage: NetworkImage(_pfp),
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
}







