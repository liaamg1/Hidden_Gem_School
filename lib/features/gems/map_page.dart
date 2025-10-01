import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

Future<Set<Marker>> getMarkersFromFirebase() async {
  final user = FirebaseAuth.instance.currentUser;
  final data = await FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .collection('posts')
      .get();

  final markers = data.docs.map((doc) {
    final docData = doc.data();
    final location = docData['location'];
    return Marker(
      markerId: MarkerId(doc.id),
      position: LatLng(location.latitude, location.longitude),
      infoWindow: InfoWindow(
        title: docData['title'],
        snippet: docData['description'],
      ),
    );
  });
  final markersSet = markers.toSet();
  return markersSet;
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};

  Future<void> loadMarkers() async {
    final loadedMarkers = await getMarkersFromFirebase();
    setState(() {
      _markers = loadedMarkers;
    });
  }

  @override
  void initState() {
    super.initState();
    loadMarkers();
  }

  static const LatLng karlskrona = LatLng(56.1612, 15.5869);
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: karlskrona,
          zoom: 11.0,
        ),
        markers: _markers,
      ),
    );
  }
}
