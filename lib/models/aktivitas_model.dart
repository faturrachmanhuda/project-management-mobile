/// Model sederhana untuk data aktivitas di widget AktivitasView.
class AktivitasModel {
  const AktivitasModel({
    required this.id,
    required this.judul,
    required this.penanggungJawab,
    required this.waktu,
    required this.kategoriPantau,
    required this.catatan,
  });

  final String id;
  final String judul;
  final String penanggungJawab;
  final DateTime waktu;
  final String kategoriPantau;
  final String catatan;
}
