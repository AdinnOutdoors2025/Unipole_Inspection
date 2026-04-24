import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unipole_inspection/auth_service.dart';
import 'package:video_compress/video_compress.dart';
import '../config/app_config.dart';
import '../helper/snackbar.dart';
import '../model/media_item.dart';
import '../widgets/question_keys.dart';

class MultiFormController extends GetxController {
  var currentStep = 0.obs;
  late List<TextEditingController> controllers;
  var stepCompleted = [false, false, false, false].obs;
  var mediaPerQuestion = <int, RxList<MediaItem>>{}.obs;
  final ImagePicker picker = ImagePicker();
  var yesNoAnswers = <int, bool>{}.obs;
 // var previousAnswers = <int, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    controllers = List.generate(40, (index) => TextEditingController());
  }

  RxList<MediaItem> getMediaList(int questionIndex) {
    return mediaPerQuestion[questionIndex] ?? <MediaItem>[].obs;
  }

  void initMediaIfNeeded(int questionIndex) {
    if (!mediaPerQuestion.containsKey(questionIndex)) {
      mediaPerQuestion[questionIndex] = <MediaItem>[].obs;
    }
  }

  void setAnswer(int index, bool value) async {
    yesNoAnswers[index] = value;
  //  if (previousAnswers[index] == value) return;
   // previousAnswers[index] = value;

    final storage = const FlutterSecureStorage();
    final inspectionId = await storage.read(key: "inspection_id");

    final key = questionKeys[index];

    final mediaList = getMediaList(index);

    final files = mediaList.map((e) => e.file).toList();

    final result = await AuthService().updateInspection(
      inspectionId: inspectionId!,
      key: key,
      status: true,
      files: files,
    );

    if (result["success"]) {
      AppSnackBar.showSuccess(result["message"]);
    } else {
      AppSnackBar.showError(result["message"]);
    }
   /* if (value == true) {
      final mediaList = getMediaList(index);
      final files = mediaList.map((e) => e.file).toList();

      final result = await AuthService().updateInspection(
        inspectionId: inspectionId!,
        key: key,
        status: true,
        files: files,
      );

      handleResult(result);
    } else {
      final result = await AuthService().updateInspection(
        inspectionId: inspectionId!,
        key: key,
        status: false,
        files: [],
      );

      handleResult(result);
    }*/
  }

  bool getAnswer(int index) {
    return yesNoAnswers[index] ?? false;
  }

  void goToStep(int index) {
    if (index <= currentStep.value) {
      currentStep.value = index;
      return;
    }

    if (!stepCompleted[index - 1]) {
      AppSnackBar.showError("Complete previous step first");
      return;
    }

    currentStep.value = index;
  }

  void nextStep(GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      stepCompleted[currentStep.value] = true;

      if (currentStep.value < 3) {
        currentStep.value++;
      }
    }
  }

  void prevStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  Future<void> pickImage(int qIndex) async {
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 90,
    );

    if (photo == null) return;

    File original = File(photo.path);

    File compressed = await compressImage(original);

    getMediaList(qIndex).add(MediaItem(file: compressed, isVideo: false));
    if (yesNoAnswers[qIndex] == true) {
      setAnswer(qIndex, true);
    }
  }

  Future<File> compressImage(File file) async {
    if (!AppConfig.compressImages) {
      return file;
    }

    final dir = file.parent.path;
    final targetPath = "$dir/${DateTime.now().millisecondsSinceEpoch}.jpg";

    // final targetPath = file.path.replaceAll(".jpg", "_compressed.jpg");

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80,
      format: CompressFormat.jpeg,
    );

    if (result == null) return file;
    return File(result.path);
  }

  Future<void> pickVideo(int qIndex) async {
    var list = getMediaList(qIndex);

    int videoCount = list.where((e) => e.isVideo).length;

    if (videoCount >= 3) {
      Get.snackbar("Limit", "Max 3 videos");
      return;
    }

    final XFile? video = await picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(seconds: 30),
    );

    if (video == null) return;

    File original = File(video.path);
    //  show instantly
    list.add(MediaItem(file: original, isVideo: true));
    int index = list.length - 1;

    // compress in background
    compressVideo(original).then((compressed) {
      if (compressed != null) {
        list[index] = MediaItem(file: compressed, isVideo: true);
        list.refresh();
      }
    });
    if (yesNoAnswers[qIndex] == true) {
      setAnswer(qIndex, true);
    }
  }

  Future<File?> compressVideo(File file) async {
    if (!AppConfig.compressVideos) {
      return file;
    }
    final info = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.MediumQuality,
    );
    return info?.file;
  }

  void removeMedia(int qIndex, int index) {
    getMediaList(qIndex).removeAt(index);
  }

  Future<void> retake(int qIndex, int index) async {
    var item = getMediaList(qIndex)[index];

    if (item.isVideo) {
      final XFile? video = await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );

      if (video == null) return;

      File original = File(video.path);

      getMediaList(qIndex)[index] = MediaItem(file: original, isVideo: true);

      compressVideo(original).then((compressed) {
        if (compressed != null) {
          getMediaList(qIndex)[index] = MediaItem(
            file: compressed,
            isVideo: true,
          );
          getMediaList(qIndex).refresh();
        }
      });
    } else {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);

      if (photo == null) return;

      File file = File(photo.path);
      File compressed = await compressImage(file);

      getMediaList(qIndex)[index] = MediaItem(file: compressed, isVideo: false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    /*for (var c in controllers) {
      c.dispose();
    }*/
  }

  void handleResult(Map result) {
    if (result["success"]) {
      AppSnackBar.showSuccess(result["message"]);
    } else {
      AppSnackBar.showError(result["message"]);
    }
  }
}
