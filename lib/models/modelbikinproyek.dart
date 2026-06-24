/// Model untuk data pekerjaan (Pekerjaan) di Flutter.
/// Digunakan untuk menyimpan dan mengirim data pekerjaan ke Django.
class ItemPekerjaan {
  ItemPekerjaan({
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
    this.kategori = '',
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
  final String kategori;
  final bool isTersinkron;

  ItemPekerjaan copyWith({
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
    String? kategori,
    bool? isTersinkron,
  }) {
    return ItemPekerjaan(
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
      kategori: kategori ?? this.kategori,
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

  factory ItemPekerjaan.fromJson(Map<String, dynamic> json) {
    return ItemPekerjaan(
      id: json['id']?.toString() ?? '',
      idProyek: json['id_proyek']?.toString() ?? json['proyek_id']?.toString() ?? json['projectId']?.toString() ?? '',
      judulProyek: json['judul_proyek'] as String? ?? json['projectTitle'] as String? ?? '',
      nama: json['nama'] as String? ?? json['name'] as String? ?? '',
      deskripsi: json['deskripsi'] as String? ?? json['description'] as String? ?? '',
      lokasi: json['lokasi'] as String? ?? json['location'] as String? ?? '',
      tanggalMulai: json['tanggal_mulai'] as String? ?? json['start_date'] as String? ?? '',
      tanggalSelesai: json['tanggal_selesai'] as String? ?? json['end_date'] as String? ?? '',
      pelaksana: json['pelaksana'] as String? ?? json['executor'] as String? ?? '',
      pengawas: json['pengawas'] as String? ?? json['supervisor'] as String? ?? '',
      kategori: json['kategori'] as String? ?? json['category'] as String? ?? '',
      isTersinkron: (json['is_synced'] ?? json['isSynced']) == 1 || (json['is_synced'] ?? json['isSynced']) == true,
    );
  }
}

/// Model untuk data aktivitas/kegiatan di Flutter.
/// Digunakan untuk menyimpan dan mengirim data aktivitas ke Django.
class ItemKegiatan {
  ItemKegiatan({
    this.id = '',
    this.idProyek = '',
    this.idPekerjaan = '',
    this.judulProyek = '',
    required this.pekerjaan,
    required this.namaKegiatan,
    required this.waktuPelaksanaan,
    required this.pelaksana,
    required this.selesai,
    this.evaluasi = '',
    this.rencanaTambahan = '',
    this.pathFileLokal,
    this.urlDokumen,
    this.namaFile,
    this.byteFile,
    this.isTersinkron = false,
  });

  final String id;
  final String idProyek;
  final String idPekerjaan;
  final String judulProyek;
  final String pekerjaan;
  final String namaKegiatan;
  final String waktuPelaksanaan;
  final String pelaksana;
  final bool selesai;
  final String evaluasi;
  final String rencanaTambahan;
  final String? pathFileLokal;
  final String? urlDokumen;
  final String? namaFile;
  final dynamic byteFile;
  final bool isTersinkron;

  ItemKegiatan copyWith({
    String? id,
    String? idProyek,
    String? idPekerjaan,
    String? judulProyek,
    String? pekerjaan,
    String? namaKegiatan,
    String? waktuPelaksanaan,
    String? pelaksana,
    bool? selesai,
    String? evaluasi,
    String? rencanaTambahan,
    String? pathFileLokal,
    String? urlDokumen,
    String? namaFile,
    dynamic byteFile,
    bool? isTersinkron,
  }) {
    return ItemKegiatan(
      id: id ?? this.id,
      idProyek: idProyek ?? this.idProyek,
      idPekerjaan: idPekerjaan ?? this.idPekerjaan,
      judulProyek: judulProyek ?? this.judulProyek,
      pekerjaan: pekerjaan ?? this.pekerjaan,
      namaKegiatan: namaKegiatan ?? this.namaKegiatan,
      waktuPelaksanaan: waktuPelaksanaan ?? this.waktuPelaksanaan,
      pelaksana: pelaksana ?? this.pelaksana,
      selesai: selesai ?? this.selesai,
      evaluasi: evaluasi ?? this.evaluasi,
      rencanaTambahan: rencanaTambahan ?? this.rencanaTambahan,
      pathFileLokal: pathFileLokal ?? this.pathFileLokal,
      urlDokumen: urlDokumen ?? this.urlDokumen,
      namaFile: namaFile ?? this.namaFile,
      byteFile: byteFile ?? this.byteFile,
      isTersinkron: isTersinkron ?? this.isTersinkron,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_pekerjaan': idPekerjaan,
      'nama': namaKegiatan,
      'waktu_pelaksanaan': waktuPelaksanaan,
      'pelaksana': pelaksana,
      'selesai': selesai,
      'evaluasi': evaluasi,
      'rencana_tambahan': rencanaTambahan,
    };
  }

  factory ItemKegiatan.fromJson(Map<String, dynamic> json) {
    return ItemKegiatan(
      id: json['id']?.toString() ?? '',
      idProyek: json['proyek_id']?.toString() ?? '',
      idPekerjaan: json['id_pekerjaan']?.toString() ?? json['pekerjaan_id']?.toString() ?? '',
      judulProyek: json['judul_proyek'] as String? ?? '',
      pekerjaan: json['pekerjaan'] as String? ?? '',
      namaKegiatan: json['nama'] as String? ?? '',
      waktuPelaksanaan: json['waktu_pelaksanaan'] as String? ?? '',
      pelaksana: json['pelaksana'] as String? ?? '',
      selesai: json['selesai'] == true || json['selesai'] == 1,
      evaluasi: json['evaluasi'] as String? ?? json['evaluation'] as String? ?? '',
      rencanaTambahan: json['rencana_tambahan'] as String? ?? json['additional_plan'] as String? ?? json['followUpPlan'] as String? ?? '',
      urlDokumen: json['bukti_urls'] != null && (json['bukti_urls'] as List).isNotEmpty 
          ? json['bukti_urls'][0]['url'] 
          : json['url_berkas'] as String? ?? json['file_url'] as String? ?? json['file'] as String?,
      isTersinkron: (json['is_synced'] ?? json['isSynced']) == 1 || (json['is_synced'] ?? json['isSynced']) == true,
    );
  }
}

/// Model untuk data proyek di Flutter.
/// Menyimpan data proyek lengkap dengan pekerjaan dan aktivitas.
/// Mendukung field broadcastStatus untuk tracking status broadcast ke subsistem lain.
class Proyek {
  Proyek({
    this.id = '',
    required this.nama,
    required this.deskripsi,
    required this.lokasi,
    required this.tanggalMulai,
    this.tanggalSelesai = '',
    required this.tim,
    this.pengawas = '',
    this.isTertutup = false,
    this.isTersinkron = false,
    this.status = 'Aktif',
    this.broadcastStatus,
    List<ItemPekerjaan>? daftarPekerjaan,
    List<ItemKegiatan>? daftarKegiatan,
  })  : daftarPekerjaan = daftarPekerjaan ?? [],
        daftarKegiatan = daftarKegiatan ?? [];

  final String id;
  final String nama;
  final String deskripsi;
  final String lokasi;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String tim;
  final String pengawas;
  final bool isTertutup;
  final bool isTersinkron;
  final String status;
  
  /// Status broadcast ke subsistem lain (IE, IC, Implementation).
  /// Format: {"IE": {"status": "success"/"failed"/"pending"}, "IC": {...}, "Implementation": {...}}
  final Map<String, dynamic>? broadcastStatus;
  
  final List<ItemPekerjaan> daftarPekerjaan;
  final List<ItemKegiatan> daftarKegiatan;

  /// Helper getter for backward compatibility with code using 'tanggal'
  String get tanggal => tanggalSelesai.isNotEmpty
      ? '$tanggalMulai - $tanggalSelesai'
      : tanggalMulai;

  /// Helper getter for backward compatibility with code using 'pelaksana'
  String get pelaksana => tim;

  Proyek copyWith({
    String? id,
    String? nama,
    String? deskripsi,
    String? lokasi,
    String? tanggalMulai,
    String? tanggalSelesai,
    String? tim,
    String? pengawas,
    bool? isTertutup,
    bool? isTersinkron,
    String? status,
    Map<String, dynamic>? broadcastStatus,
    List<ItemPekerjaan>? daftarPekerjaan,
    List<ItemKegiatan>? daftarKegiatan,
  }) {
    return Proyek(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
      lokasi: lokasi ?? this.lokasi,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
      tanggalSelesai: tanggalSelesai ?? this.tanggalSelesai,
      tim: tim ?? this.tim,
      pengawas: pengawas ?? this.pengawas,
      isTertutup: isTertutup ?? this.isTertutup,
      isTersinkron: isTersinkron ?? this.isTersinkron,
      status: status ?? this.status,
      broadcastStatus: broadcastStatus ?? this.broadcastStatus,
      daftarPekerjaan: daftarPekerjaan ?? this.daftarPekerjaan,
      daftarKegiatan: daftarKegiatan ?? this.daftarKegiatan,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'lokasi': lokasi,
      'tanggal_mulai': tanggalMulai,
      'tanggal_selesai': tanggalSelesai.isNotEmpty ? tanggalSelesai : tanggalMulai,
      'pelaksana': tim,
      'pengawas': pengawas,
      'status': status,
      'is_synced': isTersinkron,
      'sudah_selesai': isTertutup,
    };
  }

  /// JSON payload suited for sending to Django server.
  /// Includes nested pekerjaan + aktivitas so backend can create them in one request.
  Map<String, dynamic> toJsonForServer() {
    // Build aktivitas grouped by pekerjaan id
    final Map<String, List<Map<String, dynamic>>> aktivitasPerPekerjaan = {};
    for (final akt in daftarKegiatan) {
      final parentId = akt.idPekerjaan;
      aktivitasPerPekerjaan.putIfAbsent(parentId, () => []).add(akt.toJson());
    }

    final pekerjaanJson = daftarPekerjaan.map((job) {
      final jobJson = job.toJson();
      jobJson['aktivitas'] = aktivitasPerPekerjaan[job.id] ?? <Map<String, dynamic>>[];
      return jobJson;
    }).toList(growable: false);

    final base = toJson();
    base['pekerjaan'] = pekerjaanJson;
    return base;
  }

  factory Proyek.fromJson(Map<String, dynamic> json) {
    // 1. Parse Pekerjaan (dari Django field 'pekerjaan')
    final daftarPekerjaanJson = (json['pekerjaan'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();
    
    final List<ItemPekerjaan> listPekerjaan = 
        daftarPekerjaanJson.map(ItemPekerjaan.fromJson).toList();

    // 2. Kumpulkan Aktivitas dari setiap Pekerjaan
    final List<ItemKegiatan> listKegiatan = [];
    for (var jobJson in daftarPekerjaanJson) {
      final aktivitasJson = (jobJson['aktivitas'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>();
      
      for (var actJson in aktivitasJson) {
        final act = ItemKegiatan.fromJson(actJson);
        listKegiatan.add(act.copyWith(
          idPekerjaan: jobJson['id']?.toString() ?? '',
          pekerjaan: jobJson['nama'] ?? '',
          idProyek: json['id']?.toString() ?? '',
          judulProyek: json['nama'] ?? '',
        ));
      }
    }

    // Parse broadcast status from Django response
    Map<String, dynamic>? parsedBroadcastStatus;
    if (json['broadcast_status'] != null) {
      parsedBroadcastStatus = json['broadcast_status'] as Map<String, dynamic>;
    }

    return Proyek(
      id: json['id']?.toString() ?? '',
      nama: json['nama'] as String? ?? json['name'] as String? ?? '',
      deskripsi: json['deskripsi'] as String? ?? json['description'] as String? ?? '',
      lokasi: json['lokasi'] as String? ?? json['location'] as String? ?? '',
      tanggalMulai: json['tanggal_mulai'] as String? ?? json['start_date'] as String? ?? '',
      tanggalSelesai: json['tanggal_selesai'] as String? ?? json['end_date'] as String? ?? '',
      tim: json['pelaksana'] as String? ?? json['executor'] as String? ?? '',
      pengawas: json['pengawas'] as String? ?? json['supervisor'] as String? ?? '',
      status: json['status'] as String? ?? 'Aktif',
      isTertutup: json['sudah_selesai'] == true ||
          json['is_tertutup'] == true ||
          json['is_closed'] == true ||
          (json['status']?.toString().toLowerCase() == 'selesai'),
      isTersinkron: (json['is_synced'] ?? json['isSynced']) == 1 || (json['is_synced'] ?? json['isSynced']) == true,
      broadcastStatus: parsedBroadcastStatus,
      daftarPekerjaan: listPekerjaan,
      daftarKegiatan: listKegiatan,
    );
  }
}