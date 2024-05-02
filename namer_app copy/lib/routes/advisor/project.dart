import 'package:flutter/material.dart';

class IndividualProjectPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final buttonStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple); // Changed color to purple

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        automaticallyImplyLeading: false, // Remove the default back button
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center align items
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Project Title',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              width: 100,
              height: 100,
              color: Color.fromARGB(255, 204, 198, 198), // Gray background color
              child: Center(
                child: Icon(
                  Icons.computer,
                  size: 50,
                  color: Colors.grey[600], // Icon color
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity, // Same width as the screen
                height: 50, // Same height as the Project Filters box
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Box color
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Project Filters',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity, // Same width as the screen
                height: 150, // Increased height for the Description box
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Box color
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                child: Align(
                  alignment: Alignment.topLeft, // Align text to top left corner
                  child: Text(
                    'Description',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to student list page
              },
              child: Text(
                'View Student List',
                style: buttonStyle, // Applied updated buttonStyle
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center align the row
              children: [
                Container(
                  width: 50,
                  height: 50,
                  color: Color.fromARGB(255, 235, 231, 231),
                ),
                SizedBox(width: 50), // Increased spacing
                Container(
                  width: 50,
                  height: 50,
                  color: Color.fromARGB(255, 235, 231, 231),
                ),
                SizedBox(width: 50), // Increased spacing
                Container(
                  width: 50,
                  height: 50,
                  color: Color.fromARGB(255, 235, 231, 231),
                ),
                SizedBox(width: 50), // Increased spacing
                Container(
                  width: 50,
                  height: 50,
                  color: Color.fromARGB(255, 235, 231, 231),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Announcements',
                style: buttonStyle, // Applied updated buttonStyle
              ),
            ),
            ListTile(
              leading: Container(
                width: 50,
                height: 50,
                color: Color.fromARGB(255, 235, 231, 231),
              ),
              title: Text(
                'Announcement 1',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Adjustments to project specs'),
            ),
            Text(
              'Submitted Documents',
              style: buttonStyle, // Applied updated buttonStyle
            ),
            // Add widgets for submitted documents here
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    // Navigate to Advisor/Feedback
                    Navigator.pushNamed(context, '/advisor/feedback');
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Color.fromARGB(255, 235, 231, 231),
                    child: Image.asset('pdf_image.png'), // Change to your PDF image
                  ),
                ),
                SizedBox(width: 50),
                GestureDetector(
                  onTap: () {
                    // Navigate to Advisor/Feedback
                     Navigator.pushNamed(context, '/advisor/feedback');
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Color.fromARGB(255, 235, 231, 231),
                    child: Image.asset('pdf_image.png'), // Change to your PDF image
                  ),
                ),
                SizedBox(width: 50),
                GestureDetector(
                  onTap: () {
                    // Navigate to Advisor/Feedback
                     Navigator.pushNamed(context, '/advisor/feedback');
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Color.fromARGB(255, 235, 231, 231),
                    child: Image.asset('PDF_file_icon.svg.png'), // Change to your PDF image
                  ),
                ),
              ],
            ),
          ],
        )
        
        ,
      ),
      
    );
  } 
}
