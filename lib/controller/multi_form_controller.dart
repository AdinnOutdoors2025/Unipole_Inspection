import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unipole_inspection/auth_service.dart';
import 'package:unipole_inspection/model/inspection_model.dart';
import 'package:video_compress/video_compress.dart';
import '../config/app_config.dart';
import '../helper/snackbar.dart';
import '../model/media_item.dart';
import '../widgets/camera_screen.dart';
import '../widgets/question_keys.dart';

class MultiFormController extends GetxController {
  var currentStep = 0.obs;
  late List<TextEditingController> controllers;
  var stepCompleted = [false, false, false, false].obs;
  var mediaPerQuestion = <int, RxList<MediaItem>>{}.obs;
  final ImagePicker picker = ImagePicker();
  var yesNoAnswers = <int, bool>{}.obs;
  var isInspectionLoaded = false.obs;
  var isExistingInspection = false.obs;
  var isPrefilling = false;

  @override
  void onInit() {
    super.onInit();
    controllers = List.generate(40, (index) => TextEditingController());
    loadInspectionData();
  }

  RxList<MediaItem> getMediaList(int questionIndex) {
    initMediaIfNeeded(questionIndex);
    return mediaPerQuestion[questionIndex]!;
  }

  void initMediaIfNeeded(int questionIndex) {
    if (!mediaPerQuestion.containsKey(questionIndex)) {
      mediaPerQuestion[questionIndex] = <MediaItem>[].obs;
    }
  }

  Future<Map<String, dynamic>> submitAnswer(int index) async {
    final storage = const FlutterSecureStorage();
    final inspectionId = await storage.read(key: "inspection_id");
    if (inspectionId == null) {
      return {"success": false, "message": "No inspection ID"};
    }

    final key = questionKeys[index];
    final mediaList = getMediaList(index);

    final files = mediaList
        .where((e) => e.file != null)
        .map((e) => e.file!)
        .toList();

    final status = yesNoAnswers[index] ?? false;

    if (status == true && files.isEmpty) {
      return {"success": false, "message": "No files to upload"};
    }

    final result = await AuthService().updateInspection(
      inspectionId: inspectionId,
      key: key,
      status: status,
      files: files,
    );

    handleResult(result);
    return result;
  }

  bool getAnswer(int index) {
    return yesNoAnswers[index] ?? false;
  }

  void setAnswerLocal(int index, bool value) {
    yesNoAnswers[index] = value;
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
      //  setAnswer(qIndex, true);
      submitAnswer(qIndex);
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
    list.add(MediaItem(file: original, isVideo: true));
    int index = list.length - 1;
    list.refresh();

    /* // compress in background
    compressVideo(original).then((compressed) {
      if (compressed != null) {
        list[index] = MediaItem(file: compressed, isVideo: true);
        list.refresh();
      }
    });
    if (yesNoAnswers[qIndex] == true) {
      submitAnswer(qIndex);
    }*/
    final compressed = await compressVideo(original);

    if (compressed != null) {
      list[index] = MediaItem(
        file: compressed,
        isVideo: true,
        isLoading: false,
      );
      list.refresh();
    }

    if (yesNoAnswers[qIndex] == true) {
      await submitAnswer(qIndex);
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

  Future<void> removeMedia(int qIndex, int index) async {
    final list = getMediaList(qIndex);
    final item = list[index];

    list.removeAt(index);

    if (item.url != null && item.url!.isNotEmpty) {
      await deleteMedia(item.url!);
    }
  }

  Future<void> deleteMedia(String url) async {
    final storage = const FlutterSecureStorage();
    final inspectionId = await storage.read(key: "inspection_id");

    if (inspectionId == null) return;

    final result = await AuthService().deleteInspectionMedia(
      inspectionId: inspectionId,
      url: url,
    );

    handleResult(result);
  }

  Future<void> retake(int qIndex, int index) async {
    final list = getMediaList(qIndex);
    final oldItem = list[index];

    list[index] = MediaItem(
      file: oldItem.file,
      url: oldItem.url,
      isVideo: oldItem.isVideo,
      isLoading: true,
    );
    list.refresh();

    File? newFile;

    if (oldItem.isVideo) {
      final XFile? video = await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );
      if (video == null) {
        list[index] = oldItem;
        list.refresh();
        return;
      }

      File original = File(video.path);
      list[index] = MediaItem(file: original, isVideo: true, isLoading: true);
      list.refresh();

      newFile = await compressVideo(original);
    } else {
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo == null) {
        list[index] = oldItem;
        list.refresh();
        return;
      }

      File file = File(photo.path);
      list[index] = MediaItem(file: file, isVideo: false, isLoading: true);
      list.refresh();

      newFile = await compressImage(file);
    }

    if (newFile != null) {
      list[index] = MediaItem(
        file: newFile,
        isVideo: oldItem.isVideo,
        isLoading: true,
      );
      list.refresh();
    }

    if (oldItem.url != null) {
      await deleteMedia(oldItem.url!);
    }

    if (yesNoAnswers[qIndex] == true) {
      await submitAnswer(qIndex);
    }

    await loadInspectionData();
  }

