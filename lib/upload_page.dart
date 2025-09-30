import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool private = true;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Position? _currentPosition;

  //Took code from https://pub.dev/packages/geolocator, I understand everything and would have written it the same way.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _uploadPost() async {
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('posts')
        .add({
          'title': titleController.text.trim(),
          'description': descriptionController.text.trim(),
          'private': private,
          'location': GeoPoint(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          'createdAt': FieldValue.serverTimestamp(),
        });

    titleController.clear();
    descriptionController.clear();
    setState(() => private = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("Upload Hidden Gem")),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.diamond, color: Colors.blue),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final pos = await _determinePosition();
                        setState(() {
                          _currentPosition = pos;
                        });
                        //Testing if position system is working
                        debugPrint(
                          "Current position: Lat=${pos.latitude}, Lng=${pos.longitude}",
                        );
                      },
                      icon: const Icon(Icons.my_location),
                      label: const Text("Use current location"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.map),
                      label: const Text("Choose location on map"),
                    ),
                  ),
                ],
              ),
              //Grabbed switch code from https://api.flutter.dev/flutter/material/Switch-class.html and changed a little
              SwitchListTile(
                title: Text(private ? "Private" : "Public"),
                value: private,
                activeThumbColor: Colors.lightBlueAccent,
                onChanged: (bool value) {
                  setState(() {
                    private = value;
                  });
                },
                contentPadding: EdgeInsets.symmetric(horizontal: 110.0),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.upload_file, size: 30),
                label: const Text("Upload"),
                onPressed: () {
                  _uploadPost();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
