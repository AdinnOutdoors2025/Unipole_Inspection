import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/internacionalization.dart';

class AppTranslations extends Translations {
  static final AppTranslations _instance = AppTranslations._internal();

  factory AppTranslations() => _instance;

  AppTranslations._internal();

  final Map<String, Map<String, String>> translations = {};

  @override
  Map<String, Map<String, String>> get keys => translations;

  Future<void> loadTranslations() async {
    final enJson = json.decode(
      await rootBundle.loadString('assets/lang/en.json'),
    );
    final taJson = json.decode(
      await rootBundle.loadString('assets/lang/ta.json'),
    );

    translations['en_US'] = Map<String, String>.from(enJson);
    translations['ta_IN'] = Map<String, String>.from(taJson);
  }
}
