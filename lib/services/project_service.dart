import 'dart:developer' as developer;

import '../models/modelbikinproyek.dart';
import '../models/job.dart';
import '../models/activity_model.dart';
import 'api_service.dart';

/// [ProjectService] menangani semua operasi CRUD untuk:
/// - Project (`/api/proyek/`)
/// - Work / Pekerjaan (`/api/pekerjaan/`)
/// - Activity / Aktivitas (`/api/aktivitas/`)
///
/// Semua komunikasi HTTP melalui [ApiService].
class ProyekService {
  static final ProyekService _instance = ProyekService._internal();
  factory ProyekService() => _instance;
  ProyekService._internal();

  final ApiService _api = ApiService();

  // ═══════════════════════════════════════════════════════════════════════════
  // PROYEK
  // ═══════════════════════════════════════════════════════════════════════════

  /// Bulk sync semua proyek lokal ke server sekaligus.
  /// POST /api/proyek/bulk_sync/
  Future<Map<String, dynamic>> bulkSyncProjects(List<Proyek> projects) async {
    developer.log('bulkSyncProjects(${projects.length} projects)', name: 'ProyekService');
    final payload = {
      'projects': projects.map((p) => p.toJsonForServer()).toList(),
    };
    final data = await _api.post('/api/proyek/bulk_sync/', payload)
        as Map<String, dynamic>;
    return data;
  }

  /// Ambil semua proyek milik user yang sedang login.
  /// GET /api/proyek/
  Future<List<Proyek>> getProjects() async {
    developer.log('getProjects()', name: 'ProyekService');
    final data = await _api.get('/api/proyek/') as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(Proyek.fromJson)
        .toList();
  }

  /// Buat proyek baru.
  /// POST /api/proyek/
  Future<Proyek> createProject(Proyek proyek) async {
    developer.log('createProject(${proyek.nama})', name: 'ProyekService');
    // Send nested payload so Django can create pekerjaan+aktivitas
    final body = proyek.toJsonForServer();
    final response = await _api.post('/api/proyek/', body)
        as Map<String, dynamic>;
        
    final data = response.containsKey('data') && response['data'] is Map 
        ? response['data'] as Map<String, dynamic> 
        : response;
        
    return Proyek.fromJson(data);
  }

  /// Update proyek yang ada.
  /// PUT /api/proyek/{id}/
  Future<Proyek> updateProject(Proyek proyek) async {
    if (proyek.id.isEmpty) throw ArgumentError('proyek.id tidak boleh kosong');
    developer.log('updateProject(${proyek.id})', name: 'ProyekService');
    final data = await _api.put('/api/proyek/${proyek.id}/', proyek.toJson())
        as Map<String, dynamic>;
    return Proyek.fromJson(data);
  }

