import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Saves the export into the app's documents directory and returns the
/// path. (v0.2 wires the system share sheet so the file lands in
/// Downloads/Files directly; v0.1 keeps the file inside the app's own
/// storage, and the Export screen also offers copy-to-clipboard.)
Future<String> saveTextFile(String contents, String fileName) async {
  final dir = await getApplicationDocumentsDirectory();
  final safeName = fileName.replaceAll(RegExp(r'[^\w\-.]+'), '_');
  final file = File('${dir.path}/$safeName');
  await file.writeAsString(contents);
  return file.path;
}
