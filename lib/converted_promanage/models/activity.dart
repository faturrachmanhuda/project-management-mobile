class ConvertedActivity {
  final String id;
  final String pekerjaanId;
  final String nama;
  final String waktuPelaksanaan;
  final String pelaksana;
  final bool selesai;

  ConvertedActivity({
    required this.id,
    required this.pekerjaanId,
    required this.nama,
    required this.waktuPelaksanaan,
    required this.pelaksana,
    required this.selesai,
  });

  factory ConvertedActivity.fromJson(Map<String, dynamic> json) => ConvertedActivity(
        id: json['id']?.toString() ?? '',
        pekerjaanId: json['id_pekerjaan']?.toString() ?? '',
        nama: json['nama']?.toString() ?? '',
        waktuPelaksanaan: json['waktu_pelaksanaan']?.toString() ?? '',
        pelaksana: json['pelaksana']?.toString() ?? '',
        selesai: (json['selesai'] ?? false) == true,
      );
}