  /// Hapus proyek.
  /// DELETE /api/proyek/{id}/
  Future<void> deleteProject(String id) async {
    if (id.isEmpty) return;
    developer.log('deleteProject($id)', name: 'ProyekService');
    await _api.delete('/api/proyek/$id/');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PEKERJAAN
  // ═══════════════════════════════════════════════════════════════════════════

  /// Ambil semua pekerjaan (opsional: filter per proyek).
  /// GET /api/pekerjaan/?proyek_id={projectId}
  Future<List<Pekerjaan>> getWorks({String? projectId}) async {
    developer.log('getWorks(projectId=$projectId)', name: 'ProyekService');
    final endpoint = projectId != null
        ? '/api/pekerjaan/berdasarkan_proyek/?id_proyek=$projectId'
        : '/api/pekerjaan/';
    final data = await _api.get(endpoint) as List<dynamic>;
    return data.whereType<Map<String, dynamic>>().map(Pekerjaan.fromJson).toList();
  }

  /// Buat pekerjaan baru.
  /// POST /api/pekerjaan/
  Future<Pekerjaan> createWork(Pekerjaan pekerjaan) async {
    developer.log('createWork(${pekerjaan.nama})', name: 'ProyekService');
    final data = await _api.post('/api/pekerjaan/', pekerjaan.toJson())
        as Map<String, dynamic>;
    return Pekerjaan.fromJson(data);
  }

  /// Buat pekerjaan baru dari ItemPekerjaan.
  /// POST /api/pekerjaan/
  Future<ItemPekerjaan> createWorkItem(ItemPekerjaan item) async {
    developer.log('createWorkItem(${item.nama})', name: 'ProyekService');
    final data = await _api.post('/api/pekerjaan/', item.toJson())
        as Map<String, dynamic>;
    return ItemPekerjaan.fromJson(data);
  }

  /// Update pekerjaan dari ItemPekerjaan.
  /// PUT /api/pekerjaan/{id}/
  Future<ItemPekerjaan> updateWorkItem(ItemPekerjaan item) async {
    if (item.id.isEmpty) throw ArgumentError('item.id tidak boleh kosong');
    developer.log('updateWorkItem(${item.id})', name: 'ProyekService');
    final data = await _api.put('/api/pekerjaan/${item.id}/', item.toJson())
        as Map<String, dynamic>;
    return ItemPekerjaan.fromJson(data);
  }

  /// Update pekerjaan.
  /// PUT /api/pekerjaan/{id}/
  Future<Pekerjaan> updateWork(Pekerjaan pekerjaan) async {
    if (pekerjaan.id.isEmpty) throw ArgumentError('pekerjaan.id tidak boleh kosong');
    developer.log('updateWork(${pekerjaan.id})', name: 'ProyekService');
    final data = await _api.put('/api/pekerjaan/${pekerjaan.id}/', pekerjaan.toJson())
        as Map<String, dynamic>;
    return Pekerjaan.fromJson(data);
  }

  /// Hapus pekerjaan.
  /// DELETE /api/pekerjaan/{id}/
  Future<void> deleteWork(String id) async {
    if (id.isEmpty) return;
    developer.log('deleteWork($id)', name: 'ProyekService');
    await _api.delete('/api/pekerjaan/$id/');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // KEGIATAN
  // ═══════════════════════════════════════════════════════════════════════════

  /// Ambil semua kegiatan (opsional: filter per pekerjaan).
  /// GET /api/kegiatan/berdasarkan_pekerjaan/?pekerjaan_id={workId}
  Future<List<Kegiatan>> getActivities({String? workId}) async {
    developer.log('getActivities(workId=$workId)', name: 'ProyekService');
    final endpoint = workId != null
        ? '/api/aktivitas/berdasarkan_pekerjaan/?id_pekerjaan=$workId'
        : '/api/aktivitas/';
    final data = await _api.get(endpoint) as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(Kegiatan.fromJson)
        .toList();
  }

  /// Buat kegiatan baru.
  /// POST /api/kegiatan/
  Future<Kegiatan> createActivity(Kegiatan kegiatan) async {
    developer.log('createActivity(${kegiatan.title})', name: 'ProyekService');
    final data = await _api.post('/api/aktivitas/', kegiatan.toJson())
        as Map<String, dynamic>;
    return Kegiatan.fromJson(data);
  }

  /// Buat kegiatan baru dari ItemKegiatan.
  /// POST /api/kegiatan/
  Future<ItemKegiatan> createActivityItem(ItemKegiatan item) async {
    developer.log('createActivityItem(${item.namaKegiatan})', name: 'ProyekService');
    final data = await _api.post('/api/aktivitas/', item.toJson())
        as Map<String, dynamic>;
    return ItemKegiatan.fromJson(data);
  }

  /// Update kegiatan dari ItemKegiatan.
  /// PUT /api/aktivitas/{id}/
  Future<ItemKegiatan> updateActivityItem(ItemKegiatan item) async {
    if (item.id.isEmpty) throw ArgumentError('item.id tidak boleh kosong');
    developer.log('updateActivityItem(${item.id})', name: 'ProyekService');
    final data = await _api.put('/api/aktivitas/${item.id}/', item.toJson())
        as Map<String, dynamic>;
    return ItemKegiatan.fromJson(data);
  }

  /// Update kegiatan.
  /// PUT /api/kegiatan/{id}/
  Future<Kegiatan> updateActivity(Kegiatan kegiatan) async {
    if (kegiatan.id.isEmpty) throw ArgumentError('kegiatan.id tidak boleh kosong');
    developer.log('updateActivity(${kegiatan.id})', name: 'ProyekService');
    final data = await _api.put('/api/aktivitas/${kegiatan.id}/', kegiatan.toJson())
        as Map<String, dynamic>;
    return Kegiatan.fromJson(data);
  }

  /// Update status selesai kegiatan saja (PATCH).
  /// PATCH /api/kegiatan/{id}/toggle_selesai/
  Future<void> updateActivityStatus({
    required String id,
    required bool selesai,
  }) async {
    if (id.isEmpty) return;
    developer.log('updateActivityStatus($id, selesai=$selesai)', name: 'ProyekService');
    await _api.patch('/api/aktivitas/$id/toggle_selesai/', {'selesai': selesai});
  }

  /// Hapus kegiatan.
  /// DELETE /api/kegiatan/{id}/
  Future<void> deleteActivity(String id) async {
    if (id.isEmpty) return;
    developer.log('deleteActivity($id)', name: 'ProyekService');
    await _api.delete('/api/aktivitas/$id/');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BERKAS KEGIATAN
  // ═══════════════════════════════════════════════════════════════════════════

  /// Ambil daftar berkas dari suatu kegiatan.
  /// GET /api/berkas-kegiatan/?kegiatan={activityId}
  Future<List<Map<String, dynamic>>> getActivityFiles(String activityId) async {
    developer.log('getActivityFiles(activityId=$activityId)', name: 'ProyekService');
    final data = await _api.get('/api/bukti-aktivitas/?aktivitas=$activityId') as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  /// Upload berkas untuk kegiatan.
  /// POST /api/berkas-kegiatan/
  Future<Map<String, dynamic>> uploadActivityFile({
    required String activityId,
    required String filePath,
    required String fileName,
  }) async {
    developer.log('uploadActivityFile($activityId, $fileName)', name: 'ProyekService');
    final data = await _api.postMultipart(
      '/api/bukti-aktivitas/',
      {
        'aktivitas': activityId,
      },
      filePath,
      'file',
    ) as Map<String, dynamic>;
    return data;
  }

  /// Hapus berkas kegiatan.
  /// DELETE /api/berkas-kegiatan/{id}/
  Future<void> deleteActivityFile(String fileId) async {
    if (fileId.isEmpty) return;
    developer.log('deleteActivityFile($fileId)', name: 'ProyekService');
    await _api.delete('/api/bukti-aktivitas/$fileId/');
  }
}
