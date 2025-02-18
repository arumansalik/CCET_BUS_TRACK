import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_projects/StudentHome/student_profile.dart';
import 'bus_routes.dart'; // Import the Bus Routes Page

class StudentHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("CCET ", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Bus ", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            Text("Tracking", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset("assets/img/Cover.png", fit: BoxFit.cover),
              ),
              SizedBox(height: 16),

              // Buses Section
              Text("Available Buses", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('buses').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No buses available.'));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var bus = snapshot.data!.docs[index];
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Icon(Icons.directions_bus, color: Colors.blueAccent, size: 30),
                          title: Text('Bus No: ${bus['busNumber']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${bus['source']} → ${bus['destination']}', style: TextStyle(color: Colors.black87)),
                              Text('Timing: ${bus['startTime']} - ${bus['endTime']}', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BusRoutesPage(busId: bus.id)),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      // In StudentHomePage class
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StudentProfilePage()),
            );
          }
        },
      ),
    );
  }
}