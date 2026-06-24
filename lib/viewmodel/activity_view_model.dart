import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/activity_model.dart';
import '../services/project_service.dart';
import '../database/db_helper.dart';
import '../services/api_config.dart';

/// ViewModel untuk manajemen aktivitas.
/// 
/// ARSITEKTUR BARU:
/// - Source of truth adalah Django, bukan lokal
/// - Tidak ada lagi pembuatan aktivitas lokal sebelum server menyetujui
/// - Semua create/update/delete harus melalui API Django
/// - Setelah operasi berhasil, Flutter me-refresh data dari server
/// - Foto aktivitas disimpan in-memory saja (tidak ke SharedPreferences)
class ActivitiesViewModel extends ChangeNotifier {
  ActivitiesViewModel({
    ProyekService? proyekService,
    this.onHitungBerubah,
  }) : _layananProyek = proyekService ?? ProyekService();

  final ProyekService _layananProyek;

  /// Callback opsional: dipanggil setiap kali jumlah aktivitas berubah.
  /// Parameter: (idPekerjaan, total, selesai)
  final void Function(String idPekerjaan, int total, int selesai)? onHitungBerubah;

  final List<Kegiatans> _daftarActivities = [];

  // Foto aktivitas disimpan in-memory selama sesi berjalan.
  // Tidak perlu dipersistensikan — URL foto sudah ada di data server.
  final Map<String, List<String>> _fotoActivities = {};

  String statusTerpilih = 'all';
  String kataKunciCari = '';
  String _judulPekerjaan = '';
  String _judulProyek = '';
  String _idProyek = ''; 
  String _idPekerjaan = '';

  List<Kegiatans> get activities => List.unmodifiable(_daftarActivities);
  List<String> ambilFoto(String idActivities) =>
      List.unmodifiable(_fotoActivities[idActivities] ?? const []);

  List<Kegiatans> get daftarActivitiesTerfilter {
    return _daftarActivities.where((item) {
      final statusCocok =
          statusTerpilih == 'all' || item.status == statusTerpilih;
      final cariCocok = kataKunciCari.trim().isEmpty ||
          item.title.toLowerCase().contains(kataKunciCari.toLowerCase()) ||
          item.desc.toLowerCase().contains(kataKunciCari.toLowerCase());
      return statusCocok && cariCocok;
    }).toList(growable: false);
  }

  // Alias for backward compatibility
  List<Kegiatans> get daftarKegiatanTerfilter => daftarActivitiesTerfilter;

  Future<void> init(String judulPekerjaan, String judulProyek, {String idPekerjaan = '', String idProyek = ''}) async {
    _judulPekerjaan = judulPekerjaan;
    _judulProyek = judulProyek;
    _idPekerjaan = idPekerjaan;
    _idProyek = idProyek;
    
    await muatActivities();
  }

  /// Muat activities dari SERVER (Django adalah source of truth).
  Future<void> muatActivities() async {
    if (ApiConfig.useLocalOnly) {
      await _muatActivitiesDariLokal();
      return;
    }

    final workId = _idPekerjaan;
    try {
      final remoteActivities = await _layananProyek.getActivities(
        workId: workId.isNotEmpty ? workId : null,
      );

      final filtered = workId.isNotEmpty
          ? remoteActivities
          : remoteActivities.where((a) {
              final matchJob = _judulPekerjaan.isEmpty || a.jobTitle == _judulPekerjaan;
              return matchJob;
            }).toList();

      _daftarActivities..clear()..addAll(filtered);
      notifyListeners();
      _beritahuJumlah();

      debugPrint('Activities dimuat dari server: ${_daftarActivities.length}');
    } catch (e) {
      debugPrint('Gagal muat activities dari server: $e');
      // Tidak ada fallback ke SQLite — empty state lebih jujur ke user
      notifyListeners();
    }
  }

  Future<void> _muatActivitiesDariLokal() async {
    // Hanya dipakai di mode useLocalOnly
    try {
      if (!kIsWeb) {
        final localActivities = await DBHelper.instance.getActivitiesByJobTitle(
          _judulPekerjaan,
          projectId: _idProyek,
        );
        if (localActivities.isNotEmpty) {
          _daftarActivities..clear()..addAll(localActivities);
          notifyListeners();
          _beritahuJumlah();
        }
      }
    } catch (e) {
      debugPrint('Gagal muat activities lokal: $e');
    }
  }

