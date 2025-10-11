import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems_new/features/social/notification_page.dart';

//Followed documentation from https://pub.dev/packages/fake_cloud_firestore and different youtube videos
void main() {
  testWidgets('NotificationPage shows pending friend requests', (
    WidgetTester tester,
  ) async {
    final mockUser = MockUser(uid: 'user123', email: 'test@example.com');
    final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    final fakeFirestore = FakeFirebaseFirestore();

    await fakeFirestore.collection('friend_invites').add({
      'to': 'test@example.com',
      'from': 'testfriend@example.com',
      'status': 'pending',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: NotificationPage(auth: mockAuth, firestore: fakeFirestore),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('testfriend@example.com'), findsOneWidget);
    expect(find.text('Accept'), findsOneWidget);
    expect(find.text('Decline'), findsOneWidget);
  });
}
