import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../models/activity_model.dart';
import '../models/job.dart';
import '../utils/responsive_helper.dart';
import '../view/aktivitas_pantau_view.dart';
import '../viewmodel/activity_view_model.dart';
import '../viewmodel/upload_file_viewmodel.dart';
import '../viewmodel/job_view_model.dart';
import '../widgets/app_header.dart';
import '../uploaded_file_type.dart';
import '../file_storage_helper.dart';
import '../utils/design_tokens.dart';

class BikinAktivitas extends StatelessWidget {
  final Pekerjaan pekerjaan;
  final Map<String, String> projectData;
  final bool isReadOnly;

  const BikinAktivitas({
    super.key,
    required this.pekerjaan,
    required this.projectData,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    // Ambil PekerjaanViewModel dari context
    final pekerjaanVm = Provider.of<PekerjaanViewModel>(context, listen: false);

    return ChangeNotifierProvider(
      create: (_) =>
          KegiatanViewModel(
            onHitungBerubah: (idPekerjaan, total, selesai) {
              pekerjaanVm.perbaruiJumlahAktivitas(idPekerjaan, total, selesai);
            },
          )..init(
            pekerjaan.nama,
            projectData['title'] ?? '',
            idPekerjaan: pekerjaan.id,
            idProyek: projectData['id'] ?? '',
          ),
      child: _BikinAktivitasView(
        pekerjaan: pekerjaan,
        projectData: projectData,
        isReadOnly: isReadOnly,
      ),
    );
  }
}

class _BikinAktivitasView extends StatelessWidget {
  final Pekerjaan pekerjaan;
  final Map<String, String> projectData;
  final bool isReadOnly;

  const _BikinAktivitasView({
    required this.pekerjaan,
    required this.projectData,
    required this.isReadOnly,
  });

  static const Color maroonColor = DesignColors.primary;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<KegiatanViewModel>();
    final bool mobile = ResponsiveHelper.isMobile(context);
    final bool landscape = ResponsiveHelper.isMobileLandscape(context);
    // Landscape HP pakai layout 2-kolom agar space landscape dimanfaatkan
    final bool useSideLayout = !mobile || landscape;
    final EdgeInsets pad = ResponsiveHelper.pagePadding(context);

    return Scaffold(
      backgroundColor: DesignColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──────────────────────────────────────────────
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

              // ── Top bar: kembali + nama pekerjaan ───────────────────
              _buildTopBar(context, mobile, landscape, vm),
              const SizedBox(height: 10),

              // ── Body: info kiri + aktivitas kanan ───────────────────
              Padding(
                padding: pad,
                child: useSideLayout
                    ? _buildSideLayout(context, vm, landscape)
                    : _buildStackLayout(context, vm),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────

  Widget _buildTopBar(
      BuildContext context, bool mobile, bool landscape, KegiatanViewModel vm) {
    final hPad = mobile && !landscape ? 12.0 : 16.0;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kembali
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
              child: const Icon(Icons.arrow_back, size: 18, color: Color(0xFF475569)),
            ),
          ),
          const SizedBox(width: 12),
          // Nama pekerjaan + project
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pekerjaan.nama,
                  style: TextStyle(
                    fontSize: mobile && !landscape ? 15 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  projectData['title'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Tombol aksi
          _buildTopActions(context, vm, mobile, landscape),
        ],
      ),
    );
  }

