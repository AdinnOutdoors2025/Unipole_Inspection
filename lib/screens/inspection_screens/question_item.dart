import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unipole_inspection/widgets/video_preview.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import '../../config/app_config.dart';
import '../../controller/multi_form_controller.dart';

class QuestionItem extends StatefulWidget {
  final String question;
  final TextEditingController controller;
  final int widgetIndex;

  const QuestionItem({
    super.key,
    required this.question,
    required this.controller,
    required this.widgetIndex,
  });

  @override
  State<QuestionItem> createState() => _QuestionItemState();
}

class _QuestionItemState extends State<QuestionItem> {
  @override
  void initState() {
    super.initState();
    c.initMediaIfNeeded(widget.widgetIndex);
  }

  final MultiFormController c = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final isYesSelected = c.getAnswer(widget.widgetIndex);
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.question,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        c.setAnswerLocal(widget.widgetIndex, true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isYesSelected
                              ? Colors.green
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          "yes".tr,
                          style: TextStyle(
                            color: isYesSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        c.setAnswerLocal(widget.widgetIndex, false);
                        widget.controller.clear(); // clear text
                        c.mediaPerQuestion[widget.widgetIndex]
                            ?.clear(); //optional: clear media also
                        c.submitAnswer(widget.widgetIndex);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: !isYesSelected
                              ? Colors.grey.shade300
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          "no".tr,
                          style: TextStyle(
                            color: !isYesSelected ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 10),
        Obx(() {
          final isYesSelected = c.getAnswer(widget.widgetIndex);

          if (!isYesSelected) return const SizedBox();

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: "Write issue details",
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 15),
                      ),
                      controller: widget.controller,
                    ),

                    Obx(() {
                      final mediaList =
                          c.mediaPerQuestion[widget.widgetIndex] ?? [];
                      final isUploading = mediaList.any(
                        (e) => e.isLoading == true,
                      );

                      if (mediaList.isNotEmpty) {
                        return Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 60,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: isUploading
                                      ? mediaList.length
                                      : mediaList.length + 1,
                                  itemBuilder: (context, index) {
                                    if (!isUploading &&
                                        index == mediaList.length) {
                                      return GestureDetector(
                                        onTap: () => showPickerDialog(
                                          widget.widgetIndex,
                                        ),
                                        child: Container(
                                          width: 60,
                                          margin: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            size: 30,
                                          ),
                                        ),
                                      );
                                    }

                                    final item = mediaList[index];

                                    return GestureDetector(
                                      onTap: () => showPreview(
                                        widget.widgetIndex,
                                        index,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: Stack(
                                          children: [
                                            Container(
                                              height: 70,
                                              width: 60,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                color: Colors.black12,
                                              ),
                                              child: item.isVideo
                                                  ? VideoThumb(
                                                      file: item.file,
                                                      url: item.url,
                                                    )
                                                  : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                      child: item.file != null
                                                          ? Image.file(
                                                              item.file!,
                                                              fit: BoxFit.cover,
                                                            )
                                                          : item.url != null
                                                          ? Image.network(
                                                              item.url!,
                                                              fit: BoxFit.cover,
                                                              loadingBuilder:
                                                                  (
                                                                    context,
                                                                    child,
                                                                    progress,
                                                                  ) {
                                                                    if (progress ==
                                                                        null)
                                                                      return child;
                                                                    return const Center(
                                                                      child: SizedBox(
                                                                        height:
                                                                            16,
                                                                        width:
                                                                            16,
                                                                        child: CircularProgressIndicator(
                                                                          strokeWidth:
                                                                              2,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                              errorBuilder:
                                                                  (
                                                                    context,
                                                                    error,
                                                                    stackTrace,
                                                                  ) {
                                                                    return const Center(
                                                                      child: Icon(
                                                                        Icons
                                                                            .broken_image,
                                                                        size:
                                                                            18,
                                                                      ),
                                                                    );
                                                                  },
                                                            )
                                                          : const SizedBox(),
                                                    ),
                                            ),

                                            if (item.isLoading)
                                              Positioned.fill(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.4),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: const Center(
                                                    child: SizedBox(
                                                      height: 18,
                                                      width: 18,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                            Positioned(
                                              right: 2,
                                              top: 2,
                                              child: GestureDetector(
                                                onTap: () => c.removeMedia(
                                                  widget.widgetIndex,
                                                  index,
                                                ),
                                                child: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.red,
                                                    size: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  c.pickImage(widget.widgetIndex);
                                },
                                child: buildBtn("Image"),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  c.pickVideo(widget.widgetIndex);
                                },
                                child: buildBtn("Video"),
                              ),
                            ),
                          ],
                        );
                      }
                    }),
                    SizedBox(height: 10),

                    Obx(() {
                      final mediaList =
                          c.mediaPerQuestion[widget.widgetIndex] ?? [];
                      if (mediaList.isEmpty) return const SizedBox();

                      return Row(
                        children: const [
                          Text(
                            "• Maximum 7 files",
                            style: TextStyle(fontSize: 11),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          );
        }),
      ],
    );
  }

  Widget buildBtn(String text) {
    return Ink(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            const Icon(Icons.camera_alt, size: 18),
            const SizedBox(width: 5),
            Text(text),
          ],
        ),
      ),
    );
  }

  void showPreview(int qIndex, int initialIndex) {
    final MultiFormController c = Get.find();

    PageController controller = PageController(initialPage: initialIndex);
    int currentIndex = initialIndex;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              final mediaList = c.mediaPerQuestion[widget.widgetIndex] ?? [];

              return Scaffold(
                backgroundColor: Colors.black,

                appBar: AppBar(
                  backgroundColor: Colors.black,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  centerTitle: true,
                  title: Text(
                    "${currentIndex + 1}/${mediaList.length}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        c.removeMedia(qIndex, currentIndex);

                        if (mediaList.isEmpty) {
                          Navigator.pop(context);
                          return;
                        }

                        if (currentIndex >= mediaList.length) {
                          currentIndex = mediaList.length - 1;
                        }

                        setDialogState(() {});
                      },
                    ),
                  ],
                ),

                body: PageView.builder(
                  controller: controller,
                  itemCount: mediaList.length,
                  onPageChanged: (index) {
                    setDialogState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = mediaList[index];

                    if (item.isVideo) {
                      return VideoPreview(file: item.file, url: item.url);
                    }

                    return InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Center(
                        child: item.file != null
                            ? Image.file(
                                item.file!,
                                key: ValueKey(item.file!.path),
                                fit: BoxFit.cover,
                              )
                            : item.url != null
                            ? Image.network(
                                item.url!,
                                key: ValueKey(item.url),
                                fit: BoxFit.cover,

                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;

                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },

                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              )
                            : const SizedBox(),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void showPickerDialog(int qIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Select Option",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.pop(context);
                          c.pickImage(qIndex);
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: const [
                                Icon(Icons.camera_alt, size: 40),
                                SizedBox(height: 5),
                                Text("Image"),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.pop(context);
                          c.pickVideo(qIndex);
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: const [
                                Icon(Icons.videocam, size: 40),
                                SizedBox(height: 5),
                                Text("Video"),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class VideoThumb extends StatefulWidget {
  final File? file;
  final String? url;

  const VideoThumb({super.key, this.file, this.url});

  @override
  State<VideoThumb> createState() => _VideoThumbState();
}

class _VideoThumbState extends State<VideoThumb> {
  VideoPlayerController? controller;

  @override
  void initState() {
    super.initState();

    if (widget.file != null) {
      controller = VideoPlayerController.file(widget.file!);
    } else if (widget.url != null && widget.url!.isNotEmpty) {
      controller = VideoPlayerController.networkUrl(Uri.parse(widget.url!));
    }

    controller?.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container(
        height: 70,
        width: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.black12,
        ),
        child: const Center(
          child: SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 70,
            width: 60,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller!.value.size.width,
                height: controller!.value.size.height,
                child: VideoPlayer(controller!),
              ),
            ),
          ),
        ),
        const Icon(Icons.play_circle_fill, color: Colors.white, size: 22),
      ],
    );
  }
}
