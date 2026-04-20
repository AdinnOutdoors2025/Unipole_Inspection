import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:unipole_inspection/screens/inspection_first_screen.dart';
import 'package:unipole_inspection/screens/inspection_screens/multi_step_form.dart';
import 'binding/inspection_binding.dart';
import 'binding/multi_form_binding.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Unipole Inspection',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/inspection',

      getPages: [
        GetPage(
          name: '/inspection',
          page: () => InspectionFirstScreen(),
          binding: InspectionBinding(),
        ),
        GetPage(
          name: '/multiForm',
          page: () => MultiStepForm(),
          binding: MultiFormBinding(),
        ),
      ],
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
