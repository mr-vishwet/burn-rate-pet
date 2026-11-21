import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/storage_service.dart';
import 'state/momo_controller.dart';

/// Entry point: loads persisted state (or seeds the demo on first launch)
/// and starts the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final controller = await MomoController.load(
    store: StorageService(PrefsStore(prefs)),
  );
  runApp(MomoApp(controller: controller));
}
