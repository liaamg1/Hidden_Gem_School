import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gems_new/services/firebase_options.dart';
import 'package:hidden_gems_new/features/home/home_page.dart';
import 'package:hidden_gems_new/features/auth/login_page.dart';
import 'package:hidden_gems_new/features/gems/map_page.dart';
import 'package:hidden_gems_new/features/profile/profile_page.dart';
import 'package:hidden_gems_new/features/profile/setting_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hidden_gems_new/features/gems/upload_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load();
  } catch (e) {
    debugPrint("Failed to load .env file: $e");
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hidden Gem',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Widget> pages;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    final String userID = FirebaseAuth.instance.currentUser!.uid;
    pages = [
      //Const for stateless, not const for stateful
      const HomePage(),
      MapPage(),
      UploadPage(),
      ProfilePage(userId: userID),
      SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentPage],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentPage,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentPage = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map_sharp), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Upload"),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
