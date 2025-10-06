import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

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
  LatLng? _currentChosenPosition;
  //reused code from edit_profile_page
  List<File> _imageList = [];
  Future<void> _pickImage(BuildContext context) async {
    final imagePicker = ImagePicker();
    final pickedImages = await imagePicker.pickMultiImage();
    if (pickedImages.isNotEmpty) {
      setState(() {
        _imageList = pickedImages.map((picked) => File(picked.path)).toList();
      });
    }
  }

  //Reused code from _pickImage but changed function to pickImage with camera source
  Future<void> _takePhoto(BuildContext context) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageList.add(File(pickedFile.path));
      });
    }
  }

  Future<LatLng?> showMap(BuildContext context) async {
    Marker? currentMarker;

    //followed tutorial from https://api.flutter.dev/flutter/widgets/StatefulBuilder-class.html for statefulbuilder
    return showDialog<LatLng>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            content: SizedBox(
              width: 500,
              height: 500,
              //Reused some code from the map page.
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(56.1612, 15.5869),
                  zoom: 11.0,
                ),
                onTap: (LatLng pos) {
                  setState(() {
                    currentMarker = Marker(
                      markerId: const MarkerId("ChosenMarker"),
                      position: pos,
                    );
                  });
                },
                markers: currentMarker != null ? {currentMarker!} : {},
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (currentMarker != null) {
                    Navigator.pop(context, currentMarker?.position);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  //Took code from https://pub.dev/packages/geolocator, I would have written it the same way, so I saved time.

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
  //TO HERE

  Future<void> _uploadPost() async {
    final user = FirebaseAuth.instance.currentUser;
    final postID = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('posts')
        .add({
          'title': titleController.text.trim(),
          'description': descriptionController.text.trim(),
          'private': private,
          'location': GeoPoint(
            _currentPosition?.latitude ?? _currentChosenPosition?.latitude ?? 0,
            _currentPosition?.longitude ??
                _currentChosenPosition?.longitude ??
                0,
          ),
          'createdAt': FieldValue.serverTimestamp(),
        });

    List<String> photoURL = [];
    for (int i = 0; i < _imageList.length; i++) {
      final storageRef = FirebaseStorage.instance.ref().child(
        "uploaded_pictures/${postID.id}_$i.jpg",
      );
      await storageRef.putFile(_imageList[i]);
      final url = await storageRef.getDownloadURL();
      photoURL.add(url);
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('posts')
        .doc(postID.id)
        .set({'photoURL': photoURL}, SetOptions(merge: true));

    titleController.clear();
    _currentChosenPosition = null;
    _currentPosition = null;
    _imageList = [];
    descriptionController.clear();
    setState(() => private = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(centerTitle: true, title: Text("Upload Hidden Gem")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(context),
                    icon: Icon(Icons.upload),
                    label: const Text("Upload image"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _takePhoto(context),
                    icon: Icon(Icons.camera),
                    label: const Text("Take picture"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // IMAGE PREVIEW
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var img in _imageList)
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Image.file(
                        img,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 10),
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
            // COORDINATES PREVIEW
            Text(
              _currentChosenPosition != null
                  ? "Chosen position\nlatitude: ${_currentChosenPosition?.latitude}\nLongitude: ${_currentChosenPosition?.longitude}"
                  : "Chosen position\nlatitude: ${_currentPosition?.latitude}\nLongitude: ${_currentPosition?.longitude}",
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final pos = await _determinePosition();
                      setState(() {
                        _currentPosition = pos;
                        _currentChosenPosition = null;
                      });
                    },
                    icon: const Icon(Icons.my_location),
                    label: const Text("Use current location"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final chosenPosition = await showMap(context);
                      setState(() {
                        _currentPosition = null;
                        _currentChosenPosition = chosenPosition;
                      });
                    },
                    icon: const Icon(Icons.map),
                    label: const Text("Choose location on map"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            SwitchListTile(
              title: Text(private ? "Private" : "Public"),
              value: private,
              activeThumbColor: Colors.lightBlueAccent,
              onChanged: (bool value) {
                setState(() {
                  private = value;
                });
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 100.0),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.upload_file, size: 30),
              label: const Text("Upload"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (titleController.text.trim().isEmpty ||
                    descriptionController.text.trim().isEmpty ||
                    (_currentPosition == null &&
                        _currentChosenPosition == null) ||
                    _imageList.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        "Cannot upload: missing title, description, location, or photo.",
                      ),
                    ),
                  );
                } else {
                  _uploadPost();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
