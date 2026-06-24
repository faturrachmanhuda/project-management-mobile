import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/modelbikinproyek.dart';
import '../services/project_service.dart';
import '../services/api_service.dart';
import '../services/api_config.dart';
import '../database/db_helper.dart';
import '../services/sync_service.dart';

/// ViewModel untuk manajemen proyek (CRUD Project, Work, Activity).
///
/// Menghubungi UI dengan [ProjectService].
/// Menyimpan state: projects, isLoading, error.
///
/// ARSIREKTUR BARU:
/// - Source of truth adalah Django, bukan lokal
/// - Tidak ada lagi save ke SQLite sebelum konfirmasi server
/// - Remote SELALU menang untuk data bisnis
/// - Jika server gagal, TIDAK ada fallback ke data lokal
class ProyekViewModel extends ChangeNotifier {
  final ProyekService _layananProyek;

  ProyekViewModel({ProyekService? proyekService})
    : _layananProyek = proyekService ?? ProyekService() {
    SyncService().addListener(_onSyncChanged);
  }

  void _onSyncChanged() {
    muatUlang();
  }

  @override
  void dispose() {
    SyncService().removeListener(_onSyncChanged);
    super.dispose();
  }

  final List<Proyek> _daftarProyek = [];
  String _cari = '';
  bool _termuat = false;
  bool _sedangMemuat = false;
  String? _pesanError;

  // Submission state per project local id
  final Map<String, String> _submitStatus = {}; // pending, success, failed
  final Map<String, String?> _submitErrorMessage = {};
  final Map<String, Map<String, dynamic>?> _submitBroadcastStatus = {};

  List<Proyek> get daftarProyek => List.unmodifiable(_daftarProyek);
  bool get sedangMemuat => _sedangMemuat;
  String? get pesanError => _pesanError;

  List<Proyek> get daftarProyekTerfilter {
    if (_cari.trim().isEmpty) return List.unmodifiable(_daftarProyek);
    final kunci = _cari.toLowerCase();
    return _daftarProyek
        .where(
          (p) =>
              p.nama.toLowerCase().contains(kunci) ||
              p.deskripsi.toLowerCase().contains(kunci) ||
              p.tim.toLowerCase().contains(kunci),
        )
        .toList(growable: false);
  }

  /// Get submission status for a project id (local id)
  String? getSubmitStatus(String projectId) => _submitStatus[projectId];
  String? getSubmitError(String projectId) => _submitErrorMessage[projectId];
  Map<String, dynamic>? getSubmitBroadcast(String projectId) => _submitBroadcastStatus[projectId];

  // ─── Load ─────────────────────────────────────────────────────────────────

  /// Muat proyek dari API. Hanya fetch jika belum pernah dimuat.
  Future<void> muatProyek() async {
    if (_termuat) return;
    await _ambilDaftarProyek();
  }

  /// Paksa reload dari API (dipanggil setelah login berhasil).
  Future<void> muatUlang() async {
    _termuat = false;
    _pesanError = null;
    await _ambilDaftarProyek();
  }

  /// Reset semua data (dipanggil setelah logout).
  void aturUlang() {
    _daftarProyek.clear();
    _termuat = false;
    _pesanError = null;
    _sedangMemuat = false;
    notifyListeners();
  }

  Future<void> _ambilDaftarProyek() async {
    _sedangMemuat = true;
    _pesanError = null;
    notifyListeners();

    try {
      if (ApiConfig.useLocalOnly) {
        if (kIsWeb) {
          _daftarProyek.clear();
        } else {
          // AMBIL DARI SQLITE LOKAL
          final proyekLokal = await DBHelper.instance.getFullProjects();
          _daftarProyek..clear()..addAll(proyekLokal);
          _termuat = true;
        }
      } else {
        // AMBIL DARI API DJANGO (Data sudah nested: Proyek -> Pekerjaan -> Aktivitas)
        final proyekApi = await _layananProyek.getProjects();
        _daftarProyek..clear()..addAll(proyekApi);
        _termuat = true;
      }
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        _pesanError = 'Sesi habis. Silakan login ulang.';
      } else {
        _pesanError = 'Gagal memuat proyek: ${e.message}';
      }
    } catch (e) {
      debugPrint('Error ambilProyek: $e');
      if (ApiConfig.useLocalOnly) {
        _pesanError = 'Gagal memuat proyek lokal: $e';
      } else {
        _pesanError = 'Gagal memuat proyek. Pastikan server Django aktif.';
      }
    }

