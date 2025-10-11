import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems_new/features/social/notification_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final currentUser = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      NotificationPage(auth: currentUser, firestore: firestore),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 124, 181, 227),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Welcome",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "This is your home page.\n"
                "Enjoy exploring the app.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
