import 'package:flutter/foundation.dart';

import '../models/pekerjaan_model.dart';

class PekerjaanViewModel extends ChangeNotifier {
  final List<PekerjaanModel> _daftarPekerjaan = [
    PekerjaanModel(
      id: 'TSK-011',
      judul: 'Buat wireframe halaman onboarding',
      prioritas: 'Tinggi',
      status: 'Berjalan',
      tenggatWaktu: DateTime(2026, 4, 19),
      penanggungJawab: 'Ayu',
    ),
    PekerjaanModel(
      id: 'TSK-012',
      judul: 'Integrasi API autentikasi',
      prioritas: 'Tinggi',
      status: 'Review',
      tenggatWaktu: DateTime(2026, 4, 18),
      penanggungJawab: 'Dian',
    ),
    PekerjaanModel(
      id: 'TSK-013',
      judul: 'Setup analitik dashboard',
      prioritas: 'Sedang',
      status: 'Selesai',
      tenggatWaktu: DateTime(2026, 4, 15),
      penanggungJawab: 'Bimo',
    ),
  ];

  List<PekerjaanModel> get daftarPekerjaan =>
      List.unmodifiable(_daftarPekerjaan);

  int get jumlahSelesai =>
      _daftarPekerjaan.where((task) => task.status == 'Selesai').length;
}
