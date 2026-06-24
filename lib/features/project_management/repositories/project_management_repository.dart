import '../models/pm_entities.dart';

abstract class ProjectManagementRepository {
  Future<List<PmProject>> getProjects();
  Future<List<PmWork>> getWorksByProject(String projectId);
  Future<List<PmActivity>> getActivitiesByWork(String workId);

  Future<PmProject> createProject(PmProject project);
  Future<PmWork> createWork(PmWork work);
  Future<PmActivity> createActivity(PmActivity activity);
}
