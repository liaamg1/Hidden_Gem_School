import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems_new/features/gems/map_page.dart';

class SavedGemsPage extends StatefulWidget {
  final String userId;
  const SavedGemsPage({super.key, required this.userId});

  @override
  State<SavedGemsPage> createState() => _SavedGemsPageState();
}

class _SavedGemsPageState extends State<SavedGemsPage> {
  final user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> items = [];
  bool isInitialized = false;
  Future<void> getSavedGems() async {
    List<Map<String, dynamic>> tempList = [];

    var data = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .get();

    for (var element in data.docs) {
      tempList.add(element.data());
    }
    setState(() {
      items = tempList;
      isInitialized = true;
    });
  }

  @override
  void initState() {
    super.initState();
    getSavedGems();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("My Saved Gems", textAlign: TextAlign.center),
      ),
      body: (isInitialized)
          ? ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final gem = items[index];
                final location = gem['location'];
                final photos = gem['photoURL'];
                final status = gem['private'];
                if (status && widget.userId != user!.uid) {
                  return SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.all(5),
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
                            CarouselSlider(
                              options: CarouselOptions(
                                height: 400,
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
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
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
                              height: 400,
                              //Took cachednetworkImage code from https://pub.dev/packages/cached_network_image
                              child: CachedNetworkImage(
                                imageUrl: photos,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          SizedBox(height: 8),
                          Text(
                            gem['title'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.map),
                            label: const Text("View on Map"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MapPage(
                                    latitude: location.latitude,
                                    longitude: location.longitude,
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 5),
                          Text(gem['description']),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : Text("no data yet"),
    );
  }
}
