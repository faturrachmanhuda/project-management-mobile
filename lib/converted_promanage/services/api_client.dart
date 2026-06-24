import '../../services/api_service.dart';
import '../models/project.dart';
import '../models/work.dart';
import '../models/activity.dart';

/// Lightweight API client tailored for the converted PROMANAGE UI.
/// It uses the existing `ApiService` for HTTP and token handling,
/// and converts responses into `ConvertedProject` / `ConvertedWork` / `ConvertedActivity`.
class ConvertedApiClient {
  static final ConvertedApiClient _instance = ConvertedApiClient._internal();
  factory ConvertedApiClient() => _instance;
  ConvertedApiClient._internal();

  final ApiService _api = ApiService();

  List<dynamic> _unwrapList(dynamic resp) {
    if (resp == null) return <dynamic>[];
    if (resp is List) return resp;
    if (resp is Map<String, dynamic>) {
      if (resp.containsKey('data') && resp['data'] is List) return resp['data'] as List<dynamic>;
      if (resp.containsKey('results') && resp['results'] is List) return resp['results'] as List<dynamic>;
    }
    return <dynamic>[];
  }

  Map<String, dynamic>? _unwrapObject(dynamic resp) {
    if (resp == null) return null;
    if (resp is Map<String, dynamic>) return resp;
    return null;
  }

  /// GET /api/proyek/ -> List projects
  Future<List<ConvertedProject>> fetchProjects() async {
    final resp = await _api.get('/api/proyek/');
    final list = _unwrapList(resp);
    return list.whereType<Map<String, dynamic>>().map(ConvertedProject.fromJson).toList();
  }

  /// GET /api/proyek/{id}/ -> Project detail
  Future<ConvertedProject> fetchProject(String id) async {
    final resp = await _api.get('/api/proyek/$id/');
    final obj = _unwrapObject(resp);
    if (obj == null) throw Exception('Invalid project response');
    return ConvertedProject.fromJson(obj);
  }

  /// GET /api/pekerjaan/ or /api/pekerjaan/berdasarkan_proyek/?id_proyek={id}
  Future<List<ConvertedWork>> fetchWorks({String? projectId}) async {
    final endpoint = projectId != null
        ? '/api/pekerjaan/berdasarkan_proyek/?id_proyek=$projectId'
        : '/api/pekerjaan/';
    final resp = await _api.get(endpoint);
    final list = _unwrapList(resp);
    // backend sometimes wraps objects inside { 'data': [...] }
    return list.whereType<Map<String, dynamic>>().map(ConvertedWork.fromJson).toList();
  }

  /// GET /api/aktivitas/ or /api/aktivitas/berdasarkan_pekerjaan/?id_pekerjaan={id}
  Future<List<ConvertedActivity>> fetchActivities({String? workId}) async {
    final endpoint = workId != null
        ? '/api/aktivitas/berdasarkan_pekerjaan/?id_pekerjaan=$workId'
        : '/api/aktivitas/';
    final resp = await _api.get(endpoint);
    final list = _unwrapList(resp);
    return list.whereType<Map<String, dynamic>>().map(ConvertedActivity.fromJson).toList();
  }

  /// POST /api/aktivitas/ -> create activity
  /// Accepts either a map or an ItemKegiatan-like map. Returns created activity as ConvertedActivity.
  Future<ConvertedActivity> createActivity(Map<String, dynamic> body) async {
    final resp = await _api.post('/api/aktivitas/', body);
    final obj = _unwrapObject(resp);
    if (obj == null) throw Exception('Invalid create activity response');
    return ConvertedActivity.fromJson(obj);
  }

  /// Download a project timeline (uses project action timeline)
  Future<List<Map<String, dynamic>>> fetchProjectTimeline(String projectId) async {
    final resp = await _api.get('/api/proyek/$projectId/timeline/');
    if (resp is Map<String, dynamic> && resp.containsKey('timeline')) {
      return (resp['timeline'] as List<dynamic>).cast<Map<String, dynamic>>();
    }
    return <Map<String, dynamic>>[];
  }
}