    _sedangMemuat = false;
    notifyListeners();
  }

  // ─── Search ───────────────────────────────────────────────────────────────

  void aturPencarian(String kataKunci) {
    _cari = kataKunci;
    notifyListeners();
  }

  // ─── Create ───────────────────────────────────────────────────────────────

  /// Tambah proyek baru
  /// 
  /// ARSIREKTUR BARU:
  /// - Langsung kirim ke server, JANGAN simpan ke lokal dulu
  /// - Jika server berhasil, baru tambahkan ke list dari response server
  /// - Jika server gagal, TIDAK ada fallback - tampilkan error ke user
  /// - Source of truth adalah Django
  Future<void> tambahProyek(Proyek proyek) async {
    // Generate ID lokal dulu untuk tracking, tapi JANGAN masukkan ke list sebelum konfirmasi server
    final String idBaru = proyek.id.isEmpty
        ? 'LCL-${DateTime.now().millisecondsSinceEpoch}'
        : proyek.id;

    // Assign ID ke pekerjaan dan aktivitas
    final proyekDenganId = proyek.copyWith(
      id: idBaru,
      daftarPekerjaan: proyek.daftarPekerjaan.asMap().entries.map((e) {
        final j = e.value;
        return j.copyWith(
          idProyek: idBaru,
          id: j.id.isEmpty ? 'JOB-${DateTime.now().millisecondsSinceEpoch}-${e.key}' : j.id,
          judulProyek: proyek.nama,
        );
      }).toList(),
      daftarKegiatan: proyek.daftarKegiatan.asMap().entries.map((e) {
        final a = e.value;
        return a.copyWith(
          idProyek: idBaru,
          id: a.id.isEmpty ? 'ACT-${DateTime.now().millisecondsSinceEpoch}-${e.key}' : a.id,
          judulProyek: proyek.nama,
        );
      }).toList(),
    );

    // Langsung kirim ke server - JANGAN simpan ke lokal dulu
    await _buatProyekDiServer(proyekDenganId);
  }

  /// Buat proyek ke Django server.
  Future<void> _buatProyekDiServer(Proyek proyek) async {
    try {
      if (ApiConfig.useLocalOnly) {
        // Mode lokal hanya untuk pengembangan
        _daftarProyek.insert(0, proyek.copyWith(isTersinkron: false));
        _submitStatus[proyek.id] = 'success';
        notifyListeners();
        return;
      }

      // Kirim ke Django
      final proyekServer = await _layananProyek.createProject(Proyek(
        id: proyek.id,
        nama: proyek.nama,
        deskripsi: proyek.deskripsi,
        lokasi: proyek.lokasi,
        tanggalMulai: proyek.tanggalMulai,
        tanggalSelesai: proyek.tanggalSelesai,
        tim: proyek.tim,
        pengawas: proyek.pengawas,
        isTertutup: proyek.isTertutup,
        daftarPekerjaan: proyek.daftarPekerjaan,
        daftarKegiatan: proyek.daftarKegiatan,
      ));

      debugPrint('Proyek berhasil dibuat di server: ${proyekServer.id}');

      // Jika Django mengembalikan status broadcast, simpan agar UI bisa menampilkannya
      if (proyekServer.broadcastStatus != null) {
        _submitBroadcastStatus[proyek.id] = proyekServer.broadcastStatus;
      }

      // BARU tambahkan ke list dari response server (Remote SELALU menang)
      final proyekSinkron = proyekServer.copyWith(isTersinkron: true);
      _daftarProyek.insert(0, proyekSinkron);
      _submitStatus[proyek.id] = 'success';
      notifyListeners();

    } catch (e) {
      debugPrint('Gagal kirim proyek ke server: $e');

      // Extract message if ApiException
      String message = 'Gagal mengirim proyek.';
      if (e is ApiException) message = e.message;
      
      // TIDAK ada fallback ke lokal - server adalah source of truth
      _submitStatus[proyek.id] = 'failed';
      _submitErrorMessage[proyek.id] = message;
      notifyListeners();
      
      rethrow;
    }
  }

  // ─── Update ───────────────────────────────────────────────────────────────

  void perbaruiProyek(Proyek proyekLama, Proyek proyekBaru) {
    final index = _daftarProyek.indexWhere((p) => p.id == proyekLama.id);
    if (index == -1) return;
    _daftarProyek[index] = proyekBaru;
    notifyListeners();
    unawaited(_perbaruiProyekRemote(proyekBaru));
  }

  void tambahPekerjaanDalamProyek(String projectId, ItemPekerjaan pekerjaanBaru) {
    final index = _daftarProyek.indexWhere((p) => p.id == projectId);
    if (index == -1) return;

    final proyekLama = _daftarProyek[index];
    final updatedWorks = [
      pekerjaanBaru.copyWith(
        idProyek: proyekLama.id,
        judulProyek: proyekLama.nama,
      ),
      ...proyekLama.daftarPekerjaan,
    ];

    final proyekBaru = proyekLama.copyWith(daftarPekerjaan: updatedWorks);
    perbaruiProyek(proyekLama, proyekBaru);
  }

  void perbaruiPekerjaanDalamProyek(
    String projectId,
    ItemPekerjaan pekerjaanLama,
    ItemPekerjaan pekerjaanBaru,
  ) {
    final index = _daftarProyek.indexWhere((p) => p.id == projectId);
    if (index == -1) return;

    final proyekLama = _daftarProyek[index];
    final updatedWorks = proyekLama.daftarPekerjaan.map((pekerjaan) {
      if (pekerjaan.id != pekerjaanLama.id) return pekerjaan;
      return pekerjaanBaru.copyWith(
        id: pekerjaanLama.id,
        idProyek: proyekLama.id,
        judulProyek: proyekLama.nama,
      );
    }).toList(growable: false);

    final updatedActivities = proyekLama.daftarKegiatan.map((activity) {
      if (activity.idPekerjaan != pekerjaanLama.id &&
          activity.pekerjaan != pekerjaanLama.nama) {
        return activity;
      }
      return activity.copyWith(
        idProyek: proyekLama.id,
        judulProyek: proyekLama.nama,
        idPekerjaan: pekerjaanLama.id,
        pekerjaan: pekerjaanBaru.nama,
      );
    }).toList(growable: false);

    final proyekBaru = proyekLama.copyWith(
      daftarPekerjaan: updatedWorks,
      daftarKegiatan: updatedActivities,
    );
    perbaruiProyek(proyekLama, proyekBaru);
  }

  void hapusPekerjaanDalamProyek(String projectId, String workId) {
    final index = _daftarProyek.indexWhere((p) => p.id == projectId);
    if (index == -1) return;

    final proyekLama = _daftarProyek[index];
    final workToRemove = proyekLama.daftarPekerjaan
        .where((pekerjaan) => pekerjaan.id == workId)
        .toList(growable: false);

    final workTitle = workToRemove.isNotEmpty ? workToRemove.first.nama : '';
    final updatedWorks = proyekLama.daftarPekerjaan
        .where((pekerjaan) => pekerjaan.id != workId)
        .toList(growable: false);
    final updatedActivities = proyekLama.daftarKegiatan
        .where(
          (activity) =>
              activity.idPekerjaan != workId &&
              activity.pekerjaan != workTitle,
        )
        .toList(growable: false);

    final proyekBaru = proyekLama.copyWith(
      daftarPekerjaan: updatedWorks,
      daftarKegiatan: updatedActivities,
    );
    perbaruiProyek(proyekLama, proyekBaru);
  }

  void tambahKegiatanDalamProyek(String projectId, ItemKegiatan kegiatanBaru) {
    final index = _daftarProyek.indexWhere((p) => p.id == projectId);
    if (index == -1) return;

    final proyekLama = _daftarProyek[index];
    final updatedActivities = [
      kegiatanBaru.copyWith(
        idProyek: proyekLama.id,
        judulProyek: proyekLama.nama,
        isTersinkron: false,
      ),
      ...proyekLama.daftarKegiatan,
    ];

    final proyekBaru = proyekLama.copyWith(daftarKegiatan: updatedActivities);
    perbaruiProyek(proyekLama, proyekBaru);
  }

  void perbaruiKegiatanDalamProyek(
    String projectId,
    ItemKegiatan kegiatanLama,
    ItemKegiatan kegiatanBaru,
  ) {
    final index = _daftarProyek.indexWhere((p) => p.id == projectId);
    if (index == -1) return;

    final proyekLama = _daftarProyek[index];
    final updatedActivities = proyekLama.daftarKegiatan.map((act) {
      if (act.id != kegiatanLama.id) return act;
      return kegiatanBaru.copyWith(
        id: kegiatanLama.id,
        idProyek: proyekLama.id,
        judulProyek: proyekLama.nama,
        isTersinkron: false,
      );
    }).toList(growable: false);

    final proyekBaru = proyekLama.copyWith(daftarKegiatan: updatedActivities);
    perbaruiProyek(proyekLama, proyekBaru);
  }

  void hapusKegiatanDalamProyek(String projectId, String kegiatanId) {
    final index = _daftarProyek.indexWhere((p) => p.id == projectId);
    if (index == -1) return;

    final proyekLama = _daftarProyek[index];
    final updatedActivities = proyekLama.daftarKegiatan
        .where((act) => act.id != kegiatanId)
        .toList(growable: false);

    final proyekBaru = proyekLama.copyWith(daftarKegiatan: updatedActivities);
    
    _daftarProyek[index] = proyekBaru;
    notifyListeners();

    if (!ApiConfig.useLocalOnly && kegiatanId.isNotEmpty && !kegiatanId.startsWith('ACT-')) {
      unawaited(_layananProyek.deleteActivity(kegiatanId));
    }
  }

  void tutupProyek(Proyek proyek) {
    final index = _daftarProyek.indexWhere((p) => p.id == proyek.id);
    if (index == -1) return;
    _daftarProyek[index] = proyek.copyWith(
      isTertutup: true,
      status: 'Selesai',
    );
    notifyListeners();
    unawaited(_perbaruiProyekRemote(_daftarProyek[index]));
  }

  void tutupProyekBerdasarkanJudul(String judul) {
    final index = _daftarProyek.indexWhere((p) => p.nama == judul);
    if (index == -1) return;
    _daftarProyek[index] = _daftarProyek[index].copyWith(
      isTertutup: true,
      status: 'Selesai',
    );
    notifyListeners();
    unawaited(_perbaruiProyekRemote(_daftarProyek[index]));
  }

  void tutupProyekBerdasarkanId(String id) {
    final index = _daftarProyek.indexWhere((p) => p.id == id);
    if (index == -1) return;
    _daftarProyek[index] = _daftarProyek[index].copyWith(
      isTertutup: true,
      status: 'Selesai',
    );
    notifyListeners();
    unawaited(_perbaruiProyekRemote(_daftarProyek[index]));
  }

  Future<void> _perbaruiProyekRemote(Proyek proyek) async {
    try {
      if (!ApiConfig.useLocalOnly && proyek.id.isNotEmpty) {
        await _layananProyek.updateProject(proyek);
      }
    } catch (e) {
      debugPrint('Gagal update proyek: $e');
    }
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

  void hapusProyek(Proyek proyek) {
    _daftarProyek.removeWhere((p) => p.id == proyek.id);
    notifyListeners();
    unawaited(_hapusProyekRemote(proyek.id));
  }

  Future<void> _hapusProyekRemote(String id) async {
    try {
      if (!ApiConfig.useLocalOnly && id.isNotEmpty) {
        await _layananProyek.deleteProject(id);
      }
    } catch (e) {
      debugPrint('Gagal hapus proyek: $e');
    }
  }
}