import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/akun_model.dart';
import '../utils/design_tokens.dart';

/// Halaman SQLite Viewer — menampilkan daftar akun yang tersimpan di database lokal.
/// Mendukung operasi CRUD dasar: tambah, edit, hapus.
class SQLiteViewerPage extends StatefulWidget {
  const SQLiteViewerPage({super.key});

  @override
  State<SQLiteViewerPage> createState() => _SQLiteViewerPageState();
}

class _SQLiteViewerPageState extends State<SQLiteViewerPage> {
  List<Akun> _akunList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final list = await DBHelper.instance.getAllAkun();
    if (mounted) {
      setState(() {
        _akunList = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAkun(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Akun'),
        content: const Text('Yakin ingin menghapus akun ini dari database lokal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DBHelper.instance.deleteAkun(id);
      _loadData();
    }
  }

  Future<void> _showEditDialog(Akun akun) async {
    final namaCtrl = TextEditingController(text: akun.nama ?? '');
    final usernameCtrl = TextEditingController(text: akun.username ?? '');
    final nimCtrl = TextEditingController(text: akun.nim ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Edit Akun — ${akun.email}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _InputField(label: 'Nama', controller: namaCtrl),
              const SizedBox(height: 12),
              _InputField(label: 'Username', controller: usernameCtrl),
              const SizedBox(height: 12),
              _InputField(label: 'NIM', controller: nimCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (saved == true) {
      final updated = Akun(
        id: akun.id,
        email: akun.email,
        username: usernameCtrl.text.trim(),
        nama: namaCtrl.text.trim(),
        nim: nimCtrl.text.trim(),
        password: akun.password,
        profilePicture: akun.profilePicture,
        isActive: akun.isActive,
      );
      await DBHelper.instance.updateAkun(updated);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.bg,
      appBar: AppBar(
        backgroundColor: DesignColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'My Notes (SQLite)',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: DesignColors.surfaceSoft),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.storage_rounded,
                        color: DesignColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'SQLite — Database Lokal',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: DesignColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'SQLite memungkinkan aplikasi untuk:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 6),
                _BulletItem(text: 'Menyimpan data secara offline'),
                _BulletItem(text: 'Mengelola data dalam bentuk tabel'),
                _BulletItem(
                    text: 'Melakukan operasi CRUD (Create, Read, Update, Delete)'),
              ],
            ),
          ),

          // Table header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: DesignColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Expanded(
                    flex: 1,
                    child: Text('ID',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('Email / Username',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Nama',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                  SizedBox(
                    width: 72,
                    child: Text('Aksi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: DesignColors.primary))
                : _akunList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_off_rounded,
                                size: 64,
                                color: DesignColors.hint.withValues(alpha: 0.4)),
                            const SizedBox(height: 12),
                            const Text(
                              'Belum ada akun tersimpan',
                              style: TextStyle(
                                  color: DesignColors.hint, fontSize: 15),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Daftar atau login untuk menyimpan akun ke SQLite',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: DesignColors.hint, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _akunList.length,
                        itemBuilder: (context, index) {
                          final akun = _akunList[index];
                          final isActive = akun.isActive == 1;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFFFF8F8)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isActive
                                    ? DesignColors.primary.withValues(alpha: 0.4)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  // ID
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '${akun.id ?? '-'}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: DesignColors.hint,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  // Email / Username
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          akun.email,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF111827),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if ((akun.username ?? '').isNotEmpty)
                                          Text(
                                            '@${akun.username}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: DesignColors.hint,
                                            ),
                                          ),
                                        if (isActive)
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 3),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: DesignColors.primary
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'Aktif',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: DesignColors.primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Nama
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      akun.nama ?? '-',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF374151),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Aksi
                                  SizedBox(
                                    width: 72,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () => _showEditDialog(akun),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: const Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Icon(Icons.edit_rounded,
                                                size: 18,
                                                color: Color(0xFF2563EB)),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        InkWell(
                                          onTap: () => akun.id != null
                                              ? _deleteAkun(akun.id!)
                                              : null,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: const Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Icon(Icons.delete_rounded,
                                                size: 18,
                                                color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Footer info
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              'Total: ${_akunList.length} akun tersimpan • Tabel: akun • DB: promanage.db',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: DesignColors.hint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('● ',
              style: TextStyle(
                  color: DesignColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 12.5, color: Color(0xFF4B5563), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
