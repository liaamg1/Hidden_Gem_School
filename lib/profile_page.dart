import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hidden_gems_new/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 120
            ),
          const CircleAvatar(
            radius: 70,
            backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
          ),
          const SizedBox(
            height: 15
            ),
          Text("Username", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 15
            ),
          ElevatedButton(onPressed: () {
            print("");
          }, child: const Text("Edit profile")),

          ElevatedButton(onPressed: () async {
            await FirebaseAuth.instance.signOut();
            await GoogleSignIn().signOut();
            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage())
            );
          }, child: const Text("Logout"))
        ],
      ),
    );
  }
}
