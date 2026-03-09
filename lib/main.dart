import 'package:flutter/material.dart';
import 'package:runn_front/core/routes/app_routes.dart';
import 'package:runn_front/core/theme/theme_provider.dart';
import 'package:runn_front/core/theme/theme_scope.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeNotifier = await ThemeNotifier.load();
  runApp(MyApp(themeNotifier: themeNotifier));
}

class MyApp extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  const MyApp({super.key, required this.themeNotifier});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    widget.themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    widget.themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final colors = widget.themeNotifier.colors;
    return ThemeScope(
      notifier: widget.themeNotifier,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Runn',
        theme: colors.toMaterialTheme(),
        routerConfig: appRouter,
      ),
    );
  }
}
