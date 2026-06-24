import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view/auth_dialog.dart';
import '../view/profile_page.dart';
import '../database/db_helper.dart';
import '../models/akun_model.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../utils/design_tokens.dart';
import '../services/api_service.dart';

/// Shared header widget used across all pages to ensure consistent navigation.
/// Matches the LandingPage header design with logo, nav links, profile popup.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 860;

    return Container(
      decoration: BoxDecoration(
        color: DesignColors.surface,
        border: Border(
          top: BorderSide(color: isWide ? Colors.transparent : DesignColors.borderMuted),
          bottom: BorderSide(color: DesignColors.borderMuted),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 20 : 18,
        vertical: isWide ? 16 : 14,
      ),
      child: isWide ? _DesktopAppHeader() : _MobileAppHeader(),
    );
  }

  static void _showAuthDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16),
        child: AuthDialog(),
      ),
    );
  }
}

class _DesktopAppHeader extends StatelessWidget {
  void _goHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _goProjects(BuildContext context) {
    Navigator.pushNamed(context, '/projects');
  }

  void _goTaskReport(BuildContext context) {
    Navigator.pushNamed(context, '/task-report');
  }

  Future<void> _showLocalStorageViewer(BuildContext context) async {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: FutureBuilder<List<Akun>>(
          future: DBHelper.instance.getAllAkun(),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const SizedBox(height: 200, width: 400, child: Center(child: CircularProgressIndicator()));
            }
            if (snap.hasError) {
              return SizedBox(height: 200, width: 400, child: Padding(padding: const EdgeInsets.all(16), child: Text('Error: ${snap.error}')));
            }
            final data = snap.data ?? [];
            return SizedBox(
              width: 760,
              height: 420,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('My Accounts (SQLite)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Text('Total: ${data.length}'),
                    const SizedBox(height: 12),
                    Expanded(
                      child: data.isEmpty
                          ? const Center(child: Text('(kosong)'))
                          : ListView.separated(
                              itemCount: data.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, idx) {
                                final a = data[idx];
                                return Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            a.nama?.isNotEmpty == true ? a.nama! : a.email,
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          onPressed: () async {
                                            if (a.id != null) await DBHelper.instance.deleteAkun(a.id!);
                                            Navigator.pop(ctx);
                                            // Re-open to refresh
                                            await Future.delayed(const Duration(milliseconds: 50));
                                            _showLocalStorageViewer(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _goHome(context),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: DesignColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.folder_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text('ProManage', style: AppTypography.h2),
            ],
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => _goHome(context),
          style: TextButton.styleFrom(
            foregroundColor: DesignColors.neutralVariant,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text(
            'Home',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => _goProjects(context),
          style: TextButton.styleFrom(
            foregroundColor: DesignColors.neutralVariant,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text(
            'Proyek',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Consumer<AuthViewModel>(
          builder: (context, auth, _) {
            if (!auth.apakahSudahLogin || auth.penggunaSaatIni == null) {
              return const SizedBox.shrink();
            }
            return Row(
              children: [
                TextButton(
                  onPressed: () => _goTaskReport(context),
                  style: TextButton.styleFrom(
                    foregroundColor: DesignColors.neutralVariant,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text(
                    'Laporan Tugas',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            );
          },
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/about'),
          style: TextButton.styleFrom(
            foregroundColor: DesignColors.neutralVariant,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text(
            'About',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // show DB viewer button only when current route is the About page
        if (ModalRoute.of(context)?.settings.name == '/about') ...[
          IconButton(
            onPressed: () => _showLocalStorageViewer(context),
            icon: const Icon(Icons.storage_outlined),
            tooltip: 'Local Storage',
            color: DesignColors.hint,
          ),
          const SizedBox(width: 8),
        ],
        Consumer<AuthViewModel>(
          builder: (context, auth, _) {
            if (!auth.apakahSudahLogin || auth.penggunaSaatIni == null) {
              return Row(
                children: [
                  TextButton(
                    onPressed: () => AppHeader._showAuthDialog(context),
                    style: TextButton.styleFrom(
                      foregroundColor: DesignColors.neutralVariant,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => AppHeader._showAuthDialog(context),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              );
            }

            final user = auth.penggunaSaatIni!;
            final name =
                (user['nama'] ?? user['name'] ?? user['username'] ?? 'User')
                    .toString();
            final email = (user['email'] ?? '').toString();
            final String? rawImg = (user['profile_picture_url'] ?? user['profile_picture'] ?? '').toString().trim().isEmpty
                ? null
                : (user['profile_picture_url'] ?? user['profile_picture']).toString();
            final String? imageUrl = rawImg != null
                ? (rawImg.startsWith('http') ? rawImg : '${ApiService.baseUrl}$rawImg')
                : null;

            ImageProvider? avatarImage;
            if (auth.tempPhotoBytes != null) {
              avatarImage = MemoryImage(auth.tempPhotoBytes!);
            } else if (auth.tempPhotoPath != null && !kIsWeb) {
              avatarImage = FileImage(File(auth.tempPhotoPath!));
            } else if (imageUrl != null) {
              avatarImage = NetworkImage(imageUrl);
            }

            return PopupMenuButton<String>(
              offset: const Offset(-100, 48),
              onSelected: (value) async {
                if (value == 'profile') {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                } else if (value == 'projects') {
                  _goProjects(context);
                } else if (value == 'logout') {
                  await auth.keluar();
                  if (context.mounted) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false);
                  }
                }
              },
              color: DesignColors.surface,
              surfaceTintColor: DesignColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: DesignColors.borderInput),
              ),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_outline, color: DesignColors.mutedDark, size: 20),
                      SizedBox(width: 12),
                      Text('Profil Saya', style: TextStyle(color: DesignColors.mutedDark, fontSize: 14)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'projects',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.snippet_folder_outlined, color: DesignColors.mutedDark, size: 20),
                      SizedBox(width: 12),
                      Text('Proyek Saya', style: TextStyle(color: DesignColors.mutedDark, fontSize: 14)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout, color: DesignColors.danger, size: 20),
                      SizedBox(width: 12),
                      Text('Logout', style: TextStyle(color: DesignColors.danger, fontSize: 14)),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: DesignColors.borderMuted),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: DesignColors.primary,
                      backgroundImage: avatarImage,
                      child: avatarImage == null
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name.length > 15 ? '${name.substring(0, 15)}...' : name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: DesignColors.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          email.length > 20 ? '${email.substring(0, 20)}...' : email,
                          style: const TextStyle(
                            fontSize: 11,
                            color: DesignColors.hint,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: DesignColors.hint,
                      size: 18,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MobileAppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: DesignColors.primary, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.folder_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('ProManage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: DesignColors.textPrimary)),
            ],
          ),
        ),
        const Spacer(),
        Consumer<AuthViewModel>(
          builder: (context, auth, _) {
            if (!auth.apakahSudahLogin || auth.penggunaSaatIni == null) {
              return IconButton(
                onPressed: () => _showMobileMenu(context),
                icon: const Icon(Icons.menu),
              );
            }

            final user = auth.penggunaSaatIni!;
            final name = (user['nama'] ?? user['name'] ?? user['username'] ?? 'User').toString();
            final String? rawImg = (user['profile_picture_url'] ?? user['profile_picture'] ?? '').toString().trim().isEmpty
                ? null
                : (user['profile_picture_url'] ?? user['profile_picture']).toString();
            final String? imageUrl = rawImg != null
                ? (rawImg.startsWith('http') ? rawImg : '${ApiService.baseUrl}$rawImg')
                : null;

            ImageProvider? avatarImage;
            if (auth.tempPhotoBytes != null) {
              avatarImage = MemoryImage(auth.tempPhotoBytes!);
            } else if (auth.tempPhotoPath != null && !kIsWeb) {
              avatarImage = FileImage(File(auth.tempPhotoPath!));
            } else if (imageUrl != null) {
              avatarImage = NetworkImage(imageUrl);
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: DesignColors.primary,
                  backgroundImage: avatarImage,
                  child: avatarImage == null
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showMobileMenu(context),
                  icon: const Icon(Icons.menu),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return Consumer<AuthViewModel>(
          builder: (context, auth, _) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home_outlined),
                      title: const Text('Home'),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.folder_outlined),
                      title: const Text('Proyek'),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        Navigator.pushNamed(context, '/projects');
                      },
                    ),
                    if (auth.apakahSudahLogin && auth.penggunaSaatIni != null)
                      ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: const Text('Laporan Tugas'),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          Navigator.pushNamed(context, '/task-report');
                        },
                      ),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('About'),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        Navigator.pushNamed(context, '/about');
                      },
                    ),
                    const Divider(),
                    if (!auth.apakahSudahLogin || auth.penggunaSaatIni == null) ...[
                      ListTile(
                        leading: const Icon(Icons.login_outlined),
                        title: const Text('Login'),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          AppHeader._showAuthDialog(context);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.person_add_outlined),
                        title: const Text('Register'),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          AppHeader._showAuthDialog(context);
                        },
                      ),
                    ] else ...[
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: const Text('Profil Saya'),
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          await Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ProfilePage()),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout, color: DesignColors.danger),
                        title: const Text('Logout', style: TextStyle(color: DesignColors.danger)),
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          await auth.keluar();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
