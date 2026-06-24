import 'package:flutter/foundation.dart';

import '../models/modelbikinproyek.dart';
import 'project_wizard_data.dart';

/// ViewModel untuk wizard pembuatan proyek 4-step.
///
/// Mengikuti arsitektur wizard fragment (mirip identity/address/contact/summary):
///   Step 0 → Data Proyek
///   Step 1 → Tambah Pekerjaan
///   Step 2 → Tambah Aktivitas
///   Step 3 → Konfirmasi (ringkasan semua data sebelum submit)
///
/// State wizard disimpan dalam [ProjectWizardData], serupa dengan [EntryData]
/// pada wizard data diri tetapi khusus untuk pembuatan proyek.
class CreateProjectWizardViewModel extends ChangeNotifier {
  // ─── Manajemen Langkah ───────────────────────────────────────────────────

  int _langkahSaatIni = 0;
  bool _sedangMenyimpan = false;
  final ProjectWizardData _data = ProjectWizardData();

  int get langkahSaatIni => _langkahSaatIni;
  bool get sedangMenyimpan => _sedangMenyimpan;

  // ─── Langkah 1: Data Proyek ──────────────────────────────────────────────

  String get namaProyek => _data.namaProyek;
  String get deskripsiProyek => _data.deskripsiProyek;
  String get lokasiProyek => _data.lokasiProyek;
  String get tanggalMulaiProyek => _data.tanggalMulaiProyek;
  String get tanggalSelesaiProyek => _data.tanggalSelesaiProyek;
  String get pelaksanaProyek => _data.pelaksanaProyek;
  String get pengawasProyek => _data.pengawasProyek;
  String get statusProyek => _data.statusProyek;

  /// Update data proyek dari form fields.
  void aturDataProyek({
    required String nama,
    required String deskripsi,
    required String lokasi,
    required String mulai,
    required String selesai,
    required String pelaksana,
    required String pengawas,
    required String status,
  }) {
    _data.namaProyek = nama;
    _data.deskripsiProyek = deskripsi;
    _data.lokasiProyek = lokasi;
    _data.tanggalMulaiProyek = mulai;
    _data.tanggalSelesaiProyek = selesai;
    _data.pelaksanaProyek = pelaksana;
    _data.pengawasProyek = pengawas;
    _data.statusProyek = status;
  }

  /// Validasi langkah 1: semua field wajib terisi.
  String? validasiLangkah1({
    required String nama,
    required String deskripsi,
    required String lokasi,
    required String mulai,
    required String selesai,
    required String pelaksana,
    required String pengawas,
  }) {
    if ([
      nama,
      deskripsi,
      lokasi,
      mulai,
      selesai,
      pelaksana,
      pengawas,
    ].any((e) => e.trim().isEmpty)) {
      return 'Lengkapi semua data proyek';
    }
    return null;
  }

  // ─── Langkah 2: Pekerjaan Sementara ──────────────────────────────────────

  List<ItemPekerjaan> get pekerjaanSementara =>
      List.unmodifiable(_data.daftarPekerjaan);

  /// Tambah pekerjaan sementara ke wizard.
  String? tambahPekerjaanSementara({
    required String nama,
    required String deskripsi,
    required String tempat,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String pelaksana,
    required String pengawas,
  }) {
    if ([
      nama,
      deskripsi,
      tempat,
      tanggalMulai,
      tanggalSelesai,
      pelaksana,
      pengawas,
    ].any((e) => e.trim().isEmpty)) {
      return 'Silakan lengkapi semua field pekerjaan';
    }

    _data.daftarPekerjaan.add(
      ItemPekerjaan(
        id: 'TEMP-JOB-${DateTime.now().millisecondsSinceEpoch}-${_data.daftarPekerjaan.length}',
        nama: nama.trim(),
        deskripsi: deskripsi.trim(),
        lokasi: tempat.trim(),
        tanggalMulai: tanggalMulai.trim(),
        tanggalSelesai: tanggalSelesai.trim(),
        pelaksana: pelaksana.trim(),
        pengawas: pengawas.trim(),
      ),
    );
    notifyListeners();
    return null;
  }