  final AuthService apiService = AuthService();

  Future<void> loadInspectionData() async {
    isPrefilling = true;
    final res = await apiService.getInspection();

    if (res.success && res.data != null) {
      final data = res.data;

      isInspectionLoaded.value = true;
      isExistingInspection.value = true;

      final foundation = data.foundation;
      _prefillFoundation(foundation);

      final post = data.post;
      _prefillPost(post);

      final adBoard = data.adBoardFrame;
      _prefillAdBoard(adBoard);

      final generalInspection = data.generalInspection;
      _prefillGeneral(generalInspection);
    } else {
      isInspectionLoaded.value = true;
      isExistingInspection.value = false;
    }
    isPrefilling = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handleResult(Map result) {
    if (result["success"]) {
      AppSnackBar.showSuccess(result["message"]);
    } else {
      AppSnackBar.showError(result["message"]);
    }
  }

  void _prefillFoundation(Foundation f) {
    int base = 0;
    setAnswerLocal(base + 0, f.concreteCracks.status);
    setAnswerLocal(base + 1, f.soilErosionAtFoundation.status);
    setAnswerLocal(base + 2, f.waterStagnation.status);
    setAnswerLocal(base + 3, f.anchorBoltLooseness.status);
    setAnswerLocal(base + 4, f.anchorBoltsRusted.status);
    setAnswerLocal(base + 5, f.basePlateProperlySeated.status);
    setAnswerLocal(base + 6, f.gapInBasePlate.status);
    setAnswerLocal(base + 7, f.groutingDamaged.status);
    setAnswerLocal(base + 8, f.foundationTilted.status);
    setAnswerLocal(base + 9, f.foundationSettlementOccurred.status);
    setAnswerLocal(base + 10, f.surroundingSoilLoose.status);

    // images
    _setImages(base + 0, f.concreteCracks.images);
    _setImages(base + 1, f.soilErosionAtFoundation.images);
    _setImages(base + 2, f.waterStagnation.images);
    _setImages(base + 3, f.anchorBoltLooseness.images);
    _setImages(base + 4, f.anchorBoltsRusted.images);
    _setImages(base + 5, f.basePlateProperlySeated.images);
    _setImages(base + 6, f.gapInBasePlate.images);
    _setImages(base + 7, f.groutingDamaged.images);
    _setImages(base + 8, f.foundationTilted.images);
    _setImages(base + 9, f.foundationSettlementOccurred.images);
    _setImages(base + 10, f.surroundingSoilLoose.images);
  }

  void _setImages(int index, List<String> urls) {
    initMediaIfNeeded(index);
    final list = getMediaList(index);

    list.clear();

    for (var url in urls) {
      final isVideo = url.toLowerCase().endsWith(".mp4");

      list.add(MediaItem(url: url, isVideo: isVideo));
    }
  }

  void _prefillPost(Post p) {
    int base = 11;
    setAnswerLocal(base + 0, p.postStraight.status);
    setAnswerLocal(base + 1, p.postTilted.status);
    setAnswerLocal(base + 2, p.bendInPost.status);
    setAnswerLocal(base + 3, p.crackInWeldedJoint.status);
    setAnswerLocal(base + 4, p.damageInWeldedJoint.status);
    setAnswerLocal(base + 5, p.rustPresent.status);
    setAnswerLocal(base + 6, p.paintPeeledOff.status);
    setAnswerLocal(base + 7, p.postThicknessReduced.status);
    setAnswerLocal(base + 8, p.spliceBoltsTight.status);
    setAnswerLocal(base + 9, p.spliceNutsLooseness.status);
    setAnswerLocal(base + 10, p.ladderSecure.status);
    setAnswerLocal(base + 11, p.platformStrong.status);

    // images
    _setImages(base + 0, p.postStraight.images);
    _setImages(base + 1, p.postTilted.images);
    _setImages(base + 2, p.bendInPost.images);
    _setImages(base + 3, p.crackInWeldedJoint.images);
    _setImages(base + 4, p.damageInWeldedJoint.images);
    _setImages(base + 5, p.rustPresent.images);
    _setImages(base + 6, p.paintPeeledOff.images);
    _setImages(base + 7, p.postThicknessReduced.images);
    _setImages(base + 8, p.spliceBoltsTight.images);
    _setImages(base + 9, p.spliceNutsLooseness.images);
    _setImages(base + 10, p.ladderSecure.images);
    _setImages(base + 11, p.platformStrong.images);
  }

  void _prefillAdBoard(AdBoardFrame adBoard) {
    int base = 23;
    setAnswerLocal(base + 0, adBoard.waterRunoffOrSeepageOnStructure.status);
    setAnswerLocal(base + 1, adBoard.bendInFrame.status);
    setAnswerLocal(base + 2, adBoard.anglePipeMembersStrong.status);
    setAnswerLocal(base + 3, adBoard.weldedJointsStrong.status);
    setAnswerLocal(base + 4, adBoard.flexProperlyFixed.status);
    setAnswerLocal(base + 5, adBoard.flexLoose.status);
    setAnswerLocal(base + 6, adBoard.clampsTight.status);
    setAnswerLocal(base + 7, adBoard.supportFastenersLooseness.status);
    setAnswerLocal(base + 8, adBoard.vibrationDueToWind.status);
    setAnswerLocal(base + 9, adBoard.waterRunoffOrSeepageOnStructure.status);

    // images
    _setImages(base + 0, adBoard.waterRunoffOrSeepageOnStructure.images);
    _setImages(base + 1, adBoard.bendInFrame.images);
    _setImages(base + 2, adBoard.anglePipeMembersStrong.images);
    _setImages(base + 3, adBoard.weldedJointsStrong.images);
    _setImages(base + 4, adBoard.flexProperlyFixed.images);
    _setImages(base + 5, adBoard.flexLoose.images);
    _setImages(base + 6, adBoard.clampsTight.images);
    _setImages(base + 7, adBoard.supportFastenersLooseness.images);
    _setImages(base + 8, adBoard.vibrationDueToWind.images);
    _setImages(base + 9, adBoard.waterRunoffOrSeepageOnStructure.images);
  }

  void _prefillGeneral(GeneralInspection generalInspection) {
    int base = 33;
    setAnswerLocal(base + 0, generalInspection.surroundingAreaSafe.status);
    setAnswerLocal(
      base + 1,
      generalInspection.nearbyTreesTouchingStructure.status,
    );
    setAnswerLocal(base + 2, generalInspection.obstructionsPresent.status);
    setAnswerLocal(base + 3, generalInspection.windDamage.status);
    setAnswerLocal(base + 4, generalInspection.rainDamage.status);
    setAnswerLocal(
      base + 5,
      generalInspection.unauthorizedModifications.status,
    );
    setAnswerLocal(
      base + 6,
      generalInspection.repairsCarriedOutProperly.status,
    );

    // images
    _setImages(base + 0, generalInspection.surroundingAreaSafe.images);
    _setImages(base + 1, generalInspection.nearbyTreesTouchingStructure.images);
    _setImages(base + 2, generalInspection.obstructionsPresent.images);
    _setImages(base + 3, generalInspection.windDamage.images);
    _setImages(base + 4, generalInspection.rainDamage.images);
    _setImages(base + 5, generalInspection.unauthorizedModifications.images);
    _setImages(base + 6, generalInspection.repairsCarriedOutProperly.images);
  }

  Future<void> openSelfieCameraAndSubmit() async {
    final cameras = await availableCameras();

    CameraDescription? frontCamera;

    for (var cam in cameras) {
      if (cam.lensDirection == CameraLensDirection.front) {
        frontCamera = cam;
        break;
      }
    }

    // fallback to back camera if no front
    final selectedCamera = frontCamera ?? cameras.first;

    final imageFile = await Get.to(() => CameraScreen(camera: selectedCamera));

    if (imageFile != null) {
      await submitInspection(imageFile);
    }
  }

  Future<void> submitInspection(File image) async {
    final storage = const FlutterSecureStorage();
    final inspectionId = await storage.read(key: "inspection_id");

    if (inspectionId == null) return;

    final result = await AuthService().submitInspection(
      inspectionId: inspectionId,
      file: image,
    );

    handleResult(result);
    if (result["success"] == true) {
      Get.offAllNamed('/inspection');
    }
  }
}
