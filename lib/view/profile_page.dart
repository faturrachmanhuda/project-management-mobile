import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../utils/responsive_helper.dart';
import '../utils/toast_helper.dart';
import '../utils/design_tokens.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../widgets/app_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _picker = ImagePicker();

  bool _isEditing = false;
  bool _isSaving = false;
  String? _pickedPhotoPath;
  Uint8List? _pickedPhotoBytes;
  String? _pickedPhotoName;

  @override
  void initState() {
    super.initState();
    _syncFromAuth();
  }

  void _syncFromAuth() {
    final user = context.read<AuthViewModel>().penggunaSaatIni ?? {};
    _nameController.text = (user['nama'] ?? user['name'] ?? user['username'] ?? '').toString();
    _nimController.text = (user['nim'] ?? '').toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    try {
      context.read<AuthViewModel>().clearTempPhoto();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _pickFromFiles() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
    if (result == null) return;
    final file = result.files.single;
    Uint8List? bytes = file.bytes;
    if (bytes == null && file.path != null && !kIsWeb) {
      try {
        bytes = await File(file.path!).readAsBytes();
      } catch (_) {}
    }
    setState(() {
      _pickedPhotoPath = file.path;
      _pickedPhotoBytes = bytes;
      _pickedPhotoName = file.name;
    });
    if (!mounted) return;
    context.read<AuthViewModel>().setTempPhoto(bytes: bytes, path: file.path);
  }

  Future<void> _pickFromCamera() async {
    final xfile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    setState(() {
      _pickedPhotoPath = xfile.path;
      _pickedPhotoBytes = bytes;
      _pickedPhotoName = xfile.name;
    });
    if (!mounted) return;
    context.read<AuthViewModel>().setTempPhoto(bytes: bytes, path: xfile.path);
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final auth = context.read<AuthViewModel>();
      final success = await auth.perbaruiProfil(
        nama: _nameController.text.trim(),
        nim: _nimController.text.trim(),
        pathFotoProfil: _pickedPhotoPath,
        bytesFotoProfil: _pickedPhotoBytes,
        namaFile: _pickedPhotoName,
      );
      if (!mounted) return;
      if (success) {
        ToastHelper.showSuccess(context, 'Profil berhasil diperbarui');
        setState(() {
          _isEditing = false;
          _pickedPhotoPath = null;
          _pickedPhotoBytes = null;
          _pickedPhotoName = null;
        });
      } else {
        ToastHelper.showError(context, auth.pesanError ?? 'Gagal memperbarui profil');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final user = auth.penggunaSaatIni ?? {};
    final String name = (_nameController.text.isNotEmpty
            ? _nameController.text
            : (user['nama'] ?? user['name'] ?? user['username'] ?? 'User').toString())
        .trim();
    final String email = (user['email'] ?? '-').toString();
    final String? photoUrl = (user['profile_picture_url'] ?? user['profile_picture'] ?? '').toString().trim().isEmpty
        ? null
        : (user['profile_picture_url'] ?? user['profile_picture']).toString();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: DesignColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.isMobileLandscape(context) ? 24 : 16,
                ),
                child: Column(
                  children: [
                    SizedBox(height: ResponsiveHelper.isMobileLandscape(context) ? 8 : 12),
                    const AppHeader(),
                    SizedBox(height: ResponsiveHelper.isMobileLandscape(context) ? 12 : 24),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Container(
                        padding: EdgeInsets.all(ResponsiveHelper.isMobileLandscape(context) ? 18 : 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: DesignColors.surfaceSoft),
                          boxShadow: const [
                            BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4)),
                          ],
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 600;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Profil Saya', style: AppTypography.heading),
                                const SizedBox(height: 32),
                                if (isWide)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _AvatarPanel(
                                        nameInitial: initial,
                                        remotePhotoUrl: photoUrl,
                                        localPhotoPath: _pickedPhotoPath,
                                        localPhotoBytes: _pickedPhotoBytes,
                                        onUpload: _pickFromFiles,
                                        onCamera: _pickFromCamera,
                                      ),
                                      const SizedBox(width: 48),
                                      Expanded(
                                        child: _FormPanel(
                                          nameController: _nameController,
                                          nimController: _nimController,
                                          email: email,
                                          isEditing: _isEditing,
                                          isSaving: _isSaving,
                                          onToggleEdit: _toggleEdit,
                                          onSave: _saveProfile,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      _AvatarPanel(
                                        nameInitial: initial,
                                        remotePhotoUrl: photoUrl,
                                        localPhotoPath: _pickedPhotoPath,
                                        localPhotoBytes: _pickedPhotoBytes,
                                        onUpload: _pickFromFiles,
                                        onCamera: _pickFromCamera,
                                      ),
                                      const SizedBox(height: 48),
                                      _FormPanel(
                                        nameController: _nameController,
                                        nimController: _nimController,
                                        email: email,
                                        isEditing: _isEditing,
                                        isSaving: _isSaving,
                                        onToggleEdit: _toggleEdit,
                                        onSave: _saveProfile,
                                      ),
                                    ],
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleEdit() {
    if (_isEditing) {
      _syncFromAuth();
      setState(() {
        _isEditing = false;
        _pickedPhotoPath = null;
        _pickedPhotoBytes = null;
        _pickedPhotoName = null;
      });
      context.read<AuthViewModel>().clearTempPhoto();
    } else {
      setState(() => _isEditing = true);
    }
  }
}

class _AvatarPanel extends StatelessWidget {
  const _AvatarPanel({
    required this.nameInitial,
    required this.remotePhotoUrl,
    required this.localPhotoPath,
    required this.localPhotoBytes,
    required this.onUpload,
    required this.onCamera,
  });

  final String nameInitial;
  final String? remotePhotoUrl;
  final String? localPhotoPath;
  final Uint8List? localPhotoBytes;
  final VoidCallback onUpload;
  final VoidCallback onCamera;

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (kIsWeb && localPhotoBytes != null) {
      imageProvider = MemoryImage(localPhotoBytes!);
    } else if (!kIsWeb && localPhotoPath != null) {
      imageProvider = FileImage(File(localPhotoPath!));
    } else if (remotePhotoUrl != null && remotePhotoUrl!.isNotEmpty) {
      imageProvider = NetworkImage(
        remotePhotoUrl!.startsWith('http')
            ? remotePhotoUrl!
            : '${ApiService.baseUrl}$remotePhotoUrl',
      );
    }

    return Column(
      children: [
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DesignColors.bg,
            image: imageProvider != null
                ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                : null,
            boxShadow: const [
              BoxShadow(color: Color(0x0A000000), blurRadius: 16, offset: Offset(0, 4)),
            ],
          ),
          child: imageProvider == null
              ? const Icon(
                  Icons.person_outline,
                  size: 70,
                  color: DesignColors.textMuted,
                )
              : null,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: onUpload,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF334155),
                side: BorderSide(color: DesignColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Unggah', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 12),
              ElevatedButton(
              onPressed: onCamera,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Kamera', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({
    required this.nameController,
    required this.nimController,
    required this.email,
    required this.isEditing,
    required this.isSaving,
    required this.onToggleEdit,
    required this.onSave,
  });

  final TextEditingController nameController;
  final TextEditingController nimController;
  final String email;
  final bool isEditing;
  final bool isSaving;
  final VoidCallback onToggleEdit;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Informasi Pribadi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
              OutlinedButton.icon(
              onPressed: onToggleEdit,
              icon: Icon(
                isEditing ? Icons.close : Icons.edit_outlined,
                size: 16,
                color: DesignColors.primary,
              ),
              label: Text(
                isEditing ? 'Batal' : 'Edit Profil',
                style: TextStyle(color: DesignColors.primary, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFFEF2F2),
                side: const BorderSide(color: Color(0xFFFECACA)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _DataField(
          label: 'Nama Lengkap',
          value: nameController.text,
          controller: nameController,
          isEditing: isEditing,
        ),
        const SizedBox(height: 24),
        _DataField(
          label: 'NIM',
          value: nimController.text,
          controller: nimController,
          isEditing: isEditing,
        ),
        const SizedBox(height: 24),
        _DataField(
          label: 'Email',
          value: email,
          isEditing: false,
        ),
        if (isEditing) ...[
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              icon: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_rounded, size: 18),
              label: Text(
                isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DataField extends StatelessWidget {
  const _DataField({
    required this.label,
    required this.value,
    this.controller,
    this.isEditing = false,
  });

  final String label;
  final String value;
  final TextEditingController? controller;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.body.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: DesignColors.textSecondary),
        ),
        const SizedBox(height: 8),
        if (isEditing && controller != null)
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              border: UnderlineInputBorder(borderSide: BorderSide(color: DesignColors.border)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: DesignColors.border)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: DesignColors.primary, width: 2)),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: DesignColors.surfaceSoft, width: 1.5)),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
      ],
    );
  }
}
