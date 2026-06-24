import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

import '../models/activity_model.dart';
import '../models/job.dart';
import '../utils/responsive_helper.dart';
import '../viewmodel/activity_view_model.dart';
import '../services/api_config.dart';
import '../widgets/app_header.dart';
import '../utils/design_tokens.dart';

class AktivitasPantauView extends StatelessWidget {
  const AktivitasPantauView({
    super.key,
    required this.pekerjaan,
    required this.projectData,
    this.isReadOnly = false,
  });

  final Pekerjaan pekerjaan;
  final Map<String, String> projectData;
  final bool isReadOnly;

  static const Color maroonColor = DesignColors.primary;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<KegiatanViewModel>();
    final bool mobile = ResponsiveHelper.isMobile(context);
    final bool landscape = ResponsiveHelper.isMobileLandscape(context);
    final EdgeInsets hPad = ResponsiveHelper.pagePadding(context);

    return Scaffold(
      backgroundColor: DesignColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              // ── Header ─────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  mobile && !landscape ? 12 : 16,
                  mobile && !landscape ? 10 : 12,
                  mobile && !landscape ? 12 : 16,
                  0,
                ),
                child: const AppHeader(),
              ),
              const SizedBox(height: 10),

              // ── Top bar ─────────────────────────────────────────────
              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: mobile && !landscape ? 12 : 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: DesignColors.bg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(Icons.arrow_back, size: 18,
                            color: Color(0xFF475569)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pantau Realisasi',
                            style: TextStyle(
                              fontSize: mobile && !landscape ? 15 : 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            pekerjaan.nama,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF94A3B8)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Search – hanya di landscape/desktop di topbar
                    if (!mobile || landscape)
                      SizedBox(
                        width: landscape ? 160 : 220,
                        height: 36,
                        child: _SearchField(onChanged: vm.aturPencarian),
                      ),
                  ],
                ),
              ),

              // Search di portrait HP
              if (mobile && !landscape)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: _SearchField(onChanged: vm.aturPencarian),
                ),

              const SizedBox(height: 12),

              // ── Konten aktivitas ────────────────────────────────────
              Container(
                width: double.infinity,
                color: DesignColors.bg,
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: ResponsiveHelper.constrainedContentWidth(context),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      hPad.left, 12, hPad.right, 40,
                    ),
                    child: vm.daftarKegiatanTerfilter.isEmpty
                        ? _EmptyState(kataKunciCari: vm.kataKunciCari)
                        : Column(
                            children: vm.daftarKegiatanTerfilter
                                .map((activity) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: _ActivityMonitorCard(
                                        activity: activity,
                                        pekerjaan: pekerjaan,
                                        onEvaluate: () =>
                                            _showEvaluationDialog(
                                                context, vm, activity),
                                        isReadOnly: isReadOnly,
                                      ),
                                    ))
                                .toList(),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEvaluationDialog(
    BuildContext context,
    KegiatanViewModel vm,
    Kegiatan activity,
  ) async {
    final evaluationController = TextEditingController(
      text: activity.evaluation,
    );
    final followUpController = TextEditingController(
      text: activity.followUpPlan,
    );
    String status = activity.status;
    String? localFilePath = activity.localFilePath;
    String? fileName = activity.fileName;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: ResponsiveHelper.dialogWidth(context, max: 560),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Isi Evaluasi Aktivitas',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activity.title,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const _InputLabel('Status Realisasi'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: status,
                        decoration: _dialogDecoration(),
                        items: const [
                          DropdownMenuItem(
                            value: 'pending',
                            child: Text('Belum selesai'),
                          ),
                          DropdownMenuItem(
                            value: 'in_progress',
                            child: Text('Sedang berjalan'),
                          ),
                          DropdownMenuItem(
                            value: 'done',
                            child: Text('Selesai'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => status = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      const _InputLabel('Evaluasi Hasil'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: evaluationController,
                        maxLines: 4,
                        decoration: _dialogDecoration().copyWith(
                          hintText: 'Tuliskan hasil evaluasi aktivitas ini.',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _InputLabel('Rencana Tindak Lanjut'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: followUpController,
                        maxLines: 4,
                        decoration: _dialogDecoration().copyWith(
                          hintText: 'Tuliskan rencana tindak lanjut.',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _InputLabel('Lampiran Bukti (Opsional)'),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles();
                          if (result != null) {
                            setState(() {
                              localFilePath = result.files.single.path;
                              fileName = result.files.single.name;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD5DBE5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_file, color: maroonColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  fileName ?? 'Pilih file bukti...',
                                  style: TextStyle(
                                    color: fileName != null
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFD5DBE5),
                                ),
                              ),
                              child: const Text('Batal'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final updated = activity.copyWith(
                                  status: status,
                                  evaluation: evaluationController.text.trim(),
                                  followUpPlan: followUpController.text.trim(),
                                  localFilePath: localFilePath,
                                  fileName: fileName,
                                );
                                await vm.perbaruiKegiatan(activity, updated);
                                if (!context.mounted) {
                                  return;
                                }
                                Navigator.pop(dialogContext);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: maroonColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Simpan Evaluasi'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _dialogDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD5DBE5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD5DBE5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: maroonColor),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Cari aktivitas...',
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AktivitasPantauView.maroonColor),
        ),
      ),
    );
  }
}

class _ActivityMonitorCard extends StatelessWidget {
  const _ActivityMonitorCard({
    required this.activity,
    required this.pekerjaan,
    required this.onEvaluate,
    required this.isReadOnly,
  });

  final Kegiatan activity;
  final Pekerjaan pekerjaan;
  final VoidCallback onEvaluate;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    // Landscape HP + tablet + desktop → 2 kolom
    final bool useColumns = !ResponsiveHelper.isMobile(context) ||
        ResponsiveHelper.isMobileLandscape(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    activity.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _StatusChip(status: activity.status),
              ],
            ),
          ),
          const Divider(height: 1, color: DesignColors.surfaceSoft),
          Padding(
            padding: const EdgeInsets.all(20),
            child: !useColumns
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PlanningSection(
                        pekerjaan: pekerjaan,
                        activity: activity,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(color: DesignColors.surfaceSoft),
                      ),
                      _EvaluationSection(
                        activity: activity,
                        onEvaluate: onEvaluate,
                        isReadOnly: isReadOnly,
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _PlanningSection(
                          pekerjaan: pekerjaan,
                          activity: activity,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 200,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        color: DesignColors.surfaceSoft,
                      ),
                      Expanded(
                        child: _EvaluationSection(
                          activity: activity,
                          onEvaluate: onEvaluate,
                          isReadOnly: isReadOnly,
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

class _PlanningSection extends StatelessWidget {
  const _PlanningSection({required this.pekerjaan, required this.activity});

  final Pekerjaan pekerjaan;
  final Kegiatan activity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF94A3B8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'PERENCANAAN',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _InfoItem(
          icon: Icons.calendar_today_outlined,
          label: 'Waktu',
          value: activity.date.isEmpty ? '-' : activity.date,
        ),
        const SizedBox(height: 16),
        _InfoItem(
          icon: Icons.person_outline,
          label: 'Pelaksana',
          value: activity.desc.isEmpty ? pekerjaan.pelaksana : activity.desc,
        ),
        const SizedBox(height: 16),
        _buildEvidenceSection(context),
      ],
    );
  }

  Widget _buildEvidenceSection(BuildContext context) {
    final hasRemote =
        activity.documentUrl != null && activity.documentUrl!.isNotEmpty;
    final hasLocal = activity.fileName != null && activity.fileName!.isNotEmpty;

    if (!hasRemote && !hasLocal) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasRemote) ...[
            _evidenceTile(
              label: 'Dokumen Server',
              fileName: 'Lihat File',
              icon: Icons.cloud_download_outlined,
              color: const Color(0xFF2563EB),
              onTap: () async {
                final documentUrl = activity.documentUrl!;
                final uri = Uri.parse(
                  documentUrl.startsWith('http')
                      ? documentUrl
                      : '${ApiConfig.baseUrl}$documentUrl',
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
            if (hasLocal)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(height: 1),
              ),
          ],
          if (hasLocal) ...[
            _evidenceTile(
              label: 'Bukti Lokal',
              fileName: activity.fileName!,
              icon: Icons.insert_drive_file_outlined,
              color: const Color(0xFF64748B),
              onTap: null, // Read-only view
            ),
          ],
        ],
      ),
    );
  }

  Widget _evidenceTile({
    required String label,
    required String fileName,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  fileName,
                  style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: FontWeight.bold,
                    decoration: onTap != null ? TextDecoration.underline : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onTap != null) Icon(Icons.chevron_right, size: 16, color: color),
        ],
      ),
    );
  }
}

