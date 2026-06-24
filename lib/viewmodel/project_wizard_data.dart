import '../models/modelbikinproyek.dart';

/// Model state wizard pembuatan proyek.
///
/// Serupa dengan [EntryData] di wizard data diri, tetapi disesuaikan dengan
/// data proyek: informasi proyek, daftar pekerjaan, dan aktivitas per pekerjaan.
class ProjectWizardData {
  String namaProyek = '';
  String deskripsiProyek = '';
  String lokasiProyek = '';
  String tanggalMulaiProyek = '';
  String tanggalSelesaiProyek = '';
  String pelaksanaProyek = '';
  String pengawasProyek = '';
  String statusProyek = 'Aktif';

  final List<ItemPekerjaan> daftarPekerjaan = [];
  final Map<int, List<ItemKegiatan>> aktivitasSementara = {};
  int indeksPekerjaanTerpilih = 0;

  void reset() {
    namaProyek = '';
    deskripsiProyek = '';
    lokasiProyek = '';
    tanggalMulaiProyek = '';
    tanggalSelesaiProyek = '';
    pelaksanaProyek = '';
    pengawasProyek = '';
    statusProyek = 'Aktif';
    daftarPekerjaan.clear();
    aktivitasSementara.clear();
    indeksPekerjaanTerpilih = 0;
  }
}
