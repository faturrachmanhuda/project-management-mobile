import 'package:flutter/material.dart';

import '../models/modelbikinproyek.dart';
import '../services/form_draft_service.dart';
import '../utils/responsive_helper.dart';
import '../utils/toast_helper.dart';
import '../utils/design_tokens.dart';
import '../viewmodel/create_project_wizard_viewmodel.dart';

/// Dialog wizard 4-step untuk membuat proyek baru.
///
/// Arsitektur MVVM + Fragment Pattern (mirip identity/address/contact/summary):
///   - **View**      : File ini — hanya UI, tidak menyimpan state bisnis.
///   - **ViewModel** : [CreateProjectWizardViewModel] — semua state wizard.
///   - **Model**     : [Proyek], [ItemPekerjaan], [ItemKegiatan].
///
/// Alur Wizard:
///   Step 0 → [_DataProyekFragment]      : Isi data proyek
///   Step 1 → [_TambahPekerjaanFragment] : Tambah pekerjaan
///   Step 2 → [_TambahAktivitasFragment] : Tambah aktivitas per pekerjaan
///   Step 3 → [_KonfirmasiFragment]      : Ringkasan semua data + submit
class CreateProjectWizardDialog extends StatefulWidget {
  const CreateProjectWizardDialog({super.key, required this.onCreate});

  /// Callback saat proyek berhasil dibuat. Harus mengembalikan Future
  /// agar wizard dapat menunggu konfirmasi server sebelum menutup dialog.
  final Future<void> Function(Proyek proyek) onCreate;

  @override
  State<CreateProjectWizardDialog> createState() =>
      _CreateProjectWizardDialogState();
}

class _CreateProjectWizardDialogState extends State<CreateProjectWizardDialog> {
  late final CreateProjectWizardViewModel _vm;
  bool _submitted = false;

  // Kontroler Langkah 0 — Data Proyek
  final _namaC = TextEditingController();
  final _deskripsiC = TextEditingController();
  final _lokasiC = TextEditingController();
  final _mulaiC = TextEditingController();
  final _selesaiC = TextEditingController();
  final _timC = TextEditingController();
  final _pengawasC = TextEditingController();
  String _statusTerpilih = 'Aktif';

  // Kontroler Langkah 1 — Tambah Pekerjaan
  final _namaPekerjaanC = TextEditingController();
  final _deskripsiPekerjaanC = TextEditingController();
  final _lokasiPekerjaanC = TextEditingController();
  final _mulaiPekerjaanC = TextEditingController();
  final _selesaiPekerjaanC = TextEditingController();
  final _pelaksanaPekerjaanC = TextEditingController();
  final _pengawasPekerjaanC = TextEditingController();

