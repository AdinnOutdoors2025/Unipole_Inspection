import 'package:flutter/services.dart';

/*class SizeInputFormatter extends TextInputFormatter {
  final String unit;

  SizeInputFormatter(this.unit);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.isEmpty) {
      return const TextEditingValue(text: '');
    }

    int widthLimit;
    int heightLimit;

    // 🔥 SET LIMIT BASED ON UNIT
    switch (unit) {
      case "ft":
        widthLimit = 2;
        heightLimit = 2;
        break;
      case "inch":
        widthLimit = 3;
        heightLimit = 3;
        break;
      case "cm":
        widthLimit = 4;
        heightLimit = 4;
        break;
      default:
        widthLimit = 2;
        heightLimit = 2;
    }

    int maxLength = widthLimit + heightLimit;

    if (text.length > maxLength) {
      text = text.substring(0, maxLength);
    }

    String formatted;

    if (text.length <= widthLimit) {
      // typing width
      formatted = text;
      if (text.length == widthLimit) {
        formatted = "$text x ";
      }
    } else {
      // typing height
      String width = text.substring(0, widthLimit);
      String height = text.substring(widthLimit);
      formatted = "$width x $height";
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}*/
class SizeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // Allow only numbers, x, and space
    text = text.replaceAll(RegExp(r'[^0-9xX ]'), '');

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
