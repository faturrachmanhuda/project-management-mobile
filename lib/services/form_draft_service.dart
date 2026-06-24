import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

/// Service sederhana untuk menyimpan dan memuat draft form
/// menggunakan SharedPreferences.
///
/// SharedPreferences HANYA digunakan untuk draft form.
/// Semua key non-draft (token, user_data, saved_projects, file base64, foto, dll)
/// sudah dihapus dari SharedPreferences dan dipindahkan ke mekanisme yang sesuai.
///
/// Setiap form memiliki [draftKey] unik, dan data disimpan
/// sebagai JSON Map<String, String>.
class FormDraftService {
  // ─── Draft keys ──────────────────────────────────────────────────────────
  static const String keyWizardProyek = 'draft_wizard_proyek';
  static const String keyBuatPekerjaan = 'draft_buat_pekerjaan';
  static const String keyBuatAktivitas = 'draft_buat_aktivitas';

  /// Simpan draft form ke SharedPreferences.
  static Future<void> simpanDraft(
    String draftKey,
    Map<String, String> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(draftKey, jsonEncode(data));
  }

  /// Muat draft form dari SharedPreferences.
  /// Mengembalikan `null` jika tidak ada draft.
  static Future<Map<String, String>?> muatDraft(String draftKey) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(draftKey);
    if (json == null) return null;
    try {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return null;
    }
  }

  /// Hapus draft form dari SharedPreferences.
  static Future<void> hapusDraft(String draftKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(draftKey);
  }

  // ─── Cleanup key lama ────────────────────────────────────────────────────

  /// Hapus semua key non-draft yang mungkin masih tersisa dari versi lama.
  ///
  /// Panggil sekali saat startup aplikasi untuk membersihkan SharedPreferences
  /// dari key-key lama yang sudah tidak digunakan.
  ///
  /// Key yang akan dihapus:
  /// - `access_token`, `refresh_token` → dipindahkan ke in-memory
  /// - `user_data` → dipindahkan ke SQLite + in-memory
  /// - `local_accounts` → dipindahkan ke SQLite
  /// - `saved_projects` → tidak diperlukan lagi
  /// - `saved_file_name`, `saved_file_type`, `saved_file_base64` → dihapus
  /// - Semua key dengan prefix `activity_*` untuk file base64 → dihapus
  /// - Semua key yang berakhiran `_foto` untuk aktivitas → dihapus
  static Future<void> cleanupLegacyKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();

      // Key statis yang pasti harus dihapus
      const staticLegacyKeys = <String>{
        'access_token',
        'refresh_token',
        'user_data',
        'local_accounts',
        'saved_projects',
        'saved_file_name',
        'saved_file_type',
        'saved_file_base64',
      };

      // Key draft yang harus DIPERTAHANKAN
      const draftKeys = <String>{
        keyWizardProyek,
        keyBuatPekerjaan,
        keyBuatAktivitas,
      };

      int removed = 0;

      for (final key in allKeys) {
        // Jangan hapus key draft
        if (draftKeys.contains(key)) continue;

        bool shouldRemove = false;

        // Key statis lama
        if (staticLegacyKeys.contains(key)) {
          shouldRemove = true;
        }
        // Key dinamis file aktivitas (activity_*_file_name, activity_*_file_type, activity_*_file_base64)
        else if (key.startsWith('activity_') &&
            (key.endsWith('_file_name') ||
                key.endsWith('_file_type') ||
                key.endsWith('_file_base64'))) {
          shouldRemove = true;
        }
        // Key foto aktivitas (*_foto)
        else if (key.endsWith('_foto')) {
          shouldRemove = true;
        }
        // Key cache kegiatan (kegiatans_*)
        else if (key.startsWith('kegiatans_')) {
          shouldRemove = true;
        }

        if (shouldRemove) {
          await prefs.remove(key);
          removed++;
        }
      }

      if (removed > 0) {
        developer.log(
          'cleanupLegacyKeys: $removed key lama dihapus dari SharedPreferences.',
          name: 'FormDraftService',
        );
      }
    } catch (e) {
      developer.log(
        'cleanupLegacyKeys gagal: $e',
        name: 'FormDraftService',
        error: e,
      );
    }
  }
}
