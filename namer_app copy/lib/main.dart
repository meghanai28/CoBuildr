import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/routes/editProfile/editProfile_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'routes/welcome_page.dart';
import 'routes/login_page.dart';
import 'routes/signup_page.dart';
import 'routes/dashboard_page.dart';
import 'routes/createproj_page.dart';
import 'routes/your_projects.dart';
import 'routes/chat/chat_page.dart';
import 'routes/projectdetails_page.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // initalize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(MyApp()); //tells flutter to run the app defined MyApp
  
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoBuildr',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/welcome', // Set the initial route to WelcomePage
      routes: {
        '/welcome': (context) => WelcomePage(), // WelcomePage route
        '/login': (context) => LoginPage(), // LoginPage route
        '/signup': (context) => SignupPage(), // SignupPage route
        '/dashboard' : (context) => DashboardPage(), // Dashboard route
        '/createProject': (context) => CreateProjectPage(), //CreateProjectPage route
        '/yourProjects': (context) => YourProjectsPage(), //YourProjectsPage route
        '/chat' : (context) => ChatPage(), // ChatPage route
        '/editProfile' :  (context) => EditProfile(), //EditProfilePage
        '/projectDetails' : (context) => ProjectDetailsPage(userId: '',), // Inidividual project details route 
        
      },
    );
  }
}
