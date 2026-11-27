import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared runtime + persisted base URL configuration for API services.
class BaseUrlConfig {
  BaseUrlConfig({
    required this.prefsKey,
    required String Function() defaultUrlBuilder,
  }) : _defaultUrlBuilder = defaultUrlBuilder;

  final String prefsKey;
  final String Function() _defaultUrlBuilder;

  late final ValueNotifier<String> notifier = ValueNotifier<String>(defaultUrl);

  String get defaultUrl => normalize(_defaultUrlBuilder());
  String get currentUrl => notifier.value;

  static String normalize(String value) {
    final trimmed = value.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  /// Validates an HTTP(S) base URL, returning an error message or null.
  static String? validate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'URL server tidak boleh kosong.';
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return 'Masukkan URL valid dengan http:// atau https://.';
    }
    return null;
  }

  /// Loads any previously persisted base URL from [SharedPreferences].
  Future<void> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(prefsKey);
    if (saved != null && validate(saved) == null) {
      notifier.value = normalize(saved);
    }
  }

  /// Updates the active base URL in real time and persists it.
  Future<void> setUrl(String url) async {
    final error = validate(url);
    if (error != null) {
      throw ArgumentError(error);
    }
    final normalized = normalize(url);
    notifier.value = normalized;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsKey, normalized);
  }

  /// Resets the active base URL to [defaultUrl] and clears persistence.
  Future<void> resetUrl() async {
    notifier.value = defaultUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefsKey);
  }
}