  Widget _buildTopActions(
      BuildContext context, KegiatanViewModel vm, bool mobile, bool landscape) {
    final iconOnly = mobile && landscape;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pantau Realisasi
        Tooltip(
          message: 'Pantau Realisasi',
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: vm,
                  child: AktivitasPantauView(
                    pekerjaan: pekerjaan,
                    projectData: projectData,
                    isReadOnly: isReadOnly,
                  ),
                ),
              ),
            ),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: iconOnly ? 7 : 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE09090)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bar_chart, size: 17, color: maroonColor),
                  if (!iconOnly) ...[
                    const SizedBox(width: 4),
                    const Text('Pantau',
                        style: TextStyle(
                            fontSize: 12,
                            color: maroonColor,
                            fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Tambah Aktivitas
        if (!isReadOnly)
          ElevatedButton.icon(
            onPressed: () => _showRequirementDialog(context, vm),
            icon: const Icon(Icons.add, size: 16),
            label: Text(
              iconOnly ? 'Tambah' : 'Tambah Aktivitas',
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: maroonColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                  horizontal: iconOnly ? 10 : 14, vertical: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
      ],
    );
  }

  // ── Layout side-by-side (desktop / landscape HP) ─────────────────────

  Widget _buildSideLayout(
      BuildContext context, KegiatanViewModel vm, bool landscape) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel kiri: info pekerjaan
        SizedBox(
          width: landscape ? 200 : 260,
          child: _buildInfoPanel(context, landscape),
        ),
        SizedBox(width: landscape ? 10 : 16),
        // Panel kanan: aktivitas
        Expanded(child: _buildAktivitasSection(context, vm, landscape: landscape)),
      ],
    );
  }

  // ── Layout stacked (portrait HP) ─────────────────────────────────────

  Widget _buildStackLayout(BuildContext context, KegiatanViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoPanel(context, false),
        const SizedBox(height: 14),
        _buildAktivitasSection(context, vm),
      ],
    );
  }

  // ── Info Panel pekerjaan ─────────────────────────────────────────────

  Widget _buildInfoPanel(BuildContext context, bool landscape) {
    return Container(
      padding: EdgeInsets.all(landscape ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul section
          Row(
            children: const [
              Icon(Icons.work_outline, size: 15, color: maroonColor),
              SizedBox(width: 6),
              Text('Detail Pekerjaan',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: DesignColors.surfaceSoft),
          const SizedBox(height: 12),

          // Deskripsi
          if (pekerjaan.deskripsi.isNotEmpty) ...[
            _panelLabel('DESKRIPSI'),
            const SizedBox(height: 3),
            Text(pekerjaan.deskripsi,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF334155))),
            SizedBox(height: landscape ? 10 : 12),
          ],

          // Tanggal
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _panelLabel('MULAI'),
                    const SizedBox(height: 3),
                    Text(pekerjaan.tanggalMulai,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A))),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _panelLabel('SELESAI'),
                    const SizedBox(height: 3),
                    Text(pekerjaan.tanggalSelesai,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A))),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: landscape ? 10 : 12),
          _panelInfoRow(Icons.people_outline, 'PELAKSANA', pekerjaan.pelaksana),
          SizedBox(height: landscape ? 8 : 10),
          _panelInfoRow(Icons.person_outline, 'SUPERVISOR', pekerjaan.pengawas),

          // Lokasi
          if (pekerjaan.lokasi.isNotEmpty) ...[
            SizedBox(height: landscape ? 8 : 10),
            _panelInfoRow(Icons.location_on_outlined, 'LOKASI', pekerjaan.lokasi),
          ],

          // Readonly notice
          if (isReadOnly) ...[
            SizedBox(height: landscape ? 10 : 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.lock_outline, size: 13, color: Color(0xFF92400E)),
                  SizedBox(width: 5),
                  Expanded(
                    child: Text('Mode baca saja',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF92400E))),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _panelLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.5),
      );

  Widget _panelInfoRow(IconData icon, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: maroonColor),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _panelLabel(label),
                const SizedBox(height: 2),
                Text(value.isEmpty ? '-' : value,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      );

  // ── Aktivitas Section ────────────────────────────────────────────────

  Widget _buildAktivitasSection(BuildContext context, KegiatanViewModel vm,
      {bool landscape = false}) {
    final bool portrait =
        ResponsiveHelper.isMobile(context) && !landscape;

    return Container(
      padding: EdgeInsets.all(landscape ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header baris ──
          _buildAktivitasHeader(context, vm, portrait, landscape),
          const SizedBox(height: 16),

          // ── List atau empty state ──
          if (vm.daftarKegiatanTerfilter.isEmpty)
            _emptyState()
          else
            _buildGrid(context, vm, landscape),
        ],
      ),
    );
  }

  Widget _buildAktivitasHeader(
      BuildContext context, KegiatanViewModel vm, bool portrait, bool landscape) {
    final count = vm.daftarKegiatanTerfilter.length;

    if (portrait) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Daftar Aktivitas',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A))),
              const SizedBox(width: 10),
              _countBadge(count),
            ],
          ),
          const SizedBox(height: 12),
          _searchField(vm),
        ],
      );
    }

    // Landscape / desktop: satu baris
    return Row(
      children: [
        Text('Daftar Aktivitas',
            style: TextStyle(
                fontSize: landscape ? 16 : 19,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A))),
        const SizedBox(width: 10),
        _countBadge(count),
        const Spacer(),
        SizedBox(
          width: landscape ? 160 : 230,
          height: 38,
          child: _searchField(vm),
        ),
      ],
    );
  }

  Widget _countBadge(int count) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: DesignColors.surfaceSoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('$count Aktivitas',
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569))),
      );

  Widget _searchField(KegiatanViewModel vm) => TextField(
        onChanged: vm.aturPencarian,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Cari aktivitas...',
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: maroonColor, width: 1.5),
          ),
        ),
      );

  Widget _emptyState() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 44),
        decoration: BoxDecoration(
          color: DesignColors.bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.assignment_outlined, size: 52, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text('Belum ada aktivitas',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500)),
            const SizedBox(height: 4),
            Text('Mulai dengan membuat aktivitas baru',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
          ],
        ),
      );

  Widget _buildGrid(
      BuildContext context, KegiatanViewModel vm, bool landscape) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols = landscape ? 1 : (w >= 960 ? 3 : (w >= 580 ? 2 : 1));
        final spacing = 12.0;
        final cardWidth = (w - (cols - 1) * spacing) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: vm.daftarKegiatanTerfilter.map((activity) {
            return SizedBox(
              width: cardWidth,
              child: _activityCard(context, activity, vm),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _activityCard(
    BuildContext context,
    Kegiatan activity,
    KegiatanViewModel vm,
  ) {
    final isDone = activity.status == 'done';
    final isInProgress = activity.status == 'in_progress';
    Color chipBg;
    Color chipFg;
    String chipLabel;
    if (isDone) {
      chipBg = const Color(0xFFDCFCE7);
      chipFg = const Color(0xFF166534);
      chipLabel = 'SELESAI';
    } else if (isInProgress) {
      chipBg = const Color(0xFFFEF3C7);
      chipFg = const Color(0xFF92400E);
      chipLabel = 'PROSES';
    } else {
      chipBg = DesignColors.surfaceSoft;
      chipFg = const Color(0xFF475569);
      chipLabel = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: isDone ? const Color(0x08166534) : const Color(0x06000000),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status + Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status Chip
              InkWell(
                onTap: isReadOnly
                    ? null
                    : () {
                        String nextStatus;
                        if (activity.status == 'pending') {
                          nextStatus = 'in_progress';
                        } else if (activity.status == 'in_progress') {
                          nextStatus = 'done';
                        } else {
                          nextStatus = 'pending';
                        }
                        vm.perbaruiStatus(activity.id, nextStatus);
                      },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    chipLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: chipFg,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              // Action Icons
              if (!isReadOnly)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _cardIconButton(
                      icon: Icons.edit_outlined,
                      onTap: () => _showActivityDialog(
                        context,
                        vm,
                        existingActivity: activity,
                      ),
                    ),
                    const SizedBox(width: 4),
                    _cardIconButton(
                      icon: Icons.attach_file,
                      onTap: () => _showUploadDialog(context, vm, activity),
                    ),
                    const SizedBox(width: 4),
                    _cardIconButton(
                      icon: Icons.delete_outline,
                      color: Colors.red[400],
                      onTap: () => _confirmDelete(context, vm, activity),
                    ),
                  ],
                ),
            ],
          ),
          
          const SizedBox(height: 14),
          
          // Title
          Text(
            activity.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          if (activity.desc.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              activity.desc,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          const SizedBox(height: 12),
          
          // File preview if exists
          if (activity.fileName != null && activity.fileName!.isNotEmpty) ...[
            _ActivityPreview(activity: activity),
            const SizedBox(height: 12),
          ],
          
          // Footer: Date + Evidence
          const Divider(height: 1, color: DesignColors.borderMuted),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 13,
                color: const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 5),
              Text(
                activity.date,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              _buildEvidenceIndicator(activity, vm),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardIconButton({
    required IconData icon,
    VoidCallback? onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: DesignColors.bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color ?? const Color(0xFF64748B)),
      ),
    );
  }

  Widget _buildEvidenceIndicator(Kegiatan activity, KegiatanViewModel vm) {
    if (activity.fileName != null && activity.fileName!.isNotEmpty) {
      final type = detectUploadedFileType(activity.fileName!);
      IconData icon;
      Color color;
      if (type == UploadedFileType.image) {
        icon = Icons.image_outlined;
        color = Colors.blue;
      } else if (type == UploadedFileType.pdf) {
        icon = Icons.picture_as_pdf_outlined;
        color = Colors.red;
      } else if (type == UploadedFileType.audio) {
        icon = Icons.audiotrack_outlined;
        color = Colors.orange;
      } else if (type == UploadedFileType.video) {
        icon = Icons.videocam_outlined;
        color = Colors.purple;
      } else {
        icon = Icons.insert_drive_file_outlined;
        color = Colors.grey;
      }
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100),
            child: Text(
              activity.fileName!,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else if (vm.ambilFoto(activity.id).isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.photo_library_outlined,
            size: 14,
            color: Colors.blue,
          ),
          const SizedBox(width: 4),
          Text(
            '${vm.ambilFoto(activity.id).length} foto',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
    return const Text(
      'No evidence',
      style: TextStyle(
        fontSize: 11,
        color: Color(0xFFCBD5E1),
        fontStyle: FontStyle.italic,
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    KegiatanViewModel vm,
    Kegiatan activity,
  ) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Aktivitas'),
        content: const Text('Apakah Anda yakin ingin menghapus aktivitas ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              vm.hapusKegiatan(activity);
              Navigator.pop(dialogCtx);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog(
    BuildContext context,
    KegiatanViewModel vm,
    Kegiatan activity,
  ) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider(
        create: (_) => UploadFileViewModel()..muatFileTersimpan(activity.id),
        child: UploadDialog(
          activity: activity,
          activityVm: vm,
          isReadOnly: isReadOnly,
        ),
      ),
    );
  }

  void _showRequirementDialog(BuildContext context, KegiatanViewModel vm) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: ResponsiveHelper.dialogWidth(context, max: 440),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF2563EB),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Syarat Aktivitas',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sebelum menambah aktivitas, pastikan Anda telah menyiapkan informasi berikut:',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ..._syaratItems(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _showActivityDialog(context, vm);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: maroonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Mengerti & Lanjut'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _syaratItems() {
    final items = [
      {
        'title': 'Nama Aktivitas',
        'desc': 'Deskripsi spesifik tentang apa yang akan dilakukan.',
      },
      {
        'title': 'Waktu Pelaksanaan',
        'desc': 'Target waktu kapan aktivitas ini harus dijalankan.',
      },
      {
        'title': 'Pelaksana Aktivitas',
        'desc': 'Siapa yang akan bertanggung jawab menyelesaikannya.',
      },
    ];
    return items
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: maroonColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        item['desc']!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  void _showActivityDialog(
    BuildContext context,
    KegiatanViewModel vm, {
    Kegiatan? existingActivity,
  }) {
    final isEdit = existingActivity != null;
    final namaController = TextEditingController(
      text: existingActivity?.title ?? '',
    );
    final waktuController = TextEditingController(
      text: existingActivity?.date ?? '',
    );
    final pelaksanaController = TextEditingController(
      text: existingActivity?.desc ?? '',
    );
    String status = existingActivity?.status ?? 'pending';
    String? localFilePath = existingActivity?.localFilePath;
    String? fileName;
    dynamic fileBytes;
    String? documentUrl = existingActivity?.documentUrl;

    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Compute contrasting border color based on dialog background
            final dialogBg = Theme.of(context).dialogTheme.backgroundColor
                ?? Theme.of(context).colorScheme.surface;
            final bgLuminance = dialogBg.computeLuminance();
            final inputBorderColor = bgLuminance > 0.5
                ? Color.lerp(dialogBg, Colors.black, 0.50)!
                : Color.lerp(dialogBg, Colors.white, 0.50)!;

            Widget label(String text) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              );
            }

            Widget input(TextEditingController controller, String hint) {
              return TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: inputBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: inputBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: maroonColor, width: 2),
                  ),
                ),
              );
            }

            Future<void> pilihJam() async {
              // Parse existing time if available (format: HH:mm)
              TimeOfDay initialTime = TimeOfDay.now();
              if (waktuController.text.isNotEmpty) {
                final parts = waktuController.text.split(':');
                if (parts.length >= 2) {
                  final hour = int.tryParse(parts[0]);
                  final minute = int.tryParse(parts[1]);
                  if (hour != null && minute != null) {
                    initialTime = TimeOfDay(hour: hour, minute: minute);
                  }
                }
              }
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: initialTime,
              );

              if (pickedTime != null) {
                setDialogState(() {
                  waktuController.text =
                      '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                });
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: ResponsiveHelper.dialogWidth(context, max: 450),
                padding: const EdgeInsets.all(32),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEdit ? 'Edit Aktivitas' : 'Tambah Aktivitas',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      label('Nama Aktivitas'),
                      input(namaController, ''),
                      
                      // Row untuk Waktu Pelaksanaan dan Pelaksana side by side
                      Row(
                        children: [
                          // Waktu Pelaksanaan (kiri)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                label('Waktu Pelaksanaan'),
                                TextField(
                                  controller: waktuController,
                                  readOnly: true,
                                  onTap: pilihJam,
                                  decoration: InputDecoration(
                                    hintText: 'Pilih jam',
                                    hintStyle: TextStyle(color: Colors.grey[400]),
                                    suffixIcon: const Icon(Icons.access_time),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: inputBorderColor),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: inputBorderColor),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: maroonColor, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 16), // Spacing antar field
                          
                          // Pelaksana (kanan)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                label('Pelaksana'),
                                input(pelaksanaController, ''),
                              ],
                            ),
                          ),
                        ],
                      ),
                      label('Dokumen / Lampiran'),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              FilePickerResult? result = await FilePicker
                                  .platform
                                  .pickFiles();
                              if (result != null) {
                                setDialogState(() {
                                  localFilePath =
                                      result.files.single.path ??
                                      result.files.single.name;
                                  fileName = result.files.single.name;
                                  fileBytes = result.files.single.bytes;
                                });
                              }
                            },
                            icon: const Icon(Icons.upload_file, size: 18),
                            label: const Text('Pilih File'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              localFilePath != null
                                  ? localFilePath!
                                        .split('\\')
                                        .last
                                        .split('/')
                                        .last
                                  : (documentUrl != null
                                        ? 'Dokumen sudah ada'
                                        : 'Belum ada file'),
                              style: TextStyle(
                                color: localFilePath != null
                                    ? Colors.black87
                                    : Colors.grey,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (localFilePath != null || documentUrl != null)
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  localFilePath = null;
                                  documentUrl = null;
                                });
                              },
                            ),
                        ],
                      ),
                      if (isEdit) ...[
                        label('Status'),
                        DropdownButtonFormField<String>(
                          initialValue: status,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: inputBorderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: inputBorderColor),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'pending',
                              child: Text('Pending'),
                            ),
                            DropdownMenuItem(
                              value: 'in_progress',
                              child: Text('In Progress'),
                            ),
                            DropdownMenuItem(
                              value: 'done',
                              child: Text('Done'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => status = value);
                            }
                          },
                        ),
                      ],
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFF64748B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Batal',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!isEdit) {
                                  if (namaController.text.isEmpty ||
                                      waktuController.text.isEmpty ||
                                      pelaksanaController.text.isEmpty) {
                                    return;
                                  }
                                }

                                final activity = Kegiatan(
                                  id: existingActivity?.id ??
                                      DateTime.now().millisecondsSinceEpoch.toString(),
                                  projectTitle: existingActivity?.projectTitle ?? '',
                                  jobTitle: existingActivity?.jobTitle ?? '',
                                  title: namaController.text,
                                  desc: pelaksanaController.text,
                                  date: waktuController.text,
                                  status: status,
                                  localFilePath: localFilePath,
                                  documentUrl: documentUrl,
                                  fileName: fileName,
                                  fileBytes: fileBytes,
                                );

                                if (isEdit) {
                                  await vm.perbaruiKegiatan(
                                    existingActivity,
                                    activity,
                                  );
                                } else {
                                  await vm.tambahKegiatan(activity);
                                }

                                if (!context.mounted) return;
                                Navigator.pop(dialogContext);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF800000),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
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
            );
          },
        );
      },
    );
  }
}

