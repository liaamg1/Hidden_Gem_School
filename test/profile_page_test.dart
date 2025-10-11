import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:hidden_gems_new/features/profile/profile_page.dart';

//Followed documentation from https://pub.dev/packages/fake_cloud_firestore and different youtube videos
//Also  https://pub.dev/packages/firebase_auth_mocks
void main() {
  testWidgets('ProfilePage shows user data', (WidgetTester tester) async {
    final mockUser = MockUser(
      uid: 'user123',
      email: 'test@example.com',
      displayName: 'Test User',
      photoURL: '',
    );
    final mockAuth = MockFirebaseAuth(mockUser: mockUser);

    final fakeFirestore = FakeFirebaseFirestore();
    await fakeFirestore.collection('users').doc('user123').set({
      'name': 'Test User',
      'bio': 'This is a test bio',
      'photoURL': '',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ProfilePage(
          userId: 'user123',
          auth: mockAuth,
          firestore: fakeFirestore,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('This is a test bio'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
  });
}