  /// Hapus pekerjaan sementara berdasarkan index.
  void hapusPekerjaanSementara(int index) {
    if (index < 0 || index >= _data.daftarPekerjaan.length) return;
    _data.daftarPekerjaan.removeAt(index);
    // Hapus aktivitas yang terkait pekerjaan ini
    _data.aktivitasSementara.removeWhere((key, _) => key == index);
    // Re-index aktivitas
    final reindexed = <int, List<ItemKegiatan>>{};
    _data.aktivitasSementara.forEach((key, value) {
      if (key > index) {
        reindexed[key - 1] = value;
      } else {
        reindexed[key] = value;
      }
    });
    _data.aktivitasSementara
      ..clear()
      ..addAll(reindexed);
    // Adjust selected work index
    if (_data.indeksPekerjaanTerpilih >= pekerjaanSementara.length &&
        pekerjaanSementara.isNotEmpty) {
      _data.indeksPekerjaanTerpilih = pekerjaanSementara.length - 1;
    } else if (pekerjaanSementara.isEmpty) {
      _data.indeksPekerjaanTerpilih = 0;
    }
    notifyListeners();
  }

  /// Validasi langkah 2: minimal 1 pekerjaan.
  String? validasiLangkah2() {
    if (pekerjaanSementara.isEmpty) {
      return 'Tambah minimal 1 pekerjaan';
    }
    return null;
  }

  // ─── Langkah 3: Aktivitas Sementara ──────────────────────────────────────

  Map<int, List<ItemKegiatan>> get aktivitasSementara =>
      Map.unmodifiable(_data.aktivitasSementara);
  int get indeksPekerjaanTerpilih => _data.indeksPekerjaanTerpilih;

  /// Ganti pekerjaan yang dipilih di dropdown langkah 3.
  void aturIndeksPekerjaanTerpilih(int indeks) {
    _data.indeksPekerjaanTerpilih = indeks;
    notifyListeners();
  }

  /// Ambil daftar aktivitas untuk pekerjaan yang sedang dipilih.
  List<ItemKegiatan> get aktivitasPekerjaanSaatIni => List.unmodifiable(
    _data.aktivitasSementara[_data.indeksPekerjaanTerpilih] ?? const [],
  );

  /// Tambah aktivitas sementara ke pekerjaan yang sedang dipilih.
  String? tambahAktivitasSementara({
    required String namaKegiatan,
    required String waktuPelaksanaan,
    required String pelaksana,
  }) {
    if ([
      namaKegiatan,
      waktuPelaksanaan,
      pelaksana,
    ].any((e) => e.trim().isEmpty)) {
      return 'Silakan lengkapi semua field aktivitas';
    }
    if (_data.indeksPekerjaanTerpilih < 0 ||
        _data.indeksPekerjaanTerpilih >= pekerjaanSementara.length) {
      return 'Pilih pekerjaan terlebih dahulu';
    }

    final current =
        _data.aktivitasSementara[_data.indeksPekerjaanTerpilih] ?? [];
    final parentJob = _data.daftarPekerjaan[_data.indeksPekerjaanTerpilih];
    _data.aktivitasSementara[_data.indeksPekerjaanTerpilih] = [
      ...current,
      ItemKegiatan(
        idPekerjaan: parentJob.id,
        pekerjaan: parentJob.nama,
        namaKegiatan: namaKegiatan.trim(),
        waktuPelaksanaan: waktuPelaksanaan.trim(),
        pelaksana: pelaksana.trim(),
        selesai: false,
      ),
    ];
    notifyListeners();
    return null;
  }

  /// Hapus aktivitas dari pekerjaan tertentu.
  void hapusAktivitasSementara(int indeksPekerjaan, int indeksAktivitas) {
    final current = _data.aktivitasSementara[indeksPekerjaan];
    if (current == null) return;
    if (indeksAktivitas < 0 || indeksAktivitas >= current.length) return;
    current.removeAt(indeksAktivitas);
    notifyListeners();
  }

