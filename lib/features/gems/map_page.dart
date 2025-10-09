import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapPage({super.key, required this.latitude, required this.longitude});

  @override
  State<MapPage> createState() => _MapPageState();
}

Future<List<String>> getFriendsUserIds() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return [];
  }
  final friendSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('friends')
      .get();

  final friendIds = friendSnapshot.docs.map((doc) => doc.id).toList();
  final allUsers = [user.uid, ...friendIds];
  return allUsers;
}

Future<double?> getFriendColorHue(String friendId) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return null;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .collection('friends')
      .doc(friendId)
      .get();

  if (!doc.exists) return null;
  final int colorValue = doc.get('color');
  final double hue = HSVColor.fromColor(Color(colorValue)).hue;
  return hue;
}

Future<Set<Marker>> getMarkersFromFirebase(BuildContext context) async {
  final currentUser = FirebaseAuth.instance.currentUser;

  final users = await getFriendsUserIds();
  Set<Marker> markers = {};

  final allPostsFutures = users.map((userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('posts')
        .get()
        .then((snapshot) => MapEntry(userId, snapshot.docs));
  });
  final allPosts = await Future.wait(allPostsFutures);
  for (var entry in allPosts) {
    final postOwner = entry.key;
    final docs = entry.value;
    final hueFutures = docs.map((doc) async {
      if (postOwner != currentUser!.uid) {
        final value = await getFriendColorHue(postOwner);
        return value ?? BitmapDescriptor.hueAzure;
      } else {
        return BitmapDescriptor.hueRed;
      }
    }).toList();
    final postOwnerNameDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(postOwner)
        .get();
    final postOwnerName = postOwnerNameDoc['name'];
    final hues = await Future.wait(hueFutures);

    for (int i = 0; i < docs.length; i++) {
      final docData = docs[i];
      final location = docData['location'];
      final photos = docData['photoURL'];
      final hue = hues[i];
      if ((postOwner != currentUser!.uid && !docData['private']) ||
          postOwner == currentUser.uid) {
        markers.add(
          Marker(
            markerId: MarkerId(docs[i].id),
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
                              Center(
                                child: Text(
                                  "Post Owner: $postOwnerName",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),

                              if (photos is List)
                                CarouselSlider(
                                  options: CarouselOptions(
                                    height: 300,
                                    autoPlay: false,
                                    enlargeCenterPage: true,
                                    enableInfiniteScroll: false,
                                  ),
                                  items: photos.map((url) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5,
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: url,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                    );
                                  }).toList(),
                                )
                              else
                                SizedBox(
                                  width: double.infinity,
                                  height: 300,
                                  //Took cachednetworkImage code from https://pub.dev/packages/cached_network_image
                                  child: CachedNetworkImage(
                                    imageUrl: photos,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
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
            icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          ),
        );
      }
    }
  }

  return markers;
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  late final LatLng location;
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
    location = LatLng(widget.latitude, widget.longitude);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadMarkers();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(target: location, zoom: 13.0),
        markers: _markers,
      ),
    );
  }
}
