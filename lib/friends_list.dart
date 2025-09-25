import 'package:flutter/material.dart';

final List<String> placeholderFriends = <String>['Jakob', 'Bengt', 'Carl'];

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Friends", textAlign: TextAlign.center),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: placeholderFriends.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              child: Text(placeholderFriends[index][0])),
            title: Text(
              placeholderFriends[index],
              style: TextStyle(fontSize: 20),
            ),
          );
        },
      ),
    );
  }
}
