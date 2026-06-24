import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../database/db_helper.dart';
import '../models/akun_model.dart';

/// ViewModel untuk autentikasi user.
///
/// Menghubungkan UI dengan [AuthService].
/// Menyimpan state: isLoading, isLoggedIn, currentUser, errorMessage.
/// Akun lokal (local_accounts) tidak lagi dipersistensikan ke SharedPreferences.
class AuthViewModel extends ChangeNotifier {
  final AuthService _layananAuth = AuthService();

  Map<String, dynamic>? _penggunaSaatIni;
  bool _sedangMemuat = false;
  String? _pesanError;

  // Temporary selected profile photo before saving
  Uint8List? _tempPhotoBytes;
  String? _tempPhotoPath;

  Uint8List? get tempPhotoBytes => _tempPhotoBytes;
  String? get tempPhotoPath => _tempPhotoPath;

  void setTempPhoto({Uint8List? bytes, String? path}) {
    _tempPhotoBytes = bytes;
    _tempPhotoPath = path;
    notifyListeners();
  }

  void clearTempPhoto() {
    _tempPhotoBytes = null;
    _tempPhotoPath = null;
    notifyListeners();
  }

  /// Callback dipanggil setelah login/register berhasil.
  /// Diset dari main.dart untuk memicu reload proyek.
  Future<void> Function()? saatLoginBerhasil;

  /// Callback dipanggil setelah logout.
  Future<void> Function()? saatLogout;

  Map<String, dynamic>? get penggunaSaatIni => _penggunaSaatIni;
  bool get sedangMemuat => _sedangMemuat;
  String? get pesanError => _pesanError;
  bool get apakahSudahLogin => _penggunaSaatIni != null;

  AuthViewModel() {
    _pulihkanSesi();
  }

  // ─── Session Restore ──────────────────────────────────────────────────────

  /// Coba pulihkan sesi dari cache lokal saat app dibuka.
  /// Token tidak dipersistensikan, sehingga sesi tidak bisa dipulihkan
  /// setelah app di-kill — user perlu login ulang.
  Future<void> _pulihkanSesi() async {
    final penggunaCache = await _layananAuth.getCachedUser();
    if (penggunaCache != null) {
      _penggunaSaatIni = penggunaCache;
      notifyListeners();
    }
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  /// Login dengan email/username dan password.
  /// Kembalikan `true` jika berhasil, `false` jika gagal.
  Future<bool> masuk(String emailAtauUsername, String kataSandi) async {
    _aturStatusMemuat(true);
    _hapusPesanError();

    try {
      final pengguna = await _layananAuth.login(emailAtauUsername, kataSandi);
      _penggunaSaatIni = pengguna;
      // Simpan akun ke SQLite saja (tidak lagi ke SharedPreferences)
      try {
        final akun = Akun(
          email: (pengguna['email'] ?? pengguna['username'] ?? '').toString(),
          username: (pengguna['username'] ?? '').toString(),
          nama: (pengguna['nama'] ?? pengguna['name'] ?? '').toString(),
          nim: (pengguna['nim'] ?? '').toString(),
          profilePicture: (pengguna['profile_picture_url'] ?? pengguna['profile_picture'] ?? '').toString(),
        );
        await DBHelper.instance.insertAkun(akun);
      } catch (_) {}
      notifyListeners();
      await saatLoginBerhasil?.call();
      return true;
    } on ApiException catch (e) {
      _pesanError = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _pesanError = 'Terjadi kesalahan jaringan: $e';
      notifyListeners();
      return false;
    } finally {
      _aturStatusMemuat(false);
    }
  }

  // ─── Register ─────────────────────────────────────────────────────────────

  /// Daftar akun baru.
  /// Kembalikan `true` jika berhasil, `false` jika gagal.
  Future<bool> daftar({
    required String namaLengkap,
    required String nim,
    required String email,
    required String kataSandi,
  }) async {
    _aturStatusMemuat(true);
    _hapusPesanError();

    try {
      final pengguna = await _layananAuth.register(
        namaLengkap: namaLengkap,
        nim: nim,
        email: email,
        password: kataSandi,
      );
      _penggunaSaatIni = pengguna;
      // Simpan akun yang baru didaftarkan ke SQLite saja
      try {
        final akun = Akun(
          email: (pengguna['email'] ?? email).toString(),
          username: (pengguna['username'] ?? '').toString(),
          nama: (pengguna['nama'] ?? pengguna['name'] ?? namaLengkap).toString(),
          nim: (pengguna['nim'] ?? nim).toString(),
          profilePicture: (pengguna['profile_picture_url'] ?? '').toString(),
        );
        await DBHelper.instance.insertAkun(akun);
      } catch (_) {}
      notifyListeners();
      await saatLoginBerhasil?.call();
      return true;
    } on ApiException catch (e) {
      _pesanError = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _pesanError = 'Terjadi kesalahan jaringan: $e';
      notifyListeners();
      return false;
    } finally {
      _aturStatusMemuat(false);
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> keluar() async {
    await _layananAuth.logout();
    _penggunaSaatIni = null;
    notifyListeners();
    await saatLogout?.call();
  }

  // ─── Profile Update ───────────────────────────────────────────────────────

  Future<bool> perbaruiProfil({
    String? nama,
    String? nim,
    String? pathFotoProfil,
    List<int>? bytesFotoProfil,
    String? namaFile,
  }) async {
    _aturStatusMemuat(true);
    _hapusPesanError();

    try {
      final pengguna = await _layananAuth.updateProfile(
        name: nama,
        nim: nim,
        profilePicturePath: pathFotoProfil,
        profilePictureBytes: bytesFotoProfil,
        fileName: namaFile,
      );

      // Evict the image from the cache so that it reloads properly
      try {
        final newUrl = (pengguna['profile_picture_url'] ?? pengguna['profile_picture'])?.toString();
        if (newUrl != null && newUrl.isNotEmpty) {
          final fullUrl = newUrl.startsWith('http') ? newUrl : '${ApiService.baseUrl}$newUrl';
          await NetworkImage(fullUrl).evict();
        }
      } catch (_) {}

      _penggunaSaatIni = pengguna;
      clearTempPhoto(); // clear temp photo state on success
      return true;
    } on ApiException catch (e) {
      _pesanError = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _pesanError = 'Terjadi kesalahan jaringan: $e';
      notifyListeners();
      return false;
    } finally {
      _aturStatusMemuat(false);
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _aturStatusMemuat(bool nilai) {
    _sedangMemuat = nilai;
    notifyListeners();
  }

  void _hapusPesanError() {
    _pesanError = null;
  }
}
