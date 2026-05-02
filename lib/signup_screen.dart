import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:unipole_inspection/controller/signup_controller.dart';
import 'package:unipole_inspection/helper/validator.dart';
import 'package:unipole_inspection/widgets/custom_text_field.dart';
import 'auth_service.dart';
import 'helper/snackbar.dart';
import 'login_page.dart';
import 'otp_screen.dart';

const Color _red1 = Color(0xFFFF2A2A);
const Color _red2 = Color(0xFFD71920);
const Color _red3 = Color(0xFFB80F16);

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final formKey = GlobalKey<FormState>();
  final SignupController controller = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
    final currentLang = Get.locale?.languageCode;
    final isTamil = Get.locale?.languageCode == 'ta';
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Icon(Icons.arrow_back),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Image.asset(
                          'assets/images/adinn_logo.png',
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 60),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InspectionPinIcon(size: 40),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Unipole Inspection',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: CustomTextField(
                    controller: controller.nameController,
                    hintText: "enter_name_hintText".tr,
                    height: 10,
                    hintTextSize: isTamil ? 13 : 15,
                    prefixIcon: Icons.person,
                    validator: (value) =>
                        Validator.validate(value, "name_validation"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: CustomTextField(
                    controller: controller.phoneController,
                    hintText: "employee_number".tr,
                    validator: (value) =>
                        Validator.validate(value, "phone_number_validation"),
                    height: 14,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    keyboardType: TextInputType.number,
                    hintTextSize: isTamil ? 13 : 15,
                    prefixIcon: Icons.phone,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Obx(
                    () => CustomTextField(
                      controller: controller.passwordController,
                      hintText: "enter_password_hintText".tr,
                      height: 14,
                      obscureText: !controller.showPassword.value,
                      prefixIcon: Icons.lock,
                      hintTextSize: isTamil ? 13 : 15,
                      validator: (value) =>
                          Validator.validate(value, "password_validation"),
                      suffix: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          controller.showPassword.value =
                              !controller.showPassword.value;
                        },
                        child: Icon(
                          controller.showPassword.value
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: Colors.black,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Obx(
                    () => CustomTextField(
                      controller: controller.confirmPasswordController,
                      hintText: "enter_confirm_password_hintText".tr,
                      height: 14,
                      hintTextSize: isTamil ? 13 : 15,
                      obscureText: !controller.showConfirmPassword.value,
                      prefixIcon: Icons.lock,
                      validator: (value) => Validator.confirmPassword(
                        value,
                        controller.passwordController.text,
                      ),
                      suffix: InkWell(
                        onTap: () {
                          controller.showConfirmPassword.value =
                              !controller.showConfirmPassword.value;
                        },
                        child: Icon(
                          controller.showConfirmPassword.value
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                SizedBox(
                  width: 250,
                  height: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34),
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
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        try {
                          final response = await AuthService().signUp(
                            name: controller.nameController.text.trim(),
                            phoneNumber: controller.phoneController.text.trim(),
                            password: controller.passwordController.text.trim(),
                          );

                          if (response['success'] == true) {
                            final data = response['data'];
                            AppToast.showSuccess(response['message']);
                            if (kDebugMode) {
                              print("success: response['message']");
                            }

                            Get.toNamed(
                              '/otp',
                              arguments: {
                                "phone": controller.phoneController.text,
                                "otp": data['otp'],
                              },
                            );
                          } else {
                            AppToast.showError(response['message']);
                            if (kDebugMode) {
                              print("error: response['message']");
                            }
                          }
                        } catch (e) {
                          AppToast.showError("Unexpected error occurred");
                        }
                      },
                      style:
                          ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(34),
                            ),
                          ).copyWith(
                            overlayColor: MaterialStateProperty.all(
                              Colors.white.withOpacity(0.5),
                            ),
                          ),
                      child: Text(
                        "sign_up_button".tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTamil ? 15 : 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "already_have_an_account".tr,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: isTamil ? 14 : 16,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: 'login_button'.tr,
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