class UploadDialog extends StatelessWidget {
  final Kegiatan activity;
  final KegiatanViewModel activityVm;
  final bool isReadOnly;

  const UploadDialog({
    required this.activity,
    required this.activityVm,
    required this.isReadOnly,
  });

  @override
  Widget build(BuildContext context) {
    final uploadVm = context.watch<UploadFileViewModel>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upload Bukti',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: DesignColors.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Aktivitas: ${activity.title}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    hoverColor: Color(0xFFE2E8F0),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: const Color(0xFFE2E8F0),
              ),
              const SizedBox(height: 16),
              if (uploadVm.pesanError != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFDC2626),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          uploadVm.pesanError!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => uploadVm.clearError(),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFFDC2626),
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (uploadVm.sedangMemuat) ...[
                const SizedBox(height: 24),
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        color: DesignColors.primary,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Memproses file...',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ] else if (uploadVm.sedangMerekam) ...[
                const SizedBox(height: 24),
                _RecordingUI(
                  uploadVm: uploadVm,
                  activity: activity,
                  activityVm: activityVm,
                ),
                const SizedBox(height: 24),
              ] else if (uploadVm.adaFileTertunda) ...[
                const SizedBox(height: 20),
                _PendingPreview(
                  uploadVm: uploadVm,
                  activity: activity,
                  activityVm: activityVm,
                ),
                const SizedBox(height: 20),
              ] else if (uploadVm.adaFile) ...[
                const SizedBox(height: 20),
                _FilePreview(uploadVm: uploadVm),
                const SizedBox(height: 12),
                if (!isReadOnly)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await uploadVm.hapusFile(activity.id);
                        final updated = activity.copyWith(
                          fileName: null,
                          localFilePath: null,
                        );
                        await activityVm.perbaruiKegiatan(activity, updated);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('File berhasil dihapus.'),
                              backgroundColor: Color(0xFF16A34A),
                            ),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFDC2626),
                        size: 18,
                      ),
                      label: const Text(
                        'Hapus File',
                        style: TextStyle(color: Color(0xFFDC2626)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),
                const Text(
                  'Ganti dengan file lain:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
              ] else ...[
                const SizedBox(height: 20),
              ],
              if (!isReadOnly && !uploadVm.sedangMemuat) ...[
                if (uploadVm.adaFile) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: DesignColors.primary.withOpacity(0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: DesignColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'File hanya dapat di-upload 1 per aktivitas. Hapus file yang ada untuk mengganti.',
                            style: TextStyle(
                              fontSize: 12,
                              color: DesignColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                _UploadOptionTile(
                  icon: Icons.folder_open_outlined,
                  title: 'Pilih dari Storage',
                  subtitle: 'Gambar, PDF, Dokumen...',
                  onTap: uploadVm.adaFile
                      ? null
                      : () async {
                          await uploadVm.ambilDariPenyimpanan(activity.id);
                        },
                ),
                const SizedBox(height: 12),
                _UploadOptionTile(
                  icon: Icons.camera_alt_outlined,
                  title: 'Gunakan Kamera',
                  subtitle: 'Ambil Foto atau Rekam Video',
                  onTap: uploadVm.adaFile
                      ? null
                      : () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (ctx) => Container(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Pilih Mode Kamera',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.blue,
                                    ),
                                    title: const Text('Ambil Foto'),
                                    onTap: () async {
                                      Navigator.pop(ctx);
                                      await uploadVm.ambilDariKamera(
                                        activity.id,
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.videocam,
                                      color: Colors.purple,
                                    ),
                                    title: const Text('Rekam Video'),
                                    onTap: () async {
                                      Navigator.pop(ctx);
                                      await uploadVm.ambilVideoDariKamera(
                                        activity.id,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                ),
                _UploadOptionTile(
                  icon: Icons.mic_none_outlined,
                  title: 'Rekam Suara Langsung',
                  subtitle: 'Gunakan mikrofon perangkat',
                  onTap: uploadVm.adaFile
                      ? null
                      : () async {
                          await uploadVm.mulaiMerekam();
                        },
                ),
                const SizedBox(height: 20),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: DesignColors.primary.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 0.3,
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
}

class _RecordingUI extends StatefulWidget {
  final UploadFileViewModel uploadVm;
  final Kegiatan activity;
  final KegiatanViewModel activityVm;

  const _RecordingUI({
    required this.uploadVm,
    required this.activity,
    required this.activityVm,
  });

  @override
  State<_RecordingUI> createState() => _RecordingUIState();
}

class _RecordingUIState extends State<_RecordingUI>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Column(
        children: [
          FadeTransition(
            opacity: _animController,
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFE11D48),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sedang Merekam...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFBE123C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Suara Anda sedang direkam secara langsung',
            style: TextStyle(fontSize: 12, color: Color(0xFFE11D48)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await widget.uploadVm.berhentiMerekam(widget.activity.id);
                if (widget.uploadVm.adaFile &&
                    widget.uploadVm.pesanError == null) {
                  final updated = widget.activity.copyWith(
                    fileName: widget.uploadVm.namaFile,
                    localFilePath: widget.uploadVm.localFilePath,
                  );
                  await widget.activityVm.perbaruiKegiatan(
                    widget.activity,
                    updated,
                  );
                }
              },
              icon: const Icon(Icons.stop),
              label: const Text('Berhenti & Simpan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilePreview extends StatelessWidget {
  final UploadFileViewModel uploadVm;

  const _FilePreview({required this.uploadVm});

  @override
  Widget build(BuildContext context) {
    final tipeFile = uploadVm.tipeFileUnggahan;
    final bytesTampilan = uploadVm.bytesTampilan;
    final namaFile = uploadVm.namaFile ?? 'File';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignColors.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: DesignColors.primary.withOpacity(0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: DesignColors.primary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (tipeFile == UploadedFileType.image && bytesTampilan != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                bytesTampilan,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const _FileIcon(
                  icon: Icons.broken_image_outlined,
                  color: Color(0xFF94A3B8),
                  label: 'Gambar tidak dapat ditampilkan',
                ),
              ),
            )
          else if (tipeFile == UploadedFileType.pdf)
            const _FileIcon(
              icon: Icons.picture_as_pdf_outlined,
              color: DesignColors.primary,
              label: 'Dokumen PDF',
            )
          else if (tipeFile == UploadedFileType.audio)
            const _FileIcon(
              icon: Icons.audiotrack_outlined,
              color: Color(0xFFF59E0B),
              label: 'File Audio / Rekaman',
            )
          else if (tipeFile == UploadedFileType.video)
            const _FileIcon(
              icon: Icons.videocam_outlined,
              color: Color(0xFF7C3AED),
              label: 'File Video',
            )
          else
            const _FileIcon(
              icon: Icons.insert_drive_file_outlined,
              color: Color(0xFF64748B),
              label: 'Dokumen',
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF16A34A),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaFile,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: DesignColors.primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ukuran: ${uploadVm.tampilanUkuranFile}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'File tersimpan sementara selama sesi berjalan',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingPreview extends StatelessWidget {
  final UploadFileViewModel uploadVm;
  final Kegiatan activity;
  final KegiatanViewModel activityVm;

  const _PendingPreview({
    required this.uploadVm,
    required this.activity,
    required this.activityVm,
  });

  @override
  Widget build(BuildContext context) {
    final tipe = uploadVm.tipeFileTertunda;
    final bytes = uploadVm.bytesTertunda;
    final nama = uploadVm.namaFileTertunda ?? 'File';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignColors.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignColors.border),
      ),
      child: Column(
        children: [
          const Text(
            'Pratinjau File',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (tipe == UploadedFileType.image && bytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                bytes,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else if (tipe == UploadedFileType.video)
            const _FileIcon(
              icon: Icons.videocam_outlined,
              color: Colors.purple,
              label: 'Video Siap Upload',
            )
          else if (tipe == UploadedFileType.audio)
            const _FileIcon(
              icon: Icons.audiotrack_outlined,
              color: Colors.orange,
              label: 'Audio/Rekaman Siap Upload',
            )
          else
            const _FileIcon(
              icon: Icons.insert_drive_file_outlined,
              color: Colors.grey,
              label: 'Dokumen Siap Upload',
            ),
          const SizedBox(height: 12),
          Text(
            nama,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Ukuran: ${uploadVm.tampilanUkuranTertunda}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => uploadVm.batalkanTertunda(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await uploadVm.konfirmasiUnggah(activity.id);
                    if (uploadVm.adaFile && uploadVm.pesanError == null) {
                      final updated = activity.copyWith(
                        fileName: uploadVm.namaFile,
                        localFilePath: uploadVm.localFilePath,
                      );
                      await activityVm.perbaruiKegiatan(activity, updated);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('File berhasil diupload.'),
                            backgroundColor: Color(0xFF16A34A),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Upload'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityPreview extends StatelessWidget {
  final Kegiatan activity;

  const _ActivityPreview({required this.activity});

  @override
  Widget build(BuildContext context) {
    final type = detectUploadedFileType(activity.fileName ?? '');
    final data = FileStorageHelper.readFileForActivity(activity.id);
    final localPath = data['localFilePath'];

    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: DesignColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: _buildContent(type, localPath),
      ),
    );
  }

  Widget _buildContent(UploadedFileType type, String? localPath) {
    if (type == UploadedFileType.image && localPath != null) {
      try {
        final file = File(localPath);
        if (file.existsSync()) {
          return Image.memory(
            file.readAsBytesSync(),
            fit: BoxFit.cover,
            width: double.infinity,
          );
        }
      } catch (_) {
        // fallback ke icon
      }
    }

    IconData icon;
    Color color;

    switch (type) {
      case UploadedFileType.pdf:
        icon = Icons.picture_as_pdf_outlined;
        color = Colors.red;
        break;
      case UploadedFileType.audio:
        icon = Icons.audiotrack_outlined;
        color = Colors.orange;
        break;
      case UploadedFileType.video:
        icon = Icons.videocam_outlined;
        color = Colors.purple;
        break;
      default:
        icon = Icons.insert_drive_file_outlined;
        color = Colors.blueGrey;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          activity.fileName ?? '',
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _FileIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _FileIcon({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 56, color: color),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}

class _UploadOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _UploadOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      splashColor: DesignColors.primary.withOpacity(0.08),
      highlightColor: DesignColors.primary.withOpacity(0.04),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDisabled
                ? const Color(0xFFE2E8F0)
                : DesignColors.primary.withOpacity(0.15),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(14),
          color: isDisabled
              ? const Color(0xFFFAFAFA)
              : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: isDisabled
                    ? const Color(0xFFF1F5F9)
                    : DesignColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDisabled
                    ? const Color(0xFFCBD5E1)
                    : DesignColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDisabled
                          ? const Color(0xFFA0AEC0)
                          : DesignColors.primary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDisabled
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDisabled
                  ? const Color(0xFFE2E8F0)
                  : DesignColors.primary.withOpacity(0.4),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

