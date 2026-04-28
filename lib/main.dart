import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:unipole_inspection/app_translations.dart';
import 'package:unipole_inspection/otp_screen.dart';
import 'package:unipole_inspection/screens/inspection_first_screen.dart';
import 'package:unipole_inspection/screens/inspection_screens/multi_step_form.dart';
import 'package:unipole_inspection/screens/inspection_submit_screen.dart';
import 'package:unipole_inspection/signup_screen.dart';
import 'auth_service.dart';
import 'binding/inspection_binding.dart';
import 'binding/multi_form_binding.dart';
import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final translations = AppTranslations();
  await translations.loadTranslations();
  await dotenv.load(fileName: ".env");
  runApp(MyApp(translations));
}

class MyApp extends StatelessWidget {
  final AppTranslations translations;

  const MyApp(this.translations, {super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Unipole Inspection',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/splashCheckPage',
      locale: const Locale('en', 'US'),
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
        GetPage(name: '/submitScreen', page: () => InspectionSubmitScreen()),
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
      Get.offAllNamed('/inspection');
    } else {
      Get.toNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
