import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TrackingPage extends StatefulWidget {
  final String busId;
  const TrackingPage({super.key, required this.busId});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  late GoogleMapController _mapController;
  LatLng? _busLocation;
  LatLng? _studentLocation;
  String _eta = "Calculating...";
  String _nextStop = "-";
  StreamSubscription<DocumentSnapshot>? _busSubscription;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _getStudentLocation();
    _startBusTracking();
  }

  Future<void> _getStudentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() => _studentLocation = LatLng(position.latitude, position.longitude));
  }

  void _startBusTracking() {
    _busSubscription = FirebaseFirestore.instance
        .collection('liveLocations')
        .doc(widget.busId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final geoPoint = data['currentLocation'] as GeoPoint;
        final newLocation = LatLng(geoPoint.latitude, geoPoint.longitude);

        setState(() {
          _busLocation = newLocation;
          _nextStop = data['nextStop'] ?? "College Main Gate";
        });

        _updateMap(newLocation);
        _calculateETA();
      }
    });
  }

  Future<void> _calculateETA() async {
    if (_busLocation == null || _studentLocation == null) return;

    final distance = await Geolocator.distanceBetween(
      _studentLocation!.latitude, _studentLocation!.longitude,
      _busLocation!.latitude, _busLocation!.longitude,
    );

    final etaMinutes = (distance / 500).ceil(); // Assume bus speed is ~30 km/h
    setState(() => _eta = etaMinutes > 1 ? "$etaMinutes min" : "Arriving soon");
  }

  void _updateMap(LatLng position) {
    _mapController.animateCamera(CameraUpdate.newLatLngZoom(position, 16));
    _markers.clear();
    _markers.add(Marker(
      markerId: MarkerId('bus'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(title: "Bus Location"),
    ));
    if (_studentLocation != null) {
      _markers.add(Marker(
        markerId: MarkerId('student'),
        position: _studentLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: "Your Location"),
      ));
    }
  }

  @override
  void dispose() {
    _busSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bus Tracking"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: LatLng(0, 0), zoom: 16),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            onMapCreated: (controller) => _mapController = controller,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildInfoPanel(),
          )
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.blueAccent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(FontAwesomeIcons.bus, color: Colors.white, size: 24),
                Text("ETA: $_eta", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 10),
            Text("Next Stop: $_nextStop", style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
