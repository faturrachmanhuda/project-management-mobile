import 'work.dart';

class ConvertedProject {
  final String id;
  final String nama;
  final String deskripsi;
  final String lokasi;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String pelaksana;
  final String pengawas;
  final String status;
  final bool isClosed;
  final double progres;
  final List<ConvertedWork> pekerjaan;

  ConvertedProject({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.lokasi,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.pelaksana,
    required this.pengawas,
    required this.status,
    required this.isClosed,
    required this.progres,
    required this.pekerjaan,
  });

  factory ConvertedProject.fromJson(Map<String, dynamic> json) {
    final double progressValue = (json['progres'] is num) 
        ? (json['progres'] as num).toDouble() 
        : double.tryParse(json['progres']?.toString() ?? '0') ?? 0.0;
    
    // Clamp progress to valid range [0.0, 100.0]
    final double clampedProgress = progressValue.clamp(0.0, 100.0);
    
    // Determine if closed: prioritize explicit isClosed field, fall back to completion status
    final bool isClosed = (json['is_closed'] ?? json['sudah_selesai'] ?? false) == true;
    
    return ConvertedProject(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      lokasi: json['lokasi']?.toString() ?? '',
      tanggalMulai: json['tanggal_mulai']?.toString() ?? '',
      tanggalSelesai: json['tanggal_selesai']?.toString() ?? '',
      pelaksana: json['pelaksana']?.toString() ?? '',
      pengawas: json['pengawas']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      isClosed: isClosed,
      progres: clampedProgress,
      pekerjaan: (json['pekerjaan'] as List<dynamic>?)?.map((e) => ConvertedWork.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }
}
