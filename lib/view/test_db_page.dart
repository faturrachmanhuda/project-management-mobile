import 'package:flutter/material.dart';
import '../utils/design_tokens.dart';
import 'package:provider/provider.dart';
import '../database/db_helper.dart';
import '../models/modelbikinproyek.dart';
import '../models/note_model.dart';
import '../viewmodel/bikinproyek_viewmodel.dart';

class TestDbPage extends StatefulWidget {
  const TestDbPage({super.key});

  @override
  State<TestDbPage> createState() => _TestDbPageState();
}

class _TestDbPageState extends State<TestDbPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Proyek> _savedProjects = [];
  List<Note> _savedNotes = [];
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final projects = await DBHelper.instance.getAllProjects();
    final notes = await DBHelper.instance.getAllNotes();
    setState(() {
      _savedProjects = projects;
      _savedNotes = notes;
    });
  }

  // === PROJECT OPERATIONS ===
  Future<void> _saveProjectToLocal() async {
    if (_projectController.text.isEmpty) return;
    final titleToSearch = _projectController.text.trim();
    final vm = Provider.of<ProyekViewModel>(context, listen: false);
    final projectFound = vm.daftarProyek.cast<dynamic>().firstWhere(
      (p) => p.nama.toLowerCase() == titleToSearch.toLowerCase(),
      orElse: () => null,
    );

    if (projectFound == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Proyek "$titleToSearch" tidak ditemukan!')));
      return;
    }

    await DBHelper.instance.saveFullProject(projectFound);
    _projectController.clear();
    _loadData();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Proyek "${projectFound.nama}" disimpan!')));
  }

  Future<void> _deleteProject(String id) async {
    await DBHelper.instance.deleteFullProject(id);
    _loadData();
  }

  // === NOTE OPERATIONS ===
  Future<void> _addNote() async {
    if (_noteController.text.isEmpty) return;
    final note = Note(title: _noteController.text.trim());
    await DBHelper.instance.insertNote(note);
    _noteController.clear();
    _loadData();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note berhasil ditambah!')));
  }

  Future<void> _deleteNote(int id) async {
    await DBHelper.instance.deleteNote(id);
    _loadData();
  }

  Future<void> _clearAll() async {
    await DBHelper.instance.clearAll();
    _loadData();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua data dibersihkan!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Database Lokal'),
        backgroundColor: DesignColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Proyek', icon: Icon(Icons.folder)),
            Tab(text: 'Notes', icon: Icon(Icons.note)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.delete_sweep), onPressed: _clearAll, tooltip: 'Bersihkan Semua'),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProjectTab(),
          _buildNoteTab(),
        ],
      ),
    );
  }

  Widget _buildProjectTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _projectController,
                  decoration: const InputDecoration(hintText: 'Cari proyek untuk disimpan...', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _saveProjectToLocal,
                style: ElevatedButton.styleFrom(backgroundColor: DesignColors.primary, foregroundColor: Colors.white),
                child: const Text('Simpan'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _savedProjects.isEmpty
                ? const Center(child: Text('Belum ada proyek lokal.'))
                : ListView.builder(
                    itemCount: _savedProjects.length,
                    itemBuilder: (context, index) {
                      final p = _savedProjects[index];
                      return Card(
                        child: ListTile(
                          title: Text(p.nama),
                          subtitle: Text('ID: ${p.id}'),
                          trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteProject(p.id)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(hintText: 'Tulis note baru...', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addNote,
                style: ElevatedButton.styleFrom(backgroundColor: DesignColors.primary, foregroundColor: Colors.white),
                child: const Text('Tambah'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _savedNotes.isEmpty
                ? const Center(child: Text('Belum ada notes.'))
                : ListView.builder(
                    itemCount: _savedNotes.length,
                    itemBuilder: (context, index) {
                      final n = _savedNotes[index];
                      return Card(
                        child: ListTile(
                          title: Text(n.title),
                          subtitle: Text('ID: ${n.id}'),
                          trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteNote(n.id!)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
