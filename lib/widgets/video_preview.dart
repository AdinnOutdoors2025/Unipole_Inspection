import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  final File? file;
  final String? url;

  const VideoPreview({super.key, this.file, this.url});

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  VideoPlayerController? controller;

  @override
  void initState() {
    super.initState();

    if (widget.file != null) {
      controller = VideoPlayerController.file(widget.file!);
    } else if (widget.url != null) {
      controller = VideoPlayerController.networkUrl(Uri.parse(widget.url!));
    }

    controller?.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return AspectRatio(
      aspectRatio: controller!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(controller!),

          GestureDetector(
            onTap: () {
              setState(() {
                controller!.value.isPlaying
                    ? controller!.pause()
                    : controller!.play();
              });
            },
            child: Icon(
              controller!.value.isPlaying
                  ? Icons.pause_circle
                  : Icons.play_circle,
              size: 60,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
