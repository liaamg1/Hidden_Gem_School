import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hidden_gems_new/login_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Settings", textAlign: TextAlign.center),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            Text("Settings view"),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                debugPrint("");
              },
              child: const Text("Edit profile"),
            ),

            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
