import 'package:flutter/foundation.dart';

import '../models/pm_entities.dart';
import '../repositories/project_management_repository.dart';

class ProjectManagementViewModel extends ChangeNotifier {
  ProjectManagementViewModel(this._repository);

  final ProjectManagementRepository _repository;

  List<PmProject> _projects = [];
  final Map<String, List<PmWork>> _worksByProject = {};
  final Map<String, List<PmActivity>> _activitiesByWork = {};

  bool _loading = false;
  String? _error;

  List<PmProject> get projects => List.unmodifiable(_projects);
  bool get loading => _loading;
  String? get error => _error;

  List<PmWork> worksForProject(String projectId) =>
      List.unmodifiable(_worksByProject[projectId] ?? const []);

  List<PmActivity> activitiesForWork(String workId) =>
      List.unmodifiable(_activitiesByWork[workId] ?? const []);

  Future<void> loadProjects() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _projects = await _repository.getProjects();
    } catch (e) {
      _error = 'Gagal memuat project: $e';
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> loadWorks(String projectId) async {
    try {
      _worksByProject[projectId] = await _repository.getWorksByProject(projectId);
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat work: $e';
      notifyListeners();
    }
  }

  Future<void> loadActivities(String workId) async {
    try {
      _activitiesByWork[workId] = await _repository.getActivitiesByWork(workId);
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat activity: $e';
      notifyListeners();
    }
  }

  Future<void> createProject({
    required String name,
    required String description,
    required String location,
    required String startDate,
    required String endDate,
    required String executor,
    required String supervisor,
  }) async {
    await _repository.createProject(
      PmProject(
        id: '',
        name: name,
        description: description,
        location: location,
        startDate: startDate,
        endDate: endDate,
        executor: executor,
        supervisor: supervisor,
      ),
    );
    await loadProjects();
  }

  Future<void> createWork({
    required String projectId,
    required String name,
    required String description,
    required String location,
    required String startDate,
    required String endDate,
    required String executor,
    required String supervisor,
  }) async {
    await _repository.createWork(
      PmWork(
        id: '',
        projectId: projectId,
        name: name,
        description: description,
        location: location,
        startDate: startDate,
        endDate: endDate,
        executor: executor,
        supervisor: supervisor,
      ),
    );
    await loadWorks(projectId);
  }

  Future<void> createActivity({
    required String workId,
    required String name,
    required String executionTime,
    required String executor,
    required String evaluation,
    required String additionalPlan,
  }) async {
    await _repository.createActivity(
      PmActivity(
        id: '',
        workId: workId,
        name: name,
        executionTime: executionTime,
        executor: executor,
        evaluation: evaluation,
        additionalPlan: additionalPlan,
      ),
    );
    await loadActivities(workId);
  }
}
