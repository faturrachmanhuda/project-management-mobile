/// Model sederhana untuk data proyek di widget ProyekView.
class ProyekModel {
  const ProyekModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.progress,
    required this.pemilik,
    required this.jumlahAnggota,
    this.status = 'Aktif',
  });

  final String id;
  final String nama;
  final String deskripsi;
  final double progress;
  final String pemilik;
  final int jumlahAnggota;
  final String status;

  factory ProyekModel.fromMap(Map<String, dynamic> map) {
    return ProyekModel(
      id: map['id']?.toString() ?? '',
      nama: map['nama'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      pemilik: map['pemilik'] ?? '',
      jumlahAnggota: map['jumlahAnggota'] ?? 0,
      status: map['status'] ?? 'Aktif',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'progress': progress,
      'pemilik': pemilik,
      'jumlahAnggota': jumlahAnggota,
      'status': status,
    };
  }
}
