import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    controller.text = user?.displayName ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Username')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (user != null) {
                  await user.updateDisplayName(controller.text);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
