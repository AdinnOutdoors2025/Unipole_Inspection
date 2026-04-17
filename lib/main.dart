import 'package:flutter/material.dart';
import 'package:unipole_inspection/screens/home_page.dart';
import 'auth_service.dart';
import 'login_page.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Unipole Inspection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: /*const SplashCheckPage(),*/
      InspectionScreen(),
    );
  }
}

/*
class SplashCheckPage extends StatefulWidget {
  const SplashCheckPage({super.key});

  @override
  State<SplashCheckPage> createState() => _SplashCheckPageState();
}

class _SplashCheckPageState extends State<SplashCheckPage> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final loggedIn = await _authService.isLoggedIn();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => loggedIn ? const HomePage() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}*/
