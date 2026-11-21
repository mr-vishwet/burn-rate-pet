import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Downloads the export via a browser anchor element. Returns the file
/// name.
Future<String> saveTextFile(String contents, String fileName) async {
  final blob = web.Blob(
    [contents.toJS].toJS,
    web.BlobPropertyBag(type: 'application/json'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName
    ..click();
  web.URL.revokeObjectURL(url);
  anchor.remove();
  return fileName;
}
