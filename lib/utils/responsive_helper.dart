import 'package:flutter/material.dart';

/// Helper responsif agar layout konsisten di berbagai ukuran layar.
/// Mendukung portrait, landscape HP, tablet, dan desktop.
class ResponsiveHelper {
  // ── Breakpoint helpers ────────────────────────────────────────────────

  /// True jika layar adalah HP (portrait ATAU landscape)
  static bool isMobile(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    // Landscape: lebar besar tapi tinggi kecil → tetap mobile
    final shortSide = w < h ? w : h;
    return shortSide < 600;
  }

  /// True khusus landscape HP (lebar > tinggi, tapi sisi pendek < 600)
  static bool isMobileLandscape(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    return w > h && h < 600;
  }

  /// True jika tablet (sisi pendek >= 600, sisi panjang < 1200)
  static bool isTablet(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;
    final shortSide = w < h ? w : h;
    return shortSide >= 600 && w < 1200;
  }

  /// True jika desktop (lebar >= 1200)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  // ── Padding ───────────────────────────────────────────────────────────

  static EdgeInsets pagePadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    if (isMobile(context)) {
      // Landscape HP: beri padding horizontal lebih besar agar konten tidak
      // terlalu dekat tepi layar yang memanjang
      if (isMobileLandscape(context)) {
        return EdgeInsets.symmetric(horizontal: w * 0.06, vertical: 10);
      }
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
    if (w < 1200) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
  }

  // ── Kolom grid ────────────────────────────────────────────────────────

  /// Jumlah kolom untuk grid kartu (pekerjaan / aktivitas).
  static int gridColumns(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1200) return 3;
    if (w >= 760) return 2;
    return 1;
  }

  // ── Dialog ────────────────────────────────────────────────────────────

  static double dialogWidth(BuildContext context, {double max = 600}) {
    final double width = MediaQuery.of(context).size.width;
    final double target = width - 32;
    return target < max ? target : max;
  }

  // ── Lebar konten utama (info proyek sidebar dll) ──────────────────────

  /// Lebar panel info proyek di sisi kiri halaman detail.
  /// Pada HP portrait → full width; landscape/tablet → lebar tetap 280;
  /// desktop → 300.
  static double infoPanelWidth(BuildContext context) {
    if (isMobile(context) && !isMobileLandscape(context)) {
      return double.infinity; // full width portrait
    }
    if (isDesktop(context)) return 300;
    return 280;
  }

  /// Konstrain lebar konten teks (deskripsi, judul) agar tidak terlalu
  /// melebar di layar besar.
  static double constrainedContentWidth(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width < 768) return width;
    if (width < 1200) return 960;
    return 1200;
  }
}
