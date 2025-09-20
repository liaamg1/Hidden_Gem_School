import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
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
        markers: {
          Marker(
            markerId: MarkerId("Karlskrona"), 
            position: LatLng(56.1823, 15.5893), 
            infoWindow: InfoWindow(title: "BTH best swimming spot")
          ),
          Marker(
            markerId: MarkerId("Torko"), 
            position: LatLng(56.1509, 15.3979), 
            infoWindow: InfoWindow(title: "Ronneby great hidden swimming spot")
          )
        }
      ),
    );
  }
}
