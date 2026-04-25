import 'dart:io';

class MediaItem {
  final File? file;
  final String? url;
  final bool isVideo;
  bool isLoading;

  MediaItem({
    this.file,
    this.url,
    required this.isVideo,
    this.isLoading = false,
  });
}
