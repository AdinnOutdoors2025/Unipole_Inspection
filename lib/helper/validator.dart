import 'package:get/get_utils/src/extensions/internacionalization.dart';

class Validator {
  static String? validate(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'required_field'.trParams({
        'field': fieldName.tr,
      });
    }
    return null;
  }
  static String? confirmPassword(
      String? value,
      String password,
      ) {
    if (value == null || value.isEmpty) {
      return "confirm_password_validation".tr;
    }
    if (value != password) {
      return "password_do_notmatch_validation".tr;
    }
    return null;
  }
}
