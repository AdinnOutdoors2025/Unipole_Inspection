import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_config.dart';

class QuestionItem extends StatefulWidget {
  final String question;

  const QuestionItem({super.key, required this.question});

  @override
  State<QuestionItem> createState() => _QuestionItemState();
}

class _QuestionItemState extends State<QuestionItem> {
  bool isYesSelected = false;
  List<File> images = [];
  final ImagePicker picker = ImagePicker();

  Future<void> openCamera() async {
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 90,
    );

    if (photo != null) {
      File originalFile = File(photo.path);

      double originalSize = originalFile.lengthSync() / (1024 * 1024);

      File compressedFile = await compressImage(originalFile);

      double compressedSize = compressedFile.lengthSync() / (1024 * 1024);

      print("Original: ${originalSize.toStringAsFixed(2)} MB");
      print("Compressed: ${compressedSize.toStringAsFixed(2)} MB");

      setState(() {
        images.add(compressedFile);
      });
    }
  }

  Future<File> compressImage(File file) async {
    final targetPath = file.path.replaceAll(".jpg", "_compressed.jpg");

    if (!AppConfig.compressImages) {
      return file;
    }

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80,
      minWidth: 1920,
      minHeight: 1080,
    );

    return File(result!.path);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                      setState(() {
                        isYesSelected = true;
                      });
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
                        "Yes",
                        style: TextStyle(
                          color: isYesSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isYesSelected = false;
                      });
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
                        "No",
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
        ),

        const SizedBox(height: 10),

        if (isYesSelected)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextField(
                  decoration: InputDecoration(
                    hintText: "Write issue details",
                    border: InputBorder.none,
                  ),
                ),
                images.isNotEmpty
                    ? Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: images.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == images.length) {
                                    return GestureDetector(
                                      onTap: showPickerDialog,
                                      child: Container(
                                        width: 60,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(Icons.add, size: 30),
                                      ),
                                    );
                                  }

                                  return GestureDetector(
                                    onTap: () => showPreview(index),
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Stack(
                                        children: [
                                          Image.file(
                                            images[index],
                                            height: 70,
                                            width: 50,
                                            fit: BoxFit.cover,
                                          ),

                                          Positioned(
                                            right: 0,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  images.removeAt(index);
                                                });
                                              },
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.red,
                                                size: 17,
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
                      )
                    : Row(
                        children: [
                          GestureDetector(
                            onTap: openCamera,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.camera_alt, size: 18),
                                  SizedBox(width: 5),
                                  Text("Image"),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.camera_alt, size: 18),
                                SizedBox(width: 5),
                                Text("Video"),
                              ],
                            ),
                          ),
                        ],
                      ),
                SizedBox(height: 10),
                if (images.isNotEmpty)
                  Row(
                    children: [
                      const Text(
                        "• Live Camera Only",
                        style: TextStyle(fontSize: 11),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "• No gallery Upload",
                        style: TextStyle(fontSize: 11),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "• Maximum 10 files",
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }

  void showPreview(int initialIndex) {
    PageController controller = PageController(initialPage: initialIndex);
    int currentIndex = initialIndex;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
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
                    "${currentIndex + 1}/${images.length}",
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          images.removeAt(currentIndex);
                        });

                        if (images.isEmpty) {
                          Navigator.pop(context);
                          return;
                        }

                        if (currentIndex >= images.length) {
                          currentIndex = images.length - 1;
                        }

                        setDialogState(() {});
                      },
                    ),
                  ],
                ),
                body: PageView.builder(
                  controller: controller,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setDialogState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Center(
                        child: Image.file(images[index], fit: BoxFit.contain),
                      ),
                    );
                  },
                ),

                bottomNavigationBar: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  color: Colors.black.withOpacity(0.6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Swipe to view",
                        style: TextStyle(color: Colors.white70),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () async {
                          final XFile? newPhoto = await picker.pickImage(
                            source: ImageSource.camera,
                          );

                          if (newPhoto != null) {
                            File newFile = File(newPhoto.path);

                            setDialogState(() {
                              images[currentIndex] = newFile;
                            });

                            setState(() {});
                          }
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Retake"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void showPickerDialog() {
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
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        openCamera();
                      },
                      child: Column(
                        children: const [
                          Icon(Icons.camera_alt, size: 40),
                          SizedBox(height: 5),
                          Text("Image"),
                        ],
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: const [
                          Icon(Icons.videocam, size: 40),
                          SizedBox(height: 5),
                          Text("Video"),
                        ],
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
