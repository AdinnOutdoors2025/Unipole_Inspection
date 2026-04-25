import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  List<CameraDescription> cameras = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    initCamera(widget.camera);
  }

  Future<void> initCamera(CameraDescription cam) async {
    controller = CameraController(cam, ResolutionPreset.medium);
    await controller.initialize();
    setState(() {});
  }

  Future<void> switchCamera() async {
    cameras = await availableCameras();

    currentIndex = (currentIndex + 1) % cameras.length;

    await controller.dispose();
    await initCamera(cameras[currentIndex]);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(controller),

          /// 🔁 Flip button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
              onPressed: switchCamera,
            ),
          ),

          /// 📸 Capture button
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  final file = await controller.takePicture();
                  Get.back(result: File(file.path));
                },
                child: const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
