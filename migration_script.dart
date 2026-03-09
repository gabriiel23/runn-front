import 'dart:io';

void migrarArchivo(String path) {
  final file = File(path);
  if (!file.existsSync()) return;

  var content = file.readAsStringSync();

  // Remover constantes locales
  content = content.replaceAll(
    RegExp(r'const kPink = Color\(0xFF[0-9A-Fa-f]+\);\n'),
    '',
  );
  content = content.replaceAll(
    RegExp(r'const kPinkDark = Color\(0xFF[0-9A-Fa-f]+\);\n'),
    '',
  );
  content = content.replaceAll(
    RegExp(r'const kPinkDeep = Color\(0xFF[0-9A-Fa-f]+\);\n'),
    '',
  );
  content = content.replaceAll(
    RegExp(r'const kPinkLight = Color\(0xFF[0-9A-Fa-f]+\);\n'),
    '',
  );
  content = content.replaceAll(
    RegExp(r'const kPinkMid = Color\(0xFF[0-9A-Fa-f]+\);\n'),
    '',
  );
  content = content.replaceAll(
    RegExp(r'const kBgLight = Color\(0xFF[0-9A-Fa-f]+\);\n'),
    '',
  );

  // Importar theme_scope
  if (!content.contains(
    "import 'package:runn_front/core/theme/theme_scope.dart';",
  )) {
    content = content.replaceFirst(
      "import 'package:flutter/material.dart';",
      "import 'package:flutter/material.dart';\nimport 'package:runn_front/core/theme/theme_scope.dart';",
    );
  }

  // Agregando getter general the colores al inicio de los Builds
  if (!content.contains('final c = context.colors;')) {
    content = content.replaceAll(
      'Widget build(BuildContext context) {',
      'Widget build(BuildContext context) {\n    final c = context.colors;',
    );
  }

  // Reemplazar colores por propiedades del theme the context "c"
  content = content.replaceAll('kPinkDeep', 'c.primaryDeep');
  content = content.replaceAll('kPinkMid', 'c.primaryMid');
  content = content.replaceAll('kPinkLight', 'c.primaryLight');
  content = content.replaceAll('kPink', 'c.primary');
  content = content.replaceAll('kBgLight', 'c.bg');
  content = content.replaceAll('Colors.white', 'c.card');
  content = content.replaceAll('Color(0xFF1A1A1A)', 'c.textPrimary');

  // Eliminar invalid const
  content = content.replaceAll(
    'const AlwaysStoppedAnimation',
    'AlwaysStoppedAnimation',
  );

  file.writeAsStringSync(content);
  print('Migrado \$path');
}

void cleanConstModifiers(String path) {
  final file = File(path);
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();

  // Similar al anterior para remover const que dan Invalid Constant o Const With Non Const
  final constTargets = [
    'const Color',
    'const Icon',
    'const Text',
    'const Row',
    'const Column',
    'const SizedBox',
    'const Expanded',
    'const Padding',
    'const Positioned',
    'const Container',
    'const ShapeDecoration',
    'const Center',
    'const Align',
    'const EdgeInsets',
  ];

  for (final target in constTargets) {
    content = content.replaceAll('$target', '${target.substring(6)}');
  }
  file.writeAsStringSync(content);
}

void main() {
  final files = [
    'lib/features/creation_runner_profile/presentation/pages/physical_metrics_page.dart',
    'lib/features/creation_runner_profile/presentation/pages/profile_setup_page.dart',
    'lib/features/creation_runner_profile/presentation/pages/runner_profile_page.dart',
  ];

  for (final f in files) {
    migrarArchivo(f);
    cleanConstModifiers(f);
  }
}
