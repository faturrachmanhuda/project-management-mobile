import 'package:flutter/material.dart';
import '../widgets/overflow_input_field.dart';
import '../utils/design_tokens.dart';

/// Demo page untuk input field dengan overflow indicator
/// Sesuai dengan screenshot yang menunjukkan visual overflow
class OverflowDemoPage extends StatefulWidget {
  const OverflowDemoPage({super.key});

  @override
  State<OverflowDemoPage> createState() => _OverflowDemoPageState();
}

class _OverflowDemoPageState extends State<OverflowDemoPage> {
  final _pekerjaanController = TextEditingController(
    text: 'sdffffffffffffffffffffffffffffffffffffffffffffff',
  );
  final _aktivitasController = TextEditingController();
  
  String? _selectedPekerjaan;

  @override
  void dispose() {
    _pekerjaanController.dispose();
    _aktivitasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overflow Input Demo'),
        backgroundColor: DesignColors.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Input Field dengan Overflow Indicator',
              style: AppTypography.h2.copyWith(
                color: DesignColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ketika teks melebihi lebar field, akan muncul indicator visual seperti garis kuning-hitam.',
              style: AppTypography.bodySmall.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Input field dengan teks panjang (akan show overflow)
            OverflowInputField(
              labelText: 'Pilih Pekerjaan',
              controller: _pekerjaanController,
              hintText: 'Masukkan atau pilih pekerjaan',
              required: true,
              fieldWidth: 350, // Batasi lebar untuk memaksa overflow
            ),
            
            const SizedBox(height: 24),
            
            // Input field normal
            OverflowInputField(
              labelText: 'Nama Aktivitas',
              controller: _aktivitasController,
              hintText: 'Masukkan nama aktivitas',
              required: true,
              fieldWidth: 350,
            ),
            
            const SizedBox(height: 24),
            
            // Dropdown dengan option panjang
            OverflowDropdownField<String>(
              labelText: 'Pilih Pekerjaan dari Dropdown',
              hintText: 'Pilih salah satu',
              value: _selectedPekerjaan,
              required: true,
              fieldWidth: 350,
              items: const [
                DropdownMenuItem(
                  value: 'pekerjaan1',
                  child: Text('sdfasfdsadf (belum ada aktivitas) - Pekerjaan dengan nama yang sangat panjang sekali'),
                ),
                DropdownMenuItem(
                  value: 'pekerjaan2', 
                  child: Text('Implementation System Control - Sistem kontrol implementasi yang kompleks dan membutuhkan waktu lama'),
                ),
                DropdownMenuItem(
                  value: 'pekerjaan3',
                  child: Text('Quality Assurance Testing Protocol - Protokol pengujian kualitas yang menyeluruh'),
                ),
                DropdownMenuItem(
                  value: 'pekerjaan4',
                  child: Text('Singkat'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPekerjaan = value;
                });
              },
            ),
            
            const SizedBox(height: 32),
            
            // Demo dengan berbagai lebar
            Text(
              'Demo Berbagai Lebar Field',
              style: AppTypography.h3.copyWith(
                color: DesignColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Lebar 200px - akan overflow
            OverflowInputField(
              labelText: 'Field Sempit (200px)',
              initialValue: 'Teks yang akan overflow pada field sempit ini',
              fieldWidth: 200,
            ),
            
            const SizedBox(height: 16),
            
            // Lebar 300px - mungkin overflow
            OverflowInputField(
              labelText: 'Field Sedang (300px)',
              initialValue: 'Teks dengan panjang sedang untuk testing',
              fieldWidth: 300,
            ),
            
            const SizedBox(height: 16),
            
            // Lebar 400px - tidak overflow
            OverflowInputField(
              labelText: 'Field Lebar (400px)',
              initialValue: 'Teks pendek',
              fieldWidth: 400,
            ),
            
            const SizedBox(height: 32),
            
            // Info panel
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DesignColors.accent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(Radii.medium),
                border: Border.all(
                  color: DesignColors.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: DesignColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Cara Kerja Overflow Indicator',
                        style: AppTypography.labelMedium.copyWith(
                          color: DesignColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Indicator muncul ketika teks melebihi lebar field\n'
                    '• Garis kuning-hitam diagonal menunjukkan ada konten tersembunyi\n'
                    '• Field tetap dapat di-scroll horizontal untuk melihat seluruh teks\n'
                    '• Dropdown juga mendeteksi overflow pada selected text',
                    style: AppTypography.bodySmall.copyWith(
                      color: DesignColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Button untuk test programmatic text change
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _pekerjaanController.text = 'Teks pendek';
                  },
                  child: const Text('Set Teks Pendek'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    _pekerjaanController.text = 'sdfasfdsadf (belum ada aktivitas) - Teks yang sangat panjang dan akan menyebabkan overflow pada field input';
                  },
                  child: const Text('Set Teks Panjang'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Form dialog yang menggunakan overflow input fields
class OverflowFormDialog extends StatefulWidget {
  const OverflowFormDialog({super.key});

  @override
  State<OverflowFormDialog> createState() => _OverflowFormDialogState();
}

class _OverflowFormDialogState extends State<OverflowFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  
  String? _selectedKategori;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Form dengan Overflow Detection',
                style: AppTypography.h3.copyWith(
                  color: DesignColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              OverflowInputField(
                labelText: 'Nama Pekerjaan',
                controller: _namaController,
                hintText: 'Masukkan nama pekerjaan yang mungkin panjang',
                required: true,
                fieldWidth: 320, // Sesuaikan dengan lebar dialog
              ),
              
              const SizedBox(height: 16),
              
              OverflowDropdownField<String>(
                labelText: 'Kategori Pekerjaan',
                hintText: 'Pilih kategori',
                value: _selectedKategori,
                required: true,
                fieldWidth: 320,
                items: const [
                  DropdownMenuItem(
                    value: 'implementasi',
                    child: Text('Implementation System - Pembangunan sistem baru yang kompleks'),
                  ),
                  DropdownMenuItem(
                    value: 'maintenance',
                    child: Text('Maintenance & Support - Pemeliharaan sistem existing'),
                  ),
                  DropdownMenuItem(
                    value: 'testing',
                    child: Text('Quality Assurance Testing - Pengujian menyeluruh'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedKategori = value;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              OverflowInputField(
                labelText: 'Deskripsi',
                controller: _deskripsiController,
                hintText: 'Deskripsi singkat',
                maxLines: 3,
                fieldWidth: 320,
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
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        Navigator.pop(context, {
                          'nama': _namaController.text,
                          'kategori': _selectedKategori,
                          'deskripsi': _deskripsiController.text,
                        });
                      }
                    },
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
    _deskripsiController.dispose();
    super.dispose();
  }
}