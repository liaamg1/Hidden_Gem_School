import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

Future<Set<Marker>> getMarkersFromFirebase(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  final data = await FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .collection('posts')
      .get();

  final markers = data.docs.map((doc) {
    final docData = doc.data();
    final location = docData['location'];
    final photos = docData['photoURL'];
    return Marker(
      markerId: MarkerId(doc.id),
      position: LatLng(location.latitude, location.longitude),
      infoWindow: InfoWindow(
        title: docData['title'],
        snippet: "Press HERE for more information",
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: SizedBox(
                width: 500,
                height: 500,
                //reused code from saved_gems_page
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 7,
                  color: const Color.fromARGB(255, 168, 169, 169),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (photos is List)
                          for (var url in photos)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Image.network(url),
                            )
                        else
                          Image.network(photos),
                        SizedBox(height: 8),
                        Text(
                          docData['title'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Coordinates: \nLatitude: ${location.latitude}\nLongitude: ${location.longitude}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(docData['description']),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
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
    final loadedMarkers = await getMarkersFromFirebase(context);
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
