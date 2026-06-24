class Kegiatan {
  Kegiatan({
    required this.id,
    this.projectId = '',
    this.jobId = '',
    this.projectTitle = '',
    this.jobTitle = '',
    required this.title,
    required this.desc,
    required this.date,
    required this.status,
    this.evaluation = '',
    this.followUpPlan = '',
    this.documentUrl,
    this.localFilePath,
    this.fileName,
    this.fileBytes,
    this.isSynced = false,
  });

  final String id;
  final String projectId;
  final String jobId;
  final String projectTitle;
  final String jobTitle;
  final String title;
  final String desc;
  final String date;
  final String status;
  final String evaluation;
  final String followUpPlan;
  final String? documentUrl;
  final String? localFilePath;
  final String? fileName;
  final dynamic fileBytes;
  final bool isSynced;

  Kegiatan copyWith({
    String? id,
    String? projectId,
    String? jobId,
    String? projectTitle,
    String? jobTitle,
    String? title,
    String? desc,
    String? date,
    String? status,
    String? evaluation,
    String? followUpPlan,
    String? documentUrl,
    String? localFilePath,
    String? fileName,
    dynamic fileBytes,
    bool? isSynced,
  }) {
    return Kegiatan(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      jobId: jobId ?? this.jobId,
      projectTitle: projectTitle ?? this.projectTitle,
      jobTitle: jobTitle ?? this.jobTitle,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      date: date ?? this.date,
      status: status ?? this.status,
      evaluation: evaluation ?? this.evaluation,
      followUpPlan: followUpPlan ?? this.followUpPlan,
      documentUrl: documentUrl ?? this.documentUrl,
      localFilePath: localFilePath ?? this.localFilePath,
      fileName: fileName ?? this.fileName,
      fileBytes: fileBytes ?? this.fileBytes,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  /// Menggabungkan data dari remote (server) dengan data lokal.
  /// 
  /// PERATURAN: Remote SELALU menang untuk data bisnis.
  /// Data lokal hanya dipertahankan untuk field non-bisnis seperti path file lokal yang belum ter-upload.
  /// 
  /// Catatan: Method ini sekarang deprecated karena arsitektur berubah.
  /// Flutter tidak lagi membuat aktivitas lokal sebelum server menyetujui.
  /// Semua aktivitas harus berasal dari response server.
  @Deprecated('Remote data is now the single source of truth. Use server response directly.')
  Kegiatan mergeWith(Kegiatan remote) {
    // Remote SELALU menang untuk semua field bisnis
    // Lokal hanya dipertahankan untuk path file yang masih pending upload
    return remote.copyWith(
      localFilePath: localFilePath,
      fileName: fileName,
      fileBytes: fileBytes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'jobId': jobId,
      'projectTitle': projectTitle,
      'jobTitle': jobTitle,
      'title': title,
      'desc': desc,
      'date': date,
      'status': status,
      'evaluation': evaluation,
      'followUpPlan': followUpPlan,
      'documentUrl': documentUrl,
      'localFilePath': localFilePath,
      'fileName': fileName,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory Kegiatan.fromMap(Map<String, dynamic> map) {
    return Kegiatan(
      id: map['id']?.toString() ?? '',
      projectId: map['projectId']?.toString() ?? map['id_proyek']?.toString() ?? '',
      jobId: map['jobId']?.toString() ?? map['id_pekerjaan']?.toString() ?? '',
      projectTitle: map['projectTitle'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      title: map['title'] ?? '',
      desc: map['desc'] ?? '',
      date: map['date'] ?? '',
      status: map['status'] ?? 'pending',
      evaluation: map['evaluation'] ?? '',
      followUpPlan: map['followUpPlan'] ?? '',
      documentUrl: map['documentUrl'],
      localFilePath: map['localFilePath'],
      fileName: map['fileName'],
      isSynced: (map['is_synced'] ?? map['isSynced']) == 1 || (map['is_synced'] ?? map['isSynced']) == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pekerjaan': jobId,
      'nama': title,
      'waktu_pelaksanaan': date,
      'pelaksana': desc,
      'selesai': status.toLowerCase() == 'selesai' || status.toLowerCase() == 'done',
      'evaluasi': evaluation,
      'rencana_tambahan': followUpPlan,
    };
  }

  factory Kegiatan.fromJson(Map<String, dynamic> json) {
    // Tentukan status: Django pakai field 'done' (bool), Flutter pakai string 'done'/'pending'
    String statusVal;
    if (json.containsKey('selesai')) {
      statusVal = (json['selesai'] == true || json['selesai'] == 1) ? 'done' : 'pending';
    } else if (json.containsKey('done')) {
      statusVal = (json['done'] == true || json['done'] == 1) ? 'done' : 'pending';
    } else {
      statusVal = json['status'] as String? ?? 'pending';
    }

    return Kegiatan(
      id: json['id']?.toString() ?? '',
      projectId: json['id_proyek']?.toString() ?? json['project_id']?.toString() ?? json['projectId']?.toString() ?? '',
      jobId: json['id_pekerjaan']?.toString() ?? json['work_id']?.toString() ?? '',
      projectTitle: json['projectTitle'] as String? ?? json['project_title'] as String? ?? '',
      jobTitle: json['jobTitle'] as String? ?? json['job_title'] as String? ?? '',
      title: json['nama'] as String? ?? json['name'] as String? ?? json['title'] as String? ?? json['namaAktivitas'] as String? ?? '',
      desc: json['pelaksana'] as String? ?? json['executor'] as String? ?? json['desc'] as String? ?? '',
      date: json['waktu_pelaksanaan'] as String? ?? json['execution_time'] as String? ?? json['date'] as String? ?? json['waktuPelaksanaan'] as String? ?? '',
      status: statusVal,
      evaluation: json['evaluasi'] as String? ?? json['evaluation'] as String? ?? '',
      followUpPlan: json['rencana_tambahan'] as String? ?? json['additional_plan'] as String? ?? json['followUpPlan'] as String? ?? '',
      documentUrl: json['bukti_urls'] != null && (json['bukti_urls'] as List).isNotEmpty 
          ? json['bukti_urls'][0]['url'] 
          : json['document'] as String? ?? json['file_url'] as String? ?? json['file'] as String?,
      isSynced: (json['is_synced'] ?? json['isSynced']) == 1 || (json['is_synced'] ?? json['isSynced']) == true,
    );
  }
}

class ActivityFile {
  ActivityFile({
    required this.id,
    required this.activityId,
    required this.fileUrl,
    this.fileSize,
    this.uploadedAt,
  });

  final String id;
  final String activityId;
  final String fileUrl;
  final int? fileSize;
  final String? uploadedAt;

  factory ActivityFile.fromJson(Map<String, dynamic> json) {
    return ActivityFile(
      id: json['id']?.toString() ?? '',
      activityId: json['aktivitas']?.toString() ?? json['activity']?.toString() ?? '',
      fileUrl: (json['file_url'] ?? json['url'] ?? json['file'])?.toString() ?? '',
      fileSize: json['ukuran_file'] as int? ?? json['file_size'] as int?,
      uploadedAt: json['diunggah_pada']?.toString() ?? json['uploaded_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'aktivitas': activityId,
      'file': fileUrl,
      'ukuran_file': fileSize,
      'diunggah_pada': uploadedAt,
    };
  }
}
// Backward compatibility alias: 'Kegiatans' → 'Kegiatan'
typedef Kegiatans = Kegiatan;