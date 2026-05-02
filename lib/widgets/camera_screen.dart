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
  CameraController? controller;
  List<CameraDescription> cameras = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    cameras = await availableCameras();

    currentIndex = cameras.indexWhere(
      (cam) => cam.lensDirection == widget.camera.lensDirection,
    );

    if (currentIndex == -1) currentIndex = 0;

    await initCamera(cameras[currentIndex]);
  }

  Future<void> initCamera(CameraDescription cam) async {
    final newController = CameraController(cam, ResolutionPreset.medium);
    await newController.initialize();
    if (!mounted) return;

    setState(() {
      controller = newController;
    });
  }

  Future<void> switchCamera() async {
    if (cameras.isEmpty) return;
    currentIndex = (currentIndex + 1) % cameras.length;

    await controller?.dispose();
    await initCamera(cameras[currentIndex]);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: CameraPreview(controller!)),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
              onPressed: switchCamera,
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  if (controller == null || !controller!.value.isInitialized) return;
                  final file = await controller?.takePicture();
                  Get.back(result: File(file!.path));
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
