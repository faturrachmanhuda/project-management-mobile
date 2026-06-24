import 'activity.dart';

class ConvertedWork {
  final String id;
  final String proyekId;
  final String nama;
  final String kategori;
  final String deskripsi;
  final String lokasi;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String pelaksana;
  final String pengawas;
  final double progres;
  final List<ConvertedActivity> aktivitas;

  ConvertedWork({
    required this.id,
    required this.proyekId,
    required this.nama,
    required this.kategori,
    required this.deskripsi,
    required this.lokasi,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.pelaksana,
    required this.pengawas,
    required this.progres,
    required this.aktivitas,
  });

  factory ConvertedWork.fromJson(Map<String, dynamic> json) {
    final double progressValue = (json['progres'] is num) 
        ? (json['progres'] as num).toDouble() 
        : double.tryParse(json['progres']?.toString() ?? '0') ?? 0.0;
    
    // Clamp progress to valid range [0.0, 100.0]
    final double clampedProgress = progressValue.clamp(0.0, 100.0);
    
    return ConvertedWork(
      id: json['id']?.toString() ?? '',
      proyekId: json['id_proyek']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      lokasi: json['lokasi']?.toString() ?? '',
      tanggalMulai: json['tanggal_mulai']?.toString() ?? '',
      tanggalSelesai: json['tanggal_selesai']?.toString() ?? '',
      pelaksana: json['pelaksana']?.toString() ?? '',
      pengawas: json['pengawas']?.toString() ?? '',
      progres: clampedProgress,
      aktivitas: (json['aktivitas'] as List<dynamic>?)?.map((e) => ConvertedActivity.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }
}
