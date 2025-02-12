import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverHomePage extends StatefulWidget {
  @override
  _DriverHomePageState createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  String? _selectedBus;
  bool _isTracking = false;
  Timer? _locationTimer;
  double _currentSpeed = 0.0;
  String _nextStop = "College Main Gate";
  List<LatLng> _routeCoordinates = [];

  Future<void> _startTracking() async {
    if (_selectedBus == null) return;

    // Request location permission
    bool hasPermission = await _checkLocationPermission();
    if (!hasPermission) return;

    // Fetch route coordinates (if available)
    await _fetchRouteCoordinates();

    // Start location updates
    _locationTimer = Timer.periodic(Duration(seconds: 15), (timer) async {
      Position position = await Geolocator.getCurrentPosition();
      double speed = position.speed * 3.6; // Convert m/s to km/h

      await FirebaseFirestore.instance.collection('liveLocations').doc(_selectedBus).set({
        'busId': _selectedBus,
        'currentLocation': GeoPoint(position.latitude, position.longitude),
        'speed': speed,
        'nextStop': _nextStop,
        'isActive': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() {
        _currentSpeed = speed;
      });
    });

    setState(() => _isTracking = true);
  }

  Future<void> _fetchRouteCoordinates() async {
    final routeSnapshot = await FirebaseFirestore.instance
        .collection('buses')
        .doc(_selectedBus)
        .get();

    if (routeSnapshot.exists) {
      final routeData = routeSnapshot.data() as Map<String, dynamic>;
      final stops = routeData['routeStops'] as List<dynamic>;

      setState(() {
        _routeCoordinates = stops
            .where((stop) => stop.containsKey('coordinates') && stop['coordinates'] != null)
            .map((stop) {
          final coordinates = stop['coordinates'] as GeoPoint;
          return LatLng(coordinates.latitude, coordinates.longitude);
        }).toList();

        _nextStop = _routeCoordinates.isNotEmpty ? stops[0]['stopName'] : "College Main Gate";
      });
    }
  }


  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Open location settings for the user to enable GPS
      await Geolocator.openLocationSettings();
      await Future.delayed(Duration(seconds: 2)); // Give some time for the user to enable it
      serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enable location services in settings.')),
        );
        return false;
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied')),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location permissions are permanently denied. Please enable them in app settings.'),
          action: SnackBarAction(
            label: 'Open Settings',
            onPressed: () async {
              await Geolocator.openAppSettings();
            },
          ),
        ),
      );
      return false;
    }

    return true;
  }


  Future<void> _stopTracking() async {
    _locationTimer?.cancel();
    await FirebaseFirestore.instance.collection('liveLocations').doc(_selectedBus).update({
      'isActive': false,
    });
    setState(() {
      _isTracking = false;
      _currentSpeed = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Driver Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            Text(
              'Welcome, Driver!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10),
            Text(
              'Manage your bus tracking with ease.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),

            // Bus Selection
            Text('Select Your Bus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: Text('Choose Bus', style: TextStyle(color: Colors.grey)),
                  value: _selectedBus,
                  items: ['Bus 16', 'Bus 20', 'Bus 25'].map((bus) {
                    return DropdownMenuItem(value: bus, child: Text(bus));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedBus = value),
                ),
              ),
            ),
            SizedBox(height: 30),

            // Tracking Status
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isTracking ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isTracking ? 'Live Tracking Active' : 'Tracking Stopped',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      Icon(
                        _isTracking ? Icons.check_circle : Icons.cancel,
                        color: _isTracking ? Colors.green : Colors.red,
                        size: 28,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (_isTracking) ...[
                    Text(
                      'Speed: ${_currentSpeed.toStringAsFixed(1)} km/h',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Next Stop: $_nextStop',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 30),

            // Start/Stop Button
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTracking ? Colors.red : Colors.orange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _isTracking ? _stopTracking : _startTracking,
                  child: Text(
                    _isTracking ? 'Stop Sharing' : 'Start Sharing',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}