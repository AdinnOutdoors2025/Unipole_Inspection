import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unipole_inspection/controller/signup_controller.dart';
import 'package:unipole_inspection/helper/validator.dart';
import 'package:unipole_inspection/widgets/custom_text_field.dart';
import 'auth_service.dart';
import 'helper/snackbar.dart';
import 'login_page.dart';
import 'otp_screen.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final formKey = GlobalKey<FormState>();
  final SignupController controller = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    hintText: "Enter name",
                    height: 10,
                    prefixIcon: Icons.person,
                    validator: (value) => Validator.validate(value, "Name"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: CustomTextField(
                    controller: controller.phoneController,
                    hintText: "Enter phone number",
                    validator: (value) =>
                        Validator.validate(value, "phone number"),
                    height: 14,
                    prefixIcon: Icons.phone,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Obx(
                    () => CustomTextField(
                      controller: controller.passwordController,
                      hintText: "Enter password",
                      height: 14,
                      obscureText: !controller.showPassword.value,
                      prefixIcon: Icons.lock,
                      validator: (value) =>
                          Validator.validate(value, "password"),
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
                      hintText: "Enter confirm password",
                      height: 14,
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
                ElevatedButton(
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
                        AppSnackBar.showSuccess(response['message']);
                        print("success: response['message']");

                        Get.toNamed(
                          '/otp',
                          arguments: {
                            "phone": controller.phoneController.text,
                            "otp": data['otp'],
                          },
                        );
                      } else {
                        AppSnackBar.showError(response['message']);
                        print("error: response['message']");
                      }
                    } catch (e) {
                      AppSnackBar.showError("Unexpected error occurred");
                    }
                  },
                  child: Text("Sign Up"),
                ),
                SizedBox(height: 40),
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
                        text: "Already have an account? ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              color: Colors.blue,
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
