import 'dart:developer' as developer;

import 'api_service.dart';
import '../database/db_helper.dart';
import '../models/akun_model.dart';

/// [AuthService] menangani semua operasi autentikasi:
/// login, register, logout, ambil data user saat ini.
///
/// Semua komunikasi HTTP melalui [ApiService].
/// Data user di-cache ke SQLite saja — tidak ke SharedPreferences.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();

  // ─── Cache user in-memory ────────────────────────────────────────────────
  // User yang sedang login disimpan sementara di memori.
  Map<String, dynamic>? _cachedUser;

  // ─── Login ────────────────────────────────────────────────────────────────

  /// Login dengan email/username dan password.
  /// Jika berhasil: simpan token in-memory + user data ke SQLite, kembalikan user map.
  /// Jika gagal: lempar [ApiException].
  Future<Map<String, dynamic>> login(String emailOrUsername, String password) async {
    try {
      // ApiService.login sudah simpan token in-memory
      await _api.login(emailOrUsername, password);

      // Ambil data user setelah login berhasil
      final user = await getCurrentUser();
      await _saveUserData(user);
      developer.log('Login berhasil: ${user['username']}', name: 'AuthService');
      return user;
    } catch (e) {
      developer.log('Login gagal: $e', name: 'AuthService', error: e);
      rethrow;
    }
  }

  // ─── Register ─────────────────────────────────────────────────────────────

  /// Daftar akun baru.
  /// Jika berhasil: simpan token in-memory + user data ke SQLite, kembalikan user map.
  /// Jika gagal: lempar [ApiException].
  Future<Map<String, dynamic>> register({
    required String namaLengkap,
    required String nim,
    required String email,
    required String password,
  }) async {
    try {
      final data = await _api.post(
        '/api/auth/register/',
        {
          'nama': namaLengkap,
          'nim': nim,
          'email': email,
          'password': password,
        },
        withAuth: false,
      ) as Map<String, dynamic>;

      // Simpan token dari response register
      final accessToken = (data['access'] ?? data['token'] ?? '') as String;
      final refreshToken = (data['refresh'] ?? '') as String;

      if (accessToken.isNotEmpty) {
        _api.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }

      // Ambil data user yang lengkap
      final user = data['user'] as Map<String, dynamic>? ??
          {'username': namaLengkap, 'email': email};
      await _saveUserData(user);
      developer.log('Register berhasil: ${user['username']}', name: 'AuthService');
      return user;
    } catch (e) {
      developer.log('Register gagal: $e', name: 'AuthService', error: e);
      rethrow;
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  /// Hapus semua token dan data user dari memori dan SQLite.
  Future<void> logout() async {
    _api.clearTokens();
    _cachedUser = null;
    
    // Hapus semua akun di SQLite saat logout
    try {
      await DBHelper.instance.deleteAllAkun();
    } catch (e) {
      developer.log('Gagal hapus akun sementara: $e', name: 'AuthService');
    }
    
    developer.log('Logout berhasil', name: 'AuthService');
  }

  // ─── Current User ─────────────────────────────────────────────────────────

  /// Ambil data user saat ini dari server (GET /api/users/me/).
  /// Memerlukan token yang valid.
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _api.get('/api/users/me/') as Map<String, dynamic>;
    return response;
  }

  /// Update data user (nama, nim, atau profile_picture).
  /// Memerlukan token yang valid.
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? nim,
    String? profilePicturePath,
    List<int>? profilePictureBytes,
    String? fileName,
  }) async {
    final Map<String, String> fields = {};
    if (name != null) fields['nama'] = name;
    if (nim != null) fields['nim'] = nim;
    if (fileName != null) fields['fileName'] = fileName;

    dynamic response;
    if ((profilePicturePath != null && profilePicturePath.isNotEmpty) ||
        (profilePictureBytes != null && profilePictureBytes.isNotEmpty)) {
      response = await _api.patchMultipart(
        '/api/users/update_profile/',
        fields,
        profilePicturePath,
        'profile_picture',
        fileBytes: profilePictureBytes,
      );
    } else {
      response = await _api.patch('/api/users/update_profile/', fields);
    }

    final user = response as Map<String, dynamic>;
    await _saveUserData(user);
    return user;
  }

  /// Baca data user dari cache in-memory, lalu fallback ke SQLite.
  /// Tidak melakukan request ke server.
  Future<Map<String, dynamic>?> getCachedUser() async {
    // Cek cache in-memory lebih dulu
    if (_cachedUser != null) return _cachedUser;

    // Fallback: coba baca dari SQLite (untuk restore setelah app restart)
    // Namun karena token tidak dipersistensikan, session tidak bisa dipulihkan
    // setelah app di-kill. Return null agar user diminta login ulang.
    return null;
  }

  /// Apakah user sedang login (ada token di memori).
  bool get isLoggedIn => _api.isLoggedIn;

  // ─── Internal ─────────────────────────────────────────────────────────────

  Future<void> _saveUserData(Map<String, dynamic> user) async {
    // Simpan ke cache in-memory
    _cachedUser = user;

    // Simpan ke SQLite (tabel akun) untuk referensi profil
    try {
      final email = user['email']?.toString() ?? '';
      if (email.isNotEmpty) {
        final existingAkun = await DBHelper.instance.getAkunByEmail(email);
        final akunBaru = Akun(
          id: existingAkun?.id,
          email: email,
          username: user['username']?.toString(),
          nama: user['nama']?.toString() ?? user['name']?.toString() ?? user['username']?.toString(),
          nim: user['nim']?.toString(),
          profilePicture: (user['profile_picture_url'] ?? user['profile_picture'])?.toString(),
          isActive: 1, // Set aktif
        );
        
        // Hapus akun yang ada sebelumnya (hanya simpan 1 akun sementara)
        await DBHelper.instance.deleteAllAkun();
        await DBHelper.instance.insertAkun(akunBaru);
      }
    } catch (e) {
      developer.log('Gagal menyimpan akun ke SQLite: $e', name: 'AuthService');
    }
  }
}
