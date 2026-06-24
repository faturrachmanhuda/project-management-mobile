import 'package:flutter/material.dart';
import 'utils/design_tokens.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'about_page.dart';
import 'features/project_management/repositories/in_memory_project_management_repository.dart';
import 'features/project_management/viewmodels/project_management_viewmodel.dart';
import 'view/auth_dialog.dart';
import 'view/task_report_page.dart';
import 'view/view_project_page.dart';
import 'view/landing_page.dart';
import 'viewmodel/auth_viewmodel.dart';
import 'viewmodel/activity_view_model.dart';
import 'viewmodel/bikinproyek_viewmodel.dart';
import 'viewmodel/job_view_model.dart';
import 'widgets/app_header.dart';
import 'services/sync_service.dart';
import 'services/form_draft_service.dart';
// converted preview removed

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Bersihkan key lama SharedPreferences yang sudah tidak dipakai
  await FormDraftService.cleanupLegacyKeys();
  runApp(const ProManageApp());
}

class ProManageApp extends StatefulWidget {
  const ProManageApp({super.key});

  @override
  State<ProManageApp> createState() => _ProManageAppState();
}

class _ProManageAppState extends State<ProManageApp> {
  late final ProyekViewModel _proyekVM;
  late final AuthViewModel _authVM;

  @override
  void initState() {
    super.initState();
    _proyekVM = ProyekViewModel();
    _authVM = AuthViewModel();

    _authVM.saatLoginBerhasil = () async {
      // 1. Kirim data lokal yang belum tersinkron ke server
      await SyncService().syncData();
      // 2. Muat ulang daftar proyek dari server
      await _proyekVM.muatProyek();
    };
    _authVM.saatLogout = () async => _proyekVM.aturUlang();
  }

