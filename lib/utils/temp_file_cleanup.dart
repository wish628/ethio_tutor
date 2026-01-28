import 'dart:io';

/// Delete files in the given directory older than [maxAge].
Future<void> cleanOldTempFiles(Directory dir, {Duration maxAge = const Duration(minutes: 30)}) async {
  try {
    if (!await dir.exists()) return;
    final now = DateTime.now();
    await for (final entity in dir.list()) {
      if (entity is File) {
        try {
          final stat = await entity.stat();
          final modified = stat.modified;
          if (now.difference(modified) > maxAge) {
            await entity.delete();
          }
        } catch (_) {
          // ignore failures to delete individual files
        }
      }
    }
  } catch (_) {
    // ignore top-level errors to avoid crashing the app on cleanup
  }
}
