import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'theme_provider.dart';

/// InheritedNotifier that propagates [ThemeNotifier] down the widget tree.
class ThemeScope extends InheritedNotifier<ThemeNotifier> {
  const ThemeScope({
    super.key,
    required ThemeNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ThemeNotifier of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'No ThemeScope found in context');
    return scope!.notifier!;
  }
}

/// Convenience extension so any widget can do: context.colors.primary
extension ThemeContextX on BuildContext {
  AppColors get colors => ThemeScope.of(this).colors;
  ThemeNotifier get themeNotifier => ThemeScope.of(this);
}
