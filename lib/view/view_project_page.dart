import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/modelbikinproyek.dart';
import '../utils/responsive_helper.dart';
import '../viewmodel/bikinproyek_viewmodel.dart';
import '../utils/toast_helper.dart';
import '../utils/pdf_export_helper.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../widgets/app_header.dart';
import '../utils/design_tokens.dart';
import 'create_project_wizard.dart';
import 'project_detail_page.dart';
import 'proyek_dashboard_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _proyekKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<ProyekViewModel>(context, listen: false).muatProyek();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ProyekViewModel>(context);
    final bool mobile = ResponsiveHelper.isMobile(context);
    final bool landscape = ResponsiveHelper.isMobileLandscape(context);
    final pagePadding = ResponsiveHelper.pagePadding(context);
    final contentWidth = ResponsiveHelper.constrainedContentWidth(context);

    return Scaffold(
      backgroundColor: DesignColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: Column(
                children: [
                  const AppHeader(),
                  const SizedBox(height: 24),
                  _hero(mobile, landscape),
                  Container(
                    key: _proyekKey,
                    width: double.infinity,
                    color: const Color(0xFFF8FAFC),
                    padding: EdgeInsets.symmetric(
                      horizontal: pagePadding.horizontal / 2,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // header toolbar
                        if (mobile && !landscape)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Daftar Proyek',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: DesignColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 40,
                                child: TextField(
                                  onChanged: vm.aturPencarian,
                                  decoration: _searchDecoration('Cari proyek...'),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(child: _buildCreateProjectButton(context, vm)),
                                  const SizedBox(width: 10),
                                  _buildPrintGlobalButton(context, vm),
                                ],
                              ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              Text(
                                'Daftar Proyek',
                                style: TextStyle(
                                  fontSize: landscape ? 18 : 22,
                                  fontWeight: FontWeight.w800,
                                  color: DesignColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: landscape ? 160 : 240,
                                height: 38,
                                child: TextField(
                                  onChanged: vm.aturPencarian,
                                  decoration: _searchDecoration('Cari proyek...'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _buildPrintGlobalButton(context, vm),
                              const SizedBox(width: 10),
                              _buildCreateProjectButton(context, vm),
                            ],
                          ),
                        const SizedBox(height: 20),

                        // === DASHBOARD CHART ===
                        const ProyekDashboardChart(),
                        const SizedBox(height: 24),

                        // loading / error / empty / list states handled below
                        if (vm.sedangMemuat)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 80),
                            child: Center(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(
                                    color: DesignColors.primary,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Memuat proyek dari server...',
                                    style: TextStyle(color: DesignColors.hint),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (vm.pesanError != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.wifi_off,
                                    size: 48,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    vm.pesanError!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: DesignColors.hint),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () => vm.muatUlang(),
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Coba Lagi'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: DesignColors.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (vm.daftarProyekTerfilter.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 80),
                            child: Center(
                              child: Text(
                                'Belum ada proyek. Mulai dengan membuat proyek baru!',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          )
                        else
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final w = constraints.maxWidth;
                              final cols = w >= 1200
                                  ? 3
                                  : (w >= 600 ? 2 : 1);
                              final cardWidth = (w - (cols - 1) * 16) / cols;
                              return Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: vm.daftarProyekTerfilter.map((proyek) {
                                  return SizedBox(
                                    width: cardWidth,
                                    child: _projectCard(context, proyek, vm),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Hero — full-width image background with dark overlay + centered text ─
  Widget _hero(bool mobile, bool landscape) {
    final double height = landscape ? 160 : (mobile ? 240 : 380);
    final double titleSize = landscape ? 20 : (mobile ? 26 : 42);
    final double subSize = mobile ? 13 : 17;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // background image
          Positioned.fill(
            child: Image.asset(
              'assets/family.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          // dark overlay to increase contrast
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),
          // optional decorative circles (subtle)
          Positioned(
            right: -60,
            top: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.02),
              ),
            ),
          ),
          // centered content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: landscape ? 24 : (mobile ? 20 : 40),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: landscape ? 32 : (mobile ? 40 : 46),
                    height: landscape ? 32 : (mobile ? 40 : 46),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.folder_rounded,
                      color: Colors.white,
                      size: landscape ? 18 : (mobile ? 22 : 26),
                    ),
                  ),
                  SizedBox(height: landscape ? 6 : 12),
                  Text(
                    'Manajemen Proyek',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: titleSize,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kelola Proyek Mahasiswa\ndengan Efisien',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: subSize,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Project Card — seragam dengan DesignColors ───────────────────────────
  Widget _projectCard(BuildContext context, Proyek proyek, ProyekViewModel vm) {
    String statusLabel = proyek.status;
    Color statusBg;
    Color statusFg;

    if (statusLabel == 'Selesai' || proyek.isTertutup) {
      statusLabel = 'Selesai';
      statusBg = DesignColors.statusDoneBg;
      statusFg = DesignColors.statusDone;
    } else if (statusLabel == 'Tertunda') {
      statusBg = DesignColors.statusPendingBg;
      statusFg = DesignColors.statusPending;
    } else {
      statusLabel = 'Aktif';
      statusBg = DesignColors.statusActiveBg;
      statusFg = DesignColors.statusActive;
    }

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectDetailPage(proyek: proyek),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: DesignColors.borderMuted),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Baris atas: ikon + badge status ─────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: proyek.isTertutup
                        ? DesignColors.surfaceSoft
                        : DesignColors.brandSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    proyek.isTertutup ? Icons.lock_rounded : Icons.folder_rounded,
                    color: proyek.isTertutup
                        ? DesignColors.hint
                        : DesignColors.primary,
                    size: 22,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusFg,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Aksi edit / delete ───────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!proyek.isTertutup)
                  _iconActionBtn(
                    icon: Icons.edit_outlined,
                    color: DesignColors.hint,
                    onTap: () => _showEditProjectDialog(context, vm, proyek),
                  ),
                _iconActionBtn(
                  icon: Icons.delete_outline,
                  color: DesignColors.danger,
                  onTap: () => _confirmDelete(context, vm, proyek),
                ),
              ],
            ),
            const SizedBox(height: 2),

            // ── Nama & deskripsi ─────────────────────────────────
            Text(
              proyek.isTertutup ? '${proyek.nama} (Ditutup)' : proyek.nama,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: proyek.isTertutup
                    ? DesignColors.hint
                    : DesignColors.textPrimary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              proyek.deskripsi,
              style: const TextStyle(
                color: DesignColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // ── Info rows ────────────────────────────────────────
            _buildInfoRow(Icons.location_on_outlined, proyek.lokasi),
            _buildInfoRow(Icons.calendar_month_outlined, proyek.tanggal),
            _buildInfoRow(Icons.group_outlined, proyek.tim),
            const SizedBox(height: 8),

            // Broadcast status (IE / IC / Implementation) — ditampilkan jika tersedia
            if (proyek.broadcastStatus != null) ...[
              const SizedBox(height: 8),
              _buildBroadcastStatusRow(proyek.broadcastStatus!),
            ],
            const SizedBox(height: 6),

            // ── Progress bar ─────────────────────────────────────
            Builder(
              builder: (context) {
                final totalAct = proyek.daftarKegiatan.length;
                final doneAct = proyek.daftarKegiatan.where((a) => a.selesai).length;
                final progress = totalAct == 0 ? 0.0 : doneAct / totalAct;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Aktivitas: $doneAct/$totalAct selesai',
                          style: const TextStyle(
                            fontSize: 12,
                            color: DesignColors.hint,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: DesignColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: DesignColors.surfaceSoft,
                        color: DesignColors.primary,
                        minHeight: 6,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconActionBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, color: color, size: 19),
        ),
      );

  Widget _buildBroadcastStatusRow(Map<String, dynamic> statusMap) {
    // Normalize keys and prepare entries
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

    return Row(
      children: entries.map((e) {
        final label = e.key;
        final stat = e.value.isEmpty ? 'unknown' : e.value;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor(stat), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('$label: ${stat}', style: const TextStyle(fontSize: 12, color: DesignColors.textSecondary)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _confirmDelete(BuildContext context, ProyekViewModel vm, Proyek proyek) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Proyek'),
        content: const Text(
          'Yakin ingin menghapus proyek ini? Semua data terkait akan ikut terhapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              vm.hapusProyek(proyek);
              Navigator.pop(dialogCtx);
              ToastHelper.showSuccess(context, 'Proyek berhasil dihapus');
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          children: [
            Icon(icon, size: 14, color: DesignColors.hint),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  color: DesignColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  void _showEditProjectDialog(
    BuildContext context,
    ProyekViewModel vm,
    Proyek proyek,
  ) {
    final nameC = TextEditingController(text: proyek.nama);
    final descC = TextEditingController(text: proyek.deskripsi);
    final locC = TextEditingController(text: proyek.lokasi);
    final teamC = TextEditingController(text: proyek.tim);
    final supC = TextEditingController(text: proyek.pengawas);
    final startC = TextEditingController(text: proyek.tanggalMulai);
    final endC = TextEditingController(text: proyek.tanggalSelesai);
    String currentStatus = proyek.status;

    Future<void> pickDate(TextEditingController c) async {
      final p = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (p != null) {
        c.text =
            '${p.year}-${p.month.toString().padLeft(2, '0')}-${p.day.toString().padLeft(2, '0')}';
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
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 20),
                  _buildField('Nama Proyek *', nameC),
                  _buildField('Deskripsi *', descC, maxLines: 3),
                  _buildField('Tempat *', locC),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: 300,
                        child: _buildField('Tanggal Mulai *', startC,
                            isDate: true, onTap: () => pickDate(startC)),
                      ),
                      SizedBox(
                        width: 300,
                        child: _buildField('Tanggal Selesai *', endC,
                            isDate: true, onTap: () => pickDate(endC)),
                      ),
                    ],
                  ),
                  _buildField('Pelaksana Proyek *', teamC),
                  _buildField('Supervisor Proyek *', supC),
                  const Text('Status Proyek *',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: currentStatus,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 15),
                    ),
                    items: ['Aktif', 'Selesai', 'Tertunda']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => currentStatus = val);
                    },
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            if ([nameC, descC, locC, startC, endC, teamC, supC]
                                .any((c) => c.text.trim().isEmpty)) {
                              ToastHelper.showError(
                                  context, 'Lengkapi data proyek');
                              return;
                            }
                            vm.perbaruiProyek(
                              proyek,
                              proyek.copyWith(
                                nama: nameC.text.trim(),
                                deskripsi: descC.text.trim(),
                                lokasi: locC.text.trim(),
                                tanggalMulai: startC.text.trim(),
                                tanggalSelesai: endC.text.trim(),
                                tim: teamC.text.trim(),
                                pengawas: supC.text.trim(),
                                status: currentStatus,
                              ),
                            );
                            Navigator.pop(ctx);
                            ToastHelper.showSuccess(
                                context, 'Proyek berhasil diperbarui');
                          },
                          child: const Text('Simpan Perubahan',
                              style: TextStyle(fontWeight: FontWeight.w700)),
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

  Widget _buildField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool isDate = false,
    bool autofocus = false,
    VoidCallback? onTap,
    String? hintText,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              autofocus: autofocus,
              maxLines: maxLines,
              readOnly: isDate,
              onTap: onTap,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: DesignColors.hint),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: DesignColors.primary, width: 1.5),
                ),
                suffixIcon: isDate
                    ? const Icon(Icons.calendar_today, size: 18)
                    : null,
              ),
            ),
          ],
        ),
      );

  InputDecoration _searchDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon:
            Icon(Icons.search, color: Colors.grey[500], size: 20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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
          borderSide:
              const BorderSide(color: DesignColors.primary),
        ),
        filled: true,
        fillColor: Colors.white,
      );

  Widget _buildPrintGlobalButton(
      BuildContext context, ProyekViewModel vm) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignColors.borderMuted),
      ),
      child: IconButton(
        icon: const Icon(Icons.picture_as_pdf,
            color: DesignColors.primary),
        tooltip: 'Cetak Portofolio Global',
        onPressed: () async {
          final authVM =
              Provider.of<AuthViewModel>(context, listen: false);
          final user = authVM.penggunaSaatIni;
          if (user == null) {
            ToastHelper.showError(
                context, 'Silakan login terlebih dahulu');
            return;
          }
          if (vm.daftarProyek.isEmpty) {
            ToastHelper.showError(
                context, 'Tidak ada proyek untuk dicetak');
            return;
          }
          try {
            await PdfExportHelper.printGlobalReport(
                vm.daftarProyek, user);
          } catch (e) {
            if (context.mounted) {
              ToastHelper.showError(
                  context, 'Gagal mencetak dokumen global: $e');
            }
          }
        },
      ),
    );
  }

  Widget _buildCreateProjectButton(
          BuildContext context, ProyekViewModel vm) =>
      ElevatedButton.icon(
        onPressed: () => showCreateProjectWizard(context, vm.tambahProyek),
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: const Text(
          'Buat Proyek',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignColors.primary,
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
}
