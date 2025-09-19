import 'package:flutter/material.dart';

final List<String> placeHolder_friends = <String>['Jakob', 'Bengt', 'Carl'];

class FriendsPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(centerTitle: true,
        title: Text("Friends", textAlign: TextAlign.center)
        ),
      body: ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: placeHolder_friends.length,
        itemBuilder: (context, index){
          return ListTile(
            title: Text(placeHolder_friends[index], style: TextStyle(fontSize: 20),),
          );
        }
      ),
    );
  }
}
