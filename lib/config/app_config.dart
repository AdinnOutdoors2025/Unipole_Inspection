import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static bool get compressImages => dotenv.env['COMPRESS_IMAGES'] == 'true';
}
