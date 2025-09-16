import 'package:flutter/material.dart';

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
            height: 40
            ),
          ElevatedButton(onPressed: () {
            print("");
          }, child: const Text("Edit profile")),

          ElevatedButton(onPressed: () {
            print("");
          }, child: const Text("Logout"))
        ],
      ),
    );
  }
}
