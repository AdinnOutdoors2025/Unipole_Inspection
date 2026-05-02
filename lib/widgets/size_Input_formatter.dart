import 'package:flutter/services.dart';

class SizeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // Allow only digits and x
    text = text.replaceAll(RegExp(r'[^0-9xX]'), '');

    // Convert X → x
    text = text.replaceAll('X', 'x');

    // Allow only one 'x'
    if ('x'.allMatches(text).length > 1) {
      return oldValue;
    }

    // Split into parts
    List<String> parts = text.split('x');

    String left = parts[0];
    String right = parts.length > 1 ? parts[1] : "";

    // Limit left side to 3 digits
    if (left.length > 3) {
      left = left.substring(0, 3);
    }

    // Limit right side to 3 digits
    if (right.length > 3) {
      right = right.substring(0, 3);
    }

    // Rebuild WITHOUT forcing 'x'
    String newText = left;
    if (text.contains('x')) {
      newText += 'x$right';
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
