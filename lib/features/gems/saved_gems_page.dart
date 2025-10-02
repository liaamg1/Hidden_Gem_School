import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SavedGemsPage extends StatefulWidget {
  const SavedGemsPage({super.key});

  @override
  State<SavedGemsPage> createState() => _SavedGemsPageState();
}

class _SavedGemsPageState extends State<SavedGemsPage> {
  final user = FirebaseAuth.instance.currentUser;
  late List<Map<String, dynamic>> items;
  bool isInitialized = false;
  Future<void> getSavedGems() async {
    List<Map<String, dynamic>> tempList = [];

    var data = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('posts')
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
      body: isInitialized
          ? ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final gem = items[index];
                final location = gem['location'] as GeoPoint;
                return Padding(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(gem['title'], style: TextStyle(fontSize: 20)),
                      Image.network(gem['photoURL']),
                      Text(
                        "Coordinates: \nLatitude: ${location.latitude}\nLongitude: ${location.longitude}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(gem['description']),
                      SizedBox(height: 20),
                    ],
                  ),
                );
              },
            )
          : Text("no data"),
    );
  }
}
