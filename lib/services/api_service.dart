import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'api_config.dart';

/// [ApiService] adalah satu-satunya pintu komunikasi antara Flutter dan Django.
///
/// Tanggung jawab:
/// - Menyimpan token JWT secara in-memory (tidak di SharedPreferences)
/// - Menyisipkan header `Authorization: Bearer <token>` secara otomatis
/// - Menyediakan metode HTTP dasar: get, post, put, patch, delete
/// - Menangani login (simpan token) dan logout (hapus token)
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static String get baseUrl => ApiConfig.baseUrl;

  // ─── Token In-Memory ─────────────────────────────────────────────────────
  // Token hanya disimpan sementara di memori selama sesi berjalan.
  // Tidak ada persistensi ke SharedPreferences.

  String? _accessToken;
  String? _refreshToken;

  String? getAccessToken() => _accessToken;
  String? getRefreshToken() => _refreshToken;

  void saveTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  bool get isLoggedIn {
    return _accessToken != null && _accessToken!.isNotEmpty;
  }

  // Penyimpanan sementara untuk mode LocalOnly (agar data yang dibuat tetap ada selama app jalan)
  static final Map<String, List<Map<String, dynamic>>> _localStore = {
    '/proyek/': [],
    '/pekerjaan/': [],
    '/aktivitas/': [],
  };

  // ─── Headers ─────────────────────────────────────────────────────────────

  Map<String, String> _headers({bool withAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth) {
      final token = getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ─── HTTP Methods ─────────────────────────────────────────────────────────

  /// GET request. Mengembalikan body yang sudah di-decode (Map atau List).
  Future<dynamic> get(String endpoint) async {
    if (ApiConfig.useLocalOnly) {
      developer.log('LOCAL-ONLY: GET bypass → $endpoint', name: 'ApiService');
      
      // Mock Data untuk User Me
      if (endpoint.contains('/auth/me/')) {
        return {
          'id': 'local_user',
          'username': 'localuser',
          'email': 'user@local.com',
          'name': 'Local User',
          'nim': '123456789',
        };
      }

      // Ambil dari storage lokal berdasarkan kecocokan endpoint
      if (endpoint.contains('/proyek/')) return _localStore['/proyek/'];
      if (endpoint.contains('/pekerjaan/')) return _localStore['/pekerjaan/'];
      if (endpoint.contains('/aktivitas/')) return _localStore['/aktivitas/'];

      return []; // Default empty
    }
    final url = Uri.parse('$baseUrl$endpoint');
    developer.log('GET → $url', name: 'ApiService');

    final response = await http
        .get(url, headers: _headers())
        .timeout(const Duration(seconds: 15));

    developer.log('← ${response.statusCode}', name: 'ApiService');
    return _handleResponse(response);
  }

  /// GET request untuk data binary seperti PDF atau file unduhan.
  Future<Uint8List> getBytes(
    String endpoint, {
    bool withAuth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    developer.log('GET BYTES → $url', name: 'ApiService');

    final response = await http
        .get(url, headers: _headers(withAuth: withAuth))
        .timeout(const Duration(seconds: 30));

    developer.log('← ${response.statusCode}', name: 'ApiService');

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }

    if (response.statusCode == 401) {
      throw ApiException(
        statusCode: 401,
        message: 'Sesi habis. Silakan login ulang.',
      );
    }

    final body = _tryDecodeBody(response.body);
    final errorMsg = _extractErrorMessage(body, fallback: 'Request gagal.');

    throw ApiException(statusCode: response.statusCode, message: errorMsg);
  }

  /// POST request. Mengembalikan body yang sudah di-decode.
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool withAuth = true,
  }) async {
    if (ApiConfig.useLocalOnly) {
      developer.log('LOCAL-ONLY: POST bypass → $endpoint', name: 'ApiService');
      
      // Simpan data baru ke storage lokal agar bisa di-fetch lewat GET nanti
      final dataWithId = Map<String, dynamic>.from(body);
      if (dataWithId['id'] == null) {
        dataWithId['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      }

      if (endpoint.contains('/proyek/')) _localStore['/proyek/']!.add(dataWithId);
      if (endpoint.contains('/pekerjaan/')) _localStore['/pekerjaan/']!.add(dataWithId);
      if (endpoint.contains('/aktivitas/')) _localStore['/aktivitas/']!.add(dataWithId);

      return dataWithId; 
    }
    final url = Uri.parse('$baseUrl$endpoint');
    developer.log('POST → $url', name: 'ApiService');

    final response = await http
        .post(url,
            headers: _headers(withAuth: withAuth),
            body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));

    developer.log('← ${response.statusCode}', name: 'ApiService');
    return _handleResponse(response, expectedStatus: 201);
  }

  /// PUT request. Mengembalikan body yang sudah di-decode.
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    if (ApiConfig.useLocalOnly) {
      developer.log('LOCAL-ONLY: PUT bypass → $endpoint', name: 'ApiService');
      return body;
    }
    final url = Uri.parse('$baseUrl$endpoint');
    developer.log('PUT → $url', name: 'ApiService');

    final response = await http
        .put(url, headers: _headers(), body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));

    developer.log('← ${response.statusCode}', name: 'ApiService');
    return _handleResponse(response);
  }

  /// PATCH request. Mengembalikan body yang sudah di-decode.
  Future<dynamic> patch(String endpoint, Map<String, dynamic> body) async {
    if (ApiConfig.useLocalOnly) {
      developer.log('LOCAL-ONLY: PATCH bypass → $endpoint', name: 'ApiService');
      return body;
    }
    final url = Uri.parse('$baseUrl$endpoint');
    developer.log('PATCH → $url', name: 'ApiService');

    final response = await http
        .patch(url, headers: _headers(), body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));

    developer.log('← ${response.statusCode}', name: 'ApiService');
    return _handleResponse(response);
  }

  /// POST Multipart request untuk upload file. Mengembalikan body yang di-decode.
  Future<dynamic> postMultipart(
    String endpoint,
    Map<String, String> fields,
    String? filePath,
    String fileField, {
    List<int>? fileBytes,
    bool withAuth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    developer.log('POST Multipart → $url', name: 'ApiService');

    final request = http.MultipartRequest('POST', url);
    request.headers.addAll(_headers(withAuth: withAuth));
    request.headers.remove('Content-Type');

    request.fields.addAll(fields);

    if (filePath != null && filePath.isNotEmpty && !filePath.startsWith('blob:')) {
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    } else if (fileBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        fileField,
        fileBytes,
        filename: fields['fileName'] ?? 'upload.dat',
      ));
    }

    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);

    developer.log('← ${response.statusCode}', name: 'ApiService');
    return _handleResponse(response, expectedStatus: 201);
  }

  /// PUT Multipart request untuk update dengan file. Mengembalikan body yang di-decode.
  Future<dynamic> putMultipart(
    String endpoint,
    Map<String, String> fields,
    String? filePath,
    String fileField, {
    List<int>? fileBytes,
    bool withAuth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    developer.log('PUT Multipart → $url', name: 'ApiService');

    final request = http.MultipartRequest('PUT', url);
    request.headers.addAll(_headers(withAuth: withAuth));
    request.headers.remove('Content-Type');

    request.fields.addAll(fields);

    if (filePath != null && filePath.isNotEmpty && !filePath.startsWith('blob:')) {
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    } else if (fileBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        fileField,
        fileBytes,
        filename: fields['fileName'] ?? 'upload.dat',
      ));
    }

    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);

    developer.log('← ${response.statusCode}', name: 'ApiService');
    return _handleResponse(response);
  }

  /// PATCH Multipart request untuk update dengan file. Mengembalikan body yang di-decode.
  Future<dynamic> patchMultipart(
    String endpoint,
    Map<String, String> fields,
    String? filePath,
    String fileField, {
    List<int>? fileBytes,
    bool withAuth = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    developer.log('PATCH Multipart → $url', name: 'ApiService');

    final request = http.MultipartRequest('PATCH', url);
    request.headers.addAll(_headers(withAuth: withAuth));
    request.headers.remove('Content-Type');

    request.fields.addAll(fields);

    if (filePath != null && filePath.isNotEmpty && !filePath.startsWith('blob:')) {
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    } else if (fileBytes != null) {
      request.files.add(http.MultipartFile.fromBytes(
        fileField,
        fileBytes,
        filename: fields['fileName'] ?? 'upload.dat',
      ));
    }

    final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);

    developer.log('← ${response.statusCode}', name: 'ApiService');
    return _handleResponse(response);
  }

  /// DELETE request. Tidak mengembalikan body (204 No Content).
  Future<void> delete(String endpoint) async {
    if (ApiConfig.useLocalOnly) {
      developer.log('LOCAL-ONLY: DELETE bypass → $endpoint', name: 'ApiService');
      return;
    }
    final url = Uri.parse('$baseUrl$endpoint');
    developer.log('DELETE → $url', name: 'ApiService');

    final response = await http
        .delete(url, headers: _headers())
        .timeout(const Duration(seconds: 15));

    developer.log('← ${response.statusCode}', name: 'ApiService');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'DELETE gagal: ${response.body}',
      );
    }
  }

  // ─── Auth Helpers ─────────────────────────────────────────────────────────

  /// Login ke Django custom endpoint.
  /// POST /api/auth/login/ → simpan access token ke in-memory.
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (ApiConfig.useLocalOnly) {
      developer.log('LOCAL-ONLY: Login bypass', name: 'ApiService');
      final mockData = {
        'token': 'mock_token_for_local_mode',
        'user': {
          'id': 'local_user',
          'username': email.split('@')[0],
          'email': email,
          'name': 'Local User',
          'nim': '123456789',
        }
      };
      saveTokens(accessToken: 'mock_token', refreshToken: '');
      return mockData;
    }
    final url = Uri.parse('$baseUrl/api/auth/login/');
    developer.log('LOGIN → $url', name: 'ApiService');

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 15));

    developer.log('← ${response.statusCode}', name: 'ApiService');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = (data['access'] ?? data['token']) as String?;
      final refreshToken = (data['refresh'] ?? '') as String;
      
      if (token != null) {
        saveTokens(
          accessToken: token,
          refreshToken: refreshToken,
        );
      }
      return data;
    }

    final body = _tryDecodeBody(response.body);
    
    final errorMsg = _extractErrorMessage(body, fallback: 'Login gagal.');

    throw ApiException(
      statusCode: response.statusCode,
      message: errorMsg,
    );
  }

  dynamic _handleResponse(http.Response response, {int expectedStatus = 200}) {
    final ok = response.statusCode == expectedStatus ||
        response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204;

    if (ok) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      throw ApiException(
        statusCode: 401,
        message: 'Sesi habis. Silakan login ulang.',
      );
    }

    final body = _tryDecodeBody(response.body);
    
    final errorMsg = _extractErrorMessage(body, fallback: 'Request gagal.');

    throw ApiException(
      statusCode: response.statusCode,
      message: errorMsg,
    );
  }

  Map<String, dynamic> _tryDecodeBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return {};
  }

  String _extractErrorMessage(
    Map<String, dynamic> body, {
    required String fallback,
  }) {
    for (final key in ['detail', 'message', 'error']) {
      final value = body[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    for (final entry in body.entries) {
      if (entry.key == 'success') continue;
      final value = entry.value;
      if (value is List && value.isNotEmpty) {
        return '${entry.key}: ${value.first}';
      }
      if (value != null && value.toString().trim().isNotEmpty) {
        return '${entry.key}: $value';
      }
    }

    return fallback;
  }
}

/// Exception kustom yang membawa status code HTTP.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