  /// Hitung jumlah aktivitas untuk pekerjaan tertentu.
  int jumlahAktivitasUntukPekerjaan(int indeksPekerjaan) =>
      _data.aktivitasSementara[indeksPekerjaan]?.length ?? 0;

  /// Validasi langkah 3: setiap pekerjaan harus punya minimal 1 aktivitas.
  String? validasiLangkah3() {
    for (var i = 0; i < pekerjaanSementara.length; i++) {
      if ((_data.aktivitasSementara[i]?.length ?? 0) == 0) {
        return 'Setiap pekerjaan harus memiliki minimal 1 aktivitas';
      }
    }
    return null;
  }

  // ─── Navigasi ─────────────────────────────────────────────────────────────

  /// Pindah ke langkah berikutnya.
  String? pindahKeLangkahBerikutnya({
    String nama = '',
    String deskripsi = '',
    String lokasi = '',
    String mulai = '',
    String selesai = '',
    String pelaksana = '',
    String pengawas = '',
    String status = 'Aktif',
  }) {
    if (_langkahSaatIni == 0) {
      final error = validasiLangkah1(
        nama: nama,
        deskripsi: deskripsi,
        lokasi: lokasi,
        mulai: mulai,
        selesai: selesai,
        pelaksana: pelaksana,
        pengawas: pengawas,
      );
      if (error != null) return error;
      aturDataProyek(
        nama: nama,
        deskripsi: deskripsi,
        lokasi: lokasi,
        mulai: mulai,
        selesai: selesai,
        pelaksana: pelaksana,
        pengawas: pengawas,
        status: status,
      );
      _langkahSaatIni = 1;
      notifyListeners();
      return null;
    }

    if (_langkahSaatIni == 1) {
      final error = validasiLangkah2();
      if (error != null) return error;
      _langkahSaatIni = 2;
      notifyListeners();
      return null;
    }

    if (_langkahSaatIni == 2) {
      final error = validasiLangkah3();
      if (error != null) return error;
      _langkahSaatIni = 3;
      notifyListeners();
      return null;
    }

    return null;
  }

  /// Pindah ke langkah sebelumnya.
  void pindahKeLangkahSebelumnya() {
    if (_langkahSaatIni > 0) {
      _langkahSaatIni--;
      notifyListeners();
    }
  }

  /// Cek apakah bisa kirim (dipanggil di langkah 3: Konfirmasi).
  /// Validasi ulang langkah 3 (aktivitas) untuk memastikan data masih valid.
  String? bisaKirim() => validasiLangkah3();

  /// Total jumlah langkah wizard.
  static const int totalLangkah = 4;

  /// Bangun object [Proyek] final dari semua data wizard.
  Proyek bangunProyek() {
    final semuaKegiatan = <ItemKegiatan>[];
    for (var i = 0; i < _data.daftarPekerjaan.length; i++) {
      semuaKegiatan.addAll(_data.aktivitasSementara[i] ?? []);
    }

    return Proyek(
      nama: _data.namaProyek,
      deskripsi: _data.deskripsiProyek,
      lokasi: _data.lokasiProyek,
      tanggalMulai: _data.tanggalMulaiProyek,
      tanggalSelesai: _data.tanggalSelesaiProyek,
      tim: _data.pelaksanaProyek,
      pengawas: _data.pengawasProyek,
      status: _data.statusProyek,
      daftarPekerjaan: List<ItemPekerjaan>.from(_data.daftarPekerjaan),
      daftarKegiatan: semuaKegiatan,
    );
  }

  /// Set status menyimpan (menampilkan loading spinner di button).
  void aturStatusMenyimpan(bool nilai) {
    _sedangMenyimpan = nilai;
    notifyListeners();
  }

  /// Reset semua state wizard ke awal.
  void aturUlang() {
    _langkahSaatIni = 0;
    _sedangMenyimpan = false;
    _data.reset();
    notifyListeners();
  }
}
