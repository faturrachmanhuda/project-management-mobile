import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/job.dart';
import '../services/project_service.dart';
import '../database/db_helper.dart';
import '../services/api_config.dart';
import 'package:uuid/uuid.dart';

class PekerjaanViewModel extends ChangeNotifier {
  PekerjaanViewModel({ProyekService? proyekService})
    : _layananProyek = proyekService ?? ProyekService();

  final ProyekService _layananProyek;
  List<Pekerjaan> daftarPekerjaan = [];

  // Cache untuk menghitung jumlah aktivitas per pekerjaan
  final Map<String, int> _petaTotalAktivitas = {};
  final Map<String, int> _petaAktivitasSelesai = {};

  String _judulProyek = '';
  String _idProyek = '';

  void init(String judulProyek, {String idProyek = ''}) {
    _judulProyek = judulProyek;
    _idProyek = idProyek;
    muatPekerjaan();
  }

  Future<void> muatPekerjaan() async {
    try {
      if (ApiConfig.useLocalOnly) {
        // Mode lokal hanya untuk dev tanpa server
        if (!kIsWeb && _idProyek.isNotEmpty) {
          final localJobs = await DBHelper.instance.getJobsByProjectId(_idProyek);
          daftarPekerjaan = _normalisasiDanDeduplikasi(localJobs);
        }
        notifyListeners();
        return;
      }

      // SERVER-FIRST: Django adalah source of truth
      List<Pekerjaan> terfilter;
      if (_idProyek.isNotEmpty) {
        terfilter = await _layananProyek.getWorks(projectId: _idProyek);
      } else {
        final semuaPekerjaanServer = await _layananProyek.getWorks();
        terfilter = semuaPekerjaanServer
            .where((j) => j.judulProyek == _judulProyek)
            .toList();
      }

      daftarPekerjaan = _normalisasiDanDeduplikasi(
        List<Pekerjaan>.from(terfilter),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal memuat pekerjaan: $e');
      // Tidak ada fallback ke SQLite — biarkan UI menampilkan empty state
      // agar user tahu ada masalah koneksi
      notifyListeners();
    }
  }

  List<Pekerjaan> get daftarPekerjaanTerfilter {
    return daftarPekerjaan;
  }

  /// Tambah pekerjaan baru — SERVER-FIRST.
  /// Kirim ke Django dulu, baru tambahkan ke list dari response server.
  /// Jika server gagal, pekerjaan TIDAK ditambahkan ke list.
  Future<void> tambahPekerjaan(Pekerjaan pekerjaan) async {
    if (ApiConfig.useLocalOnly) {
      // Mode lokal hanya untuk dev tanpa server
      final uuid = const Uuid();
      final pekerjaanLokal = pekerjaan.copyWith(
        id: pekerjaan.id.isEmpty
            ? 'JOB-${uuid.v4().replaceAll('-', '')}'
            : pekerjaan.id,
        idProyek: _idProyek,
        judulProyek: _judulProyek,
        isTersinkron: false,
      );
      daftarPekerjaan.add(pekerjaanLokal);
      notifyListeners();
      return;
    }

    try {
      final pekerjaanKirim = pekerjaan.copyWith(
        idProyek: _idProyek,
        judulProyek: _judulProyek,
      );

      // POST ke server — tunggu konfirmasi
      final pekerjaanServer = await _layananProyek.createWork(pekerjaanKirim);

      // Baru tambahkan ke list dari response server (ID dari server, bukan lokal)
      daftarPekerjaan.add(pekerjaanServer.copyWith(isTersinkron: true));
      notifyListeners();
    } catch (e) {
      debugPrint('Gagal tambah pekerjaan ke server: $e');
      rethrow;
    }
  }

  /// Hapus pekerjaan — SERVER-FIRST.
  Future<void> hapusPekerjaan(Pekerjaan pekerjaan) async {
    // Optimistic: hapus dari list dulu agar UI responsif
    daftarPekerjaan.remove(pekerjaan);
    notifyListeners();

    if (ApiConfig.useLocalOnly) {
      if (!kIsWeb) await DBHelper.instance.deleteJobModel(pekerjaan.id);
      return;
    }

    try {
      await _layananProyek.deleteWork(pekerjaan.id);
    } catch (e) {
      // Rollback jika server gagal
      debugPrint('Gagal hapus pekerjaan dari server: $e');
      daftarPekerjaan.add(pekerjaan);
      notifyListeners();
      rethrow;
    }
  }

  /// Perbarui pekerjaan — SERVER-FIRST.
  Future<void> perbaruiPekerjaan(Pekerjaan pekerjaanLama, Pekerjaan pekerjaanBaru) async {
    final index = daftarPekerjaan.indexWhere(
      (job) => job.id == pekerjaanLama.id,
    );
    if (index == -1) return;

    if (ApiConfig.useLocalOnly) {
      daftarPekerjaan[index] = pekerjaanBaru.copyWith(
        id: pekerjaanLama.id,
        judulProyek: _judulProyek,
        isTersinkron: false,
      );
      notifyListeners();
      return;
    }

    // Optimistic update
    final pekerjaanUpdate = pekerjaanBaru.copyWith(
      id: pekerjaanLama.id,
      idProyek: _idProyek,
      judulProyek: _judulProyek,
    );
    daftarPekerjaan[index] = pekerjaanUpdate;
    notifyListeners();

    try {
      final serverResult = await _layananProyek.updateWork(pekerjaanUpdate);
      daftarPekerjaan[index] = serverResult.copyWith(isTersinkron: true);
      notifyListeners();
    } catch (e) {
      // Rollback jika server gagal
      debugPrint('Gagal update pekerjaan di server: $e');
      daftarPekerjaan[index] = pekerjaanLama;
      notifyListeners();
      rethrow;
    }
  }

  /// Perbarui cache jumlah aktivitas untuk pekerjaan tertentu
  void perbaruiJumlahAktivitas(String idPekerjaan, int total, int selesai) {
    _petaTotalAktivitas[idPekerjaan] = total;
    _petaAktivitasSelesai[idPekerjaan] = selesai;
    notifyListeners();
  }

  int ambilJumlahAktivitas(String idPekerjaan) =>
      _petaTotalAktivitas[idPekerjaan] ?? 0;

  int ambilJumlahAktivitasSelesai(String idPekerjaan) =>
      _petaAktivitasSelesai[idPekerjaan] ?? 0;

  Future<void> isiPekerjaanAwal(List<Pekerjaan> daftarPekerjaanAwal) async {
    if (daftarPekerjaan.isNotEmpty || daftarPekerjaanAwal.isEmpty) return;
    // Hanya set data awal dari parent (misalnya dari ProyekViewModel yang sudah fetch server)
    // Tidak perlu simpan ke SQLite
    daftarPekerjaan = _normalisasiDanDeduplikasi(
      List<Pekerjaan>.from(daftarPekerjaanAwal),
    );
    notifyListeners();
  }


  List<Pekerjaan> _normalisasiDanDeduplikasi(List<Pekerjaan> sumber) {
    final byId = <String, Pekerjaan>{};
    final byIsi = <String, Pekerjaan>{};

    for (final item in sumber) {
      final normal = item;

      if (normal.id.isNotEmpty && byId.containsKey(normal.id)) {
        final prev = byId[normal.id]!;
        final keep = _pilihLebihBaik(prev, normal);
        byId[normal.id] = keep;
        continue;
      }

      final keyIsi = _tanpaIdKey(normal);
      if (byIsi.containsKey(keyIsi)) {
        final prev = byIsi[keyIsi]!;
        final keep = _pilihLebihBaik(prev, normal);
        byIsi[keyIsi] = keep;
        if (keep.id.isNotEmpty) {
          byId[keep.id] = keep;
        }
        continue;
      }

      byIsi[keyIsi] = normal;
      if (normal.id.isNotEmpty) {
        byId[normal.id] = normal;
      }
    }

    return byIsi.values.toList(growable: false);
  }

  String _tanpaIdKey(Pekerjaan p) {
    return [
      p.idProyek,
      p.judulProyek.trim().toLowerCase(),
      p.nama.trim().toLowerCase(),
      p.deskripsi.trim().toLowerCase(),
      p.lokasi.trim().toLowerCase(),
      p.tanggalMulai.trim(),
      p.tanggalSelesai.trim(),
      p.pelaksana.trim().toLowerCase(),
      p.pengawas.trim().toLowerCase(),
    ].join('|');
  }

  Pekerjaan _pilihLebihBaik(Pekerjaan a, Pekerjaan b) {
    if (a.isTersinkron != b.isTersinkron) {
      return a.isTersinkron ? a : b;
    }

    return b;
  }
}
