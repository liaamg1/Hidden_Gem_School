import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


Future<void> addFriend(String toEmail) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  await FirebaseFirestore.instance
      .collection('friend_invites').add({
        'from': currentUser.email,
        'to': toEmail,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
}

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text("Add friend"), centerTitle: true),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(
          left: 40,
          right: 40,
          top: 200,
          bottom: 200,
        ),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Add New Friend",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Friend's email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  addFriend(emailController.text.trim());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text("Friend Request Sent!")),
                  );
                  setState(() {
                    emailController.clear();
                  });
                },
                child: const Text("Send Invite"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
