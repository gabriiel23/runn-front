import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeNotifier extends ChangeNotifier {
  static const _keyScheme = 'theme_scheme';
  static const _keyBrightness = 'theme_brightness';

  AppColorScheme _scheme;
  AppBrightness _brightness;

  ThemeNotifier({
    AppColorScheme scheme = AppColorScheme.pink,
    AppBrightness brightness = AppBrightness.light,
  }) : _scheme = scheme,
       _brightness = brightness;

  AppColorScheme get scheme => _scheme;
  AppBrightness get brightness => _brightness;
  AppColors get colors => AppColors.resolve(_scheme, _brightness);

  bool get isDark => _brightness == AppBrightness.dark;

  /// Load persisted prefs (call once at startup)
  static Future<ThemeNotifier> load() async {
    final prefs = await SharedPreferences.getInstance();
    final schemeIndex = prefs.getInt(_keyScheme) ?? 0;
    final brightnessIndex = prefs.getInt(_keyBrightness) ?? 0;
    return ThemeNotifier(
      scheme: AppColorScheme.values[schemeIndex],
      brightness: AppBrightness.values[brightnessIndex],
    );
  }

  Future<void> setScheme(AppColorScheme scheme) async {
    _scheme = scheme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyScheme, scheme.index);
  }

  Future<void> setBrightness(AppBrightness brightness) async {
    _brightness = brightness;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBrightness, brightness.index);
  }

  Future<void> setTheme(AppColorScheme scheme, AppBrightness brightness) async {
    _scheme = scheme;
    _brightness = brightness;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyScheme, scheme.index);
    await prefs.setInt(_keyBrightness, brightness.index);
  }
}
