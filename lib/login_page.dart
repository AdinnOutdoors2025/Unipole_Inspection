import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unipole_inspection/signup_screen.dart';

import 'auth_service.dart';
import 'main.dart';

const Color _bgColor = Color(0xFFF6F6F8);
const Color _headerColor = _bgColor;
const Color _red1 = Color(0xFFFF2A2A);
const Color _red2 = Color(0xFFD71920);
const Color _red3 = Color(0xFFB80F16);
const Color _textBlack = Color(0xFF15151E);
const Color _subText = Color(0xFF5F616B);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // static const String _loginUrl = 'http://192.168.0.111:5000/api/auth/login';

  // Android emulator use panna:
  // http://10.0.2.2:5000/api/auth/login
  // Real mobile device use panna:
  // http://YOUR_PC_IP:5000/api/auth/login

  final _formKey = GlobalKey<FormState>();
  final _employeeIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _employeeFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _showPassword = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();


    Future.delayed(const Duration(seconds: 3), () {
      checkPermissions();
    });
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _passwordController.dispose();
    _employeeFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await AuthService().login(
        employeeId: _employeeIdController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final bool success = response['success'] == true;
      final String message = response['message'] ?? "Something went wrong";
      if (!mounted) return;
      if (success) {
        final data = response['data'] as Map<String, dynamic>?;
        final user = response["data"]["user"];

        // Get.offAllNamed('/inspection');
        if (user["isAdmin"] == 1) {
          Get.offAllNamed('/adminDashboard');
        } else {
          Get.offAllNamed('/inspection');
        }
      } else {
        setState(() {
          _errorMessage = message;
        });
      }
    } on http.ClientException {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to connect to server';
      });
    } on FormatException {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Invalid server response';
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Something went wrong";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSignupTap() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = Get.locale?.languageCode;
    final isTamil = Get.locale?.languageCode == 'ta';
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: _bgColor,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final media = MediaQuery.of(context);
                final h = constraints.maxHeight;
                final w = constraints.maxWidth;
                final bottomInset = media.viewInsets.bottom;
                final isKeyboardOpen = bottomInset > 0;

                final isVerySmall = h < 670;
                final isSmall = h < 760;

                final horizontalPadding = w * 0.075;
                final headerHeight = isVerySmall ? 86.0 : 96.0;
                final logoHeight = isVerySmall ? 42.0 : 50.0;

                final pinSize = isVerySmall ? 40.0 : 44.0;
                final titleFont = isVerySmall ? 16.0 : 18.0;
                final welcomeFont = isVerySmall ? 28.0 : 33.0;
                final subtitleFont = isVerySmall ? 13.0 : 15.0;

                final heroHeight = isVerySmall
                    ? 140.0
                    : (isSmall ? 168.0 : 210.0);
                final fieldHeight = isVerySmall ? 48.0 : 54.0;
                final buttonHeight = isVerySmall ? 50.0 : 56.0;

                final gapAfterHeader = isVerySmall ? 8.0 : 12.0;
                final gap1 = isVerySmall ? 12.0 : 16.0;
                final gap2 = isVerySmall ? 6.0 : 8.0;
                final gap3 = isVerySmall ? 8.0 : 12.0;
                final gap4 = isVerySmall ? 10.0 : 14.0;
                final gap5 = isVerySmall ? 8.0 : 10.0;
                final gap6 = isVerySmall ? 12.0 : 16.0;
                final gap7 = isVerySmall ? 10.0 : 14.0;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString('lang', 'ta');
                                    Get.updateLocale(const Locale('ta', 'IN'));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: currentLang == 'ta'
                                          ? Colors.red
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "தமிழ்",
                                      style: TextStyle(
                                        color: currentLang == 'ta'
                                            ? Colors.white
                                            : Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 2),

                                GestureDetector(
                                  onTap: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString('lang', 'en');
                                    Get.updateLocale(const Locale('en', 'US'));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: currentLang == 'en'
                                          ? Colors.red
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "English",
                                      style: TextStyle(
                                        color: currentLang == 'en'
                                            ? Colors.white
                                            : Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: _SimpleHeader(
                              height: headerHeight,
                              horizontalPadding: horizontalPadding,
                              logoHeight: logoHeight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, bodyConstraints) {
                          return SingleChildScrollView(
                            physics: isKeyboardOpen
                                ? const ClampingScrollPhysics()
                                : const NeverScrollableScrollPhysics(),
                            keyboardDismissBehavior: isKeyboardOpen
                                ? ScrollViewKeyboardDismissBehavior.onDrag
                                : ScrollViewKeyboardDismissBehavior.manual,
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              gapAfterHeader,
                              horizontalPadding,
                              16 + bottomInset,
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight:
                                    bodyConstraints.maxHeight - gapAfterHeader,
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InspectionPinIcon(size: pinSize),
                                          const SizedBox(width: 10),
                                          Flexible(
                                            child: Text(
                                              'Unipole Inspection',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: _textBlack,
                                                fontSize: titleFont,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: gap1),
                                    Text(
                                      "welcome_back".tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _textBlack,
                                        fontSize: /*welcomeFont*/ isTamil
                                            ? 25
                                            : 35,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    SizedBox(height: gap2),
                                    SizedBox(height: gap3),
                                    _UnipoleHero(height: heroHeight),
                                    SizedBox(height: gap4),
                                    _CompactTextField(
                                      controller: _employeeIdController,
                                      focusNode: _employeeFocusNode,
                                      hintText: 'employee_number'.tr,
                                      hintTextSize: isTamil ? 13 : 15,
                                      prefixIcon: Icons.person,
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      height: fieldHeight,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(10),
                                      ],
                                      onFieldSubmitted: (_) {
                                        FocusScope.of(
                                          context,
                                        ).requestFocus(_passwordFocusNode);
                                      },
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'phone_number_login_validation'
                                              .tr;
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: gap5),
                                    _CompactTextField(
                                      controller: _passwordController,
                                      focusNode: _passwordFocusNode,
                                      hintText: 'password_hintText'.tr,
                                      prefixIcon: Icons.lock,
                                      hintTextSize: isTamil ? 13 : 15,
                                      obscureText: !_showPassword,
                                      textInputAction: TextInputAction.done,
                                      height: fieldHeight,
                                      onFieldSubmitted: (_) => _handleLogin(),
                                      suffix: InkWell(
                                        borderRadius: BorderRadius.circular(30),
                                        onTap: () {
                                          setState(() {
                                            _showPassword = !_showPassword;
                                          });
                                        },
                                        child: Icon(
                                          _showPassword
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                          color: _red2,
                                          size: 28,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'password_login_validation'.tr;
                                        }
                                        return null;
                                      },
                                    ),
                                    if (_errorMessage != null) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        _errorMessage!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: _red2,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                    SizedBox(height: gap6),
                                    SizedBox(
                                      width: double.infinity,
                                      height: buttonHeight,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            34,
                                          ),
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [_red1, _red2, _red3],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _red2.withOpacity(0.24),
                                              blurRadius: 14,
                                              offset: const Offset(0, 7),
                                            ),
                                            const BoxShadow(
                                              color: Color(0xFF8B0B11),
                                              blurRadius: 0,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : _handleLogin,
                                          style:
                                              ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                disabledBackgroundColor:
                                                    Colors.transparent,
                                                surfaceTintColor:
                                                    Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(34),
                                                ),
                                              ).copyWith(
                                                overlayColor:
                                                    MaterialStateProperty.all(
                                                      Colors.white.withOpacity(
                                                        0.5,
                                                      ),
                                                    ),
                                              ),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  height: 24,
                                                  width: 24,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2.6,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                )
                                              : Text(
                                                  'login_button'.tr,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: isTamil ? 15 : 16,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: gap7),
                                    Center(
                                      child: GestureDetector(
                                        onTap: _onSignupTap,
                                        child: RichText(
                                          text: TextSpan(
                                            text: "do_not_have_account".tr,
                                            style: TextStyle(
                                              color: _subText,
                                              fontSize: isTamil ? 14 : 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'sign_up_button'.tr,
                                                style: TextStyle(
                                                  color: _red2,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SimpleHeader extends StatelessWidget {
  const _SimpleHeader({
    required this.height,
    required this.horizontalPadding,
    required this.logoHeight,
  });

  final double height;
  final double horizontalPadding;
  final double logoHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: _headerColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Align(
          alignment: Alignment.centerRight,
          child: Image.asset(
            'assets/images/adinn_logo.png',
            height: logoHeight,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class InspectionPinIcon extends StatelessWidget {
  const InspectionPinIcon({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.location_on_rounded, size: size, color: _red2),
          Positioned(
            top: size * 0.20,
            child: Container(
              width: size * 0.20,
              height: size * 0.20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: size * 0.38,
            child: Container(
              width: size * 0.11,
              height: size * 0.24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Positioned(
            top: size * 0.54,
            child: Container(
              width: size * 0.28,
              height: size * 0.05,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnipoleHero extends StatelessWidget {
  const _UnipoleHero({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final size = height;

    return SizedBox(
      height: size,
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: ClipOval(
            child: Transform.translate(
              offset: Offset(0, size * 0.10),
              child: Transform.scale(
                scale: 1.34,
                child: SizedBox.expand(
                  child: Image.asset(
                    'assets/images/unipole_logo.jpeg',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final IconData prefixIcon;
  final String? Function(String?) validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffix;
  final double height;
  final double? hintTextSize;
  final List<TextInputFormatter>? inputFormatters;

  const _CompactTextField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.prefixIcon,
    required this.validator,
    required this.height,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.suffix,
    this.hintTextSize,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      textAlignVertical: TextAlignVertical.center,
      validator: validator,
      style: const TextStyle(
        color: Color(0xFF202129),
        fontSize: 17,
        fontWeight: FontWeight.w500,
      ),
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: const Color(0xFF6A6C76),
          fontSize: hintTextSize,
          fontWeight: FontWeight.w500,
        ),
        errorStyle: const TextStyle(
          fontSize: 12,
          color: Color(0xFFD71920),
          height: 1.15,
        ),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF202129), size: 29),
        suffixIcon: suffix == null
            ? null
            : Padding(padding: const EdgeInsets.only(right: 16), child: suffix),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        filled: true,
        fillColor: const Color(0xFFFDFDFF),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: (height - 24) / 2,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFFE3E3E8), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: _red2, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: _red2, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: _red2, width: 1.4),
        ),
      ),
    );
  }
}

class LoginSuccessPage extends StatelessWidget {
  const LoginSuccessPage({super.key, required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _textBlack),
        title: const Text(
          'Home',
          style: TextStyle(color: _textBlack, fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: Text(
          'Welcome, $userName',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: _textBlack,
          ),
        ),
      ),
    );
  }
}
