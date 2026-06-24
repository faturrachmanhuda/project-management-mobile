import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../models/modelbikinproyek.dart';
import '../services/api_config.dart';
import '../utils/pdf_export_helper.dart';
import '../utils/responsive_helper.dart';
import '../utils/toast_helper.dart';
import '../viewmodel/bikinproyek_viewmodel.dart';
import '../widgets/app_header.dart';
import '../utils/design_tokens.dart';
import 'gantt_chart_widget.dart';

class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({super.key, required this.proyek});

  final Proyek proyek;

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  static const Color _maroon = DesignColors.primary;
  static const Color _maroonSoft = DesignColors.primarySoft;
  static const Color _slate = DesignColors.textSecondary;
  static const Color _cardBorder = DesignColors.borderInput;

  Proyek _project(BuildContext context) {
    final vm = context.watch<ProyekViewModel>();
    return vm.daftarProyek.firstWhere(
      (p) => p.id == widget.proyek.id,
      orElse: () => widget.proyek,
    );
  }

  // Removed search query state variable

  @override
  Widget build(BuildContext context) {
    final project = _project(context);
    final mobile = ResponsiveHelper.isMobile(context);
    final landscape = ResponsiveHelper.isMobileLandscape(context);
    final useSideLayout = !mobile || landscape;
    final pagePadding = ResponsiveHelper.pagePadding(context);
    final contentWidth = ResponsiveHelper.constrainedContentWidth(context);
    
    final totalActivities = project.daftarKegiatan.length;
    final doneActivities = project.daftarKegiatan.where((a) => a.selesai).length;
    final progress = totalActivities == 0 ? 0.0 : doneActivities / totalActivities;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppHeader(),
                  const SizedBox(height: 10),
                  _buildTopBar(context, project, mobile, landscape),
                  const SizedBox(height: 16),
                  Padding(
                    padding: pagePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        useSideLayout
                            ? LayoutBuilder(
                                builder: (context, constraints) {
                                  final leftWidth = landscape
                                      ? 300.0
                                      : (constraints.maxWidth * 0.42).clamp(160.0, 390.0);
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Kolom kiri: Info + Progress
                                      SizedBox(
                                        width: leftWidth,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            _buildInfoCard(project, progress, doneActivities, totalActivities),
                                            const SizedBox(height: 16),
                                            _buildProgressCard(project, progress, doneActivities, totalActivities),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Kolom kanan: Timeline + Daftar Pekerjaan
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            _buildTimelineCard(project),
                                            const SizedBox(height: 16),
                                            _buildWorksPanel(project, mobile: mobile, landscape: landscape),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildInfoCard(project, progress, doneActivities, totalActivities),
                                  const SizedBox(height: 16),
                                  _buildProgressCard(project, progress, doneActivities, totalActivities),
                                  const SizedBox(height: 16),
                                  _buildTimelineCard(project),
                                  const SizedBox(height: 16),
                                  _buildWorksPanel(project, mobile: mobile, landscape: landscape),
                                ],
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    Proyek project,
    bool mobile,
    bool landscape,
  ) {
    final status = _statusLabel(project);
    final compact = mobile && !landscape;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: DesignColors.borderMuted),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        compact ? 14 : 18,
        compact ? 14 : 18,
        compact ? 14 : 18,
        compact ? 16 : 18,
      ),
      child: compact
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _backButton(context),
                const SizedBox(width: 8),
                // Judul + status (kiri)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.nama,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: DesignColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          _statusChip(status, fontSize: 9),
                          const SizedBox(width: 5),
                          Icon(Icons.location_on_outlined, size: 10, color: Colors.grey.shade400),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              project.lokasi.isEmpty ? '-' : project.lokasi,
                              style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol kanan: 2 baris grid, lebar sama
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Baris 1: PDF, Excel, Hapus — stretch penuh
                      Row(
                        children: [
                          Expanded(child: _smallChipExpanded(Icons.picture_as_pdf_outlined, _maroon, _maroonSoft, () => _exportPdf(context, project), 'PDF')),
                          const SizedBox(width: 6),
                          Expanded(child: _smallChipExpanded(Icons.table_chart_outlined, DesignColors.statusActive, DesignColors.statusActiveBg, () => _exportExcel(context, project), 'Excel')),
                          const SizedBox(width: 6),
                          Expanded(child: _smallChipExpanded(Icons.delete_outline, _maroon, _maroonSoft, () => _confirmDeleteProject(context, project), 'Hapus')),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Baris 2: Tutup Proyek, Edit Proyek — stretch penuh
                      Row(
                        children: [
                          Expanded(
                            child: _smallChipLabelFixed(
                              icon: project.isTertutup ? Icons.lock_open : Icons.lock_outline,
                              label: project.isTertutup ? 'Buka Proyek' : 'Tutup Proyek',
                              iconColor: project.isTertutup ? Colors.green.shade800 : _slate,
                              bg: project.isTertutup ? Colors.green.shade50 : Colors.white,
                              onTap: () => _toggleProjectClosure(context, project),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _smallChipLabelFixed(
                              icon: Icons.edit_outlined,
                              label: 'Edit Proyek',
                              iconColor: _slate,
                              bg: Colors.white,
                              onTap: () => _showEditProjectDialog(context, project),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _backButton(context),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.nama,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: DesignColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _statusChip(status),
                          const SizedBox(width: 8),
                          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              project.lokasi.isEmpty ? '-' : project.lokasi,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Tombol aksi desktop — satu baris sejajar judul
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _actionChip(
                      icon: Icons.picture_as_pdf_outlined,
                      label: null,
                      iconColor: _maroon,
                      background: _maroonSoft,
                      onTap: () => _exportPdf(context, project),
                      tooltip: 'Cetak PDF proyek',
                    ),
                    const SizedBox(width: 8),
                    _actionChip(
                      icon: Icons.table_chart_outlined,
                      label: null,
                      iconColor: DesignColors.statusActive,
                      background: DesignColors.statusActiveBg,
                      onTap: () => _exportExcel(context, project),
                      tooltip: 'Ekspor Excel proyek',
                    ),
                    const SizedBox(width: 8),
                    _actionChip(
                      icon: Icons.delete_outline,
                      label: null,
                      iconColor: _maroon,
                      background: _maroonSoft,
                      onTap: () => _confirmDeleteProject(context, project),
                      tooltip: 'Hapus proyek',
                    ),
                    const SizedBox(width: 8),
                    _actionChip(
                      icon: project.isTertutup ? Icons.lock_open : Icons.lock_outline,
                      label: project.isTertutup ? 'Buka Kembali' : 'Tutup Proyek',
                      iconColor: project.isTertutup ? Colors.green.shade800 : _slate,
                      background: project.isTertutup ? Colors.green.shade50 : Colors.white,
                      onTap: () => _toggleProjectClosure(context, project),
                      tooltip: project.isTertutup ? 'Buka kembali proyek' : 'Tutup proyek',
                    ),
                    const SizedBox(width: 8),
                    _actionChip(
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      iconColor: _slate,
                      background: Colors.white,
                      onTap: () => _showEditProjectDialog(context, project),
                      tooltip: 'Edit proyek',
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildInfoCard(Proyek project, double progress, int doneActivities, int totalActivities) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: DesignColors.primary, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Informasi Proyek',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: DesignColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (project.deskripsi.isNotEmpty) ...[
            _sectionLabel('DESKRIPSI'),
            const SizedBox(height: 6),
            Text(
              project.deskripsi,
              style: const TextStyle(fontSize: 14, color: DesignColors.mutedDark, height: 1.5),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: _dateStat(
                  label: 'MULAI',
                  value: _formatDate(project.tanggalMulai),
                ),
              ),
              Expanded(
                child: _dateStat(
                  label: 'SELESAI',
                  value: _formatDate(project.tanggalSelesai),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _personRow(Icons.person_outline, 'PELAKSANA', project.tim),
          const SizedBox(height: 12),
          _personRow(Icons.school_outlined, 'SUPERVISOR', project.pengawas),
          const SizedBox(height: 16),
          if (project.broadcastStatus != null) ...[
            _sectionLabel('BROADCAST STATUS'),
            const SizedBox(height: 8),
            _buildBroadcastStatusRow(project.broadcastStatus!),
            const SizedBox(height: 12),
          ],
          _miniProgress(progress, doneActivities, totalActivities),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    Proyek project,
    double progress,
    int doneActivities,
    int totalActivities,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_maroon, _maroon],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Keseluruhan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                '$doneActivities/$totalActivities Selesai',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.18),
              color: DesignColors.yellowLight,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            totalActivities == 0
                ? 'Belum ada aktivitas yang ditambahkan'
                : 'Perubahan status aktivitas akan otomatis tercermin di sini.',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(Proyek project) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 14, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: DesignColors.primarySoft, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.timeline, color: DesignColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Timeline Pekerjaan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: DesignColors.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (project.daftarPekerjaan.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.calendar_month_outlined, size: 56, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('Belum ada pekerjaan untuk ditampilkan', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            )
          else
            SimpleGanttChart(
              jobs: project.daftarPekerjaan,
              activities: project.daftarKegiatan,
            ),
        ],
      ),
    );
  }

  Widget _buildBroadcastStatusRow(Map<String, dynamic> statusMap) {
    final entries = <MapEntry<String, String>>[];
    statusMap.forEach((k, v) {
      String key = k.toString();
      String stat = '';
      if (v is String) stat = v;
      else if (v is Map && v['status'] != null) stat = v['status'].toString();
      else if (v is Map && v['state'] != null) stat = v['state'].toString();
      else stat = v?.toString() ?? '';
      entries.add(MapEntry(key, stat));
    });

    if (entries.isEmpty) return const SizedBox.shrink();

    Color dotColor(String s) {
      final lower = s.toLowerCase();
      if (lower.contains('success') || lower.contains('ok') || lower.contains('done')) return Colors.green;
      if (lower.contains('failed') || lower.contains('error')) return Colors.red;
      if (lower.contains('pending') || lower.contains('waiting')) return Colors.orange;
      return Colors.grey;
    }

    final scrollController = ScrollController();

    return StatefulBuilder(
      builder: (context, setState) {
        bool showScrollIndicator = entries.length > 2;

        scrollController.addListener(() {
          final atEnd = scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 4;
          if (atEnd && showScrollIndicator) {
            setState(() => showScrollIndicator = false);
          } else if (!atEnd && !showScrollIndicator) {
            setState(() => showScrollIndicator = true);
          }
        });

        return Stack(
          children: [
            SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: entries.map((e) {
                  final label = e.key;
                  final stat = e.value.isEmpty ? 'unknown' : e.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: dotColor(stat),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              Text(stat, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Fade + chevron scroll indicator di kanan
            if (showScrollIndicator)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.95),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildWorksPanel(
    Proyek project, {
    required bool mobile,
    required bool landscape,
  }) {
    final filteredWorks = project.daftarPekerjaan;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row dengan tombol Tambah Pekerjaan
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Daftar Pekerjaan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: DesignColors.textPrimary,
                  ),
                ),
              ),
              if (!project.isTertutup)
                ElevatedButton.icon(
                  onPressed: () => _showAddWorkDialog(context, project),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _maroon,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'Tambah Pekerjaan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (filteredWorks.isEmpty)
            _emptyWorksState(project)
          else
            Column(
              children: filteredWorks
                  .map((work) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: WorkCardWidget(
                          project: project,
                          work: work,
                          activities: project.daftarKegiatan,
                          isReadOnly: project.isTertutup,
                          onToggleActivity: (activity) {
                            final updated = activity.copyWith(selesai: !activity.selesai);
                            context.read<ProyekViewModel>().perbaruiKegiatanDalamProyek(project.id, activity, updated);
                          },
                          onDeleteActivity: (activity) {
                            _confirmDeleteActivity(context, project.id, activity.id);
                          },
                          onEditActivity: (activity) {
                            _showEditActivityDialog(context, project, work, activity);
                          },
                          onAddActivity: () {
                            _showAddActivityDialog(context, project, work);
                          },
                          onEditWork: () {
                            _showEditWorkDialog(context, project, work);
                          },
                          onDeleteWork: () {
                            _confirmDeleteWork(context, project, work);
                          },
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  void _exportPdf(BuildContext context, Proyek project) async {
    try {
      await PdfExportHelper.printProjectReport(project);
    } catch (e) {
      if (context.mounted) {
        ToastHelper.showError(context, 'Gagal mencetak PDF: $e');
      }
    }
  }

  Future<void> _exportExcel(BuildContext context, Proyek project) async {
    if (ApiConfig.useLocalOnly) {
      if (context.mounted) {
        ToastHelper.showError(context, 'Ekspor Excel hanya tersedia saat server aktif.');
      }
      return;
    }

    final projectId = project.id;
    if (projectId.isEmpty) {
      if (context.mounted) {
        ToastHelper.showError(context, 'ID proyek tidak ditemukan.');
      }
      return;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/api/reports/project/$projectId/excel/');
    try {
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ToastHelper.showError(context, 'Gagal membuka ekspor Excel.');
      }
    } catch (e) {
      if (context.mounted) {
        ToastHelper.showError(context, 'Gagal membuka ekspor Excel: $e');
      }
    }
  }

  void _confirmDeleteProject(BuildContext context, Proyek project) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Proyek'),
        content: const Text(
          'Yakin ingin menghapus proyek ini? Semua pekerjaan dan aktivitas di dalamnya juga akan ikut terhapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _maroon),
            onPressed: () {
              context.read<ProyekViewModel>().hapusProyek(project);
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              ToastHelper.showSuccess(context, 'Proyek berhasil dihapus');
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _toggleProjectClosure(BuildContext context, Proyek project) {
    final isClosed = project.isTertutup;
    final msg = isClosed
        ? 'Buka kembali proyek ini? Status akan kembali menjadi Aktif.'
        : 'Tutup proyek ini? Proyek akan ditandai sebagai Selesai Sepenuhnya.';
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isClosed ? 'Buka Kembali Proyek' : 'Tutup Proyek'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: isClosed ? Colors.green : _maroon),
            onPressed: () {
              if (isClosed) {
                // Open again
                final updated = project.copyWith(isTertutup: false, status: 'Aktif');
                context.read<ProyekViewModel>().perbaruiProyek(project, updated);
                ToastHelper.showSuccess(context, 'Proyek dibuka kembali');
              } else {
                // Close
                context.read<ProyekViewModel>().tutupProyekBerdasarkanId(project.id);
                ToastHelper.showSuccess(context, 'Proyek berhasil ditutup');
              }
              Navigator.pop(dialogContext);
            },
            child: Text(isClosed ? 'Buka Kembali' : 'Tutup', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteWork(BuildContext context, Proyek project, ItemPekerjaan work) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Pekerjaan'),
        content: const Text('Yakin ingin menghapus pekerjaan ini? Aktivitas terkait juga akan ikut dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _maroon),
            onPressed: () {
              context.read<ProyekViewModel>().hapusPekerjaanDalamProyek(project.id, work.id);
              Navigator.pop(dialogContext);
              ToastHelper.showSuccess(context, 'Pekerjaan berhasil dihapus');
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteActivity(BuildContext context, String projectId, String activityId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Aktivitas'),
        content: const Text('Yakin ingin menghapus aktivitas ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _maroon),
            onPressed: () {
              context.read<ProyekViewModel>().hapusKegiatanDalamProyek(projectId, activityId);
              Navigator.pop(dialogContext);
              ToastHelper.showSuccess(context, 'Aktivitas berhasil dihapus');
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddActivityDialog(BuildContext context, Proyek project, ItemPekerjaan work) {
    final namaC = TextEditingController();
    final pelaksanaC = TextEditingController();
    final waktuC = TextEditingController(text: '08:00');

    Future<void> pickTime() async {
      final selected = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 8, minute: 0),
      );
      if (selected != null) {
        waktuC.text = '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: ResponsiveHelper.dialogWidth(context, max: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tambah Aktivitas Baru',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: DesignColors.textPrimary),
                ),
                const SizedBox(height: 20),
                _field('Nama Aktivitas *', namaC),
                _field('Pelaksana *', pelaksanaC),
                _field('Waktu Pelaksanaan * (HH:MM)', waktuC, isDate: true, onTap: pickTime),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (namaC.text.trim().isEmpty) {
                            ToastHelper.showError(context, 'Nama aktivitas wajib diisi');
                            return;
                          }
                          final timeStr = waktuC.text.trim();
                          String dateTimeStr = '';
                          if (work.tanggalMulai.isNotEmpty) {
                            final datePart = work.tanggalMulai.split('T')[0];
                            dateTimeStr = '${datePart}T$timeStr:00';
                          } else {
                            final now = DateTime.now();
                            dateTimeStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T$timeStr:00';
                          }

                          final newAct = ItemKegiatan(
                            id: 'ACT-${const Uuid().v4().replaceAll('-', '')}',
                            idProyek: project.id,
                            idPekerjaan: work.id,
                            judulProyek: project.nama,
                            pekerjaan: work.nama,
                            namaKegiatan: namaC.text.trim(),
                            waktuPelaksanaan: dateTimeStr,
                            pelaksana: pelaksanaC.text.trim(),
                            selesai: false,
                          );

                          context.read<ProyekViewModel>().tambahKegiatanDalamProyek(project.id, newAct);
                          Navigator.pop(ctx);
                          ToastHelper.showSuccess(context, 'Aktivitas berhasil ditambahkan');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _maroon,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditActivityDialog(BuildContext context, Proyek project, ItemPekerjaan work, ItemKegiatan activity) {
    final namaC = TextEditingController(text: activity.namaKegiatan);
    final pelaksanaC = TextEditingController(text: activity.pelaksana);
    final evaluasiC = TextEditingController(text: activity.evaluasi);
    final rencanaC = TextEditingController(text: activity.rencanaTambahan);
    
    String initialTime = '08:00';
    if (activity.waktuPelaksanaan.contains('T')) {
      final parts = activity.waktuPelaksanaan.split('T');
      if (parts.length > 1 && parts[1].length >= 5) {
        initialTime = parts[1].substring(0, 5);
      }
    }
    final waktuC = TextEditingController(text: initialTime);

    Future<void> pickTime() async {
      int initHour = 8;
      int initMin = 0;
      final tParts = waktuC.text.split(':');
      if (tParts.length > 1) {
        initHour = int.tryParse(tParts[0]) ?? 8;
        initMin = int.tryParse(tParts[1]) ?? 0;
      }
      final selected = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: initHour, minute: initMin),
      );
      if (selected != null) {
        waktuC.text = '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: ResponsiveHelper.dialogWidth(context, max: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Aktivitas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: DesignColors.textPrimary),
                ),
                const SizedBox(height: 20),
                _field('Nama Aktivitas *', namaC),
                _field('Pelaksana *', pelaksanaC),
                _field('Waktu Pelaksanaan * (HH:MM)', waktuC, isDate: true, onTap: pickTime),
                _field('Evaluasi', evaluasiC, maxLines: 2),
                _field('Rencana Tindak Lanjut', rencanaC, maxLines: 2),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (namaC.text.trim().isEmpty) {
                            ToastHelper.showError(context, 'Nama aktivitas wajib diisi');
                            return;
                          }
                          final timeStr = waktuC.text.trim();
                          String dateTimeStr = activity.waktuPelaksanaan;
                          if (work.tanggalMulai.isNotEmpty) {
                            final datePart = work.tanggalMulai.split('T')[0];
                            dateTimeStr = '${datePart}T$timeStr:00';
                          }

                          final updated = activity.copyWith(
                            namaKegiatan: namaC.text.trim(),
                            waktuPelaksanaan: dateTimeStr,
                            pelaksana: pelaksanaC.text.trim(),
                            evaluasi: evaluasiC.text.trim(),
                            rencanaTambahan: rencanaC.text.trim(),
                          );

                          context.read<ProyekViewModel>().perbaruiKegiatanDalamProyek(project.id, activity, updated);
                          Navigator.pop(ctx);
                          ToastHelper.showSuccess(context, 'Aktivitas berhasil diperbarui');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _maroon,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProjectDialog(BuildContext context, Proyek project) {
    final nameC = TextEditingController(text: project.nama);
    final descC = TextEditingController(text: project.deskripsi);
    final locC = TextEditingController(text: project.lokasi);
    final teamC = TextEditingController(text: project.tim);
    final supC = TextEditingController(text: project.pengawas);
    final startC = TextEditingController(text: project.tanggalMulai);
    final endC = TextEditingController(text: project.tanggalSelesai);
    String currentStatus = project.status;

    Future<void> pickDate(TextEditingController c) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        c.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SizedBox(
            width: ResponsiveHelper.dialogWidth(context, max: 700),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edit Data Proyek',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _field('Nama Proyek *', nameC),
                  _field('Deskripsi *', descC, maxLines: 3),
                  _field('Tempat *', locC),
                  Wrap(
                    spacing: 16,
                    runSpacing: 0,
                    children: [
                      SizedBox(
                        width: 300,
                        child: _field('Tanggal Mulai *', startC, isDate: true, onTap: () => pickDate(startC)),
                      ),
                      SizedBox(
                        width: 300,
                        child: _field('Tanggal Selesai *', endC, isDate: true, onTap: () => pickDate(endC)),
                      ),
                    ],
                  ),
                  _field('Pelaksana Proyek *', teamC),
                  _field('Supervisor Proyek *', supC),
                  const Text(
                    'Status Proyek *',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: currentStatus.isNotEmpty && ['Aktif', 'Selesai', 'Tertunda'].contains(currentStatus)
                        ? currentStatus
                        : 'Aktif',
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    ),
                    items: ['Aktif', 'Selesai', 'Tertunda']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => currentStatus = val);
                    },
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _maroon,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            if ([nameC, descC, locC, startC, endC, teamC, supC]
                                .any((c) => c.text.trim().isEmpty)) {
                              ToastHelper.showError(context, 'Lengkapi data proyek');
                              return;
                            }
                            final updated = project.copyWith(
                              nama: nameC.text.trim(),
                              deskripsi: descC.text.trim(),
                              lokasi: locC.text.trim(),
                              tanggalMulai: startC.text.trim(),
                              tanggalSelesai: endC.text.trim(),
                              tim: teamC.text.trim(),
                              pengawas: supC.text.trim(),
                              status: currentStatus,
                            );
                            context.read<ProyekViewModel>().perbaruiProyek(project, updated);
                            Navigator.pop(ctx);
                            ToastHelper.showSuccess(context, 'Proyek berhasil diperbarui');
                          },
                          child: const Text(
                            'Simpan Perubahan',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddWorkDialog(BuildContext context, Proyek project) {
    final nameC = TextEditingController();
    final descC = TextEditingController();
    final locC = TextEditingController();
    final startC = TextEditingController();
    final endC = TextEditingController();
    final execC = TextEditingController();
    final supC = TextEditingController();

    Future<void> pickDate(TextEditingController c) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        c.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: ResponsiveHelper.dialogWidth(context, max: 620),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tambah Pekerjaan Baru',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _field('Nama Pekerjaan *', nameC),
                _field('Deskripsi *', descC, maxLines: 3),
                _field('Lokasi *', locC),
                Row(
                  children: [
                    Expanded(child: _field('Tanggal Mulai *', startC, isDate: true, onTap: () => pickDate(startC))),
                    const SizedBox(width: 12),
                    Expanded(child: _field('Tanggal Selesai *', endC, isDate: true, onTap: () => pickDate(endC))),
                  ],
                ),
                _field('Pelaksana *', execC),
                _field('Supervisor *', supC),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameC.text.trim().isEmpty ||
                              startC.text.trim().isEmpty ||
                              endC.text.trim().isEmpty) {
                            ToastHelper.showError(context, 'Nama, tanggal mulai, dan selesai wajib diisi');
                            return;
                          }
                          final newWork = ItemPekerjaan(
                            nama: nameC.text.trim(),
                            deskripsi: descC.text.trim(),
                            lokasi: locC.text.trim(),
                            tanggalMulai: startC.text.trim(),
                            tanggalSelesai: endC.text.trim(),
                            pelaksana: execC.text.trim(),
                            pengawas: supC.text.trim(),
                          );
                          context.read<ProyekViewModel>().tambahPekerjaanDalamProyek(project.id, newWork);
                          Navigator.pop(ctx);
                          ToastHelper.showSuccess(context, 'Pekerjaan berhasil ditambahkan');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _maroon,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditWorkDialog(BuildContext context, Proyek project, ItemPekerjaan work) {
    final nameC = TextEditingController(text: work.nama);
    final descC = TextEditingController(text: work.deskripsi);
    final locC = TextEditingController(text: work.lokasi);
    final startC = TextEditingController(text: work.tanggalMulai);
    final endC = TextEditingController(text: work.tanggalSelesai);
    final execC = TextEditingController(text: work.pelaksana);
    final supC = TextEditingController(text: work.pengawas);

    Future<void> pickDate(TextEditingController c) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        c.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: ResponsiveHelper.dialogWidth(context, max: 620),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Pekerjaan',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _field('Nama Pekerjaan *', nameC),
                _field('Deskripsi *', descC, maxLines: 3),
                _field('Lokasi *', locC),
                Row(
                  children: [
                    Expanded(child: _field('Tanggal Mulai *', startC, isDate: true, onTap: () => pickDate(startC))),
                    const SizedBox(width: 12),
                    Expanded(child: _field('Tanggal Selesai *', endC, isDate: true, onTap: () => pickDate(endC))),
                  ],
                ),
                _field('Pelaksana *', execC),
                _field('Supervisor *', supC),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameC.text.trim().isEmpty) {
                            ToastHelper.showError(context, 'Nama pekerjaan wajib diisi');
                            return;
                          }
                          final updated = work.copyWith(
                            nama: nameC.text.trim(),
                            deskripsi: descC.text.trim(),
                            lokasi: locC.text.trim(),
                            tanggalMulai: startC.text.trim(),
                            tanggalSelesai: endC.text.trim(),
                            pelaksana: execC.text.trim(),
                            pengawas: supC.text.trim(),
                          );
                          context.read<ProyekViewModel>().perbaruiPekerjaanDalamProyek(project.id, work, updated);
                          Navigator.pop(ctx);
                          ToastHelper.showSuccess(context, 'Pekerjaan berhasil diperbarui');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _maroon,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          'Simpan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, String> _projectData(Proyek project) {
    return {
      'id': project.id,
      'title': project.nama,
      'desc': project.deskripsi,
      'location': project.lokasi,
      'date': project.tanggal,
      'startDate': project.tanggalMulai,
      'endDate': project.tanggalSelesai,
      'team': project.tim,
      'supervisor': project.pengawas,
      'status': project.isTertutup ? 'SELESAI' : project.status.toUpperCase(),
    };
  }

  String _formatDate(String value) {
    if (value.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(value);
      return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return value;
    }
  }

  String _statusLabel(Proyek project) {
    if (project.isTertutup || project.status.toLowerCase() == 'selesai') {
      return 'SELESAI';
    }
    if (project.status.toLowerCase() == 'tertunda') {
      return 'TERTUNDA';
    }
    return 'AKTIF';
  }

  Widget _statusChip(String label, {double fontSize = 12}) {
    Color bg;
    Color fg;
    switch (label) {
      case 'SELESAI':
        bg = DesignColors.statusDoneBg;
        fg = DesignColors.statusDone;
        break;
      case 'TERTUNDA':
        bg = DesignColors.statusPendingBg;
        fg = DesignColors.statusPending;
        break;
      default:
        bg = DesignColors.statusActiveBg;
        fg = DesignColors.statusActive;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: fontSize <= 10 ? 6 : 10, vertical: fontSize <= 10 ? 3 : 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }

  // Chip ikon yang stretch (dipakai di baris 1 portrait grid)
  Widget _smallChipExpanded(IconData icon, Color iconColor, Color bg, VoidCallback onTap, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 34,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: iconColor.withOpacity(0.2)),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
      ),
    );
  }

  // Chip label dengan lebar tetap agar baris 2 sejajar dengan baris 1
  Widget _smallChipLabelFixed({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 34,
        width: double.infinity,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: iconColor.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: iconColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String? label,
    required Color iconColor,
    required Color background,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: label == null ? 10 : 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: iconColor.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: iconColor),
              if (label != null) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: iconColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: DesignColors.bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _cardBorder),
        ),
        child: const Icon(
          Icons.arrow_back,
          size: 20,
          color: _slate,
        ),
      ),
    );
  }

  Widget _miniProgress(double progress, int doneActivities, int totalActivities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'PROGRESS AKTIVITAS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: DesignColors.slate,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              '$doneActivities/$totalActivities',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _maroon,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: DesignColors.borderLight,
            color: _maroon,
          ),
        ),
      ],
    );
  }

  Widget _dateStat({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(label),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: DesignColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _personRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: DesignColors.bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _cardBorder),
          ),
          child: Icon(icon, size: 18, color: _maroon),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: DesignColors.slate,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '-' : value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: DesignColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: DesignColors.slate,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _emptyWorksState(Proyek project) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      decoration: BoxDecoration(
        color: DesignColors.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(Icons.work_outline, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Belum ada pekerjaan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            project.isTertutup
                ? 'Proyek ini sudah ditutup, jadi tidak bisa menambah pekerjaan baru.'
                : 'Klik tombol "Tambah Pekerjaan" untuk mulai mengisi pekerjaan proyek.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool isDate = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: DesignColors.mutedDark,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            readOnly: isDate,
            onTap: onTap,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: DesignColors.borderLight),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class WorkCardWidget extends StatefulWidget {
  final Proyek project;
  final ItemPekerjaan work;
  final List<ItemKegiatan> activities;
  final bool isReadOnly;
  final Function(ItemKegiatan) onToggleActivity;
  final Function(ItemKegiatan) onDeleteActivity;
  final Function(ItemKegiatan) onEditActivity;
  final VoidCallback onAddActivity;
  final VoidCallback onEditWork;
  final VoidCallback onDeleteWork;

  const WorkCardWidget({
    super.key,
    required this.project,
    required this.work,
    required this.activities,
    required this.isReadOnly,
    required this.onToggleActivity,
    required this.onDeleteActivity,
    required this.onEditActivity,
    required this.onAddActivity,
    required this.onEditWork,
    required this.onDeleteWork,
  });

  @override
  State<WorkCardWidget> createState() => _WorkCardWidgetState();
}

class _WorkCardWidgetState extends State<WorkCardWidget> {

  Widget _buildEvaluasiWidget(String evaluasi) {
    try {
      final json = jsonDecode(evaluasi);
      if (json is Map<String, dynamic> && json.containsKey('links')) {
        final links = json['links'] as List;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evaluasi:',
              style: TextStyle(fontSize: 11, color: Colors.blue, fontStyle: FontStyle.italic),
            ),
            ...links.map((link) {
              final title = link['title'] ?? 'Link';
              String url = link['url'] ?? '';
              
              // Ganti 127.0.0.1 atau localhost dengan IP laptop agar bisa dibuka dari HP
              url = url.replaceAll('127.0.0.1', ApiConfig.laptopIp);
              url = url.replaceAll('localhost', ApiConfig.laptopIp);
              
              return InkWell(
                onTap: () async {
                  if (url.isNotEmpty) {
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '- $title',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      }
    } catch (e) {
      // Not a valid JSON or not the expected format, fallback to raw text
    }

    return Text(
      'Evaluasi: $evaluasi',
      style: const TextStyle(fontSize: 11, color: Colors.blue, fontStyle: FontStyle.italic),
    );
  }

  String _formatTime(String dateStr) {
    if (dateStr.isEmpty) return '-';
    try {
      if (dateStr.contains('T')) {
        final timePart = dateStr.split('T')[1];
        if (timePart.length >= 5) {
          return timePart.substring(0, 5);
        }
      }
      return dateStr;
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final workActivities = widget.activities
        .where((a) => a.idPekerjaan == widget.work.id || a.pekerjaan == widget.work.nama)
        .toList();

    final totalCount = workActivities.length;
    final doneCount = workActivities.where((a) => a.selesai).length;

    // Status badge untuk pekerjaan
    String statusText = 'BELUM';
    Color statusBg = DesignColors.statusPendingBg;
    Color statusFg = DesignColors.statusPending;

    if (totalCount > 0) {
      if (doneCount == totalCount) {
        statusText = 'SELESAI';
        statusBg = DesignColors.statusDoneBg;
        statusFg = DesignColors.statusDone;
      } else if (doneCount > 0) {
        statusText = 'PROSES';
        statusBg = DesignColors.statusActiveBg;
        statusFg = DesignColors.statusActive;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignColors.borderAlt, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Pekerjaan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFAFAFA), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.work.nama,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: DesignColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: statusFg,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!widget.isReadOnly) ...[
                      IconButton(
                        onPressed: widget.onEditWork,
                        icon: const Icon(Icons.edit_outlined, size: 18, color: DesignColors.textSecondary),
                        tooltip: 'Edit pekerjaan',
                      ),
                      IconButton(
                        onPressed: widget.onDeleteWork,
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                        tooltip: 'Hapus pekerjaan',
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    if (widget.work.lokasi.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            widget.work.lokasi,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_month_outlined, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatDate(widget.work.tanggalMulai)} – ${_formatDate(widget.work.tanggalSelesai)}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Section Header: AKTIVITAS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                top: BorderSide(color: Colors.grey.shade100),
                bottom: BorderSide(color: Colors.grey.shade100),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list, size: 14, color: DesignColors.primary),
                const SizedBox(width: 6),
                const Text(
                  'AKTIVITAS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: DesignColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Aktivitas Content
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: _buildActivitiesContent(workActivities),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesContent(List<ItemKegiatan> workActivities) {
    if (workActivities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'Belum ada aktivitas',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(workActivities.length, (index) {
        final act = workActivities[index];
        final isLast = index == workActivities.length - 1;
        return _buildActivityItem(act, isLast: isLast);
      }),
    );
  }

  Widget _buildActivityItem(ItemKegiatan act, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            act.namaKegiatan,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: act.selesai ? Colors.grey : DesignColors.textPrimary,
              decoration: act.selesai ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${_formatTime(act.waktuPelaksanaan)} · ${act.pelaksana.isEmpty ? "Belum ditentukan" : act.pelaksana}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          if (act.evaluasi.isNotEmpty) ...[
            const SizedBox(height: 4),
            _buildEvaluasiWidget(act.evaluasi),
          ],
          if (act.rencanaTambahan.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Rencana: ${act.rencanaTambahan}',
              style: TextStyle(fontSize: 11, color: Colors.orange.shade800, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String value) {
    if (value.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(value);
      return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return value;
    }
  }
}
