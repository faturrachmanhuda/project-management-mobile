import 'package:flutter/material.dart';
import '../widgets/scrollable_input_field.dart';
import '../widgets/form_utils.dart';
import '../utils/design_tokens.dart';
import '../models/job.dart';

/// Form pekerjaan yang ditingkatkan dengan horizontal scroll
class ImprovedWorkForm extends StatefulWidget {
  final Pekerjaan? existingWork;
  final String projectId;
  final String projectTitle;
  
  const ImprovedWorkForm({
    super.key,
    this.existingWork,
    required this.projectId,
    required this.projectTitle,
  });

  @override
  State<ImprovedWorkForm> createState() => _ImprovedWorkFormState();
}

class _ImprovedWorkFormState extends State<ImprovedWorkForm> 
    with ScrollableFormMixin {
  
  final _formKey = GlobalKey<FormState>();
  
  // Controllers untuk input fields
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
      
      body: SingleChildScrollView(
        child: buildScrollableForm(
          formKey: _formKey,
          minWidth: 600, // Form akan scroll horizontal jika layar < 600px
          padding: const EdgeInsets.all(16),
          children: [
            
            // Info panel
            FormUtils.createInfoPanel(
              title: 'Form dengan Horizontal Scroll',
              message: 'Form ini akan otomatis scroll horizontal jika konten melebihi lebar layar. '
                      'Input field dengan teks panjang juga dapat di-scroll secara individual.',
            ),
            
            // Section 1: Informasi Dasar
            FormUtils.createFormSection(
              title: 'Informasi Dasar Pekerjaan',
              maxWidth: 700,
              fields: [
                FormUtils.createScrollableTextField(
                  label: 'Nama Pekerjaan *',
                  controller: _namaController,
                  hint: 'Masukkan nama pekerjaan (dapat berupa teks panjang yang akan scroll)',
                  icon: Icons.work_outline,
                  required: true,
                ),
                
                FormUtils.createScrollableDropdown<String>(
                  label: 'Kategori Pekerjaan *',
                  items: const [
                    DropdownMenuItem(
                      value: 'implementasi',
                      child: Text('Implementasi System - Pembangunan dan implementasi sistem baru'),
                    ),
                    DropdownMenuItem(
                      value: 'maintenance',
                      child: Text('Maintenance & Support - Pemeliharaan sistem yang sudah ada'),
                    ),
                    DropdownMenuItem(
                      value: 'testing',
                      child: Text('Quality Assurance Testing - Pengujian kualitas dan validasi sistem'),
                    ),
                    DropdownMenuItem(
                      value: 'integration',
                      child: Text('System Integration - Integrasi antar sistem dan platform'),
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
                ),
                
                FormUtils.createScrollableTextField(
                  label: 'Deskripsi Pekerjaan',
                  controller: _deskripsiController,
                  hint: 'Deskripsi lengkap tentang pekerjaan yang akan dikerjakan, '
                        'termasuk scope, deliverables, dan requirements...',
                  icon: Icons.description_outlined,
                  maxLines: 4,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Section 2: Lokasi dan Jadwal
            FormUtils.createFormSection(
              title: 'Lokasi dan Jadwal Pekerjaan',
              fields: [
                FormUtils.createScrollableTextField(
                  label: 'Lokasi Pekerjaan *',
                  controller: _lokasiController,
                  hint: 'Alamat lengkap atau koordinat lokasi pelaksanaan pekerjaan',
                  icon: Icons.location_on_outlined,
                  required: true,
                ),
                
                FormUtils.createTwoColumnRow(
                  leftField: FormUtils.createDateField(
                    label: 'Tanggal Mulai *',
                    controller: _tanggalMulaiController,
                    context: context,
                    required: true,
                  ),
                  rightField: FormUtils.createDateField(
                    label: 'Tanggal Selesai *',
                    controller: _tanggalSelesaiController,
                    context: context,
                    required: true,
                  ),
                ),
                
                FormUtils.createScrollableDropdown<String>(
                  label: 'Prioritas Pekerjaan',
                  items: const [
                    DropdownMenuItem(
                      value: 'rendah',
                      child: Text('Rendah - Dapat dikerjakan sesuai jadwal normal'),
                    ),
                    DropdownMenuItem(
                      value: 'sedang',
                      child: Text('Sedang - Prioritas standar dengan deadline yang fleksibel'),
                    ),
                    DropdownMenuItem(
                      value: 'tinggi',
                      child: Text('Tinggi - Pekerjaan urgent yang memerlukan perhatian khusus'),
                    ),
                    DropdownMenuItem(
                      value: 'kritikal',
                      child: Text('Kritikal - Pekerjaan darurat yang harus segera diselesaikan'),
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
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Section 3: Tim dan Tanggung Jawab
            FormUtils.createFormSection(
              title: 'Tim dan Tanggung Jawab',
              fields: [
                FormUtils.createTwoColumnRow(
                  leftField: FormUtils.createScrollableTextField(
                    label: 'Nama Pelaksana *',
                    controller: _pelaksanaController,
                    hint: 'Tim atau individu yang bertanggung jawab mengerjakan',
                    icon: Icons.person_outline,
                    required: true,
                  ),
                  rightField: FormUtils.createScrollableTextField(
                    label: 'Nama Pengawas *',
                    controller: _pengawasController,
                    hint: 'Supervisor atau manager yang mengawasi pekerjaan',
                    icon: Icons.supervisor_account_outlined,
                    required: true,
                  ),
                ),
              ],
            ),
            
            // Action buttons
            FormUtils.createActionButtons(
              onSave: _submitForm,
              onCancel: () => Navigator.pop(context),
              saveLabel: widget.existingWork != null ? 'Perbarui' : 'Simpan',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog form yang juga mendukung horizontal scroll
class QuickWorkFormDialog extends StatefulWidget {
  final String projectId;
  final String projectTitle;
  
  const QuickWorkFormDialog({
    super.key,
    required this.projectId,
    required this.projectTitle,
  });

  @override
  State<QuickWorkFormDialog> createState() => _QuickWorkFormDialogState();
}

class _QuickWorkFormDialogState extends State<QuickWorkFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _pelaksanaController = TextEditingController();
  
  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
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
        width: 500,
        constraints: const BoxConstraints(maxHeight: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: HorizontalScrollableForm(
            minWidth: 450,
            padding: EdgeInsets.zero,
            children: [
              Column(
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
                  
                  ScrollableInputField(
                    labelText: 'Nama Pekerjaan *',
                    controller: _namaController,
                    hintText: 'Masukkan nama pekerjaan (bisa teks panjang yang akan scroll)',
                    required: true,
                    prefixIcon: const Icon(Icons.work_outline),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ScrollableInputField(
                    labelText: 'Pelaksana *',
                    controller: _pelaksanaController,
                    hintText: 'Nama tim atau individu yang mengerjakan',
                    required: true,
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