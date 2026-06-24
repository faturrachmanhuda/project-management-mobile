import 'package:flutter/foundation.dart';

import '../models/proyek_model.dart';

class ProyekViewModel extends ChangeNotifier {
  final List<ProyekModel> _daftarProyek = [
    ProyekModel(
      id: 'PRJ-001',
      nama: 'Website Corporate',
      deskripsi: 'Redesign landing page dan dashboard admin.',
      progress: 78,
      pemilik: 'Tia',
      jumlahAnggota: 6,
    ),
    ProyekModel(
      id: 'PRJ-002',
      nama: 'Aplikasi Mobile Internal',
      deskripsi: 'Fitur approval, notifikasi, dan laporan.',
      progress: 54,
      pemilik: 'Rudi',
      jumlahAnggota: 5,
    ),
    ProyekModel(
      id: 'PRJ-003',
      nama: 'Integrasi CRM',
      deskripsi: 'Sinkronisasi data pelanggan lintas sistem.',
      progress: 34,
      pemilik: 'Nadia',
      jumlahAnggota: 4,
    ),
  ];

  List<ProyekModel> get daftarProyek => List.unmodifiable(_daftarProyek);

  double get rataRataProgress {
    if (_daftarProyek.isEmpty) {
      return 0;
    }
    final total = _daftarProyek.fold<double>(
      0,
      (nilai, proyek) => nilai + proyek.progress,
    );
    return total / _daftarProyek.length;
  }
}
