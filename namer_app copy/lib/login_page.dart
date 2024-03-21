// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key : key); 

  @override State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color.fromARGB(255, 239, 177, 177),
      body: SafeArea(
        child:Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter, 
              colors: [Color.fromARGB(255, 84, 1, 109), Color.fromARGB(255, 31, 3, 188)],
              ),
          ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 25), 
          //Hello again
          Text(
            'Hello!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24, 
              color: Colors.white, 
              ),
            ),
          SizedBox(height: 10), 
          Text(
            'Welcome back!',
            style: TextStyle(
              fontSize: 20, 
              color: Colors.white, 
              ),
          ),
            SizedBox(height: 20), 

          //email field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Container(
              decoration: BoxDecoration( 
                color: const Color.fromARGB(255, 246, 237, 237), 
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Email', 
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 15),

          //password field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Container(
              decoration: BoxDecoration( 
                color: const Color.fromARGB(255, 246, 237, 237), 
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Password', 
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 15),

          //sign in button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Container(
              padding: EdgeInsets.all(25), 
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 60, 34, 192),
                borderRadius: BorderRadius.circular(12)
                ), 
              child: Center( 
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15, 
                  ),
                ), 
              )
            ),
          ),
          SizedBox(height: 15),

          //register button 
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Not a member?', 
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                ),
              ),
              Text(' Register here', 
                style: TextStyle(
                  color: Color.fromARGB(255, 2, 171, 255),
                  fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        ), 
      ), 
      ),
    );
  }
}