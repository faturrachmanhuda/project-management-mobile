/// Konfigurasi URL server Django.
/// Untuk backend yang ada di folder `PROMANAGE/backend`, jalankan Django
/// di `http://127.0.0.1:8000` saat frontend Flutter dan backend ada di mesin yang sama.
class ApiConfig {
  // ============================================================
  // IP Configuration untuk berbagai environment:
  // - Android Emulator: gunakan '10.0.2.2' (alias ke localhost host machine)
  // - iOS Simulator: gunakan '127.0.0.1' atau 'localhost'
  // - Physical Device: gunakan IP komputer di network (misal: '192.168.x.x')
  // ============================================================
  
  // PILIH SALAH SATU SESUAI ENVIRONMENT:
  
  // Untuk Android Emulator (RECOMMENDED untuk testing)
  static const String laptopIp = '192.168.1.6';
  
  // Untuk Physical Device di WiFi yang sama (uncomment jika pakai HP real)
  // static const String laptopIp = '192.168.1.6';
  
  // Untuk iOS Simulator (uncomment jika pakai iOS)
  // static const String laptopIp = '127.0.0.1';

  /// Set ini ke [true] untuk "memutuskan hubungan" dengan Django
  /// dan menjalankan aplikasi dalam mode lokal/offline.
  static const bool useLocalOnly = false;

  static String get baseUrl => useLocalOnly ? '' : 'http://$laptopIp:8001';
}

