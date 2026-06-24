import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/modelbikinproyek.dart';
import 'work_detail_page.dart';

class ProjectDetailPage extends StatefulWidget {
  final String? projectId;

  const ProjectDetailPage({super.key, this.projectId});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  String activeTab = 'aktivitas';
  Proyek? proyek;
  List<ItemPekerjaan> works = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      if (widget.projectId != null && widget.projectId!.isNotEmpty) {
        final api = ApiService();
        final resp = await api.get('/api/proyek/${widget.projectId!}/');
        if (resp is Map<String, dynamic>) {
          final proj = Proyek.fromJson(resp);
          final worksList = (resp['pekerjaan'] as List?)?.map((w) => ItemPekerjaan.fromJson(w as Map<String, dynamic>)).toList() ?? [];
          setState(() {
            proyek = proj;
            works = worksList;
            loading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        error = 'Gagal memuat proyek: $e';
        loading = false;
      });
    }
  }

  Future<void> _deleteProject() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Proyek?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ApiService().delete('/api/proyek/${widget.projectId!}/');
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteWork(ItemPekerjaan work) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pekerjaan?'),
        content: Text('Yakin hapus "${work.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ApiService().delete('/api/pekerjaan/${work.id}/');
      await _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (proyek == null) return const Scaffold(body: Center(child: Text('Proyek tidak ditemukan')));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(icon: const Icon(Icons.arrow_left, color: Colors.grey), onPressed: () => Navigator.pop(context)),
        title: Text(proyek!.nama, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: _deleteProject),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProjectInfoCard(),
              const SizedBox(height: 20),
              _buildProgressCard(),
              const SizedBox(height: 30),
              _buildWorkList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DESKRIPSI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 8),
          Text(proyek!.deskripsi),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildInfoCol('MULAI', proyek!.tanggalMulai)),
              Expanded(child: _buildInfoCol('SELESAI', proyek!.tanggalSelesai)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Color(0xFFDC2626)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PELAKSANA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF))),
                  Text(proyek!.pelaksana, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Color(0xFF3B82F6)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SUPERVISOR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF))),
                  Text(proyek!.pengawas, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProgressCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF991B1B), Color(0xFFB91C1C)]),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Progress Keseluruhan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('0%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('0/0 Selesai', style: const TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0,
              minHeight: 6,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Daftar Pekerjaan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFFFE4E4), borderRadius: BorderRadius.circular(12)),
              child: Text('${works.length} Pekerjaan', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFC00F1A))),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (works.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('Belum ada pekerjaan', style: TextStyle(color: Color(0xFF9CA3AF))),
          )
        else
          Column(
            children: works.map((work) => _buildWorkCard(work)).toList(),
          ),
      ],
    );
  }

  Widget _buildWorkCard(ItemPekerjaan work) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(work.nama, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('${work.pelaksana} 📅 ${work.tanggalMulai}', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFFFE4E4), borderRadius: BorderRadius.circular(4)),
                  child: const Text('BELUM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFC00F1A))),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => WorkDetailPage(workId: work.id, projectId: widget.projectId!)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => _deleteWork(work),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildTabButton('aktivitas', 'AKTIVITAS'),
                const SizedBox(width: 24),
                _buildTabButton('status', 'STATUS & BUKTI'),
                const SizedBox(width: 24),
                _buildTabButton('aksi', 'AKSI'),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Checkbox(value: false, onChanged: (_) {}),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('dfgds', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('06:45 · rafdqs', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.download_outlined, size: 16), onPressed: () {}),
                  ],
                ),
                const SizedBox(height: 12),
                Center(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 14), label: const Text('Tambah Aktivitas'))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String id, String label) {
    final isActive = activeTab == id;
    return GestureDetector(
      onTap: () => setState(() => activeTab = id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: isActive ? const Color(0xFFB91C1C) : Colors.transparent, width: 2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive ? const Color(0xFFB91C1C) : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}
