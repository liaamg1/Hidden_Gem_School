import 'package:flutter/material.dart';

class Gem {
  final String title;
  final String imageUrl;
  final String location;
  final String description;

  Gem({
    required this.title,
    required this.imageUrl,
    required this.location,
    required this.description,
  });
}

final List<Gem> placeHolderGems = [
  Gem(
    title: "Karlskrona picnic spot",
    imageUrl: "assets/images/karlskrona.jpg",
    location: "56.1612, 15.5869",
    description: "Best picnic spot in Karlskrona.",
  ),
  Gem(
    title: "Rio de Janeiro best view",
    imageUrl: "assets/images/rio.jpg",
    location: "-22.9068, -43.1729",
    description: "Hidden botanic garden in Rio.",
  ),
  Gem(
  title: "Tokyo Tower best view",
  imageUrl: "assets/images/tokyo_tower.jpg",
  location: "35.6586, 139.7454",
  description: "BEST VIEW SPOT FOR TOKYO",
  )
];

class SavedGemsPage extends StatelessWidget {
  const SavedGemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("My Saved Gems", textAlign: TextAlign.center),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: placeHolderGems.length,
        itemBuilder: (context, index) {
          final gem = placeHolderGems[index];
          return Padding(padding: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(gem.title, style: TextStyle(fontSize: 20)),
              Image.asset(gem.imageUrl),
              Text("Coordinates: ${gem.location}", style: TextStyle(fontWeight: FontWeight.bold )),
              Text(gem.description),
              SizedBox(height: 20,)
            ],
          ),);
        },
      ),
    );
  }
}
