import 'dart:html' as html;

/// Downloads the export via a browser anchor element. Returns the file
/// name.
Future<String> saveTextFile(String contents, String fileName) async {
  final blob = html.Blob([contents], 'application/json');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = fileName
    ..click();
  html.Url.revokeObjectUrl(url);
  anchor.remove();
  return fileName;
}