  @override
  void dispose() {
    _proyekVM.dispose();
    _authVM.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProyekViewModel>.value(value: _proyekVM),
        ChangeNotifierProvider(create: (_) => PekerjaanViewModel()),
        ChangeNotifierProvider(create: (_) => KegiatanViewModel()),
        ChangeNotifierProvider<AuthViewModel>.value(value: _authVM),
        ChangeNotifierProvider(
          create: (_) =>
              ProjectManagementViewModel(InMemoryProjectManagementRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'ProManage',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme(),
          colorScheme: ColorScheme.fromSeed(
            seedColor: DesignColors.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: DesignColors.bg,
        ),
        home: const CustomLandingPage(),
        // Custom landing page (from lib/view/landing_page.dart)
        routes: {
          '/projects': (_) => const HomePage(),
          '/about': (_) => const AboutPage(),
          '/task-report': (_) => const TaskReportPage(),
        },
        // no custom onGenerateRoute
      ),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const Color maroon = DesignColors.primary;
  static const Color maroonDark = DesignColors.primary;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        const AppHeader(),
                        const SizedBox(height: 28),
                        _HeroSection(
                          onGetStarted: () => _handleMulaiSekarang(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _FeatureSection(),
              _CtaSection(onGetStarted: () => _handleMulaiSekarang(context)),
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMulaiSekarang(BuildContext context) {
    final auth = context.read<AuthViewModel>();
    if (auth.apakahSudahLogin) {
      Navigator.pushNamed(context, '/projects');
      return;
    }
    _showAuthDialog(context);
  }

  void _showAuthDialog(BuildContext context) {
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

// Removed unused desktop/mobile header helper widgets (AppHeader now used)

// `_MenuButton` was removed as it is not referenced anywhere.

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.onGetStarted});

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final isWide = w >= 860;
    // Landscape HP: lebar > tinggi, sisi pendek < 600
    final isLandscapePhone = w > h && h < 600;

    // Ukuran font adaptif
    final double titleSize = isLandscapePhone ? 28 : (isWide ? 54 : 36);
    final double bodySize = isLandscapePhone ? 13 : (isWide ? 18 : 15);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isLandscapePhone ? 10 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isWide ? 24 : 0),
              child: Column(
                crossAxisAlignment: isWide || isLandscapePhone
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  // Badge — disembunyikan di landscape HP supaya hemat ruang
                  if (!isLandscapePhone)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF2F2),
                        border: Border.all(color: const Color(0xFFFECACA)),
                        borderRadius: BorderRadius.circular(999),
                      ),
                        child: const Text(
                        'Manage Smarter, Achieve Faster',
                        style: TextStyle(
                          color: DesignColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  SizedBox(height: isLandscapePhone ? 0 : 24),
                  Text(
                    'Manajemen Proyek\nMahasiswa',
                    textAlign: isWide || isLandscapePhone
                        ? TextAlign.left
                        : TextAlign.center,
                    style: TextStyle(
                      fontSize: titleSize,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -1.0,
                    ),
                  ),
                  SizedBox(height: isLandscapePhone ? 8 : 18),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Text(
                      'Platform kolaborasi yang memudahkan mahasiswa dalam mengelola, merencanakan, dan memantau setiap tahapan proyek.',
                      textAlign: isWide || isLandscapePhone
                          ? TextAlign.left
                          : TextAlign.center,
                      style: TextStyle(
                        fontSize: bodySize,
                        color: const Color(0xFF64748B),
                        height: 1.6,
                      ),
                    ),
                  ),
                  SizedBox(height: isLandscapePhone ? 12 : 28),
                  FilledButton.icon(
                    onPressed: onGetStarted,
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isLandscapePhone ? 18 : 24,
                        vertical: isLandscapePhone ? 12 : 18,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Mulai Sekarang',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          ),
          // Gambar preview — hanya di desktop/tablet, tidak di landscape HP
          if (isWide && !isLandscapePhone)
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: -18,
                    bottom: -18,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: DesignColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: DesignColors.primary.withOpacity(0.08),
                            blurRadius: 40,
                            spreadRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: DesignColors.primary.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 30,
                          offset: Offset(0, 18),
                        ),
                      ],
                    ),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset('assets/logo_tim_5.png',
                            fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FeatureSection extends StatelessWidget {
  final List<_FeatureItem> _items = const [
    _FeatureItem(
      icon: Icons.folder_rounded,
      title: 'Profil Proyek',
      description:
          'Kelola informasi lengkap proyek meliputi nama, deskripsi, tempat, tanggal, pelaksana, dan supervisor untuk dokumentasi yang terstruktur.',
    ),
    _FeatureItem(
      icon: Icons.check_box_rounded,
      title: 'Pekerjaan dalam Proyek',
      description:
          'Atur dan monitor setiap pekerjaan dengan detail nama, deskripsi, lokasi, timeline, serta pembagian pelaksana dan supervisor.',
    ),
    _FeatureItem(
      icon: Icons.calendar_month_rounded,
      title: 'Perencanaan Aktivitas',
      description:
          'Rencanakan setiap aktivitas dengan menentukan nama kegiatan, jadwal waktu pelaksanaan, dan siapa pelaksana yang bertanggung jawab.',
    ),
    _FeatureItem(
      icon: Icons.bar_chart_rounded,
      title: 'Pemantauan Realisasi',
      description:
          'Evaluasi pelaksanaan aktivitas secara berkala dan susun rencana tambahan untuk memastikan proyek berjalan sesuai target.',
    ),
    _FeatureItem(
      icon: Icons.lock_rounded,
      title: 'Penutupan Proyek',
      description:
          'Finalisasi proyek dengan sistem kunci otomatis yang memastikan tidak ada pekerjaan atau aktivitas yang dapat ditambahkan.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final isLandscapePhone = w > h && h < 600;
    // Landscape HP: 2 kolom agar tidak terlalu lebar tiap card
    final columns = w >= 1024 ? 3 : (w >= 540 || isLandscapePhone ? 2 : 1);
    final vertPad = isLandscapePhone ? 20.0 : 48.0;

    return Container(
      width: double.infinity,
      color: DesignColors.bg,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: vertPad),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              const Text(
                'Kemampuan Aplikasi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: const Text(
                  'Lima fitur utama yang dirancang khusus untuk membantu mahasiswa mengelola proyek dari awal hingga selesai',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF64748B),
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    itemCount: _items.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: columns == 1 ? 1.45 : 1.25,
                    ),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: DesignColors.surfaceSoft),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x08000000),
                              blurRadius: 16,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: DesignColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item.icon,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.description,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF64748B),
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CtaSection extends StatelessWidget {
  const _CtaSection({required this.onGetStarted});

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: DesignColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 52),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            children: [
              const Text(
                'Siap Mengelola Proyek Anda?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Bergabunglah dan mulai kelola proyek mahasiswa Anda secara lebih terstruktur.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFFFECACA),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: onGetStarted,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: DesignColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text(
                  'Mulai Sekarang',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: const Center(
        child: Text(
          '© 2026 ProManage. Platform Manajemen Proyek Mahasiswa.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
      ),
    );
  }
}

class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