  // Kontroler Langkah 2 — Tambah Aktivitas
  final _namaKegiatanC = TextEditingController();
  final _waktuKegiatanC = TextEditingController();
  final _pelaksanaKegiatanC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = CreateProjectWizardViewModel();
    _vm.addListener(_onVmChanged);
    _muatDraft();
  }

  Future<void> _muatDraft() async {
    final draft = await FormDraftService.muatDraft(FormDraftService.keyWizardProyek);
    if (draft == null || !mounted) return;
    setState(() {
      _namaC.text = draft['nama'] ?? '';
      _deskripsiC.text = draft['deskripsi'] ?? '';
      _lokasiC.text = draft['lokasi'] ?? '';
      _mulaiC.text = draft['mulai'] ?? '';
      _selesaiC.text = draft['selesai'] ?? '';
      _timC.text = draft['tim'] ?? '';
      _pengawasC.text = draft['pengawas'] ?? '';
      _statusTerpilih = draft['status'] ?? 'Aktif';
    });
  }

  Future<void> _simpanDraft() async {
    await FormDraftService.simpanDraft(FormDraftService.keyWizardProyek, {
      'nama': _namaC.text,
      'deskripsi': _deskripsiC.text,
      'lokasi': _lokasiC.text,
      'mulai': _mulaiC.text,
      'selesai': _selesaiC.text,
      'tim': _timC.text,
      'pengawas': _pengawasC.text,
      'status': _statusTerpilih,
    });
  }

  void _onVmChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    if (_submitted) {
      FormDraftService.hapusDraft(FormDraftService.keyWizardProyek);
    } else {
      _simpanDraft();
    }
    _vm.removeListener(_onVmChanged);
    _vm.dispose();
    for (final c in [
      _namaC, _deskripsiC, _lokasiC, _mulaiC, _selesaiC, _timC, _pengawasC,
      _namaPekerjaanC, _deskripsiPekerjaanC, _lokasiPekerjaanC,
      _mulaiPekerjaanC, _selesaiPekerjaanC, _pelaksanaPekerjaanC, _pengawasPekerjaanC,
      _namaKegiatanC, _waktuKegiatanC, _pelaksanaKegiatanC,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Future<void> _pilihTanggal(TextEditingController c) async {
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

  Future<void> _pilihWaktu(TextEditingController c) async {
    final now = TimeOfDay.now();
    final selected = await showTimePicker(
      context: context,
      initialTime: now,
    );
    if (selected != null) {
      c.text = '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
    }
  }

  void _tampilkanError(String pesan) => ToastHelper.showError(context, pesan);

  // ─── Aksi Navigasi ────────────────────────────────────────────────────────

  Future<void> _lanjut() async {
    final langkah = _vm.langkahSaatIni;

    if (langkah == 0) {
      final err = _vm.pindahKeLangkahBerikutnya(
        nama: _namaC.text,
        deskripsi: _deskripsiC.text,
        lokasi: _lokasiC.text,
        mulai: _mulaiC.text,
        selesai: _selesaiC.text,
        pelaksana: _timC.text,
        pengawas: _pengawasC.text,
        status: _statusTerpilih,
      );
      if (err != null) _tampilkanError(err);
      return;
    }

    if (langkah == 1) {
      final err = _vm.pindahKeLangkahBerikutnya();
      if (err != null) _tampilkanError(err);
      return;
    }

    if (langkah == 2) {
      // Validasi aktivitas, lalu pindah ke Step 3: Konfirmasi
      final err = _vm.pindahKeLangkahBerikutnya();
      if (err != null) _tampilkanError(err);
      return;
    }

    // Langkah 3: Konfirmasi → submit
    final err = _vm.bisaKirim();
    if (err != null) {
      _tampilkanError(err);
      return;
    }
    _vm.aturStatusMenyimpan(true);
    _submitted = true;

    try {
      final proyek = _vm.bangunProyek();
      await widget.onCreate(proyek);
      if (mounted) {
        Navigator.pop(context);
        ToastHelper.showSuccess(context, 'Proyek berhasil dibuat');
      }
    } catch (e) {
      _submitted = false;
      if (mounted) {
        _tampilkanError('Gagal membuat proyek: $e');
        _vm.aturStatusMenyimpan(false);
      }
    }
  }

  void _kembali() {
    if (_vm.langkahSaatIni == 0) {
      Navigator.pop(context);
    } else {
      _vm.pindahKeLangkahSebelumnya();
    }
  }

  void _tambahPekerjaan() {
    final err = _vm.tambahPekerjaanSementara(
      nama: _namaPekerjaanC.text,
      deskripsi: _deskripsiPekerjaanC.text,
      tempat: _lokasiPekerjaanC.text,
      tanggalMulai: _mulaiPekerjaanC.text,
      tanggalSelesai: _selesaiPekerjaanC.text,
      pelaksana: _pelaksanaPekerjaanC.text,
      pengawas: _pengawasPekerjaanC.text,
    );
    if (err != null) {
      _tampilkanError(err);
      return;
    }
    for (final c in [
      _namaPekerjaanC, _deskripsiPekerjaanC, _lokasiPekerjaanC,
      _mulaiPekerjaanC, _selesaiPekerjaanC, _pelaksanaPekerjaanC,
      _pengawasPekerjaanC,
    ]) {
      c.clear();
    }
  }

  void _tambahKegiatan() {
    final err = _vm.tambahAktivitasSementara(
      namaKegiatan: _namaKegiatanC.text,
      waktuPelaksanaan: _waktuKegiatanC.text,
      pelaksana: _pelaksanaKegiatanC.text,
    );
    if (err != null) {
      _tampilkanError(err);
      return;
    }
    for (final c in [_namaKegiatanC, _waktuKegiatanC, _pelaksanaKegiatanC]) {
      c.clear();
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: ResponsiveHelper.dialogWidth(context, max: 760),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderLangkah(_vm.langkahSaatIni),
              const SizedBox(height: 20),
              // ── Fragment per langkah ──
              if (_vm.langkahSaatIni == 0) _DataProyekFragment(
                namaC: _namaC,
                deskripsiC: _deskripsiC,
                lokasiC: _lokasiC,
                mulaiC: _mulaiC,
                selesaiC: _selesaiC,
                timC: _timC,
                pengawasC: _pengawasC,
                statusTerpilih: _statusTerpilih,
                onStatusChanged: (val) => setState(() => _statusTerpilih = val),
                onPilihTanggal: _pilihTanggal,
              ),
              if (_vm.langkahSaatIni == 1) _TambahPekerjaanFragment(
                vm: _vm,
                namaPekerjaanC: _namaPekerjaanC,
                deskripsiPekerjaanC: _deskripsiPekerjaanC,
                lokasiPekerjaanC: _lokasiPekerjaanC,
                mulaiPekerjaanC: _mulaiPekerjaanC,
                selesaiPekerjaanC: _selesaiPekerjaanC,
                pelaksanaPekerjaanC: _pelaksanaPekerjaanC,
                pengawasPekerjaanC: _pengawasPekerjaanC,
              onPilihTanggal: _pilihTanggal,
                onTambahPekerjaan: _tambahPekerjaan,
              ),
              if (_vm.langkahSaatIni == 2) _TambahAktivitasFragment(
                vm: _vm,
                namaKegiatanC: _namaKegiatanC,
                waktuKegiatanC: _waktuKegiatanC,
                pelaksanaKegiatanC: _pelaksanaKegiatanC,
                onTambahKegiatan: _tambahKegiatan,
                onPilihTanggal: _pilihWaktu,
              ),
              if (_vm.langkahSaatIni == 3) _KonfirmasiFragment(vm: _vm),
              const SizedBox(height: 20),
              _buildTombolNavigasi(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header Langkah (Step Indicator) ─────────────────────────────────────

  Widget _buildHeaderLangkah(int step) {
    const totalStep = CreateProjectWizardViewModel.totalLangkah;
    const labelLangkah = ['Data Proyek', 'Tambah Pekerjaan', 'Tambah Aktivitas', 'Konfirmasi'];

    Widget lingkaran(int i) {
      final aktif = step >= i;
      final selesai = step > i;
      return Container(
        width: 32, height: 32,
          decoration: BoxDecoration(
            color: aktif ? DesignColors.primary : Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: selesai
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : Text('${i + 1}',
                  style: TextStyle(
                    color: aktif ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.bold,
                  )),
        ),
      );
    }

    Widget garis(bool aktif) => Container(
          width: 40, height: 2,
          color: aktif ? DesignColors.primary : Colors.grey.shade300,
        );

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < totalStep; i++) ...[
              if (i > 0) ...[
                const SizedBox(width: 8),
                garis(step > i - 1),
                const SizedBox(width: 8),
              ],
              lingkaran(i),
              const SizedBox(width: 6),
              Text(labelLangkah[i],
                  style: TextStyle(
                    color: step >= i ? DesignColors.primary : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  )),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Tombol Navigasi ──────────────────────────────────────────────────────

  Widget _buildTombolNavigasi() {
    final langkah = _vm.langkahSaatIni;
    final isLangkahTerakhir = langkah == CreateProjectWizardViewModel.totalLangkah - 1;

    return Row(children: [
      Expanded(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          onPressed: _kembali,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (langkah > 0) const Icon(Icons.arrow_back, size: 18, color: Colors.black87),
              if (langkah > 0) const SizedBox(width: 8),
              Text(langkah == 0 ? 'Batal' : 'Kembali',
                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _vm.sedangMenyimpan ? null : _lanjut,
          child: _vm.sedangMenyimpan
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLangkahTerakhir) const Icon(Icons.check_circle_outline, size: 18),
                    if (isLangkahTerakhir) const SizedBox(width: 8),
                    Text(isLangkahTerakhir ? 'Buat Proyek' : 'Selanjutnya',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (!isLangkahTerakhir) const SizedBox(width: 8),
                    if (!isLangkahTerakhir) const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
        ),
      ),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FRAGMENT: Step 0 — Data Proyek
// ═══════════════════════════════════════════════════════════════════════════

class _DataProyekFragment extends StatelessWidget {
  const _DataProyekFragment({
    required this.namaC,
    required this.deskripsiC,
    required this.lokasiC,
    required this.mulaiC,
    required this.selesaiC,
    required this.timC,
    required this.pengawasC,
    required this.statusTerpilih,
    required this.onStatusChanged,
    required this.onPilihTanggal,
  });

  final TextEditingController namaC;
  final TextEditingController deskripsiC;
  final TextEditingController lokasiC;
  final TextEditingController mulaiC;
  final TextEditingController selesaiC;
  final TextEditingController timC;
  final TextEditingController pengawasC;
  final String statusTerpilih;
  final ValueChanged<String> onStatusChanged;
  final Future<void> Function(TextEditingController) onPilihTanggal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 1 - Data Proyek',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
          'Isikan informasi dasar proyek Anda',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 28),
        _inputField('Nama Proyek *', namaC, autofocus: true, hintText: 'Masukkan nama proyek'),
        _inputField('Deskripsi *', deskripsiC, maxLines: 3, hintText: 'Deskripsikan proyek'),
        _inputField('Tempat *', lokasiC, hintText: 'Lokasi proyek'),
        
        // ── Tanggal Mulai & Selesai ──
        Row(
          children: [
            Expanded(
              child: _inputField(
                'Tanggal Mulai *',
                mulaiC,
                isDate: true,
                onTap: () => onPilihTanggal(mulaiC),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _inputField(
                'Tanggal Selesai *',
                selesaiC,
                isDate: true,
                onTap: () => onPilihTanggal(selesaiC),
              ),
            ),
          ],
        ),
        
        _inputField('Pelaksana Proyek *', timC, hintText: 'Nama tim/pelaksana'),
        _inputField('Supervisor Proyek *', pengawasC, hintText: 'Nama supervisor'),
        
        const SizedBox(height: 16),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Status Proyek *',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: statusTerpilih,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE8EAED),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBDC1C6), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBDC1C6), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: ['Aktif', 'Selesai', 'Tertunda']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
            if (val != null) onStatusChanged(val);
          },
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FRAGMENT: Step 1 — Tambah Pekerjaan
// ═══════════════════════════════════════════════════════════════════════════

class _TambahPekerjaanFragment extends StatelessWidget {
  const _TambahPekerjaanFragment({
    required this.vm,
    required this.namaPekerjaanC,
    required this.deskripsiPekerjaanC,
    required this.lokasiPekerjaanC,
    required this.mulaiPekerjaanC,
    required this.selesaiPekerjaanC,
    required this.pelaksanaPekerjaanC,
    required this.pengawasPekerjaanC,
    required this.onPilihTanggal,
    required this.onTambahPekerjaan,
  });

  final CreateProjectWizardViewModel vm;
  final TextEditingController namaPekerjaanC;
  final TextEditingController deskripsiPekerjaanC;
  final TextEditingController lokasiPekerjaanC;
  final TextEditingController mulaiPekerjaanC;
  final TextEditingController selesaiPekerjaanC;
  final TextEditingController pelaksanaPekerjaanC;
  final TextEditingController pengawasPekerjaanC;
  final Future<void> Function(TextEditingController) onPilihTanggal;
  final VoidCallback onTambahPekerjaan;

  @override
  Widget build(BuildContext context) {
    final daftarPekerjaan = vm.pekerjaanSementara;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 2 - Tambah Pekerjaan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          'Tambahkan pekerjaan untuk proyek "${vm.namaProyek}"',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 28),
        _inputField('Nama Pekerjaan *', namaPekerjaanC, hintText: 'Masukkan nama pekerjaan'),
        _inputField('Deskripsi *', deskripsiPekerjaanC, maxLines: 3, hintText: 'Deskripsikan pekerjaan'),
        _inputField('Tempat *', lokasiPekerjaanC, hintText: 'Lokasi pekerjaan'),
        
        // ── Tanggal Mulai & Selesai ──
        Row(
          children: [
            Expanded(
              child: _inputField(
                'Tanggal Mulai *',
                mulaiPekerjaanC,
                isDate: true,
                onTap: () => onPilihTanggal(mulaiPekerjaanC),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _inputField(
                'Tanggal Selesai *',
                selesaiPekerjaanC,
                isDate: true,
                onTap: () => onPilihTanggal(selesaiPekerjaanC),
              ),
            ),
          ],
        ),
        
        // ── Pelaksana & Supervisor ──
        Row(
          children: [
            Expanded(
              child: _inputField(
                'Pelaksana *',
                pelaksanaPekerjaanC,
                hintText: 'Nama pelaksana',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _inputField(
                'Supervisor *',
                pengawasPekerjaanC,
                hintText: 'Nama supervisor',
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            onPressed: onTambahPekerjaan,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Tambah Pekerjaan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
        if (daftarPekerjaan.isNotEmpty) _buildDaftarPekerjaan(daftarPekerjaan),
      ],
    );
  }

  Widget _buildDaftarPekerjaan(List<ItemPekerjaan> pekerjaan) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignColors.statusActiveBg,
        border: Border.all(color: DesignColors.borderMuted),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.check_circle_outline, color: DesignColors.statusActive, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text('Pekerjaan yang sudah ditambahkan (${pekerjaan.length})',
                  style: const TextStyle(color: DesignColors.statusActive, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ]),
          const SizedBox(height: 12),
          ...List.generate(pekerjaan.length, (i) {
            final p = pekerjaan[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: DesignColors.borderMuted),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                const Icon(Icons.work_outline, color: DesignColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(p.deskripsi, style: const TextStyle(color: DesignColors.hint, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: DesignColors.danger, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => vm.hapusPekerjaanSementara(i),
                ),
              ]),
            );
          }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FRAGMENT: Step 2 — Tambah Aktivitas
// ═══════════════════════════════════════════════════════════════════════════

class _TambahAktivitasFragment extends StatelessWidget {
  const _TambahAktivitasFragment({
    required this.vm,
    required this.namaKegiatanC,
    required this.waktuKegiatanC,
    required this.pelaksanaKegiatanC,
    required this.onTambahKegiatan,
    required this.onPilihTanggal,
  });

  final CreateProjectWizardViewModel vm;
  final TextEditingController namaKegiatanC;
  final TextEditingController waktuKegiatanC;
  final TextEditingController pelaksanaKegiatanC;
  final VoidCallback onTambahKegiatan;
  final Future<void> Function(TextEditingController) onPilihTanggal;

  @override
  Widget build(BuildContext context) {
    final pekerjaan = vm.pekerjaanSementara;
    final idxTerpilih = vm.indeksPekerjaanTerpilih;
    final kegiatanSaatIni = vm.aktivitasPekerjaanSaatIni;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 3 - Tambah Aktivitas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Tambahkan aktivitas untuk setiap pekerjaan',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 28),
        
        // ── Pilih Pekerjaan ──
        const Text(
          'Pilih Pekerjaan *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: idxTerpilih < pekerjaan.length ? idxTerpilih : 0,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: const Color(0xFFE8EAED),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBDC1C6), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFBDC1C6), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
            ),
          ),
          items: List.generate(pekerjaan.length, (i) {
            final jumlah = vm.jumlahAktivitasUntukPekerjaan(i);
            final label = jumlah == 0
                ? '${pekerjaan[i].nama} (belum ada aktivitas)'
                : '${pekerjaan[i].nama} ($jumlah aktivitas)';
            return DropdownMenuItem(value: i, child: Text(label));
          }),
          onChanged: (val) {
            if (val != null) vm.aturIndeksPekerjaanTerpilih(val);
          },
        ),
        const SizedBox(height: 24),
        
        // ── Nama Aktivitas ──
        _inputField('Nama Aktivitas *', namaKegiatanC),
        
        // ── Waktu Pelaksanaan & Pelaksana (Side by side) ──
        Row(
          children: [
            Expanded(
              child: _inputField(
                'Waktu Pelaksanaan *',
                waktuKegiatanC,
                isTime: true,
                onTap: () => onPilihTanggal(waktuKegiatanC),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _inputField(
                'Pelaksana *',
                pelaksanaKegiatanC,
                hintText: 'Nama pelaksana',
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            onPressed: onTambahKegiatan,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Tambah Aktivitas',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
        if (kegiatanSaatIni.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DesignColors.statusActiveBg,
              border: Border.all(color: DesignColors.borderMuted),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.check_circle_outline, color: DesignColors.statusActive, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Aktivitas untuk "${pekerjaan[idxTerpilih].nama}" (${kegiatanSaatIni.length})',
                      style: const TextStyle(color: DesignColors.statusActive, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                ...List.generate(kegiatanSaatIni.length, (i) {
                  final k = kegiatanSaatIni[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(k.namaKegiatan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('${k.pelaksana} • ${k.waktuPelaksanaan}',
                                style: const TextStyle(color: DesignColors.hint, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: DesignColors.danger, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => vm.hapusAktivitasSementara(idxTerpilih, i),
                      ),
                    ]),
                  );
                }),
              ],
            ),
          ),
        const SizedBox(height: 24),
        _buildRingkasanAktivitas(),
      ],
    );
  }

  Widget _buildRingkasanAktivitas() {
    final pekerjaan = vm.pekerjaanSementara;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: DesignColors.borderMuted),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: DesignColors.surfaceSoft,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8), topRight: Radius.circular(8),
              ),
            ),
            child: const Text('Ringkasan Aktivitas',
                style: TextStyle(color: DesignColors.textPrimary, fontWeight: FontWeight.bold)),
          ),
          ...List.generate(pekerjaan.length, (i) {
            final jumlah = vm.jumlahAktivitasUntukPekerjaan(i);
            final adaKegiatan = jumlah > 0;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: adaKegiatan ? Colors.transparent : DesignColors.brandSoft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      pekerjaan[i].nama,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: adaKegiatan ? DesignColors.textPrimary : DesignColors.danger,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: adaKegiatan ? DesignColors.statusActiveBg : DesignColors.dangerSoft,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(children: [
                      Icon(adaKegiatan ? Icons.check : Icons.close,
                          size: 14,
                          color: adaKegiatan ? DesignColors.statusActive : DesignColors.danger),
                      const SizedBox(width: 4),
                      Text(adaKegiatan ? '$jumlah aktivitas' : 'Belum ada',
                          style: TextStyle(
                            color: adaKegiatan ? DesignColors.statusActive : DesignColors.danger,
                            fontSize: 12,
                          )),
                    ]),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FRAGMENT: Step 3 — Konfirmasi (Summary)
// Terinspirasi dari SummaryFragment — menampilkan ringkasan semua data
// sebelum user menekan "Buat Proyek"
// ═══════════════════════════════════════════════════════════════════════════

class _KonfirmasiFragment extends StatelessWidget {
  const _KonfirmasiFragment({required this.vm});

  final CreateProjectWizardViewModel vm;

  @override
  Widget build(BuildContext context) {
    final pekerjaan = vm.pekerjaanSementara;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 4 - Konfirmasi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text(
          'Periksa kembali semua data sebelum membuat proyek.',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 20),

        // ── Bagian: Info Proyek ──
        _sectionHeader(Icons.folder_outlined, 'Informasi Proyek', Colors.indigo),
        const SizedBox(height: 12),
        _infoCard([
          _infoRow('Nama Proyek', vm.namaProyek),
          _infoRow('Deskripsi', vm.deskripsiProyek),
          _infoRow('Lokasi', vm.lokasiProyek),
          _infoRow('Tanggal Mulai', vm.tanggalMulaiProyek),
          _infoRow('Tanggal Selesai', vm.tanggalSelesaiProyek),
          _infoRow('Pelaksana', vm.pelaksanaProyek),
          _infoRow('Supervisor', vm.pengawasProyek),
          _infoRow('Status', vm.statusProyek),
        ]),
        const SizedBox(height: 20),

        // ── Bagian: Daftar Pekerjaan + Aktivitas ──
        _sectionHeader(Icons.work_outline, 'Pekerjaan & Aktivitas (${pekerjaan.length})', Colors.orange.shade700),
        const SizedBox(height: 12),

        if (pekerjaan.isEmpty)
          _emptyInfo('Belum ada pekerjaan')
        else
          ...List.generate(pekerjaan.length, (i) {
            final p = pekerjaan[i];
            final aktivitas = vm.aktivitasSementara[i] ?? [];
            return _pekerjaanCard(p, aktivitas, i + 1);
          }),

        const SizedBox(height: 20),

        // ── Peringatan jika ada pekerjaan tanpa aktivitas ──
        if (_adaPekerjaanTanpaAktivitas(pekerjaan))
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              border: Border.all(color: const Color(0xFFFFE082)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFF57F17), size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ada pekerjaan yang belum memiliki aktivitas. Kembali ke langkah sebelumnya untuk menambahkan aktivitas.',
                  style: TextStyle(color: Color(0xFFF57F17), fontSize: 13),
                ),
              ),
            ]),
          ),
      ],
    );
  }

  bool _adaPekerjaanTanpaAktivitas(List<ItemPekerjaan> pekerjaan) {
    for (var i = 0; i < pekerjaan.length; i++) {
      if ((vm.aktivitasSementara[i]?.isEmpty ?? true)) return true;
    }
    return false;
  }

  // ─── Sub-widgets ──────────────────────────────────────────────────────

  Widget _sectionHeader(IconData icon, String label, Color color) {
    return Row(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 8),
      Text(label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          )),
    ]);
  }

  Widget _infoCard(List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows),
    );
  }

  /// Satu baris info label: nilai — mirip `item()` di SummaryFragment
  Widget _infoRow(String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          const Text(': ', style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              nilai.isEmpty ? '-' : nilai,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pekerjaanCard(ItemPekerjaan p, List<ItemKegiatan> aktivitas, int nomor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
            color: aktivitas.isEmpty ? DesignColors.brandBorder : DesignColors.borderMuted),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header pekerjaan
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: aktivitas.isEmpty
                  ? DesignColors.brandSoft
                  : DesignColors.statusActiveBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10),
              ),
            ),
            child: Row(children: [
              const Icon(Icons.work_outline, size: 16, color: DesignColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text('$nomor. ${p.nama}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: aktivitas.isEmpty ? DesignColors.dangerSoft : DesignColors.statusActiveBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  aktivitas.isEmpty ? 'Belum ada aktivitas' : '${aktivitas.length} aktivitas',
                  style: TextStyle(
                    fontSize: 11,
                    color: aktivitas.isEmpty ? DesignColors.danger : DesignColors.statusActive,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ]),
          ),
          // Detail pekerjaan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('Lokasi', p.lokasi),
                _infoRow('Periode', '${p.tanggalMulai} s/d ${p.tanggalSelesai}'),
                _infoRow('Pelaksana', p.pelaksana),
                _infoRow('Supervisor', p.pengawas),
              ],
            ),
          ),
          // Daftar aktivitas
          if (aktivitas.isNotEmpty) ...[
            const Divider(height: 1, color: DesignColors.borderMuted),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Aktivitas:',
                      style: TextStyle(
                          fontSize: 12,
                          color: DesignColors.hint,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  ...List.generate(aktivitas.length, (j) {
                    final k = aktivitas[j];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.circle, size: 6, color: DesignColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(k.namaKegiatan,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600, fontSize: 13)),
                                Text('${k.pelaksana} • ${k.waktuPelaksanaan}',
                                    style: const TextStyle(
                                        color: DesignColors.hint, fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyInfo(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Shared helper — input field widget dipakai oleh semua fragment
// ═══════════════════════════════════════════════════════════════════════════

Widget _inputField(
  String label,
  TextEditingController controller, {
  int maxLines = 1,
  bool isDate = false,
  bool isTime = false,
  bool autofocus = false,
  VoidCallback? onTap,
  String? hintText,
}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            autofocus: autofocus,
            maxLines: maxLines,
            readOnly: isDate || isTime,
            onTap: onTap,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hintText ?? 'Masukkan $label',
              hintStyle: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: const Color(0xFFE8EAED),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFBDC1C6), width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFBDC1C6), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: isDate
                    ? const Icon(Icons.calendar_today, size: 18, color: Color(0xFF3498DB))
                    : (isTime ? const Icon(Icons.access_time, size: 18, color: Color(0xFF3498DB)) : null),
              ),
            ),
          ),
        ],
      ),
    );

/// Helper function — dipanggil dari [view_project_page.dart].
void showCreateProjectWizard(
  BuildContext context,
  Future<void> Function(Proyek) onCreate,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => CreateProjectWizardDialog(onCreate: onCreate),
  );
}
