
class Pekerjaan {
  Pekerjaan({
    this.id = '',
    this.idProyek = '',
    this.judulProyek = '',
    required this.nama,
    required this.deskripsi,
    required this.lokasi,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.pelaksana,
    required this.pengawas,
    this.isTersinkron = false,
  });

  final String id;
  final String idProyek;
  final String judulProyek;
  final String nama;
  final String deskripsi;
  final String lokasi;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String pelaksana;
  final String pengawas;
  final bool isTersinkron;

  Pekerjaan copyWith({
    String? id,
    String? idProyek,
    String? judulProyek,
    String? nama,
    String? deskripsi,
    String? lokasi,
    String? tanggalMulai,
    String? tanggalSelesai,
    String? pelaksana,
    String? pengawas,
    bool? isTersinkron,
  }) {
    return Pekerjaan(
      id: id ?? this.id,
      idProyek: idProyek ?? this.idProyek,
      judulProyek: judulProyek ?? this.judulProyek,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
      lokasi: lokasi ?? this.lokasi,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalSelesai: tanggalSelesai ?? this.tanggalSelesai,
      pelaksana: pelaksana ?? this.pelaksana,
      pengawas: pengawas ?? this.pengawas,
      isTersinkron: isTersinkron ?? this.isTersinkron,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_proyek': idProyek,
      'nama': nama,
      'deskripsi': deskripsi,
      'lokasi': lokasi,
      'tanggal_mulai': tanggalMulai,
      'tanggal_selesai': tanggalSelesai,
      'pelaksana': pelaksana,
      'pengawas': pengawas,
    };
  }

  factory Pekerjaan.fromJson(Map<String, dynamic> json) {
    return Pekerjaan(
      id: json['id']?.toString() ?? '',
      idProyek: json['id_proyek']?.toString() ?? json['projectId']?.toString() ?? json['project_id']?.toString() ?? '',
      judulProyek: json['projectTitle'] as String? ?? json['project_title'] as String? ?? json['proyek'] as String? ?? '',
      nama: json['nama'] as String? ?? json['title'] as String? ?? json['name'] as String? ?? '',
      deskripsi: json['deskripsi'] as String? ?? json['desc'] as String? ?? json['description'] as String? ?? '',
      lokasi: json['lokasi'] as String? ?? json['location'] as String? ?? json['tempat'] as String? ?? '',
      tanggalMulai: json['tanggal_mulai'] as String? ?? json['tanggalMulai'] as String? ?? json['startDate'] as String? ?? json['start_date'] as String? ?? '',
      tanggalSelesai: json['tanggal_selesai'] as String? ?? json['tanggalSelesai'] as String? ?? json['endDate'] as String? ?? json['end_date'] as String? ?? '',
      pelaksana: json['pelaksana'] as String? ?? json['executor'] as String? ?? '',
      pengawas: json['pengawas'] as String? ?? json['supervisor'] as String? ?? '',
      isTersinkron: (json['is_synced'] ?? json['isSynced'] ?? json['is_tersinkron']) == 1 || (json['is_synced'] ?? json['isSynced'] ?? json['is_tersinkron']) == true,
    );
  }
}