class _EvaluationSection extends StatelessWidget {
  const _EvaluationSection({
    required this.activity,
    required this.onEvaluate,
    required this.isReadOnly,
  });

  final Kegiatan activity;
  final VoidCallback onEvaluate;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text(
                'REALISASI & EVALUASI',
                style: TextStyle(
                  fontSize: 13,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: isReadOnly ? null : onEvaluate,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Isi Evaluasi'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                backgroundColor: const Color(0xFFFEF2F2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Evaluasi Hasil:',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        _ContentPanel(
          text: activity.evaluation.isEmpty
              ? 'Belum ada evaluasi.'
              : activity.evaluation,
          isPlaceholder: activity.evaluation.isEmpty,
        ),
        const SizedBox(height: 16),
        const Text(
          'Rencana Tindak Lanjut:',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        _ContentPanel(
          text: activity.followUpPlan.isEmpty
              ? 'Belum ada rencana tindak lanjut.'
              : activity.followUpPlan,
          isPlaceholder: activity.followUpPlan.isEmpty,
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: DesignColors.surfaceSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF475569), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContentPanel extends StatelessWidget {
  const _ContentPanel({required this.text, required this.isPlaceholder});

  final String text;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: DesignColors.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EAF1)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isPlaceholder
              ? const Color(0xFF94A3B8)
              : const Color(0xFF334155),
          fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
          height: 1.5,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      'done' => 'Selesai',
      'in_progress' => 'Sedang berjalan',
      _ => 'Belum selesai',
    };
    final background = switch (status) {
      'done' => const Color(0xFFDCFCE7),
      'in_progress' => const Color(0xFFDBEAFE),
      _ => DesignColors.surfaceSoft,
    };
    final foreground = switch (status) {
      'done' => const Color(0xFF166534),
      'in_progress' => const Color(0xFF1D4ED8),
      _ => const Color(0xFF475569),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: foreground, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.kataKunciCari});

  final String kataKunciCari;

  @override
  Widget build(BuildContext context) {
    final hasSearch = kataKunciCari.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE3EC)),
      ),
      child: Column(
        children: [
          Icon(
            hasSearch ? Icons.search_off_outlined : Icons.assignment_outlined,
            size: 64,
            color: const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch
                ? 'Tidak ada aktivitas yang cocok dengan pencarian.'
                : 'Belum ada aktivitas untuk dipantau.',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            hasSearch
                ? 'Coba kata kunci lain untuk melihat aktivitas yang tersedia.'
                : 'Tambahkan aktivitas terlebih dahulu agar halaman pantau berisi data.',
            style: const TextStyle(color: Color(0xFF64748B), height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  const _InputLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        color: Color(0xFF334155),
      ),
    );
  }
}
