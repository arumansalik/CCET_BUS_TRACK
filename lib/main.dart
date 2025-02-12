import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_projects/loginPages/driver_login.dart';
import 'package:flutter_projects/loginPages/student_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Bus Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RoleSelectionPage(),
    );
  }
}



class RoleSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900, // Dark theme background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Padding(
              padding: EdgeInsets.only(bottom: 40), // Space below logo
              child: Image.asset(
                'assets/img/logo.png', // Replace with actual logo
                height: 220,
              ),
            ),

            // Student Login Button
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StudentLoginPage()),
              ),
              icon: Icon(Icons.school, color: Colors.white),
              label: Text(
                'Student Login',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
            ),

            SizedBox(height: 20), // Space between buttons

            // Driver Login Button
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DriverLoginPage()),
              ),
              icon: Icon(Icons.directions_bus, color: Colors.white),
              label: Text(
                'Driver Login',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
            ),

            SizedBox(height: 50), // Space below buttons

            // Footer Text
            Text(
              'Choose Your Role',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}