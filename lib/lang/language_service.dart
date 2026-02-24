import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_model.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static Language _currentLanguage = LanguageData.supportedLanguages.first;

  // Getter for current language
  Language get currentLanguage => _currentLanguage;

  // Getter for current language code
  String get currentLanguageCode => _currentLanguage.code;

  // Getter for current language name
  String get currentLanguageName => _currentLanguage.name;

  // Getter for current language native name
  String get currentLanguageNativeName => _currentLanguage.nativeName;

  // Getter for current language flag
  String get currentLanguageFlag => _currentLanguage.flag;

  LanguageService() {
    _loadSavedLanguage();
  }

  // Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString(_languageKey);

      if (savedLanguageCode != null) {
        final savedLanguage = LanguageData.getLanguageByCode(savedLanguageCode);
        _currentLanguage = savedLanguage;
        notifyListeners();
            }
    } catch (e) {
      debugPrint('Error loading saved language: $e');
    }
  }

  // Save language to SharedPreferences
  Future<void> _saveLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }

  // Change language
  Future<void> changeLanguage(String languageCode) async {
    final newLanguage = LanguageData.getLanguageByCode(languageCode);
    if (newLanguage != _currentLanguage) {
      _currentLanguage = newLanguage;
      await _saveLanguage(languageCode);
      notifyListeners();
    }
  }

  // Change language by name
  Future<void> changeLanguageByName(String languageName) async {
    final newLanguage = LanguageData.getLanguageByName(languageName);
    if (newLanguage != _currentLanguage) {
      _currentLanguage = newLanguage;
      await _saveLanguage(newLanguage.code);
      notifyListeners();
    }
  }

  // Get translation for a key
  String translate(String key) {
    return _currentLanguage.translations[key] ?? key;
  }

  // Get translation with fallback
  String translateWithFallback(String key, String fallback) {
    return _currentLanguage.translations[key] ?? fallback;
  }

  // Get all supported languages
  List<Language> get supportedLanguages => LanguageData.supportedLanguages;

  // Get language names for UI
  List<String> get languageNames => LanguageData.getLanguageNames();

  // Get language native names for UI
  List<String> get languageNativeNames => LanguageData.getLanguageNativeNames();

  // Get language codes
  List<String> get languageCodes => LanguageData.getLanguageCodes();

  // Check if current language is English
  bool get isEnglish => _currentLanguage.code == 'en';

  // Check if current language is Khmer
  bool get isKhmer => _currentLanguage.code == 'kh';

  // Get current language display name (native name if available, otherwise English name)
  String get displayName {
    return _currentLanguage.nativeName != _currentLanguage.name
        ? '${_currentLanguage.nativeName} (${_currentLanguage.name})'
        : _currentLanguage.name;
  }
}
