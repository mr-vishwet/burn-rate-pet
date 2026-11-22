import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'screens/corrupt_state_screen.dart';
import 'services/storage_service.dart';
import 'state/momo_controller.dart';

/// Entry point: boots the app — loads persisted state (or starts fresh
/// on first launch) and runs it. Load failures route to the
/// corrupt-state screen instead of stranding the app or silently
/// discarding data.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _boot();
}

/// One boot attempt. Separated from [main] so the corrupt-state screen
/// can re-run it after a recovery (backup restored, fresh start, or
/// retry) — [runApp] replaces the root widget each time.
Future<void> _boot() async {
  final StorageService store;
  try {
    final prefs = await SharedPreferences.getInstance();
    store = StorageService(PrefsStore(prefs));
  } catch (_) {
    // Storage itself is unavailable (blocked, full, or otherwise
    // broken): there is no store to read from or write to, so the only
    // honest path is the error screen with a retry.
    runApp(
      const CorruptStateApp(
        screen: CorruptStateScreen.storageUnavailable(
          onRecovered: _boot,
        ),
      ),
    );
    return;
  }

  try {
    final controller = await MomoController.load(store: store);
    runApp(MomoApp(controller: controller));
  } on CorruptStateException {
    // The stored document exists but cannot be read. It stays exactly
    // where it is — the error screen offers Restore from backup or
    // Start fresh, and nothing is discarded without the user's say-so.
    runApp(
      CorruptStateApp(
        screen: CorruptStateScreen(
          store: store,
          onRecovered: _boot,
        ),
      ),
    );
  } catch (_) {
    // Any other load failure (a read or a first-launch persist that
    // threw — storage full or blocked mid-boot): same treatment as
    // unavailable storage, with a retry.
    runApp(
      const CorruptStateApp(
        screen: CorruptStateScreen.storageUnavailable(
          onRecovered: _boot,
        ),
      ),
    );
  }
}
