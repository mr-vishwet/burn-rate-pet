/// Fallback for platforms with no saver: reports that saving is unavailable.
Future<String> saveTextFile(String contents, String fileName) async {
  throw UnsupportedError('Saving exports is not supported on this platform.');
}
