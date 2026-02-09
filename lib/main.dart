import 'package:flutter/material.dart';
import 'package:runn_front/core/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Runn',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      routerConfig: appRouter,
    );
  }
}
