import 'package:flutter/material.dart';
import '../widgets/overflow_input_field.dart';
import '../widgets/form_field_helpers.dart';
import '../utils/design_tokens.dart';
import '../models/job.dart';

/// Contoh implementasi praktis form dengan overflow detection
/// Menggunakan model existing dan sesuai dengan screenshot
class PracticalOverflowForm extends StatefulWidget {
  final Pekerjaan? existingWork;
  final String projectId;
  final String projectTitle;
  
  const PracticalOverflowForm({
    super.key,
    this.existingWork,
    required this.projectId,
    required this.projectTitle,
  });

  @override
  State<PracticalOverflowForm> createState() => _PracticalOverflowFormState();
}

class _PracticalOverflowFormState extends State<PracticalOverflowForm> 
    with OverflowFormMixin {
  
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for form fields
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _tanggalMulaiController = TextEditingController();
  final _tanggalSelesaiController = TextEditingController();
  final _pelaksanaController = TextEditingController();
  final _pengawasController = TextEditingController();
  
  String? _selectedKategori;
  String? _selectedPrioritas;
  bool _isLoading = false;

  // Field width untuk konsistensi
  static const double _fieldWidth = 380.0;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.existingWork != null) {
      final work = widget.existingWork!;
      _namaController.text = work.nama;
      _deskripsiController.text = work.deskripsi;
      _lokasiController.text = work.lokasi;
      _tanggalMulaiController.text = work.tanggalMulai;
      _tanggalSelesaiController.text = work.tanggalSelesai;
      _pelaksanaController.text = work.pelaksana;
      _pengawasController.text = work.pengawas;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _tanggalMulaiController.dispose();
    _tanggalSelesaiController.dispose();
    _pelaksanaController.dispose();
    _pengawasController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!validateForm(_formKey)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      final newWork = Pekerjaan(
        id: widget.existingWork?.id ?? '',
        idProyek: widget.projectId,
        judulProyek: widget.projectTitle,
        nama: _namaController.text,
        deskripsi: _deskripsiController.text,
        lokasi: _lokasiController.text,
        tanggalMulai: _tanggalMulaiController.text,
        tanggalSelesai: _tanggalSelesaiController.text,
        pelaksana: _pelaksanaController.text,
        pengawas: _pengawasController.text,
      );

      showFormMessage(
        widget.existingWork != null 
            ? 'Pekerjaan berhasil diperbarui!' 
            : 'Pekerjaan berhasil dibuat!',
      );
      
      Navigator.pop(context, newWork);
      
    } catch (e) {
      showFormMessage('Gagal menyimpan pekerjaan: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existingWork != null ? 'Edit Pekerjaan' : 'Tambah Pekerjaan',
              style: AppTypography.h3.copyWith(
                fontSize: 18,
                color: DesignColors.textPrimary,
              ),
            ),
            Text(
              widget.projectTitle,
              style: AppTypography.bodySmall.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
          ],
        ),
        backgroundColor: DesignColors.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      
      body: buildOverflowForm(
        formKey: _formKey,
        children: [
          
          // Info panel tentang overflow
          FormFieldHelpers.createInfoPanel(
            title: 'Form dengan Overflow Detection',
            message: 'Ketika teks input melebihi lebar field, akan muncul indicator visual (garis kuning-hitam) '
                    'seperti yang terlihat pada field "Pilih Pekerjaan" di screenshot.',
            icon: Icons.visibility_outlined,
          ),
          
          // Section 1: Informasi Dasar
          FormFieldHelpers.createFormSection(
            title: 'Informasi Dasar Pekerjaan',
            fields: [
              // Field seperti di screenshot - dengan teks panjang akan overflow
              FormFieldHelpers.createOverflowTextField(
                label: 'Pilih Pekerjaan',
                controller: _namaController,
                hint: 'sdfasfdsadf (belum ada aktivitas) - akan muncul overflow indicator',
                icon: Icons.work_outline,
                required: true,
                fieldWidth: _fieldWidth,
              ),
              
              FormFieldHelpers.createOverflowDropdown<String>(
                label: 'Kategori Pekerjaan',
                items: const [
                  DropdownMenuItem(
                    value: 'implementasi',
                    child: Text('sdfasfdsadf (belum ada aktivitas) - Implementasi sistem yang sangat kompleks dan membutuhkan waktu lama'),
                  ),
                  DropdownMenuItem(
                    value: 'maintenance',
                    child: Text('Maintenance & Support - Pemeliharaan sistem yang sudah ada dengan berbagai komponen'),
                  ),
                  DropdownMenuItem(
                    value: 'testing',
                    child: Text('Quality Assurance Testing - Pengujian kualitas sistem secara menyeluruh dan komprehensif'),
                  ),
                  DropdownMenuItem(
                    value: 'integration',
                    child: Text('System Integration - Integrasi berbagai sistem dan platform'),
                  ),
                ],
                value: _selectedKategori,
                onChanged: (value) {
                  setState(() {
                    _selectedKategori = value;
                  });
                },
                hint: 'Pilih kategori pekerjaan',
                icon: Icons.category_outlined,
                required: true,
                fieldWidth: _fieldWidth,
              ),
              
              FormFieldHelpers.createOverflowTextField(
                label: 'Deskripsi Pekerjaan',
                controller: _deskripsiController,
                hint: 'Deskripsi lengkap tentang pekerjaan yang akan dikerjakan...',
                icon: Icons.description_outlined,
                maxLines: 4,
                fieldWidth: _fieldWidth,
              ),
            ],
          ),
          
          // Section 2: Lokasi dan Jadwal
          FormFieldHelpers.createFormSection(
            title: 'Lokasi dan Jadwal',
            fields: [
              FormFieldHelpers.createOverflowTextField(
                label: 'Lokasi Pekerjaan',
                controller: _lokasiController,
                hint: 'Alamat lengkap atau koordinat lokasi pelaksanaan pekerjaan',
                icon: Icons.location_on_outlined,
                required: true,
                fieldWidth: _fieldWidth,
              ),
              
              // Two-field row untuk tanggal (responsive)
              FormFieldHelpers.createTwoFieldRow(
                leftField: FormFieldHelpers.createOverflowDateField(
                  label: 'Tanggal Mulai',
                  controller: _tanggalMulaiController,
                  required: true,
                  fieldWidth: (_fieldWidth - 16) / 2,
                ),
                rightField: FormFieldHelpers.createOverflowDateField(
                  label: 'Tanggal Selesai',
                  controller: _tanggalSelesaiController,
                  required: true,
                  fieldWidth: (_fieldWidth - 16) / 2,
                ),
              ),
              
              FormFieldHelpers.createOverflowDropdown<String>(
                label: 'Prioritas Pekerjaan',
                items: const [
                  DropdownMenuItem(
                    value: 'rendah',
                    child: Text('Rendah - Dapat dikerjakan sesuai jadwal normal tanpa tekanan waktu khusus'),
                  ),
                  DropdownMenuItem(
                    value: 'sedang',
                    child: Text('Sedang - Prioritas standar dengan deadline yang cukup fleksibel'),
                  ),
                  DropdownMenuItem(
                    value: 'tinggi',
                    child: Text('Tinggi - Pekerjaan urgent yang memerlukan perhatian dan penanganan khusus'),
                  ),
                  DropdownMenuItem(
                    value: 'kritikal',
                    child: Text('Kritikal - Pekerjaan darurat yang harus segera diselesaikan dalam waktu singkat'),
                  ),
                ],
                value: _selectedPrioritas,
                onChanged: (value) {
                  setState(() {
                    _selectedPrioritas = value;
                  });
                },
                hint: 'Pilih tingkat prioritas',
                icon: Icons.priority_high_outlined,
                fieldWidth: _fieldWidth,
              ),
            ],
          ),
          
          // Section 3: Tim Pelaksana
          FormFieldHelpers.createFormSection(
            title: 'Tim Pelaksana',
            fields: [
              FormFieldHelpers.createTwoFieldRow(
                leftField: FormFieldHelpers.createOverflowTextField(
                  label: 'Nama Pelaksana',
                  controller: _pelaksanaController,
                  hint: 'Tim atau individu yang bertanggung jawab',
                  icon: Icons.person_outline,
                  required: true,
                  fieldWidth: (_fieldWidth - 16) / 2,
                ),
                rightField: FormFieldHelpers.createOverflowTextField(
                  label: 'Nama Pengawas',
                  controller: _pengawasController,
                  hint: 'Supervisor atau manager yang mengawasi',
                  icon: Icons.supervisor_account_outlined,
                  required: true,
                  fieldWidth: (_fieldWidth - 16) / 2,
                ),
              ),
            ],
          ),
          
          // Action buttons
          FormFieldHelpers.createActionButtons(
            onSave: _submitForm,
            onCancel: () => Navigator.pop(context),
            saveLabel: widget.existingWork != null ? 'Perbarui' : 'Simpan',
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}

/// Quick form dialog untuk demonstrasi overflow di dialog
class QuickOverflowFormDialog extends StatefulWidget {
  final String projectId;
  final String projectTitle;
  
  const QuickOverflowFormDialog({
    super.key,
    required this.projectId,
    required this.projectTitle,
  });

  @override
  State<QuickOverflowFormDialog> createState() => _QuickOverflowFormDialogState();
}

class _QuickOverflowFormDialogState extends State<QuickOverflowFormDialog>
    with OverflowFormMixin {
  
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _pelaksanaController = TextEditingController();
  
  String? _selectedPekerjaan;

  void _submit() {
    if (validateForm(_formKey)) {
      final work = Pekerjaan(
        id: '',
        idProyek: widget.projectId,
        judulProyek: widget.projectTitle,
        nama: _namaController.text,
        deskripsi: '',
        lokasi: '',
        tanggalMulai: DateTime.now().toIso8601String().split('T')[0],
        tanggalSelesai: DateTime.now().add(const Duration(days: 7)).toIso8601String().split('T')[0],
        pelaksana: _pelaksanaController.text,
        pengawas: '',
      );
      
      Navigator.pop(context, work);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 450,
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah Pekerjaan Cepat',
                style: AppTypography.h3.copyWith(
                  color: DesignColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.projectTitle,
                style: AppTypography.bodySmall.copyWith(
                  color: DesignColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Dropdown seperti di screenshot
              OverflowDropdownField<String>(
                labelText: 'Pilih Pekerjaan',
                hintText: 'Pilih dari daftar',
                value: _selectedPekerjaan,
                required: true,
                fieldWidth: 380,
                items: const [
                  DropdownMenuItem(
                    value: 'pekerjaan1',
                    child: Text('sdfasfdsadf (belum ada aktivitas) - Pekerjaan dengan nama yang sangat panjang dan akan overflow'),
                  ),
                  DropdownMenuItem(
                    value: 'pekerjaan2',
                    child: Text('Implementation System Control - Sistem kontrol implementasi yang kompleks'),
                  ),
                  DropdownMenuItem(
                    value: 'pekerjaan3',
                    child: Text('Quality Assurance and Testing Protocol - Protokol pengujian kualitas menyeluruh'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPekerjaan = value;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Field seperti di screenshot
              OverflowInputField(
                labelText: 'Nama Aktivitas',
                controller: _namaController,
                hintText: 'Masukkan nama aktivitas (akan show overflow jika panjang)',
                required: true,
                fieldWidth: 380,
                prefixIcon: const Icon(Icons.assignment_outlined),
              ),
              
              const SizedBox(height: 16),
              
              OverflowInputField(
                labelText: 'Pelaksana',
                controller: _pelaksanaController,
                hintText: 'Nama tim atau individu yang mengerjakan',
                required: true,
                fieldWidth: 380,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _namaController.dispose();
    _pelaksanaController.dispose();
    super.dispose();
  }
}