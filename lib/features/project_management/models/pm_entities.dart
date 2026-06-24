class PmProject {
  const PmProject({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.executor,
    required this.supervisor,
  });

  final String id;
  final String name;
  final String description;
  final String location;
  // Django returns String (ISO format), Flutter follows Django
  final String startDate;
  final String endDate;
  final String executor;
  final String supervisor;
}

class PmWork {
  const PmWork({
    required this.id,
    required this.projectId,
    required this.name,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.executor,
    required this.supervisor,
  });

  final String id;
  final String projectId;
  final String name;
  final String description;
  final String location;
  // Django returns String (ISO format), Flutter follows Django
  final String startDate;
  final String endDate;
  final String executor;
  final String supervisor;
}

class PmActivity {
  const PmActivity({
    required this.id,
    required this.workId,
    required this.name,
    required this.executionTime,
    required this.executor,
    this.done = false,
    this.evaluation = '',
    this.additionalPlan = '',
  });

  final String id;
  final String workId;
  final String name;
  // Django returns String (ISO format), Flutter follows Django
  final String executionTime;
  final String executor;
  final bool done;
  final String evaluation;
  final String additionalPlan;
}