  /// Tambah activities melalui server.
  Future<Kegiatans?> tambahActivities(Kegiatans activities) async {
    try {
      final serverActivity = await _layananProyek.createActivity(activities);
      _daftarActivities.insert(0, serverActivity);
      notifyListeners();
      _beritahuJumlah();
      return serverActivity;
    } catch (e) {
      debugPrint('Gagal membuat activities: $e');
      rethrow;
    }
  }

  // Alias for backward compatibility
  Future<Kegiatans?> tambahKegiatan(Kegiatans kegiatan) => tambahActivities(kegiatan);

  Future<void> hapusActivities(Kegiatans activities) async {
    final isLocalOnly = activities.id.startsWith('ACT-') || activities.isSynced == false;

    if (!isLocalOnly) {
      try {
        await _layananProyek.deleteActivity(activities.id);
      } catch (e) {
        debugPrint('Gagal hapus aktivitas dari server: $e');
        rethrow;
      }
    }

    _daftarActivities.removeWhere((item) => item.id == activities.id);
    _fotoActivities.remove(activities.id);
    notifyListeners();
    _beritahuJumlah();
  }

  // Alias for backward compatibility
  Future<void> hapusKegiatan(Kegiatans kegiatan) => hapusActivities(kegiatan);

  Future<bool> perbaruiStatus(String idActivities, String status) async {
    final index = _daftarActivities.indexWhere((item) => item.id == idActivities);
    if (index == -1) return false;

    final activities = _daftarActivities[index];
    if (activities.id.startsWith('ACT-') || activities.isSynced == false) {
      return false;
    }

    try {
      final bool selesai = status.toLowerCase() == 'selesai' || status.toLowerCase() == 'done';
      await _layananProyek.updateActivityStatus(id: idActivities, selesai: selesai);

      final updated = _daftarActivities[index].copyWith(status: status);
      _daftarActivities[index] = updated;
      notifyListeners();
      _beritahuJumlah();
      return true;
    } catch (e) {
      debugPrint('Gagal update: $e');
      return false;
    }
  }

  Future<bool> perbaruiActivities(Kegiatans activitiesLama, Kegiatans activitiesBaru) async {
    final index = _daftarActivities.indexWhere((item) => item.id == activitiesLama.id);
    if (index == -1) return false;

    if (activitiesLama.id.startsWith('ACT-') || activitiesLama.isSynced == false) {
      return false;
    }

    try {
      final serverActivity = await _layananProyek.updateActivity(activitiesBaru);
      _daftarActivities[index] = serverActivity;
      notifyListeners();
      _beritahuJumlah();
      return true;
    } catch (e) {
      debugPrint('Gagal update: $e');
      return false;
    }
  }

  // Alias for backward compatibility
  Future<bool> perbaruiKegiatan(Kegiatans kegiatanLama, Kegiatans kegiatanBaru) =>
      perbaruiActivities(kegiatanLama, kegiatanBaru);

  /// Tambah path foto ke in-memory (tidak dipersistensikan ke SharedPreferences).
  Future<String?> tambahPathFoto({
    required String idActivities,
    required List<String> paths,
    int maksFoto = 20,
  }) async {
    final current = List<String>.from(_fotoActivities[idActivities] ?? const []);
    if (current.length + paths.length > maksFoto) {
      return 'Maksimal $maksFoto foto.';
    }
    current.addAll(paths);
    _fotoActivities[idActivities] = current;
    notifyListeners();
    return null;
  }

  Future<void> hapusFotoPada(String idActivities, int index) async {
    final current = List<String>.from(_fotoActivities[idActivities] ?? const []);
    if (index < 0 || index >= current.length) return;
    current.removeAt(index);
    _fotoActivities[idActivities] = current;
    notifyListeners();
  }

  void aturStatus(String status) {
    statusTerpilih = status;
    notifyListeners();
  }

  void aturPencarian(String query) {
    kataKunciCari = query;
    notifyListeners();
  }

  void _beritahuJumlah() {
    if (_idPekerjaan.isNotEmpty && onHitungBerubah != null) {
      final total = _daftarActivities.length;
      final selesai = _daftarActivities.where((a) => a.status == 'selesai' || a.status == 'done').length;
      onHitungBerubah!(_idPekerjaan, total, selesai);
    }
  }
}
// Alias for backward compatibility: ' activitiesViewModel' → 'ActivitiesViewModel'
typedef KegiatanViewModel = ActivitiesViewModel;