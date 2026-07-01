/// Konfigurasi URL server Django.
class ApiConfig {
  /// Production server URL
  static const String baseUrl = 'http://38.47.94.194/tif2/pm';

  /// Set ini ke [true] untuk mode lokal/offline.
  static const bool useLocalOnly = false;
  
  /// Laptop IP untuk replace local server URLs
  static const String laptopIp = '38.47.94.194';
}
