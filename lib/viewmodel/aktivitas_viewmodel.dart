import 'package:flutter/foundation.dart';

import '../models/aktivitas_model.dart';

class AktivitasViewModel extends ChangeNotifier {
  final List<AktivitasModel> _daftarAktivitas = [
    AktivitasModel(
      id: 'ACT-101',
      judul: 'Standup tim pagi',
      penanggungJawab: 'Scrum Master',
      waktu: DateTime(2026, 4, 15, 9, 0),
      kategoriPantau: 'Rutinitas',
      catatan: 'Semua update disampaikan tepat waktu.',
    ),
    AktivitasModel(
      id: 'ACT-102',
      judul: 'Demo progres sprint',
      penanggungJawab: 'Lead Engineer',
      waktu: DateTime(2026, 4, 15, 13, 30),
      kategoriPantau: 'Milestone',
      catatan: 'Perlu tindak lanjut untuk modul laporan.',
    ),
    AktivitasModel(
      id: 'ACT-103',
      judul: 'Monitoring bug prioritas',
      penanggungJawab: 'QA Lead',
      waktu: DateTime(2026, 4, 15, 16, 0),
      kategoriPantau: 'Resiko',
      catatan: '2 bug major masih aktif dan dipantau.',
    ),
  ];

  List<AktivitasModel> get daftarAktivitas =>
      List.unmodifiable(_daftarAktivitas);
}
