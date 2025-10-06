import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems_new/features/profile/profile_page.dart';

final List<String> placeholderFriends = <String>['Jakob', 'Bengt', 'Carl'];

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<Map<String, dynamic>> friendsList = [];
  bool isInitialized = true;

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    final user = FirebaseAuth.instance.currentUser;
    final friends = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('friends')
        .get();
    List<Map<String, dynamic>> temp = [];
    for (var friend in friends.docs) {
      final friendData = await FirebaseFirestore.instance
          .collection('users')
          .doc(friend.id)
          .get();
      temp.add({'id': friend.id, ...friendData.data()!});
    }

    setState(() {
      friendsList = temp;
      isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Friends")),
      body: Builder(
        builder: (context) {
          if (!isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }
          if (friendsList.isEmpty) {
            return const Center(child: Text("No friends yet"));
          }
          return ListView.builder(
            itemCount: friendsList.length,
            itemBuilder: (context, index) {
              final friend = friendsList[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(friend['photoURL']),
                ),
                title: Text(friend['name']),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(userId: friend['id']),
                      ),
                    );
                  },
                  child: Text("View Proile"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
