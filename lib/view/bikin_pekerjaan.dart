import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/job.dart';
import '../utils/responsive_helper.dart';
import '../viewmodel/bikinproyek_viewmodel.dart';
import '../viewmodel/job_view_model.dart';
import '../widgets/app_header.dart';
import '../utils/design_tokens.dart';
import 'bikin_aktivitas_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_config.dart';
import 'gantt_chart_widget.dart';
import '../utils/toast_helper.dart';
import '../utils/pdf_export_helper.dart';

class BikinPekerjaan extends StatefulWidget {
  final Map<String, String> projectData;
  final bool isReadOnly;
  final bool showCreateOnOpen;

  const BikinPekerjaan({
    super.key,
    required this.projectData,
    this.isReadOnly = false,
    this.showCreateOnOpen = false,
  });

  @override
  State<BikinPekerjaan> createState() => _BikinPekerjaanState();
}

class _BikinPekerjaanState extends State<BikinPekerjaan> {
  static const Color _maroon = DesignColors.primary;
  static const Color _slate = DesignColors.textSecondary;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final vm = Provider.of<PekerjaanViewModel>(context, listen: false);
      vm.init(
        widget.projectData['title']!,
        idProyek: widget.projectData['id'] ?? '',
      );
      if (widget.showCreateOnOpen) {
        // show create dialog after init
        Future.microtask(() => _tampilkanDialogInput(context, vm));
      }
    });
  }

  // ── Export helpers ────────────────────────────────────────────────────

  Future<void> _cetakPDFLokal() async {
    final projectId = widget.projectData['id'];
    if (projectId == null || projectId.isEmpty) {
      if (mounted) ToastHelper.showError(context, 'ID Proyek tidak ditemukan');
      return;
    }
    try {
      final proyekVM = Provider.of<ProyekViewModel>(context, listen: false);
      final list = proyekVM.daftarProyek.where((p) => p.id == projectId).toList();
      if (list.isEmpty) {
        if (mounted) ToastHelper.showError(context, 'Data proyek tidak ditemukan');
        return;
      }
      await PdfExportHelper.printProjectReport(list.first);
    } catch (e) {
      if (mounted) ToastHelper.showError(context, 'Gagal mencetak dokumen: $e');
    }
  }

  Future<void> _downloadFile(String format) async {
    if (format == 'pdf') { await _cetakPDFLokal(); return; }
    final projectId = widget.projectData['id'];
    if (projectId == null || projectId.isEmpty) {
      if (mounted) ToastHelper.showError(context, 'ID Proyek tidak ditemukan');
      return;
    }
    final url = Uri.parse('${ApiConfig.baseUrl}/api/reports/project/$projectId/$format/');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) ToastHelper.showError(context, 'Gagal membuka tautan unduhan');
      }
    } catch (e) {
      if (mounted) ToastHelper.showError(context, 'Terjadi kesalahan: $e');
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PekerjaanViewModel>(context);
    final bool mobile = ResponsiveHelper.isMobile(context);
    final bool landscape = ResponsiveHelper.isMobileLandscape(context);
    // Landscape HP: gunakan layout 2-kolom (info kiri, pekerjaan kanan)
    final bool useSideLayout = !mobile || landscape;

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
              const SizedBox(height: 12),

              // ── Body: info proyek + daftar pekerjaan ────────────────
              Padding(
                padding: ResponsiveHelper.pagePadding(context),
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

  // ── Layout: side-by-side (desktop / landscape HP) ────────────────────

  Widget _buildSideLayout(BuildContext context, PekerjaanViewModel vm, bool landscape) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel kiri: info proyek
        SizedBox(
          width: landscape ? 220 : 280,
          child: _buildInfoPanel(context, landscape),
        ),
        SizedBox(width: landscape ? 12 : 20),
        // Panel kanan: daftar pekerjaan
        Expanded(child: _buildPekerjaanSection(context, vm, landscape: landscape)),
      ],
    );
  }

  // ── Layout: stacked (portrait HP) ────────────────────────────────────

  Widget _buildStackLayout(BuildContext context, PekerjaanViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoPanel(context, false),
        const SizedBox(height: 16),
        _buildPekerjaanSection(context, vm),
      ],
    );
  }

  // ── Info Panel ────────────────────────────────────────────────────────

  Widget _buildInfoPanel(BuildContext context, bool landscape) {
    final desc = widget.projectData['desc'] ?? '';
    final startDate = widget.projectData['startDate'] ?? '';
    final endDate = widget.projectData['endDate'] ?? '';
    final dateStr = widget.projectData['date'] ?? (startDate.isNotEmpty ? '$startDate - $endDate' : '-');
    final team = widget.projectData['team'] ?? '-';
    final supervisor = widget.projectData['supervisor'] ?? '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Card info utama
        Container(
          padding: EdgeInsets.all(landscape ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(color: Color(0x06000000), blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul section
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: _maroon),
                  const SizedBox(width: 6),
                  const Text(
                    'Informasi Proyek',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: DesignColors.surfaceSoft),
              const SizedBox(height: 14),

              // Deskripsi
              if (desc.isNotEmpty) ...[
                _infoLabel('DESKRIPSI'),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 13, color: Color(0xFF334155))),
                SizedBox(height: landscape ? 10 : 14),
              ],

              // Tanggal
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoLabel('MULAI'),
                        const SizedBox(height: 4),
                        Text(_extractStart(dateStr),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoLabel('SELESAI'),
                        const SizedBox(height: 4),
                        Text(_extractEnd(dateStr),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: landscape ? 10 : 14),

              // Pelaksana
              _infoRowWithIcon(Icons.people_outline, 'PELAKSANA', team),
              SizedBox(height: landscape ? 8 : 12),

              // Supervisor
              _infoRowWithIcon(Icons.person_outline, 'SUPERVISOR', supervisor),

              // Status readonly
              if (widget.isReadOnly) ...[
                SizedBox(height: landscape ? 10 : 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFED7AA)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.lock_outline, size: 14, color: Color(0xFF92400E)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text('Proyek ditutup · mode baca saja',
                            style: TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Card progress
        Consumer<ProyekViewModel>(
          builder: (context, proyekVM, _) {
            final proyek = proyekVM.daftarProyek
                .where((p) => p.id == (widget.projectData['id'] ?? ''))
                .firstOrNull;
            final total = proyek?.daftarKegiatan.length ?? 0;
            final done = proyek?.daftarKegiatan.where((k) => k.selesai).length ?? 0;
            final pct = total == 0 ? 0.0 : done / total;
            return Container(
              padding: EdgeInsets.all(landscape ? 12 : 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [DesignColors.primary, DesignColors.brandDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Progress Keseluruhan',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(
                    '${(pct * 100).toInt()}%',
                    style: TextStyle(fontSize: landscape ? 22 : 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      color: Colors.white,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('$done/$total Selesai',
                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85))),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _infoLabel(String text) => Text(
    text,
    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8), letterSpacing: 0.6),
  );

  Widget _infoRowWithIcon(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _maroon),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoLabel(label),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
            ],
          ),
        ),
      ],
    );
  }

  String _extractStart(String dateStr) {
    if (dateStr.contains(' - ')) return dateStr.split(' - ')[0].trim();
    return dateStr;
  }

  String _extractEnd(String dateStr) {
    if (dateStr.contains(' - ')) {
      final parts = dateStr.split(' - ');
      return parts.length > 1 ? parts[1].trim() : '-';
    }
    return '-';
  }

  // ── Daftar Pekerjaan Section ──────────────────────────────────────────

  Widget _buildPekerjaanSection(BuildContext context, PekerjaanViewModel vm, {bool landscape = false}) {
    final isMob = ResponsiveHelper.isMobile(context) && !landscape;

    return Container(
      padding: EdgeInsets.all(landscape ? 14 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header baris: Daftar Pekerjaan + badge + search + tombol
          _buildPekerjaanHeader(context, vm, isMob, landscape),
          const SizedBox(height: 16),

          // Gantt chart (jika ada data)
          Consumer<ProyekViewModel>(
            builder: (context, proyekVM, _) {
              final proyek = proyekVM.daftarProyek
                  .where((p) => p.nama == widget.projectData['title'])
                  .firstOrNull;
              if (proyek == null || proyek.daftarPekerjaan.isEmpty) return const SizedBox.shrink();
              return Column(
                children: [
                  SimpleGanttChart(jobs: proyek.daftarPekerjaan),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),

          // List pekerjaan
          vm.daftarPekerjaanTerfilter.isEmpty
              ? _emptyState()
              : _buildPekerjaanGrid(context, vm, landscape),
        ],
      ),
    );
  }

  Widget _buildPekerjaanHeader(BuildContext context, PekerjaanViewModel vm, bool isMob, bool landscape) {
    final count = vm.daftarPekerjaanTerfilter.length;

    if (isMob) {
      // Portrait HP: hanya judul + badge 
      return Row(
        children: [
          const Text('Daftar Pekerjaan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(width: 8),
          _countBadge(count),
        ],
      );
    }

    // Landscape / desktop: judul + badge saja
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Daftar Pekerjaan',
            style: TextStyle(
              fontSize: landscape ? 16 : 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            )),
        const SizedBox(width: 8),
        _countBadge(count),
      ],
    );
  }

  Widget _countBadge(int count) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: DesignColors.surfaceSoft,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      '$count Pekerjaan',
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _slate),
    ),
  );

  Widget _emptyState() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 48),
    decoration: BoxDecoration(
      color: DesignColors.bg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Icon(Icons.work_outline, size: 56, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(
          'Belum ada pekerjaan',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 4),
        Text(
          'Data pekerjaan akan muncul di sini',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        ),
      ],
    ),
  );

  Widget _buildPekerjaanGrid(BuildContext context, PekerjaanViewModel vm, bool landscape) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        // Landscape HP: 1 kolom (panel sudah sempit)
        final cols = landscape ? 1 : (w >= 1000 ? 3 : (w >= 620 ? 2 : 1));
        final cardWidth = (w - (cols - 1) * 12) / cols;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: vm.daftarPekerjaanTerfilter.map((p) {
            return SizedBox(width: cardWidth, child: _kartuPekerjaan(context, p, vm, compact: landscape));
          }).toList(),
        );
      },
    );
  }

  // ── Kartu Pekerjaan ───────────────────────────────────────────────────

  Widget _kartuPekerjaan(BuildContext context, Pekerjaan pekerjaan, PekerjaanViewModel vm, {bool compact = false}) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BikinAktivitas(
          pekerjaan: pekerjaan,
          projectData: widget.projectData,
          isReadOnly: widget.isReadOnly,
        )),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(compact ? 12 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(color: Color(0x05000000), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Judul + aksi ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    pekerjaan.nama,
                    style: TextStyle(
                      fontSize: compact ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!widget.isReadOnly) ...[
                  const SizedBox(width: 4),
                  _miniIconBtn(Icons.add_circle_outline, _maroon, () => _tampilkanDialogInput(context, vm)),
                  _miniIconBtn(Icons.edit_outlined, _slate, () => _tampilkanDialogInput(context, vm, existingJob: pekerjaan)),
                  _miniIconBtn(Icons.delete_outline, const Color(0xFFEF4444), () => _confirmHapus(context, vm, pekerjaan)),
                ],
              ],
            ),

            // ── Kolom info kecil ──
            if (!compact) ...[
              const SizedBox(height: 10),
              _infoChip(Icons.location_on_outlined, pekerjaan.lokasi),
            ],
            SizedBox(height: compact ? 6 : 10),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 11, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${pekerjaan.tanggalMulai} · ${pekerjaan.tanggalSelesai}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (!compact) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(child: _infoChip(Icons.people_outline, pekerjaan.pelaksana)),
                  const SizedBox(width: 8),
                  Expanded(child: _infoChip(Icons.person_outline, pekerjaan.pengawas)),
                ],
              ),
            ],

            SizedBox(height: compact ? 8 : 12),
            const Divider(height: 1, color: DesignColors.surfaceSoft),
            SizedBox(height: compact ? 8 : 10),

            // ── Progress ──
            Consumer<PekerjaanViewModel>(
              builder: (context, jobVm, _) {
                final total = jobVm.ambilJumlahAktivitas(pekerjaan.id);
                final done = jobVm.ambilJumlahAktivitasSelesai(pekerjaan.id);
                final pct = total == 0 ? 0.0 : done / total;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('AKTIVITAS',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.6)),
                        const Spacer(),
                        const Text('STATUS & BUKTI',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.6)),
                        const Spacer(),
                        const Text('AKSI',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.6)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              backgroundColor: DesignColors.surfaceSoft,
                              color: _maroon,
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(pct * 100).toInt()}%',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _maroon),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      total == 0 ? 'Belum ada aktivitas' : '$done dari $total aktivitas selesai',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Lihat aktivitas →',
                style: TextStyle(fontSize: 12, color: _maroon, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniIconBtn(IconData icon, Color color, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: Padding(
      padding: const EdgeInsets.all(3),
      child: Icon(icon, size: 16, color: color),
    ),
  );

  Widget _infoChip(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: const Color(0xFF94A3B8)),
      const SizedBox(width: 4),
      Flexible(
        child: Text(
          text.isEmpty ? '-' : text,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  void _confirmHapus(BuildContext context, PekerjaanViewModel vm, Pekerjaan pekerjaan) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Pekerjaan'),
        content: const Text('Apakah Anda yakin ingin menghapus pekerjaan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _maroon),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await vm.hapusPekerjaan(pekerjaan);
              } catch (_) {
                // rollback sudah ditangani di ViewModel
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Dialog tambah/edit pekerjaan ──────────────────────────────────────

  void _tampilkanDialogInput(BuildContext context, PekerjaanViewModel vm, {Pekerjaan? existingJob}) {
    final isEdit = existingJob != null;
    final titleCtrl = TextEditingController(text: existingJob?.nama ?? '');
    final descCtrl = TextEditingController(text: existingJob?.deskripsi ?? '');
    final locCtrl = TextEditingController(text: existingJob?.lokasi ?? '');
    final startCtrl = TextEditingController(text: existingJob?.tanggalMulai ?? '');
    final endCtrl = TextEditingController(text: existingJob?.tanggalSelesai ?? '');
    final execCtrl = TextEditingController(text: existingJob?.pelaksana ?? '');
    final supCtrl = TextEditingController(text: existingJob?.pengawas ?? '');

    Future<void> pickDate(TextEditingController ctrl) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        ctrl.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.isMobile(context) ? 16 : 40,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isEdit ? 'Edit Pekerjaan' : 'Buat Pekerjaan Baru',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _dlgLabel('Nama Pekerjaan *'),
                _dlgInput('Masukkan nama pekerjaan', controller: titleCtrl),
                _dlgLabel('Deskripsi'),
                _dlgInput('Masukkan deskripsi', controller: descCtrl, maxLines: 2),
                _dlgLabel('Lokasi'),
                _dlgInput('Masukkan lokasi', controller: locCtrl),
                // Tanggal dalam 2 kolom
                Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _dlgLabel('Tanggal Mulai'),
                      _dlgInput('yyyy-mm-dd', controller: startCtrl, readOnly: true,
                          icon: Icons.calendar_month, onTap: () => pickDate(startCtrl)),
                    ])),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _dlgLabel('Tanggal Selesai'),
                      _dlgInput('yyyy-mm-dd', controller: endCtrl, readOnly: true,
                          icon: Icons.calendar_month, onTap: () => pickDate(endCtrl)),
                    ])),
                  ],
                ),
                _dlgLabel('Pelaksana'),
                _dlgInput('Masukkan pelaksana', controller: execCtrl),
                _dlgLabel('Supervisor'),
                _dlgInput('Masukkan supervisor', controller: supCtrl),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text('Batal', style: TextStyle(color: Colors.black54)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (titleCtrl.text.trim().isEmpty) return;
                          final newJob = Pekerjaan(
                            id: existingJob?.id ?? '',
                            idProyek: existingJob?.idProyek ?? '',
                            judulProyek: existingJob?.judulProyek ?? '',
                            nama: titleCtrl.text.trim(),
                            deskripsi: descCtrl.text.trim(),
                            lokasi: locCtrl.text.trim(),
                            tanggalMulai: startCtrl.text,
                            tanggalSelesai: endCtrl.text,
                            pelaksana: execCtrl.text.trim(),
                            pengawas: supCtrl.text.trim(),
                          );
                          Navigator.pop(dialogContext);
                          try {
                            if (isEdit) {
                              await vm.perbaruiPekerjaan(existingJob, newJob);
                            } else {
                              await vm.tambahPekerjaan(newJob);
                            }
                          } catch (_) {
                            // error ditampilkan via ViewModel state
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _maroon,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(isEdit ? 'Simpan' : 'Buat Pekerjaan',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _dlgLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
  );

  Widget _dlgInput(String hint, {
    TextEditingController? controller,
    int maxLines = 1,
    bool readOnly = false,
    IconData? icon,
    VoidCallback? onTap,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13),
        suffixIcon: icon != null ? Icon(icon, size: 18) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _maroon),
        ),
      ),
    ),
  );
}
