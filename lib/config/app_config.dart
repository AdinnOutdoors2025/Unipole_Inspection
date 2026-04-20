import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static bool get compressImages => dotenv.env['COMPRESS_IMAGES'] == 'true';
  static bool get compressVideos => dotenv.env['COMPRESS_VIDEOS'] == 'true';
}
