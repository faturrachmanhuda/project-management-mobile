import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/auth_viewmodel.dart';
import 'auth_dialog.dart';
import '../utils/design_tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Halaman utama / landing page ProManage
// Layout di semua ukuran layar mengikuti desain web PROMANAGE:
//   • Navbar   — logo + nav links + tombol Login/Register
//   • Hero     — 2 kolom: teks kiri, card gambar kanan (bahkan di HP)
//   • Badge    — "Manage Smarter, Achieve Faster"
//   • Features — grid (3 kolom desktop, 2 kolom tablet, 2 kolom HP kecil)
//   • CTA      — section merah maroon full-width
//   • Footer
// ─────────────────────────────────────────────────────────────────────────────

class CustomLandingPage extends StatelessWidget {
  const CustomLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Navbar(onAction: () => _handleGetStarted(context)),
              _HeroSection(onGetStarted: () => _handleGetStarted(context)),
              const _FeaturesSection(),
              _CtaSection(onGetStarted: () => _handleGetStarted(context)),
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }

  void _handleGetStarted(BuildContext context) {
    final auth = context.read<AuthViewModel>();
    if (auth.apakahSudahLogin) {
      Navigator.pushReplacementNamed(context, '/projects');
      return;
    }
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

// ═══════════════════════════════════════════════════════════════════════════
// NAVBAR
// ═══════════════════════════════════════════════════════════════════════════
class _Navbar extends StatelessWidget {
  final VoidCallback onAction;
  const _Navbar({required this.onAction});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 768;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 32 : 16,
        vertical: isWide ? 16 : 13,
      ),
      child: Row(
        children: [
          // Logo
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: DesignColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.folder_rounded,
                    color: Colors.white, size: 19),
              ),
              const SizedBox(width: 8),
              const Text(
                'ProManage',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: DesignColors.textPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Nav links — hanya desktop
          if (isWide) ...[
            _navLink('Beranda'),
            const SizedBox(width: 24),
            _navLink('Proyek'),
            const SizedBox(width: 24),
            _navLink('Tentang'),
            const SizedBox(width: 32),
          ],
          // Laporan Tugas button — tampil di semua ukuran tapi kompak di HP, hanya saat sudah login
          Consumer<AuthViewModel>(
            builder: (context, auth, _) {
              if (!auth.apakahSudahLogin || auth.penggunaSaatIni == null) {
                return const SizedBox.shrink();
              }
              return Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/task-report'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DesignColors.primary,
                      side: const BorderSide(color: Color(0xFFFECACA)),
                      backgroundColor: DesignColors.brandSoft,
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 14 : 10,
                        vertical: isWide ? 10 : 8,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Icon(Icons.description_outlined,
                        size: isWide ? 16 : 14, color: DesignColors.primary),
                    label: Text(
                      'Laporan Tugas',
                      style: TextStyle(
                          fontSize: isWide ? 13 : 11,
                          fontWeight: FontWeight.w700,
                          color: DesignColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              );
            },
          ),
          // Login & Register
          Consumer<AuthViewModel>(
            builder: (context, auth, _) {
              if (auth.apakahSudahLogin) {
                return FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: DesignColors.primary,
                    padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 16 : 10,
                        vertical: isWide ? 10 : 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('Dashboard',
                      style: TextStyle(
                          fontSize: isWide ? 13 : 11,
                          fontWeight: FontWeight.w700)),
                );
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 12 : 8,
                          vertical: isWide ? 10 : 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: DesignColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: isWide ? 13 : 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  FilledButton(
                    onPressed: onAction,
                    style: FilledButton.styleFrom(
                      backgroundColor: DesignColors.primary,
                      padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 16 : 10,
                          vertical: isWide ? 10 : 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Register',
                      style: TextStyle(
                          fontSize: isWide ? 13 : 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _navLink(String label) => Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: DesignColors.textPrimary,
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════════════
// HERO SECTION — 2 kolom bahkan di HP (teks kiri, card kanan)
// ═══════════════════════════════════════════════════════════════════════════
class _HeroSection extends StatelessWidget {
  final VoidCallback onGetStarted;
  const _HeroSection({required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 768;

    // Di HP: padding lebih kecil, font lebih kecil
    final hPad = isWide ? 40.0 : 16.0;
    final vPad = isWide ? 48.0 : 24.0;
    final titleSize = isWide ? 44.0 : 24.0;
    final bodySize = isWide ? 17.0 : 13.0;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, vPad),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Kiri: badge + judul + deskripsi + tombol ──────────────
              Expanded(
                flex: isWide ? 5 : 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge "Manage Smarter, Achieve Faster"
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: DesignColors.brandSoft,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Text(
                        'Manage Smarter, Achieve Faster',
                        style: TextStyle(
                          color: DesignColors.primary,
                          fontSize: isWide ? 12 : 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    SizedBox(height: isWide ? 20 : 12),
                    // Judul
                    Text(
                      'Manajemen Proyek\nMahasiswa',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w900,
                        color: DesignColors.textPrimary,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: isWide ? 16 : 10),
                    // Deskripsi
                    Text(
                      'Platform kolaborasi yang memudahkan mahasiswa dalam mengelola, merencanakan, dan memantau setiap tahapan proyek.',
                      style: TextStyle(
                        fontSize: bodySize,
                        color: DesignColors.textSecondary,
                        height: 1.55,
                      ),
                    ),
                    SizedBox(height: isWide ? 28 : 18),
                    // Tombol Mulai Sekarang
                    FilledButton.icon(
                      onPressed: onGetStarted,
                      style: FilledButton.styleFrom(
                        backgroundColor: DesignColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 24 : 16,
                          vertical: isWide ? 16 : 12,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: Icon(Icons.arrow_forward,
                          size: isWide ? 18 : 15),
                      label: Text(
                        'Mulai Sekarang',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: isWide ? 15 : 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isWide ? 48 : 12),
              // ── Kanan: card gambar / ilustrasi ────────────────────────
              Expanded(
                flex: isWide ? 5 : 4,
                child: _HeroCard(isWide: isWide),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Card kanan hero — background putih + gambar logo_tim_5
class _HeroCard extends StatelessWidget {
  final bool isWide;
  const _HeroCard({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCF3F3),
        borderRadius: BorderRadius.circular(isWide ? 24 : 16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      padding: EdgeInsets.all(isWide ? 28 : 16),
      child: AspectRatio(
        aspectRatio: isWide ? 4 / 3 : 1.1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isWide ? 16 : 10),
          child: Image.asset(
            'assets/logo_tim_5.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FEATURES SECTION
// ═══════════════════════════════════════════════════════════════════════════
class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  static const _features = [
    _Feature(
      icon: Icons.folder_rounded,
      title: 'Profil Proyek',
      desc: 'Kelola informasi lengkap proyek meliputi nama, deskripsi, tempat, tanggal, pelaksana, dan supervisor untuk dokumentasi yang terstruktur.',
    ),
    _Feature(
      icon: Icons.check_box_rounded,
      title: 'Pekerjaan dalam Proyek',
      desc: 'Atur dan monitor setiap pekerjaan dengan detail nama, deskripsi, lokasi, timeline, serta pembagian pelaksana dan supervisor.',
    ),
    _Feature(
      icon: Icons.calendar_month_rounded,
      title: 'Perencanaan Aktivitas',
      desc: 'Rencanakan setiap aktivitas dengan menentukan nama kegiatan, jadwal waktu pelaksanaan, dan siapa pelaksana yang bertanggung jawab.',
    ),
    _Feature(
      icon: Icons.bar_chart_rounded,
      title: 'Pemantauan Realisasi',
      desc: 'Evaluasi pelaksanaan aktivitas secara berkala dan susun rencana tambahan untuk memastikan proyek berjalan sesuai target.',
    ),
    _Feature(
      icon: Icons.lock_rounded,
      title: 'Penutupan Proyek',
      desc: 'Finalisasi proyek dengan sistem kunci otomatis yang memastikan tidak ada pekerjaan atau aktivitas yang dapat ditambahkan.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 768;
    final isMedium = w >= 480;

    // Kolom: 3 di desktop, 2 di tablet & HP ≥ 480, 2 di HP kecil (mirip gambar)
    final cols = isWide ? 3 : 2;
    final hPad = isWide ? 40.0 : 16.0;

    return Container(
      color: const Color(0xFFF8F9FA),
      padding: EdgeInsets.fromLTRB(hPad, isWide ? 56 : 32, hPad, isWide ? 56 : 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Header
              Text(
                'Kemampuan Aplikasi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isWide ? 32 : 20,
                  fontWeight: FontWeight.w900,
                  color: DesignColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lima fitur utama yang dirancang khusus untuk membantu mahasiswa mengelola proyek dari awal hingga selesai',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isWide ? 16 : 12.5,
                  color: DesignColors.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: isWide ? 40 : 24),
              // Grid fitur
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: isWide ? 20 : 12,
                  mainAxisSpacing: isWide ? 20 : 12,
                  // Aspect ratio adaptif: lebih tinggi di HP supaya teks muat
                  childAspectRatio: isWide ? 0.95 : (isMedium ? 0.80 : 0.75),
                ),
                itemCount: _features.length,
                itemBuilder: (_, i) => _FeatureCard(
                  feature: _features[i],
                  isWide: isWide,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String desc;
  const _Feature({
    required this.icon,
    required this.title,
    required this.desc,
  });
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;
  final bool isWide;
  const _FeatureCard({required this.feature, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final pad = isWide ? 20.0 : 12.0;
    final iconSize = isWide ? 44.0 : 34.0;
    final iconInner = isWide ? 22.0 : 17.0;
    final titleSize = isWide ? 15.5 : 12.5;
    final descSize = isWide ? 13.0 : 11.0;

    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isWide ? 16 : 12),
        border: Border.all(color: const Color(0xFFEEF2F7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon merah
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: DesignColors.primary,
              borderRadius: BorderRadius.circular(isWide ? 12 : 9),
            ),
            child: Icon(feature.icon, color: Colors.white, size: iconInner),
          ),
          SizedBox(height: isWide ? 14 : 9),
          // Judul
          Text(
            feature.title,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              color: DesignColors.textPrimary,
              height: 1.2,
            ),
          ),
          SizedBox(height: isWide ? 8 : 5),
          // Deskripsi
          Expanded(
            child: Text(
              feature.desc,
              style: TextStyle(
                fontSize: descSize,
                color: DesignColors.hint,
                height: 1.4,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CTA SECTION — background merah maroon penuh
// ═══════════════════════════════════════════════════════════════════════════
class _CtaSection extends StatelessWidget {
  final VoidCallback onGetStarted;
  const _CtaSection({required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 768;

    return Container(
      color: DesignColors.primary,
      padding: EdgeInsets.symmetric(
        vertical: isWide ? 64 : 36,
        horizontal: isWide ? 40 : 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              Text(
                'Siap Mengelola Proyek Anda?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isWide ? 32 : 20,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              SizedBox(height: isWide ? 12 : 8),
              Text(
                'Bergabunglah dan mulai kelola proyek mahasiswa Anda secara lebih terstruktur.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: isWide ? 16 : 13,
                  height: 1.5,
                ),
              ),
              SizedBox(height: isWide ? 28 : 20),
              OutlinedButton.icon(
                onPressed: onGetStarted,
                style: OutlinedButton.styleFrom(
                  foregroundColor: DesignColors.primary,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 28 : 20,
                    vertical: isWide ? 16 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: Icon(Icons.arrow_forward,
                    size: isWide ? 18 : 15,
                    color: DesignColors.primary),
                label: Text(
                  'Mulai Sekarang',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: isWide ? 15 : 13,
                    color: DesignColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FOOTER
// ═══════════════════════════════════════════════════════════════════════════
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: const Center(
        child: Text(
          '© 2026 ProManage. Platform Manajemen Proyek Mahasiswa.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
