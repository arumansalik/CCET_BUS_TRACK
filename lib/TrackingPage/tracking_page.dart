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
  double _busSpeed = 0.0;
  DateTime? _lastUpdated;
  StreamSubscription<DocumentSnapshot>? _busSubscription;
  final Set<Marker> _markers = {};

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
        .listen((snapshot) async {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final geoPoint = data['currentLocation'] as GeoPoint;
        final newLocation = LatLng(geoPoint.latitude, geoPoint.longitude);

        setState(() {
          _busLocation = newLocation;
          _busSpeed = (data['speed'] ?? 0.0).toDouble();
          _lastUpdated = (data['lastUpdated'] as Timestamp).toDate();
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

    final speed = _busSpeed > 0 ? _busSpeed : 30.0;
    final etaSeconds = distance / (speed * 1000 / 3600);

    setState(() => _eta = etaSeconds > 60 ? "${(etaSeconds / 60).toStringAsFixed(0)} min" : "Arriving soon");
  }

  void _updateMap(LatLng position) {
    _mapController.animateCamera(CameraUpdate.newLatLngZoom(position, 16));
    _markers.clear();
    _markers.add(Marker(
      markerId: MarkerId('bus'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(title: ""
          "${widget.busId}"),
    ));
    if (_studentLocation != null) {
      _markers.add(Marker(
        markerId: MarkerId('student'),
        position: _studentLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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
        title: Text("${widget.busId} Tracking"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _getStudentLocation,
          )
        ],
      ),
      body: Stack(
        children: [
          _busLocation == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _busLocation!,
              zoom: 16,
            ),
            markers: _markers,
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
            Text("Speed: ${_busSpeed.toStringAsFixed(1)} km/h", style: TextStyle(color: Colors.white, fontSize: 16)),
            if (_lastUpdated != null)
              Text("Updated: ${DateFormat('hh:mm a').format(_lastUpdated!)}", style: TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
