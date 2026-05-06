import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unipole_inspection/app_translations.dart';
import 'package:unipole_inspection/otp_screen.dart';
import 'package:unipole_inspection/screens/admin_screens/dashboard.dart';
import 'package:unipole_inspection/screens/admin_screens/inspection_screen.dart';
import 'package:unipole_inspection/screens/inspection_first_screen.dart';
import 'package:unipole_inspection/screens/inspection_screens/multi_step_form.dart';
import 'package:unipole_inspection/screens/inspection_submit_screen.dart';
import 'package:unipole_inspection/signup_screen.dart';
import 'package:unipole_inspection/widgets/video_loader.dart';
import 'auth_service.dart';
import 'binding/admin_inspection_binding.dart';
import 'binding/dashboard_binding.dart';
import 'binding/inspection_binding.dart';
import 'binding/inspection_submit_binding.dart';
import 'binding/multi_form_binding.dart';
import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('lang') ?? 'en';
  final translations = AppTranslations();
  await translations.loadTranslations();
  await dotenv.load(fileName: ".env");

  runApp(MyApp(translations, savedLang));
}

class MyApp extends StatelessWidget {
  final AppTranslations translations;
  final String savedLang;

  const MyApp(this.translations, this.savedLang, {super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Unipole Inspection',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/splashCheckPage',
      locale: Locale(savedLang),
      supportedLocales: [Locale('en'), Locale('ta')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      translations: translations,
      fallbackLocale: const Locale('en', 'US'),
      getPages: [
        GetPage(name: '/splashCheckPage', page: () => SplashCheckPage()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(
          name: '/inspection',
          page: () => InspectionFirstScreen(),
          binding: InspectionBinding(),
        ),
        GetPage(name: '/otp', page: () => OtpScreen()),
        GetPage(name: '/signup', page: () => SignupScreen()),
        GetPage(
          name: '/multiForm',
          page: () => MultiStepForm(),
          binding: MultiFormBinding(),
        ),
        GetPage(
          name: '/submitScreen',
          page: () => InspectionSubmitScreen(),
          binding: InspectionSubmitBinding(),
        ),
        GetPage(
          name: '/adminDashboard',
          page: () => Dashboard(),
          binding: DashboardBinding(),
        ),
        GetPage(
          name: '/adminInspectionScreen',
          page: () => InspectionScreen(),
          binding: AdminInspectionBinding(),
        ),
      ],
    );
  }
}

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

    if (loggedIn) {
      final storage = const FlutterSecureStorage();
      final isAdmin = await storage.read(key: "isAdmin");
      if (isAdmin == "1") {
        Get.offAllNamed('/adminDashboard');
      } else {
        Get.offAllNamed('/inspection');
      }
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: VideoLoader()));
  }
}

Future<void> checkPermissions() async {
  while (true) {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.location,
    ].request();

    final camera = statuses[Permission.camera];
    final mic = statuses[Permission.microphone];
    final location = statuses[Permission.location];

    if (camera!.isGranted && mic!.isGranted && location!.isGranted) {
      break;
    }

    if (camera.isPermanentlyDenied ||
        mic!.isPermanentlyDenied ||
        location!.isPermanentlyDenied) {
      await openAppSettings();

      await Future.delayed(const Duration(seconds: 2));
      continue;
    }

    await Future.delayed(const Duration(seconds: 2));
  }
}
