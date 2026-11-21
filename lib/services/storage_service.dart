import 'package:shared_preferences/shared_preferences.dart';

/// Local-first persistence: the whole app state is one JSON document under
/// a single key. The [KeyValueStore] abstraction keeps the controller
/// testable without plugins ([MemoryStore] in tests, [PrefsStore] in the
/// app).
abstract class KeyValueStore {
  /// Reads the value for [key], or null.
  Future<String?> read(String key);

  /// Writes [value] for [key].
  Future<void> write(String key, String value);

  /// Removes [key].
  Future<void> remove(String key);
}

/// In-memory store for tests.
class MemoryStore implements KeyValueStore {
  /// Creates an in-memory store, optionally prefilled.
  MemoryStore([Map<String, String>? initial])
    : _map = Map<String, String>.of(initial ?? {});

  final Map<String, String> _map;

  @override
  Future<String?> read(String key) async => _map[key];

  @override
  Future<void> write(String key, String value) async {
    _map[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _map.remove(key);
  }
}

/// SharedPreferences-backed store for the app.
class PrefsStore implements KeyValueStore {
  /// Creates a prefs-backed store.
  PrefsStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<String?> read(String key) async => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}

/// Reads/writes the app-state document.
class StorageService {
  /// Creates the service around [store].
  StorageService(this.store);

  /// The underlying store.
  final KeyValueStore store;

  /// Storage key for the state document.
  static const String stateKey = 'momo_state_v1';

  /// Reads the raw state JSON, or null on first launch.
  Future<String?> read() => store.read(stateKey);

  /// Writes the raw state JSON.
  Future<void> write(String json) => store.write(stateKey, json);

  /// Deletes the stored state.
  Future<void> clear() => store.remove(stateKey);
}
