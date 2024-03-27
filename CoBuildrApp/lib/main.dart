import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/home_page.dart';
import 'package:namer_app/login_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  // initalize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(MyApp()); //tells flutter to run the app defined MyApp
  
}

class MyApp extends StatelessWidget { //widgets = elements you build every flutter app with 
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'CoBuildr',
        // theme: ThemeData(
        //   useMaterial3: true,
        //   colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(84, 1, 109, 1)),
        // ),
        home: Consumer<MyAppState>(
          builder: (context, appState, _) {
            if(appState.isAuthenticated) {
              return MyHomePage(); 
            } else {
              return LoginPage(); 
            }
          }
      ),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier { //defines app state, changenotifier = notifies others of its own changes
  var current = WordPair.random();
  bool isAuthenticated = false; 

  void login(){ //temp login logic for testing
    isAuthenticated = true;
    notifyListeners(); 
  }

  void getNext() {
    current = WordPair.random(); 
    notifyListeners(); 
  }

  var favorites = <WordPair>[]; //wordpair generics used to specify list can only ever contain word pairs

  void toggleFavorite() {
    if(favorites.contains(current)) {
      favorites.remove(current); 
    } else {
      favorites.add(current); 
    }
    notifyListeners(); 
  }

}
