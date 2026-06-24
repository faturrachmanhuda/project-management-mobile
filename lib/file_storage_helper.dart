/// Helper untuk menyimpan & mengambil metadata file sementara (in-memory).
///
/// Menggantikan FileStorageHelper lama yang menyimpan base64 ke SharedPreferences.
/// Sekarang hanya menyimpan path file lokal dan metadata ringan di memori,
/// bukan base64 besar yang tidak perlu dipersistensikan.
class FileStorageHelper {
  // ─── In-memory store per activityId ──────────────────────────────────────
  static final Map<String, _FileEntry> _store = {};

  // ─── Per-activity ─────────────────────────────────────────────────────────

  /// Simpan metadata file untuk aktivitas tertentu (in-memory).
  static void saveFileForActivity({
    required String activityId,
    required String fileName,
    required String fileType,
    required String localFilePath,
  }) {
    _store[activityId] = _FileEntry(
      fileName: fileName,
      fileType: fileType,
      localFilePath: localFilePath,
    );
  }

  /// Baca metadata file untuk aktivitas tertentu.
  static Map<String, String?> readFileForActivity(String activityId) {
    final entry = _store[activityId];
    return {
      'fileName': entry?.fileName,
      'fileType': entry?.fileType,
      'localFilePath': entry?.localFilePath,
    };
  }

  /// Hapus metadata file untuk aktivitas tertentu.
  static void clearFileForActivity(String activityId) {
    _store.remove(activityId);
  }

  /// Cek apakah ada file tersimpan untuk aktivitas tertentu.
  static bool hasFileForActivity(String activityId) {
    final entry = _store[activityId];
    return entry != null && entry.localFilePath.isNotEmpty;
  }

  /// Hapus semua data tersimpan (misal saat logout).
  static void clearAll() {
    _store.clear();
  }
}

class _FileEntry {
  final String fileName;
  final String fileType;
  final String localFilePath;

  const _FileEntry({
    required this.fileName,
    required this.fileType,
    required this.localFilePath,
  });
}
