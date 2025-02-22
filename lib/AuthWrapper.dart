import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_projects/DriverHome/driver_home.dart';
import 'package:flutter_projects/StudentHome/student_home.dart';
import 'package:flutter_projects/main.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

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
            return GetStartedPage();
          } else {
            // User authenticated - determine role
            if (_isStudent(user)) {
              return StudentHomePage();
            } else if (_isDriver(user)) {
              return DriverHomePage();
            } else {
              // Unknown role - show role selection with logout
              return GetStartedPage();
            }
          }
        }
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  bool _isStudent(User user) {
    return user.email?.endsWith('@gmail') ?? false;
  }

  bool _isDriver(User user) {
    return user.email?.endsWith('@driver') ?? false;
  }
}

class GetStartedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.deepPurple.shade800, Colors.indigo.shade500],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                // Animated Illustration
                Lottie.asset(
                  'assets/animations/bus_animation.json', // Ensure you add this Lottie animation
                  height: 350,
                ),
                SizedBox(height: 20),

                // Welcome Text
                Text(
                  "Let's Get Started",
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  "Track your college bus in real-time with ease.",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),

                // Get Started Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RoleSelectionPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                      elevation: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_forward_ios, color: Colors.indigo.shade800),
                        SizedBox(width: 10),
                        Text(
                          "Get Started",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
