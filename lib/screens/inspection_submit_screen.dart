import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import '../controller/multi_form_controller.dart';

class InspectionSubmitScreen extends StatefulWidget {
  const InspectionSubmitScreen({super.key});

  @override
  State<InspectionSubmitScreen> createState() => _InspectionSubmitScreenState();
}

class _InspectionSubmitScreenState extends State<InspectionSubmitScreen> {
  final MultiFormController c = Get.find();

  File? selfie;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.arrow_back),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/images/adinn_logo.png',
                    height: 40,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              "final_step".tr,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "selfie_to_complete".tr,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
                Icon(Icons.photo_camera_rounded, size: 20),
              ],
            ),

            const SizedBox(height: 30),

            Expanded(
              child: Center(
                child: selfie == null
                    ? GestureDetector(
                        onTap: () async {
                          final file = await c.openSelfieCamera();
                          if (file != null) {
                            setState(() {
                              selfie = file;
                            });
                          }
                        },
                        child: Container(
                          width: 200,
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person, size: 70),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          selfie!,
                          width: 200,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final file = await c.openSelfieCamera();
                      if (file != null) {
                        setState(() {
                          selfie = file;
                        });
                      }
                    },
                    style:
                        ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade400,
                        ).copyWith(
                          overlayColor: MaterialStateProperty.all(
                            Colors.white.withOpacity(0.5),
                          ),
                        ),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      selfie == null ? "take_selfie".tr : "retake".tr,
                      style: TextStyle(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Obx(() {
                    return ElevatedButton(
                      onPressed: (selfie == null || c.isSubmitting.value)
                          ? null
                          : () {
                              c.submitInspection(selfie!);
                            },
                      style:
                          ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade400,
                          ).copyWith(
                            overlayColor: MaterialStateProperty.all(
                              Colors.white.withOpacity(0.5),
                            ),
                          ),
                      child: c.isSubmitting.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text("submit_inspection".tr),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
