/// Saves a text export (the JSON data export). Platform implementations
/// live in `export_service_io.dart` (mobile/desktop: app documents
/// directory) and `export_service_web.dart` (web: browser download).
export 'export_service_stub.dart'
    if (dart.library.io) 'export_service_io.dart'
    if (dart.library.html) 'export_service_web.dart';
