import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/modelbikinproyek.dart';
import '../services/api_config.dart';
import '../services/api_service.dart';
import '../utils/pdf_export_helper.dart';
import '../utils/responsive_helper.dart';
import '../utils/toast_helper.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../viewmodel/bikinproyek_viewmodel.dart';
import '../widgets/app_header.dart';
import '../utils/design_tokens.dart';

class TaskReportPage extends StatefulWidget {
  const TaskReportPage({super.key});

  @override
  State<TaskReportPage> createState() => _TaskReportPageState();
}

class _TaskReportPageState extends State<TaskReportPage> {
  String _statusFilter = 'all';
  String _projectFilter = 'all';
  bool _exportingPdf = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ProyekViewModel>().muatProyek();
    });
  }

  List<Proyek> _filteredProjects(List<Proyek> projects) {
    return projects
        .where((project) {
          final projectMatches =
              _projectFilter == 'all' || project.id == _projectFilter;
          final isDone = _isProjectDone(project);
          final statusMatches =
              _statusFilter == 'all' ||
              (_statusFilter == 'done' && isDone) ||
              (_statusFilter == 'undone' && !isDone);
          return projectMatches && statusMatches;
        })
        .toList(growable: false);
  }

  bool _isProjectDone(Proyek project) {
    if (project.isTertutup || project.status.toLowerCase() == 'selesai') {
      return true;
    }
    final totalActivities = project.daftarKegiatan.length;
    if (totalActivities == 0) return false;
    final doneActivities = project.daftarKegiatan
        .where((a) => a.selesai)
        .length;
    return doneActivities == totalActivities;
  }

  int _doneActivities(Proyek project) =>
      project.daftarKegiatan.where((a) => a.selesai).length;

  double _progress(Proyek project) {
    final total = project.daftarKegiatan.length;
    if (total == 0) return 0;
    return (_doneActivities(project) / total) * 100;
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '-';
    final parts = dateStr.split(' - ');
    if (parts.length == 2) {
      return '${_formatSingleDate(parts[0])} s/d ${_formatSingleDate(parts[1])}';
    }
    return _formatSingleDate(dateStr);
  }

  String _formatSingleDate(String dateStr) {
    try {
      final parsed = DateTime.parse(dateStr.trim());
      return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _exportPdf(
    BuildContext context,
    List<Proyek> projects,
    Map<String, dynamic> user,
  ) async {
    if (_exportingPdf) return;
    setState(() => _exportingPdf = true);

    try {
      if (ApiConfig.useLocalOnly) {
        await PdfExportHelper.printGlobalReport(projects, user);
      } else {
        final bytes = await ApiService().getBytes('/api/reports/all/pdf/');
        await Printing.sharePdf(
          bytes: bytes,
          filename: 'laporan_tugas_promanage.pdf',
        );
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(
          context,
          'Gagal mengunduh PDF dari backend, memakai laporan lokal.',
        );
      }
      try {
        await PdfExportHelper.printGlobalReport(projects, user);
      } catch (fallbackError) {
        if (mounted) {
          ToastHelper.showError(
            context,
            'Gagal membuat PDF laporan: $fallbackError',
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _exportingPdf = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final proyekVM = context.watch<ProyekViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final isMobile = ResponsiveHelper.isMobile(context);
    final projects = proyekVM.daftarProyek;
    final filteredProjects = _filteredProjects(projects);
    final totalProjects = filteredProjects.length;
    final totalWorks = filteredProjects.fold<int>(
      0,
      (sum, project) => sum + project.daftarPekerjaan.length,
    );
    final totalActivities = filteredProjects.fold<int>(
      0,
      (sum, project) => sum + project.daftarKegiatan.length,
    );
    final doneActivities = filteredProjects.fold<int>(
      0,
      (sum, project) => sum + _doneActivities(project),
    );
    final pendingActivities = totalActivities - doneActivities;
    final overallProgress = totalActivities == 0
        ? 0
        : ((doneActivities / totalActivities) * 100).round();
    final completedProjects = filteredProjects
        .where((project) => _isProjectDone(project))
        .length;

    final user = authVM.penggunaSaatIni ?? <String, dynamic>{};

    return Scaffold(
      backgroundColor: DesignColors.bg,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isMobile ? 132 : 84),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const AppHeader(),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFEF2F2), Color(0xFFFFFBFA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFFECACA)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isCompact = constraints.maxWidth < 720;
                              return isCompact
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 9,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEE2E2),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                            child: const Text(
                                            'Laporan Tugas',
                                            style: TextStyle(
                                              color: DesignColors.primary,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 560,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Ringkasan aktivitas, pekerjaan, dan progres proyek dalam satu halaman.',
                                                style: TextStyle(
                                                  fontSize: isCompact ? 24 : 30,
                                                  height: 1.1,
                                                  fontWeight: FontWeight.w900,
                                                  color: DesignColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                'Gunakan filter untuk melihat proyek yang sudah selesai atau yang masih berjalan, lalu unduh laporan PDF dari backend Django.',
                                                style: TextStyle(
                                                  fontSize: isCompact ? 14 : 15,
                                                  height: 1.7,
                                                  color: DesignColors.hint,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          children: [
                                            FilledButton.icon(
                                              onPressed: _exportingPdf
                                                  ? null
                                                  : () => _exportPdf(
                                                      context,
                                                      projects,
                                                      user,
                                                    ),
                                              style: FilledButton.styleFrom(
                                                  backgroundColor: DesignColors.primary,
                                                  foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 18,
                                                      vertical: 16,
                                                    ),
                                              ),
                                              icon: _exportingPdf
                                                  ? const SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                          ),
                                                    )
                                                  : const Icon(
                                                      Icons
                                                          .picture_as_pdf_outlined,
                                                    ),
                                              label: Text(
                                                _exportingPdf
                                                    ? 'Memproses...'
                                                    : 'Unduh PDF',
                                              ),
                                            ),
                                            OutlinedButton.icon(
                                              onPressed: () => setState(() {
                                                _statusFilter = 'all';
                                                _projectFilter = 'all';
                                              }),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: DesignColors.primary,
                                                side: const BorderSide(
                                                  color: Color(0xFFFCA5A5),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 18,
                                                      vertical: 16,
                                                    ),
                                              ),
                                              icon: const Icon(
                                                Icons.refresh_outlined,
                                              ),
                                              label: const Text('Reset Filter'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 9,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFFEE2E2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        999,
                                                      ),
                                                ),
                                                child: const Text(
                                                  'Laporan Tugas',
                                                  style: TextStyle(
                                                    color: DesignColors.primary,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 0.6,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              const Text(
                                                'Ringkasan aktivitas, pekerjaan, dan progres proyek dalam satu halaman.',
                                                style: TextStyle(
                                                  fontSize: 30,
                                                  height: 1.1,
                                                  fontWeight: FontWeight.w900,
                                                  color: DesignColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              const Text(
                                                'Gunakan filter untuk melihat proyek yang sudah selesai atau yang masih berjalan, lalu unduh laporan PDF dari backend Django.',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  height: 1.7,
                                                  color: DesignColors.hint,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          alignment: WrapAlignment.end,
                                          children: [
                                            FilledButton.icon(
                                              onPressed: _exportingPdf
                                                  ? null
                                                  : () => _exportPdf(
                                                      context,
                                                      projects,
                                                      user,
                                                    ),
                                              style: FilledButton.styleFrom(
                                                backgroundColor: DesignColors.primary,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 18,
                                                      vertical: 16,
                                                    ),
                                              ),
                                              icon: _exportingPdf
                                                  ? const SizedBox(
                                                      width: 16,
                                                      height: 16,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color: Colors.white,
                                                          ),
                                                    )
                                                  : const Icon(
                                                      Icons
                                                          .picture_as_pdf_outlined,
                                                    ),
                                              label: Text(
                                                _exportingPdf
                                                    ? 'Memproses...'
                                                    : 'Unduh PDF',
                                              ),
                                            ),
                                            OutlinedButton.icon(
                                              onPressed: () => setState(() {
                                                _statusFilter = 'all';
                                                _projectFilter = 'all';
                                              }),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: DesignColors.primary,
                                                side: const BorderSide(
                                                  color: Color(0xFFFCA5A5),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 18,
                                                      vertical: 16,
                                                    ),
                                              ),
                                              icon: const Icon(
                                                Icons.refresh_outlined,
                                              ),
                                              label: const Text('Reset Filter'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _StatsGrid(
                      totalProjects: totalProjects,
                      totalWorks: totalWorks,
                      totalActivities: totalActivities,
                      doneActivities: doneActivities,
                      pendingActivities: pendingActivities,
                      overallProgress: overallProgress,
                      completedProjects: completedProjects,
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: DesignColors.borderLight),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: isMobile ? double.infinity : 320,
                            child: DropdownButtonFormField<String>(
                              initialValue: _projectFilter,
                              decoration: _fieldDecoration('Filter proyek'),
                              items: [
                                const DropdownMenuItem(
                                  value: 'all',
                                  child: Text('Semua proyek'),
                                ),
                                ...projects.map(
                                  (project) => DropdownMenuItem(
                                    value: project.id,
                                    child: Text(project.nama),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _projectFilter = value);
                              },
                            ),
                          ),
                          SizedBox(
                            width: isMobile ? double.infinity : null,
                            child: SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'all',
                                  label: Text('Semua'),
                                  icon: Icon(Icons.list_alt),
                                ),
                                ButtonSegment(
                                  value: 'done',
                                  label: Text('Selesai'),
                                  icon: Icon(Icons.check_circle_outline),
                                ),
                                ButtonSegment(
                                  value: 'undone',
                                  label: Text('Belum selesai'),
                                  icon: Icon(Icons.schedule_outlined),
                                ),
                              ],
                              selected: {_statusFilter},
                              onSelectionChanged: (values) {
                                setState(() => _statusFilter = values.first);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (proyekVM.sedangMemuat)
                      const _LoadingCard()
                    else if (proyekVM.pesanError != null)
                      _ErrorCard(
                        message: proyekVM.pesanError!,
                        onRetry: proyekVM.muatUlang,
                      )
                    else if (filteredProjects.isEmpty)
                      _EmptyCard(
                        title: 'Belum ada data yang cocok',
                        subtitle:
                            'Coba ubah filter proyek atau status untuk melihat laporan yang lain.',
                      )
                    else
                      Column(
                        children: filteredProjects
                            .map(
                              (project) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _ProjectCard(
                                  project: project,
                                  progress: _progress(project).round(),
                                  doneActivities: _doneActivities(project),
                                  totalActivities:
                                      project.daftarKegiatan.length,
                                  totalWorks: project.daftarPekerjaan.length,
                                  isCompleted: _isProjectDone(project),
                                  formatDate: _formatDate,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: DesignColors.bg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: DesignColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: DesignColors.primary),
      ),
    );
  }
}



class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.totalProjects,
    required this.totalWorks,
    required this.totalActivities,
    required this.doneActivities,
    required this.pendingActivities,
    required this.overallProgress,
    required this.completedProjects,
  });

  final int totalProjects;
  final int totalWorks;
  final int totalActivities;
  final int doneActivities;
  final int pendingActivities;
  final int overallProgress;
  final int completedProjects;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 760;
    final items = [
      _StatCard(
        icon: Icons.folder_outlined,
        title: 'Total Proyek',
        value: totalProjects.toString(),
        subtitle: 'yang tampil di filter',
        accent: DesignColors.primary,
      ),
      _StatCard(
        icon: Icons.view_week_outlined,
        title: 'Total Pekerjaan',
        value: totalWorks.toString(),
        subtitle: 'seluruh pekerjaan aktif',
        accent: DesignColors.statusDone,
      ),
      _StatCard(
        icon: Icons.check_circle_outline,
        title: 'Aktivitas Selesai',
        value: doneActivities.toString(),
        subtitle: 'dari $totalActivities aktivitas',
        accent: DesignColors.statusActive,
      ),
      _StatCard(
        icon: Icons.schedule_outlined,
        title: 'Aktivitas Pending',
        value: pendingActivities.toString(),
        subtitle: 'perlu ditindaklanjuti',
        accent: DesignColors.statusPending,
      ),
      _StatCard(
        icon: Icons.percent_outlined,
        title: 'Progres Global',
        value: '$overallProgress%',
        subtitle: '$completedProjects proyek selesai',
        accent: DesignColors.primary,
      ),
      _StatCard(
        icon: Icons.flag_outlined,
        title: 'Proyek Selesai',
        value: completedProjects.toString(),
        subtitle: 'status selesai / tertutup',
        accent: DesignColors.success,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 3 : 1,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: isWide ? 1.7 : 2.2,
      ),
      itemBuilder: (context, index) => items[index],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DesignColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
              decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: DesignColors.hint,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: DesignColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesignColors.slate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.progress,
    required this.doneActivities,
    required this.totalActivities,
    required this.totalWorks,
    required this.isCompleted,
    required this.formatDate,
  });

  final Proyek project;
  final int progress;
  final int doneActivities;
  final int totalActivities;
  final int totalWorks;
  final bool isCompleted;
  final String Function(String) formatDate;

  @override
  Widget build(BuildContext context) {
    final statusColor = isCompleted
      ? DesignColors.statusActive
      : project.status.toLowerCase() == 'tertunda'
      ? DesignColors.statusPending
      : DesignColors.primary;
    final statusBg = statusColor.withOpacity(0.12);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DesignColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                  decoration: BoxDecoration(
                  color: DesignColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.folder_rounded, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            project.nama,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: DesignColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isCompleted ? 'Selesai' : project.status,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      project.deskripsi,
                      style: const TextStyle(
                        color: DesignColors.hint,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _InfoChip(
                icon: Icons.location_on_outlined,
                label: project.lokasi,
              ),
              _InfoChip(
                icon: Icons.date_range_outlined,
                label: formatDate(project.tanggal),
              ),
              _InfoChip(icon: Icons.groups_outlined, label: project.tim),
              _InfoChip(
                icon: Icons.badge_outlined,
                label: 'Pembimbing: ${project.pengawas}',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Pekerjaan',
                  value: totalWorks.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  label: 'Aktivitas',
                  value: '$doneActivities/$totalActivities',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(label: 'Progres', value: '$progress%'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 10,
              backgroundColor: DesignColors.surfaceSoft,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 18),
          const _SubmissionSectionHeader(),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 960
                  ? 3
                  : constraints.maxWidth >= 620
                  ? 2
                  : 1;

              final cards = _submissionCategories.map((category) {
                // Cari berdasarkan kategori (lebih akurat daripada nama)
                final syncJob = project.daftarPekerjaan.where((p) => p.kategori == category.slug).firstOrNull;
                
                String syncStatus = 'Menunggu sinkronisasi...';
                bool isSynced = false;
                String syncEvaluasi = '';
                
                if (syncJob != null) {
                   final jobActivities = project.daftarKegiatan.where((k) => k.idPekerjaan == syncJob.id).toList();
                   if (jobActivities.isNotEmpty) {
                       final lastActivity = jobActivities.first;
                       if (lastActivity.evaluasi != null && lastActivity.evaluasi!.isNotEmpty) {
                           isSynced = true;
                           syncStatus = lastActivity.namaKegiatan;
                           syncEvaluasi = lastActivity.evaluasi!;
                       }
                   }
                }

                return _SubmissionCategoryCard(
                  projectName: project.nama,
                  category: category,
                  isSynced: isSynced,
                  syncStatusText: syncStatus,
                  syncEvaluasi: syncEvaluasi,
                  onOpen: () {
                    ToastHelper.showSuccess(
                      context,
                      'Slot ${category.title} untuk ${project.nama} siap digunakan',
                    );
                  },
                );
              }).toList();

              if (columns == 1) {
                return Column(
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      cards[i],
                      if (i != cards.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: columns == 2 ? 0.86 : 0.92,
                ),
                itemBuilder: (context, index) => cards[index],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SubmissionSectionHeader extends StatelessWidget {
  const _SubmissionSectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.inbox_rounded,
            color: DesignColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tempat Pengumpulan Tugas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: DesignColors.textPrimary,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Setiap proyek punya 3 slot kategori pengumpulan.',
                style: TextStyle(fontSize: 12, color: DesignColors.hint),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubmissionCategoryCard extends StatelessWidget {
  const _SubmissionCategoryCard({
    required this.projectName,
    required this.category,
    required this.isSynced,
    required this.syncStatusText,
    required this.syncEvaluasi,
    required this.onOpen,
  });

  final String projectName;
  final _SubmissionCategory category;
  final bool isSynced;
  final String syncStatusText;
  final String syncEvaluasi;
  final VoidCallback onOpen;

  Widget _buildLinks(String evaluasi) {
    if (evaluasi.isEmpty) return const SizedBox();
    try {
      final json = jsonDecode(evaluasi);
      if (json is Map<String, dynamic> && json.containsKey('links')) {
        final links = json['links'] as List;
        if (links.isEmpty) return const SizedBox();
        return Column(
          children: links.map((link) {
            final title = link['title'] ?? 'Link';
            String url = link['url'] ?? '';
            url = url.replaceAll('127.0.0.1', ApiConfig.laptopIp).replaceAll('localhost', ApiConfig.laptopIp);
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: InkWell(
                onTap: () async {
                  if (url.isNotEmpty) {
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.open_in_new, size: 12, color: Color(0xFF334155)),
                      const SizedBox(width: 6),
                      Text(
                        title,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }
    } catch (_) {}
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: category.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: category.accentColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(category.icon, color: Colors.white, size: 22),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: category.badgeBgColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Terhubung API',
                  style: TextStyle(
                    color: category.badgeTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            category.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: DesignColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: DesignColors.hint,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: category.panelColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: category.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Status Pengumpulan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isSynced
                      ? 'Data untuk kategori ${category.title.toLowerCase()} telah disinkronisasikan dari sistem mitra.'
                      : 'Data untuk kategori ${category.title.toLowerCase()} akan ditarik secara otomatis dari sistem mitra.',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 10),
                if (!isSynced)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.9)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sync, size: 16, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 6),
                        const Text(
                          'Menunggu sinkronisasi...',
                          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.9)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 16, color: category.accentColor),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                syncStatusText,
                                style: TextStyle(fontSize: 12, color: category.accentColor, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildLinks(syncEvaluasi),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: DesignColors.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmissionCategory {
  const _SubmissionCategory({
    required this.slug,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.panelColor,
    required this.borderColor,
    required this.badgeBgColor,
    required this.badgeTextColor,
  });

  final String slug;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final Color panelColor;
  final Color borderColor;
  final Color badgeBgColor;
  final Color badgeTextColor;
}

const List<_SubmissionCategory> _submissionCategories = [
  _SubmissionCategory(
    slug: 'implementation',
    title: 'Implementation',
    description:
        'Hasil implementasi fitur, penerapan kode, atau bukti pengerjaan teknis.',
    icon: Icons.code_rounded,
    accentColor: Color(0xFF2563EB),
    panelColor: Color(0xFFEFF6FF),
    borderColor: Color(0xFFBFDBFE),
    badgeBgColor: Color(0xFFDBEAFE),
    badgeTextColor: Color(0xFF1D4ED8),
  ),
  _SubmissionCategory(
    slug: 'creation',
    title: 'Creation',
    description:
        'Karya baru, dokumen perancangan, atau hasil pembuatan awal proyek.',
    icon: Icons.brush_rounded,
    accentColor: Color(0xFFD97706),
    panelColor: Color(0xFFFFFBEB),
    borderColor: Color(0xFFFDE68A),
    badgeBgColor: Color(0xFFFEF3C7),
    badgeTextColor: Color(0xFFB45309),
  ),
  _SubmissionCategory(
    slug: 'engineering',
    title: 'Engineering',
    description: 'Rekayasa sistem, analisis teknis, dan pengembangan lanjutan.',
    icon: Icons.settings_rounded,
    accentColor: Color(0xFF059669),
    panelColor: Color(0xFFECFDF5),
    borderColor: Color(0xFFA7F3D0),
    badgeBgColor: Color(0xFFD1FAE5),
    badgeTextColor: Color(0xFF047857),
  ),
];

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: DesignColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(color: DesignColors.primary),
          SizedBox(height: 12),
          Text(
            'Memuat laporan tugas...',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off_outlined,
            color: DesignColors.primary,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF334155)),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => onRetry(),
            style: FilledButton.styleFrom(
              backgroundColor: DesignColors.primary,
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: DesignColors.bg,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.inbox_outlined,
              size: 34,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B), height: 1.6),
          ),
        ],
      ),
    );
  }
}
