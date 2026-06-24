import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// [SyncService] sekarang menjadi service pasif.
/// 
/// Fungsi:
/// - Tidak lagi melakukan sync local-first untuk entitas inti (proyek, pekerjaan, aktivitas)
/// - Hanya menyediakan method untuk refresh data dari server
/// - Tidak melakukan merge antara data lokal dengan remote
/// - Source of truth adalah Django, bukan lokal
/// 
/// Catatan: Kelas ini tetap ada untuk backward compatibility dengan kode yang sudah ada,
/// tapi logika sync telah dinonaktifkan untuk entitas bisnis utama.
class SyncService with ChangeNotifier {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  /// Method ini sekarang NO-OP untuk entitas inti.
  /// Hanya notify listeners untuk trigger refresh dari UI.
  Future<void> syncData() async {
    developer.log('SyncService: syncData dipanggil - sekarang pasif, hanya notify', name: 'SyncService');
    // Tidak lagi melakukan sync lokal ke server
    // Data diambil ulang melalui API service masing-masing
    notifyListeners();
  }

  /// Ambil dan discard data dari server.
  /// Ini digunakan saat user ingin refresh data terbaru dari server.
  /// Hasilnya di-handle oleh masing-masing ViewModel yang memanggil API langsung.
  Future<void> fetchAndSaveRemoteData() async {
    developer.log('SyncService: fetchAndSaveRemoteData dipanggil - data akan di-fetch langsung oleh ViewModel', name: 'SyncService');
    // Sekarang ViewModel memanggil API langsung, tidak perlu melalui SyncService
    notifyListeners();
  }

  /// Force refresh - memberitahu semua listener untuk reload dari server.
  /// Ini digunakan setelah operasi CRUD berhasil untuk menyegarkan UI.
  Future<void> notifyRefresh() async {
    developer.log('SyncService: notifyRefresh dipanggil', name: 'SyncService');
    notifyListeners();
  }
}