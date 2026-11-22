import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../state/momo_state.dart';

/// Thrown when a backup file cannot be imported. The [message] is safe
/// to show the user as-is; a bad file is a message, never a crash.
class ImportFormatException implements Exception {
  /// Creates an import failure with a user-facing [message].
  const ImportFormatException(this.message);

  /// Why the file could not be imported.
  final String message;

  @override
  String toString() => 'ImportFormatException: $message';
}

/// Backup import: picks the JSON file the app already exports (Data
/// Controls → Export JSON) and parses it back into state.
///
/// The picker is the only platform-dependent part (file_picker handles
/// web + native); parsing is pure and covered by tests.
class ImportService {
  /// Opens the file picker for a `.json` backup and returns the file's
  /// text, or null when the user cancels. Throws
  /// [ImportFormatException] when the picked file cannot be read as
  /// text.
  static Future<String?> pickBackupText() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (file == null) return null;
    final Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (_) {
      throw const ImportFormatException(
        'That file could not be read — please try again.',
      );
    }
    try {
      return utf8.decode(bytes);
    } on FormatException {
      throw const ImportFormatException(
        'That file is not readable text — pick the JSON file Momo '
        'exported.',
      );
    }
  }

  /// Parses backup [text] into state. Validates the version and the
  /// shape before returning anything: garbage is rejected with a clear
  /// [ImportFormatException], never a crash and never a half-loaded
  /// state.
  static MomoState parseBackup(String text) {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      throw const ImportFormatException(
        'That file is not valid JSON — pick the JSON file Momo exported.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const ImportFormatException(
        'That file is not a Momo backup — a backup is a JSON object.',
      );
    }
    final version = decoded['version'];
    if (version is! int || version != 1) {
      throw const ImportFormatException(
        'That file is not a Momo backup (missing or unknown version).',
      );
    }
    try {
      return MomoState.fromJson(decoded);
    } on TypeError {
      throw const ImportFormatException(
        'That file looks like a Momo backup but its contents are damaged.',
      );
    }
  }
}
