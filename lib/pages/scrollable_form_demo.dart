import 'package:flutter/material.dart';
import '../widgets/scrollable_input_field.dart';
import '../utils/design_tokens.dart';

/// Demo page untuk form yang dapat di-scroll horizontal
class ScrollableFormDemo extends StatefulWidget {
  const ScrollableFormDemo({super.key});

  @override
  State<ScrollableFormDemo> createState() => _ScrollableFormDemoState();
}

class _ScrollableFormDemoState extends State<ScrollableFormDemo> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _pelaksanaController = TextEditingController();
  
  String? _selectedPekerjaan;
  String? _selectedStatus;

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _pelaksanaController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form berhasil disimpan!'),
          backgroundColor: DesignColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scrollable Form Demo'),
        backgroundColor: DesignColors.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      
      body: Form(
        key: _formKey,
        child: HorizontalScrollableForm(
          minWidth: 500, // Form akan scroll horizontal jika layar < 500px
          children: [
            // Header
            Text(
              'Form Input dengan Horizontal Scroll',
              style: AppTypography.h2.copyWith(
                color: DesignColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Form ini akan scroll ke kanan jika konten melebihi lebar layar.',
              style: AppTypography.bodySmall.copyWith(
                color: DesignColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Section 1: Informasi Dasar
            ScrollableFormSection(
              title: 'Informasi Dasar Pekerjaan',
              maxWidth: 600,
              children: [
                ScrollableInputField(
                  labelText: 'Nama Pekerjaan *',
                  hintText: 'Masukkan nama pekerjaan (bisa panjang dan akan scroll)',
                  controller: _namaController,
                  required: true,
                  prefixIcon: const Icon(Icons.work_outline),
                ),
                
                ScrollableDropdownField<String>(
                  labelText: 'Pilih Pekerjaan *',
                  hintText: 'Pilih dari daftar',
                  value: _selectedPekerjaan,
                  required: true,
                  prefixIcon: const Icon(Icons.list_alt),
                  items: const [
                    DropdownMenuItem(
                      value: 'pekerjaan1',
                      child: Text('sdfasfdsadf (belum ada aktivitas) - Pekerjaan dengan nama yang sangat panjang'),
                    ),
                    DropdownMenuItem(
                      value: 'pekerjaan2',
                      child: Text('Implementation System - Sistem implementasi yang kompleks dan membutuhkan waktu lama'),
                    ),
                    DropdownMenuItem(
                      value: 'pekerjaan3',
                      child: Text('Quality Assurance Testing - Pengujian kualitas sistem secara menyeluruh'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPekerjaan = value;
                    });
                  },
                ),
                
                ScrollableInputField(
                  labelText: 'Deskripsi Pekerjaan',
                  hintText: 'Deskripsi lengkap pekerjaan yang akan dikerjakan...',
                  controller: _deskripsiController,
                  maxLines: 3,
                  minLines: 2,
                  enableHorizontalScroll: false, // Untuk textarea, disable horizontal scroll
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Section 2: Detail Lokasi dan Pelaksana
            ScrollableFormSection(
              title: 'Detail Lokasi dan Pelaksana',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ScrollableInputField(
                        labelText: 'Lokasi Pekerjaan *',
                        hintText: 'Alamat atau lokasi lengkap pekerjaan',
                        controller: _lokasiController,
                        required: true,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ScrollableInputField(
                        labelText: 'Nama Pelaksana *',
                        hintText: 'Tim atau person yang bertanggung jawab',
                        controller: _pelaksanaController,
                        required: true,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                  ],
                ),
                
                Row(
                  children: [
                    Expanded(
                      child: ScrollableInputField(
                        labelText: 'Tanggal Mulai *',
                        hintText: 'YYYY-MM-DD',
                        keyboardType: TextInputType.datetime,
                        required: true,
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ScrollableInputField(
                        labelText: 'Tanggal Selesai *',
                        hintText: 'YYYY-MM-DD',
                        keyboardType: TextInputType.datetime,
                        required: true,
                        prefixIcon: const Icon(Icons.event_outlined),
                      ),
                    ),
                  ],
                ),
                
                ScrollableDropdownField<String>(
                  labelText: 'Status Pekerjaan *',
                  value: _selectedStatus,
                  required: true,
                  prefixIcon: const Icon(Icons.flag_outlined),
                  items: const [
                    DropdownMenuItem(
                      value: 'belum',
                      child: Text('BELUM - Belum dimulai'),
                    ),
                    DropdownMenuItem(
                      value: 'progress',
                      child: Text('PROGRESS - Sedang dikerjakan'),
                    ),
                    DropdownMenuItem(
                      value: 'selesai',
                      child: Text('SELESAI - Sudah selesai'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Simpan Pekerjaan'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Form sederhana untuk menguji scrollable input field
class SimpleScrollableFormPage extends StatefulWidget {
  const SimpleScrollableFormPage({super.key});

  @override
  State<SimpleScrollableFormPage> createState() => _SimpleScrollableFormPageState();
}

class _SimpleScrollableFormPageState extends State<SimpleScrollableFormPage> {
  final _longTextController = TextEditingController(
    text: 'sdfasfdsadf (belum ada aktivitas) - teks yang sangat panjang dan melebihi lebar layar mobile'
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Scrollable Form'),
        backgroundColor: DesignColors.bg,
        elevation: 0,
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Input Field dengan Horizontal Scroll',
              style: AppTypography.h3.copyWith(
                color: DesignColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Input dengan teks panjang yang dapat di-scroll
            ScrollableInputField(
              labelText: 'Pilih Pekerjaan *',
              controller: _longTextController,
              hintText: 'Field ini akan menampilkan scroll indicator jika teks panjang',
              prefixIcon: const Icon(Icons.work),
              enableHorizontalScroll: true,
            ),
            
            const SizedBox(height: 16),
            
            // Input biasa tanpa scroll
            ScrollableInputField(
              labelText: 'Input Normal',
              hintText: 'Input biasa tanpa scroll horizontal',
              enableHorizontalScroll: false,
              prefixIcon: const Icon(Icons.text_fields),
            ),
            
            const SizedBox(height: 16),
            
            // Dropdown dengan option panjang
            ScrollableDropdownField<String>(
              labelText: 'Dropdown dengan Option Panjang',
              hintText: 'Pilih opsi',
              items: const [
                DropdownMenuItem(
                  value: 'option1',
                  child: Text('sdfasfdsadf (belum ada aktivitas) - Option yang sangat panjang sekali'),
                ),
                DropdownMenuItem(
                  value: 'option2', 
                  child: Text('Implementation Control System - Sistem kontrol implementasi yang kompleks'),
                ),
                DropdownMenuItem(
                  value: 'option3',
                  child: Text('Quality Assurance and Testing Protocol - Protokol pengujian dan jaminan kualitas'),
                ),
              ],
              onChanged: (value) {
                print('Selected: $value');
              },
            ),
            
            const SizedBox(height: 24),
            
            // Contoh dalam Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Form dalam Card',
                      style: AppTypography.labelMedium.copyWith(
                        color: DesignColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    ScrollableInputField(
                      labelText: 'Field dalam Card',
                      controller: TextEditingController(
                        text: 'Teks panjang dalam card yang dapat di-scroll horizontal'
                      ),
                      maxWidth: 280, // Batasi lebar untuk memaksa scroll
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
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
                        'Fitur Horizontal Scroll',
                        style: AppTypography.labelMedium.copyWith(
                          color: DesignColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Input field dengan teks panjang akan menampilkan indikator scroll\n'
                    '• Gunakan gesture swipe untuk scroll horizontal\n'
                    '• Icon panah akan muncul jika konten dapat di-scroll\n'
                    '• Form section dapat di-set dengan lebar minimum',
                    style: AppTypography.bodySmall.copyWith(
                      color: DesignColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _longTextController.dispose();
    super.dispose();
  }
}