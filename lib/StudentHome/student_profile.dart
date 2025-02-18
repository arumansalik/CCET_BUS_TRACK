import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_projects/StudentHome/student_home.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StudentProfilePage extends StatefulWidget {
  @override
  _StudentProfilePageState createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  late Future<DocumentSnapshot> _studentData;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _studentData = _fetchStudentData();
  }

  Future<DocumentSnapshot> _fetchStudentData() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    return await FirebaseFirestore.instance
        .collection('students')
        .doc(user.email)
        .get();
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.purple.shade400, Colors.blue.shade200],
              ),
            ),
          ),
          SafeArea(
            child: FutureBuilder<DocumentSnapshot>(
              future: _studentData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('Profile data not found'));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildProfileHeader(data),
                      SizedBox(height: 20),
                      _buildInfoCard('Personal Info', FontAwesomeIcons.user, [
                        _buildInfoRow('Name', data['name']),
                        _buildInfoRow('Email', data['email']),
                        _buildInfoRow('Phone', data['phone']),
                      ]),
                      _buildInfoCard('Academic Info', FontAwesomeIcons.graduationCap, [
                        _buildInfoRow('Department', data['department']),
                        _buildInfoRow('Year', data['year']),
                      ]),
                      _buildInfoCard('Transport Info', FontAwesomeIcons.bus, [
                        _buildInfoRow('Bus Number', data['busNo']),
                        _buildInfoRow('Bus Stop', data['busStop']),
                      ]),
                      SizedBox(height: 30),
                      _buildLogoutButton(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 12,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StudentHomePage()),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> data) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            child: Text(
              data['name'][0],
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.purple),
            ),
          ),
          SizedBox(height: 15),
          Text(
            data['name'],
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            data['email'],
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      elevation: 10,
      shadowColor: Colors.purpleAccent,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.purple, size: 30),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple),
                ),
              ],
            ),
            Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text(value, style: TextStyle(fontSize: 18, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: _signOut,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.white),
            SizedBox(width: 12),
            Text('Logout', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
