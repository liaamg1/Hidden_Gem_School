import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems_new/features/profile/friends_list.dart';
import 'package:hidden_gems_new/features/gems/saved_gems_page.dart';
import 'package:hidden_gems_new/features/profile/setting_page.dart';

Future<void> unfollowUser(friend) async {
  final currentUid = FirebaseAuth.instance.currentUser?.uid;
  if (currentUid == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUid)
      .collection('friends')
      .doc(friend)
      .delete();

  await FirebaseFirestore.instance
      .collection('users')
      .doc(friend)
      .collection('friends')
      .doc(currentUid)
      .delete();
}

class ProfilePage extends StatelessWidget {
  final String userId;

  ProfilePage({super.key, required this.userId});
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Profile View"),
        actions: [
          if (userId == currentUser?.uid)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Text("Loading..."));
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(data['photoURL']),
                ),
                const SizedBox(height: 15),
                Text(
                  data['name'] ?? "Anonymous",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(data['bio'] ?? "Default bio"),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 30),
                    userId == currentUser?.uid
                        ? Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FriendsPage(),
                                  ),
                                );
                              },
                              child: const Text("Friends"),
                            ),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Are you sure?"),
                                  content: const Text(
                                    "Do you really want to remove this friend?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text("Remove"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await unfollowUser(userId);
                                if (!context.mounted) {
                                  return;
                                }
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FriendsPage(),
                                  ),
                                );
                              }
                            },
                            child: const Text("Remove Friend"),
                          ),
                    SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SavedGemsPage(userId: userId),
                            ),
                          );
                        },
                        child: const Text("My Saved Gems"),
                      ),
                    ),
                    SizedBox(width: 30),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
