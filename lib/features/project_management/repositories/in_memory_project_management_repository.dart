import 'dart:math';

import '../models/pm_entities.dart';
import 'project_management_repository.dart';
import '../../../services/project_service.dart';
import '../../../models/modelbikinproyek.dart';
import '../../../models/job.dart';
import '../../../models/activity_model.dart';

/// Repository untuk Project Management.
/// 
/// ARSIREKTUR BARU:
/// - Source of truth adalah Django
/// - Repository ini sekarang menggunakan API service untuk mengambil data
/// - In-memory storage tidak lagi digunakan untuk data bisnis
/// 
/// Catatan: Repository ini mungkin tidak digunakan di flow utama,
/// karena ProyekViewModel sudah langsung menggunakan ProyekService.
/// Disini untuk backward compatibility.
class InMemoryProjectManagementRepository implements ProjectManagementRepository {
  InMemoryProjectManagementRepository() {
    _layananProyek = ProyekService();
  }

  late final ProyekService _layananProyek;
  String _id(String prefix) => '$prefix-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(999)}';

  /// Ambil semua proyek dari server (Django adalah source of truth).
  @override
  Future<List<PmProject>> getProjects() async {
    try {
      final proyekList = await _layananProyek.getProjects();
      return proyekList.map((p) => PmProject(
        id: p.id,
        name: p.nama,
        description: p.deskripsi,
        location: p.lokasi,
        startDate: p.tanggalMulai,
        endDate: p.tanggalSelesai,
        executor: p.tim,
        supervisor: p.pengawas,
      )).toList();
    } catch (e) {
      // Jika gagal, kembalikan list kosong - tidak ada fallback ke lokal
      return [];
    }
  }

  /// Ambil pekerjaan untuk proyek tertentu dari server.
  @override
  Future<List<PmWork>> getWorksByProject(String projectId) async {
    try {
      final works = await _layananProyek.getWorks(projectId: projectId);
      return works.map((w) => PmWork(
        id: w.id,
        projectId: w.idProyek,
        name: w.nama,
        description: w.deskripsi,
        location: w.lokasi,
        startDate: w.tanggalMulai,
        endDate: w.tanggalSelesai,
        executor: w.pelaksana,
        supervisor: w.pengawas,
      )).toList();
    } catch (e) {
      return [];
    }
  }

  /// Ambil aktivitas untuk pekerjaan tertentu dari server.
  @override
  Future<List<PmActivity>> getActivitiesByWork(String workId) async {
    try {
      final activities = await _layananProyek.getActivities(workId: workId);
      return activities.map((a) => PmActivity(
        id: a.id,
        workId: a.jobId,
        name: a.title,
        executionTime: a.date,
        executor: a.desc,
        done: a.status == 'selesai' || a.status == 'done',
        evaluation: a.evaluation,
        additionalPlan: a.followUpPlan,
      )).toList();
    } catch (e) {
      return [];
    }
  }

  /// Buat proyek baru via server.
  @override
  Future<PmProject> createProject(PmProject project) async {
    final proyek = Proyek(
      id: project.id.isEmpty ? _id('PRJ') : project.id,
      nama: project.name,
      deskripsi: project.description,
      lokasi: project.location,
      tanggalMulai: project.startDate,
      tanggalSelesai: project.endDate,
      tim: project.executor,
      pengawas: project.supervisor,
    );

    final created = await _layananProyek.createProject(proyek);
    return PmProject(
      id: created.id,
      name: created.nama,
      description: created.deskripsi,
      location: created.lokasi,
      startDate: created.tanggalMulai,
      endDate: created.tanggalSelesai,
      executor: created.tim,
      supervisor: created.pengawas,
    );
  }

  /// Buat pekerjaan baru via server.
  @override
  Future<PmWork> createWork(PmWork work) async {
    final pekerjaan = Pekerjaan(
      id: work.id.isEmpty ? _id('WRK') : work.id,
      idProyek: work.projectId,
      nama: work.name,
      deskripsi: work.description,
      lokasi: work.location,
      tanggalMulai: work.startDate,
      tanggalSelesai: work.endDate,
      pelaksana: work.executor,
      pengawas: work.supervisor,
    );

    final created = await _layananProyek.createWork(pekerjaan);
    return PmWork(
      id: created.id,
      projectId: created.idProyek,
      name: created.nama,
      description: created.deskripsi,
      location: created.lokasi,
      startDate: created.tanggalMulai,
      endDate: created.tanggalSelesai,
      executor: created.pelaksana,
      supervisor: created.pengawas,
    );
  }

  /// Buat aktivitas baru via server.
  @override
  Future<PmActivity> createActivity(PmActivity activity) async {
    final kegiatan = Kegiatan(
      id: activity.id.isEmpty ? _id('ACT') : activity.id,
      jobId: activity.workId,
      title: activity.name,
      date: activity.executionTime,
      desc: activity.executor,
      status: activity.done ? 'done' : 'pending',
      evaluation: activity.evaluation,
      followUpPlan: activity.additionalPlan,
    );

    final created = await _layananProyek.createActivity(kegiatan);
    return PmActivity(
      id: created.id,
      workId: created.jobId,
      name: created.title,
      executionTime: created.date,
      executor: created.desc,
      done: created.status == 'done',
      evaluation: created.evaluation,
      additionalPlan: created.followUpPlan,
    );
  }
}