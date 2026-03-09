import 'dart:io';

void main() {
  final res = Process.runSync('dart', ['analyze', '--format=machine']);
  final lines = res.stdout.toString().split('\n');
  final out = File('analysis_out.txt');
  final buffer = StringBuffer();
  for (var line in lines) {
    if (line.trim().isEmpty) continue;
    final parts = line.split('|');
    if (parts.length > 7) {
      final severity = parts[0];
      final code = parts[2];
      final file = parts[3];
      final lineNum = parts[4];
      final col = parts[5];
      final msg = parts[7];
      buffer.writeln('$severity|$code|$file:$lineNum:$col|$msg');
    }
  }
  out.writeAsStringSync(buffer.toString());
}
