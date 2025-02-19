import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_projects/DriverHome/driver_home.dart';
import 'package:flutter_projects/StudentHome/student_home.dart';
import 'package:flutter_projects/main.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;

          if (user == null) {
            // User not authenticated - show role selection
            return RoleSelectionPage();
          } else {
            // User authenticated - determine role
            if (_isStudent(user)) {
              return StudentHomePage();
            } else if (_isDriver(user)) {
              return DriverHomePage();
            } else {
              // Unknown role - show role selection with logout
              return _UnknownUserPage();
            }
          }
        }
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  bool _isStudent(User user) {
    // Check student email pattern (e.g., ends with @student.college.edu)
    return user.email?.endsWith('@gmail') ?? false;
  }

  bool _isDriver(User user) {
    // Check driver email pattern or Firestore role
    return user.email?.endsWith('@driver') ?? false;
  }
}

class _UnknownUserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Unknown user type', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => RoleSelectionPage()),
                );
              },
              child: Text('Return to Login'),
            ),
          ],
        ),
      ),
    );
  }
}