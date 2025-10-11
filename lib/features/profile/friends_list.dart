import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems_new/features/profile/profile_page.dart';
import 'package:hidden_gems_new/features/social/add_friend_page.dart';

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

          return ListView.builder(
            itemCount: friendsList.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: const Text("Add new friend"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddFriendPage(),
                        ),
                      );
                    },
                  ),
                );
              }

              if (friendsList.isEmpty) {
                return const Center(child: Text("No friends yet"));
              }

              // List starts from index 1, so use index - 1
              final friend = friendsList[index - 1];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(friend['photoURL']),
                ),
                title: Text(friend['name']),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final removed = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          userId: FirebaseAuth.instance.currentUser!.uid,
                          auth: FirebaseAuth.instance,
                          firestore: FirebaseFirestore.instance,
                        ),
                      ),
                    );

                    if (removed == true) {
                      await fetchFriends();
                    }
                  },
                  child: const Text("View Profile"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
