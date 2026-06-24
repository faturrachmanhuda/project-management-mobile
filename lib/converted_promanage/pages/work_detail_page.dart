import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/modelbikinproyek.dart';

class WorkDetailPage extends StatefulWidget {
  final String? workId;
  final String projectId;

  const WorkDetailPage({super.key, this.workId, required this.projectId});

  @override
  State<WorkDetailPage> createState() => _WorkDetailPageState();
}

class _WorkDetailPageState extends State<WorkDetailPage> {
  ItemPekerjaan? work;
  List<ItemKegiatan> activities = [];
  bool loading = true;
  String? error;
  bool editMode = false;
  bool showActivityForm = false;

  late TextEditingController nameController;
  late TextEditingController locationController;
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  late TextEditingController executorController;
  late TextEditingController supervisorController;
  late TextEditingController descriptionController;

  late TextEditingController activityNameController;
  late TextEditingController activityTimeController;
  late TextEditingController activityExecutorController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    locationController = TextEditingController();
    startDateController = TextEditingController();
    endDateController = TextEditingController();
    executorController = TextEditingController();
    supervisorController = TextEditingController();
    descriptionController = TextEditingController();
    activityNameController = TextEditingController();
    activityTimeController = TextEditingController();
    activityExecutorController = TextEditingController();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.workId == null || widget.workId!.isEmpty) {
      setState(() {
        error = 'ID pekerjaan tidak valid';
        loading = false;
      });
      return;
    }

    try {
      final api = ApiService();
      final resp = await api.get('/api/pekerjaan/${widget.workId!}/');
      if (resp is Map<String, dynamic>) {
        final workData = ItemPekerjaan.fromJson(resp);
        final activitiesList = (resp['aktivitas'] as List?)?.map((a) => ItemKegiatan.fromJson(a as Map<String, dynamic>)).toList() ?? [];
        setState(() {
          work = workData;
          activities = activitiesList;
          _populateControllers();
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Gagal memuat pekerjaan: $e';
        loading = false;
      });
    }
  }

  void _populateControllers() {
    if (work != null) {
      nameController.text = work!.nama;
      locationController.text = work!.lokasi;
      startDateController.text = work!.tanggalMulai;
      endDateController.text = work!.tanggalSelesai;
      executorController.text = work!.pelaksana;
      supervisorController.text = work!.pengawas;
      descriptionController.text = work!.deskripsi;
    }
  }

  Future<void> _saveWork() async {
    if (!_validateForm()) return;

    try {
      final api = ApiService();
      final data = {
        'nama': nameController.text,
        'deskripsi': descriptionController.text,
        'lokasi': locationController.text,
        'tanggal_mulai': startDateController.text,
        'tanggal_selesai': endDateController.text,
        'pelaksana': executorController.text,
        'pengawas': supervisorController.text,
      };

      await api.put('/api/pekerjaan/${widget.workId!}/', data);
      setState(() => editMode = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pekerjaan berhasil diperbarui')),
      );
      await _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  bool _validateForm() {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama pekerjaan tidak boleh kosong')),
      );
      return false;
    }
    return true;
  }

  Future<void> _addActivity() async {
    if (activityNameController.text.isEmpty || activityExecutorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }

    try {
      final api = ApiService();
      final data = {
        'id_pekerjaan': widget.workId,
        'nama': activityNameController.text,
        'waktu_pelaksanaan': activityTimeController.text,
        'pelaksana': activityExecutorController.text,
      };

      await api.post('/api/aktivitas/', data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktivitas ditambahkan')),
      );
      activityNameController.clear();
      activityTimeController.clear();
      activityExecutorController.clear();
      setState(() => showActivityForm = false);
      await _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _toggleActivityStatus(ItemKegiatan activity) async {
    try {
      final api = ApiService();
      await api.patch('/api/aktivitas/${activity.id}/toggle_selesai/', {});
      await _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deleteActivity(String activityId) async {
    try {
      final api = ApiService();
      await api.delete('/api/aktivitas/$activityId/');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktivitas dihapus')),
      );
      await _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pekerjaan')),
        body: Center(child: Text(error!)),
      );
    }

    if (work == null) {
      return const Scaffold(
        body: Center(child: Text('Pekerjaan tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_left, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          work!.nama,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkDetailPage(workId: work!.id, projectId: widget.projectId),
              ),
            ),
            icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFFB91C1C)),
            label: const Text('Edit Pekerjaan', style: TextStyle(color: Color(0xFFB91C1C))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Work Info Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                padding: const EdgeInsets.all(20),
                child: editMode ? _buildEditForm() : _buildInfoDisplay(),
              ),
              const SizedBox(height: 30),

              // Activities Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Aktivitas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => showActivityForm = !showActivityForm),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Tambah Aktivitas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB91C1C),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Add Activity Form
              if (showActivityForm) _buildActivityForm(),

              // Activities List
              if (activities.isEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  padding: const EdgeInsets.all(40),
                  child: const Column(
                    children: [
                      Icon(Icons.note_outlined, size: 40, color: Color(0xFFD1D5DB)),
                      SizedBox(height: 12),
                      Text(
                        'Belum ada aktivitas',
                        style: TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: activities.map((activity) {
                    return _buildActivityCard(activity);
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('Lokasi', work!.lokasi),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _infoColumn('Tanggal Mulai', work!.tanggalMulai),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _infoColumn('Tanggal Selesai', work!.tanggalSelesai),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _infoRow('Pelaksana', work!.pelaksana),
        const SizedBox(height: 16),
        _infoRow('Pengawas', work!.pengawas),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ],
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Nama Pekerjaan *', nameController),
        const SizedBox(height: 16),
        _buildTextField('Deskripsi *', descriptionController, maxLines: 3),
        const SizedBox(height: 16),
        _buildTextField('Lokasi *', locationController),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField('Tanggal Mulai *', startDateController),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField('Tanggal Selesai *', endDateController),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField('Pelaksana *', executorController),
        const SizedBox(height: 16),
        _buildTextField('Pengawas *', supervisorController),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => editMode = false),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB91C1C),
                ),
                onPressed: _saveWork,
                child: const Text('Simpan', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            hintText: label,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Nama Aktivitas *', activityNameController),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Waktu',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: activityTimeController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        hintText: 'HH:MM',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField('Pelaksana *', activityExecutorController),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => showActivityForm = false),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB91C1C),
                  ),
                  onPressed: _addActivity,
                  child: const Text('Tambah', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(ItemKegiatan activity) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          Checkbox(
            value: activity.selesai,
            onChanged: (_) => _toggleActivityStatus(activity),
            activeColor: const Color(0xFF16A34A),
          ),
          const SizedBox(width: 12),

          // Activity Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.namaKegiatan,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    decoration: activity.selesai ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${activity.waktuPelaksanaan} · ${activity.pelaksana}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                ),
                if (activity.evaluasi.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Evaluasi: ${activity.evaluasi}',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF3B82F6), fontStyle: FontStyle.italic),
                  ),
                ],
                if (activity.rencanaTambahan.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Rencana: ${activity.rencanaTambahan}',
                    style: const TextStyle(fontSize: 10, color: Color(0xFFB45309), fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),

          // Action Buttons
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.upload_file, size: 18, color: Color(0xFF9CA3AF)),
                onPressed: () {},
                tooltip: 'Upload Bukti',
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF9CA3AF)),
                    onPressed: () {},
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFF9CA3AF)),
                    onPressed: () => _deleteActivity(activity.id),
                    tooltip: 'Hapus',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    executorController.dispose();
    supervisorController.dispose();
    descriptionController.dispose();
    activityNameController.dispose();
    activityTimeController.dispose();
    activityExecutorController.dispose();
    super.dispose();
  }
}
