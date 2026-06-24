/// Model sederhana untuk data pekerjaan di widget PekerjaanView.
class PekerjaanModel {
  const PekerjaanModel({
    required this.id,
    this.idProyek = '',
    required this.judul,
    required this.prioritas,
    required this.status,
    required this.tenggatWaktu,
    required this.penanggungJawab,
  });

  final String id;
  final String idProyek;
  final String judul;
  final String prioritas;
  final String status;
  final DateTime tenggatWaktu;
  final String penanggungJawab;

  factory PekerjaanModel.fromMap(Map<String, dynamic> map) {
    return PekerjaanModel(
      id: map['id']?.toString() ?? '',
      idProyek: map['idProyek']?.toString() ?? map['projectId']?.toString() ?? '',
      judul: map['judul'] ?? '',
      prioritas: map['prioritas'] ?? '',
      status: map['status'] ?? '',
      tenggatWaktu: DateTime.parse(map['tenggatWaktu'] ?? DateTime.now().toIso8601String()),
      penanggungJawab: map['penanggungJawab'] ?? map['pic'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idProyek': idProyek,
      'judul': judul,
      'prioritas': prioritas,
      'status': status,
      'tenggatWaktu': tenggatWaktu.toIso8601String(),
      'penanggungJawab': penanggungJawab,
    };
  }
}
