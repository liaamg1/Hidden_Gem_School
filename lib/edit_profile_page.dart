import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController bioController = TextEditingController();
  File? _image;
  bool _initialized = false;

  Future<void> _pickImage(BuildContext context) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() => _image = File(pickedImage.path));
    }
  }

  Future<void> _saveProfile(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    String? photoURL =
        (await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get())
            .data()?['photoURL'];

    if (_image != null) {
      final storageRef = FirebaseStorage.instance.ref().child(
        "profile_pics/${user.uid}.jpg",
      );
      await storageRef.putFile(_image!);
      photoURL = await storageRef.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': nameController.text.trim(),
      'bio': bioController.text.trim(),
      'photoURL': photoURL,
    }, SetOptions(merge: true));

    if (!context.mounted) {
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    //Reused code from profile page
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Text("Loading..."));
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (!_initialized) {
            bioController.text = data['bio'] ?? '';
            nameController.text = data['name'] ?? '';
            _initialized = true;
          }
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    _pickImage(context);
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : NetworkImage(data['photoURL']),
                  ),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: bioController,
                  decoration: const InputDecoration(labelText: 'Bio'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _saveProfile(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
