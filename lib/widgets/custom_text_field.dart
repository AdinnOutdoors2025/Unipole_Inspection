import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  //final FocusNode focusNode;
  final String hintText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffix;
  final double height;

  const CustomTextField({
    super.key,
    required this.controller,
    //  required this.focusNode,
    required this.hintText,
    this.prefixIcon,
    this.validator,
    required this.height,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      // focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      textAlignVertical: TextAlignVertical.center,
      validator: validator,
      style: const TextStyle(
        color: Color(0xFF202129),
        fontSize: 17,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF6A6C76),
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
        errorStyle: const TextStyle(
          fontSize: 12,
          color: Color(0xFFD71920),
          height: 1.15,
        ),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF202129), size: 29),
        suffixIcon: suffix == null
            ? null
            : Padding(padding: const EdgeInsets.only(right: 16), child: suffix),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        filled: true,
        fillColor: const Color(0xFFFDFDFF),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: (height - 24) / 2,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFFE3E3E8), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFFD71920), width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFFD71920), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFFD71920), width: 1.4),
        ),
      ),
    );
  }
}
