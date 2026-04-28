 /*
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
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    initVideo();
  }

  Future<void> initVideo() async {
    try {
      if (widget.file != null) {
        controller = VideoPlayerController.file(widget.file!);
      } else if (widget.url != null && widget.url!.isNotEmpty) {
        controller = VideoPlayerController.networkUrl(Uri.parse(widget.url!));
      }

      if (controller == null) {
        setState(() {
          hasError = true;
        });
        return;
      }

      await controller!.initialize();

      controller!.addListener(() {
        if (!mounted) return;

        final isCompleted =
            controller!.value.position >= controller!.value.duration;

        if (isCompleted) {
          setState(() {}); // refresh UI
        }
      });

      controller!.setLooping(false);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint("VIDEO ERROR: $e");

      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return const Center(
        child: Text(
          "Failed to load video",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    if (isLoading || controller == null || !controller!.value.isInitialized) {
      return const Center(
        child: SizedBox(
          height: 30,
          width: 30,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final isCompleted =
        controller!.value.position >= controller!.value.duration;

    return AspectRatio(
      aspectRatio: controller!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(controller!),

          GestureDetector(
            onTap: () async {
              if (isCompleted) {
                await controller!.seekTo(Duration.zero);
                controller!.play();
              } else {
                setState(() {
                  controller!.value.isPlaying
                      ? controller!.pause()
                      : controller!.play();
                });
              }
            },
            child: Icon(
              controller!.value.isPlaying || isCompleted
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
*/
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
  bool isLoading = true;
  bool hasError = false;

  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    initVideo();
  }

  Future<void> initVideo() async {
    try {
      if (widget.file != null) {
        controller = VideoPlayerController.file(widget.file!);
      } else if (widget.url != null && widget.url!.isNotEmpty) {
        controller = VideoPlayerController.networkUrl(Uri.parse(widget.url!));
      }

      if (controller == null) {
        hasError = true;
        setState(() {});
        return;
      }

      await controller!.initialize();

      duration = controller!.value.duration;

      controller!.addListener(() {
        if (!mounted) return;

        setState(() {
          position = controller!.value.position;
        });
      });

      controller!.setLooping(false);
      controller!.play();

      isLoading = false;
      setState(() {});
    } catch (e) {
      hasError = true;
      isLoading = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  String formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final isBuffering = controller!.value.isBuffering;
    if (hasError) {
      return const Center(
        child: Text(
          "Failed to load video",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final isInitialized = controller != null && controller!.value.isInitialized;

    final isCompleted = isInitialized && position >= duration;

    return Stack(
      children: [
        if (isInitialized)
          Center(
            child: AspectRatio(
              aspectRatio: controller!.value.aspectRatio,
              child: VideoPlayer(controller!),
            ),
          )
        else
          Container(color: Colors.black),

        if (isLoading || !isInitialized)
          Container(
            color: Colors.black.withOpacity(0.6),
            child: const Center(child: CircularProgressIndicator()),
          ),

        if (!isLoading && isInitialized)
          Center(
            child: GestureDetector(
              onTap: () async {
                if (isCompleted) {
                  await controller!.seekTo(Duration.zero);
                  controller!.play();
                } else {
                  controller!.value.isPlaying
                      ? controller!.pause()
                      : controller!.play();
                }
              },
              child: isBuffering
                  ? const SizedBox(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      isCompleted
                          ? Icons.replay_circle_filled
                          : controller!.value.isPlaying
                          ? Icons.pause_circle
                          : Icons.play_circle,
                      size: 60,
                      color: Colors.white,
                    ),
            ),
          ),

        if (!isLoading && isInitialized)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              color: Colors.black.withOpacity(0.6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    min: 0,
                    max: duration.inSeconds.toDouble(),
                    value: position.inSeconds
                        .clamp(0, duration.inSeconds)
                        .toDouble(),
                    onChanged: (value) async {
                      final newPos = Duration(seconds: value.toInt());
                      await controller!.seekTo(newPos);
                    },
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatTime(position),
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        formatTime(duration),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
