import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  late final String? currentEmail;

  @override
  void initState() {
    super.initState();
    currentEmail = currentUser!.email!.toLowerCase();
  }

  Stream<QuerySnapshot> loadRequests() {
    return FirebaseFirestore.instance
        .collection('friend_invites')
        .where('to', isEqualTo: currentEmail)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications"), centerTitle: true),
      body: StreamBuilder(
        stream: loadRequests(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final invites = snapshot.data!.docs;
          if (invites.isEmpty) {
            return const Center(child: Text("No pending friend requests!"));
          }
          return ListView.builder(
            itemCount: invites.length,
            itemBuilder: (BuildContext context, index) {
              final invite = invites[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${invite['from']}\nWants to be your friend.",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              final fromUserQuery = await FirebaseFirestore
                                  .instance
                                  .collection('users')
                                  .where('email', isEqualTo: invite['from'])
                                  .limit(1)
                                  .get();

                              if (fromUserQuery.docs.isEmpty) return;
                              final fromUserId = fromUserQuery.docs.first.id;

                              await FirebaseFirestore.instance
                                  .collection('friend_invites')
                                  .doc(invite.id)
                                  .update({'status': 'accepted'});

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUser!.uid)
                                  .collection('friends')
                                  .doc(fromUserId)
                                  .set({});

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(fromUserId)
                                  .collection('friends')
                                  .doc(currentUser!.uid)
                                  .set({});
                            },
                            child: const Text("Accept"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('friend_invites')
                                  .doc(invite.id)
                                  .update({'status': 'rejected'});
                            },
                            child: const Text("Decline"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
