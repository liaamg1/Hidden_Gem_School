import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:hidden_gems_new/features/gems/saved_gems_page.dart';
import 'package:network_image_mock/network_image_mock.dart';

//Followed documentation from https://pub.dev/packages/fake_cloud_firestore and different youtube videos
//Also https://pub.dev/packages/network_image_mock and https://pub.dev/packages/firebase_auth_mocks

void main() {
  testWidgets('Saved Gems shows correct data', (WidgetTester tester) async {
    final mockUser = MockUser(uid: 'test123', displayName: 'testing');
    final mockAuth = MockFirebaseAuth(mockUser: mockUser);
    final fakeFirestore = FakeFirebaseFirestore();

    await fakeFirestore
        .collection('users')
        .doc('test123')
        .collection('posts')
        .add({
          'title': 'testingTheTitle',
          'description': 'testingTheDescription',
          'location': {'latitude': 56.162939, 'longitude': 15.586994},
          'private': false,
          'photoURL': ['https://example.com/image.png'],
          'createdAt': '',
        });
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: SavedGemsPage(
            userId: 'test123',
            auth: mockAuth,
            firestore: fakeFirestore,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('testingTheTitle'), findsOneWidget);
      expect(find.text('testingTheDescription'), findsOneWidget);
      expect(find.text("View on Map"), findsOneWidget);

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });
  });
}
