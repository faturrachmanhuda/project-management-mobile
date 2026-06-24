import 'package:flutter/material.dart';

class DesignColors {
  // ── PROMANAGE brand palette ───────────────────────────────────────────────
  // brand: merah maroon #AE2B35 (diambil dari Color.fromARGB(255,174,43,53))
  static const Color brand = Color(0xFFAE2B35);
  static const Color brandDark = Color(0xFF8B1E28);
  static const Color brandSoft = Color(0xFFFFF1F2); // latar merah muda terang
  static const Color brandBorder = Color(0xFFFECACA); // border merah muda

  // ── Tokens yang sudah ada — dipertahankan untuk kompatibilitas ────────────
  static const Color bg = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);

  // primary sekarang = brand (merah maroon), bukan near-black
  static const Color primary = Color(0xFFAE2B35);
  static const Color primaryDark = Color(0xFF8B1E28);

  // accent = abu terang (latar ikon, chip lunak)
  static const Color accent = Color(0xFFE9EBEF);

  static const Color destructive = Color(0xFFD4183D);
  static const Color border = Color.fromRGBO(0, 0, 0, 0.1);
  static const Color borderInput = Color(0xFFF3F3F5);

  // teks
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF9CA3AF);

  // status
  static const Color statusActive = Color(0xFF166534);
  static const Color statusActiveBg = Color(0xFFDCFCE7);
  static const Color statusDone = Color(0xFF1E40AF);
  static const Color statusDoneBg = Color(0xFFDBEAFE);
  static const Color statusPending = Color(0xFF92400E);
  static const Color statusPendingBg = Color(0xFFFFF9C3);

  // surface variants
  static const Color surfaceSoft = Color(0xFFF3F3F5);
  static const Color almostWhite = Color(0xFFFCFCFD);

  // borders
  static const Color borderMuted = Color(0xFFE5E7EB);
  static const Color borderAlt = Color(0xFFE8EDF4);
  static const Color borderLight = Color(0xFFE2E8F0);

  // misc
  static const Color mutedDark = Color(0xFF334155);
  static const Color neutralVariant = Color(0xFF475569);
  static const Color hint = Color(0xFF64748B);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSoft = Color(0xFFFECACA);
  // primarySoft = versi lembut warna brand
  static const Color primarySoft = Color(0xFFFFF1F2);
  static const Color yellowLight = Color(0xFFFDE68A);
  static const Color success = Color(0xFF059669);
  static const Color info = Color(0xFF0891B2);
  static const Color warning = Color(0xFFF97316);
  static const Color slate = Color(0xFF94A3B8);
}

class Spacing {
  static const double page = 16.0;
  static const double section = 24.0;
}

class Radii {
  // Web theme radius: --radius = 0.625rem (~10px)
  static const double small = 6.0;
  static const double medium = 10.0;
  static const double large = 18.0;
}

class AppTypography {
  // Typographic scale based on the spec
  static const String fontFamily = 'Inter';

  static const TextStyle h1 = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: DesignColors.textPrimary,
    height: 1.2,
    fontFamily: fontFamily,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: DesignColors.textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: DesignColors.textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: DesignColors.textSecondary,
    height: 1.6,
    fontFamily: fontFamily,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: DesignColors.textSecondary,
    fontFamily: fontFamily,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: DesignColors.textMuted,
    fontFamily: fontFamily,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    fontFamily: fontFamily,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: DesignColors.textPrimary,
    fontFamily: fontFamily,
  );

  // Backwards-compatible aliases used in older files
  static const TextStyle heading = h2;
  static const TextStyle body = bodyLarge;
  static const TextStyle display = h1;
}
