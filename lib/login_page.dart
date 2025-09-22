import 'package:flutter/material.dart';
import 'package:hidden_gems_new/main.dart';
import 'package:hidden_gems_new/auth_method.dart';
import 'package:sign_button/sign_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<void> _handleGoogleLogin(BuildContext context) async {
    final googleLogIn = GoogleSignUpService();
    final userCredential = await googleLogIn.login();

    if (!context.mounted) {
      return;
    }

    if (userCredential != null) {
      final user = userCredential.user;

      if (user != null) {
        final usersRef = FirebaseFirestore.instance.collection('users');

        try {
          await usersRef.doc(user.uid).set({
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'photoURL': user.photoURL ?? '',
            'bio': 'This is your bio',
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint('Firestore write failed');
        }
      }

      if (!context.mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    } else {
      debugPrint("Login didn't work");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "HIDDEN GEM",
              style: TextStyle(fontSize: 22, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            SignInButton(
              buttonType: ButtonType.google,
              onPressed: () => _handleGoogleLogin(context),
            ),
          ],
        ),
      ),
    );
  }
}
