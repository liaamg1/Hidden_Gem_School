import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems_new/friends_list.dart';
import 'package:hidden_gems_new/saved_gems_page.dart';
import 'package:hidden_gems_new/setting_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Temporary Text "),
        actions: [
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
        stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(), 
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
              backgroundImage: NetworkImage(user.photoURL!),
            ),
            const SizedBox(height: 15),
            Text(
              data['name'] ?? "Anonymous",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              data['bio'] ?? "Default bio"
              ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 30),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FriendsPage()),
                      );
                    },
                    child: const Text("Friends"),
                  ),
                ),
                SizedBox(width: 25),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SavedGemsPage(),
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
      }
      )
    );
  }
}
