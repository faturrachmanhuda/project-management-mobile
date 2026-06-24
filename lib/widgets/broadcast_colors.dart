import 'package:flutter/material.dart';

/// Color mapping to match Django broadcast system styling
class BroadcastColors {
  // ── Django-inspired broadcast system colors ──────────────────────────────
  
  /// IE (Implementation Evaluation) - Blue theme
  static const Color iePrimary = Color(0xFF3B82F6);     // Blue-500
  static const Color ieBackground = Color(0xFFEFF6FF);   // Blue-50
  static const Color ieBorder = Color(0xFFBFDBFE);       // Blue-200
  static const Color ieText = Color(0xFF1E40AF);         // Blue-700
  
  /// IC (Implementation Control) - Green theme  
  static const Color icPrimary = Color(0xFF10B981);      // Emerald-500
  static const Color icBackground = Color(0xFFF0FDF4);   // Green-50
  static const Color icBorder = Color(0xFFBBF7D0);       // Green-200
  static const Color icText = Color(0xFF047857);         // Green-700
  
  /// Implementation - Purple theme
  static const Color implPrimary = Color(0xFF8B5CF6);    // Violet-500
  static const Color implBackground = Color(0xFFF5F3FF); // Violet-50
  static const Color implBorder = Color(0xFFDDD6FE);     // Violet-200
  static const Color implText = Color(0xFF6D28D9);       // Violet-700
  
  // ── Status colors matching Django system ─────────────────────────────────
  
  /// Status: Belum (Not Started) - Red theme
  static const Color statusBelum = Color(0xFFEF4444);        // Red-500
  static const Color statusBelumBg = Color(0xFFFEF2F2);      // Red-50
  static const Color statusBelumBorder = Color(0xFFFECACA);  // Red-200
  static const Color statusBelumText = Color(0xFFDC2626);    // Red-600
  
  /// Status: Progress - Yellow/Orange theme
  static const Color statusProgress = Color(0xFFF59E0B);      // Amber-500
  static const Color statusProgressBg = Color(0xFFFFFBEB);    // Amber-50
  static const Color statusProgressBorder = Color(0xFFFDE68A); // Amber-200
  static const Color statusProgressText = Color(0xFFD97706);   // Amber-600
  
  /// Status: Selesai (Done) - Green theme
  static const Color statusSelesai = Color(0xFF10B981);       // Emerald-500
  static const Color statusSelesaiBg = Color(0xFFECFDF5);     // Emerald-50
  static const Color statusSelesaiBorder = Color(0xFFBBF7D0); // Emerald-200
  static const Color statusSelesaiText = Color(0xFF059669);   // Emerald-600
  
  // ── Card and UI colors ──────────────────────────────────────────────────
  
  /// Card colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE5E7EB);         // Gray-200
  static const Color cardShadow = Color(0x0F000000);         // 6% black
  
  /// Icon colors
  static const Color iconPrimary = Color(0xFF6366F1);        // Indigo-500 (matches screenshot icon)
  static const Color iconSecondary = Color(0xFF9CA3AF);      // Gray-400
  static const Color iconMuted = Color(0xFFD1D5DB);          // Gray-300
  
  /// Text colors (complementing existing design tokens)
  static const Color textTitle = Color(0xFF111827);          // Gray-900
  static const Color textSubtitle = Color(0xFF6B7280);       // Gray-500
  static const Color textMeta = Color(0xFF9CA3AF);           // Gray-400
  
  // ── Helper methods ──────────────────────────────────────────────────────
  
  /// Get broadcast type colors
  static Map<String, Color> getBroadcastColors(String type) {
    switch (type.toUpperCase()) {
      case 'IE':
        return {
          'primary': iePrimary,
          'background': ieBackground,
          'border': ieBorder,
          'text': ieText,
        };
      case 'IC':
        return {
          'primary': icPrimary,
          'background': icBackground,
          'border': icBorder,
          'text': icText,
        };
      case 'IMPLEMENTATION':
        return {
          'primary': implPrimary,
          'background': implBackground,
          'border': implBorder,
          'text': implText,
        };
      default:
        return {
          'primary': iconSecondary,
          'background': cardBackground,
          'border': cardBorder,
          'text': textSubtitle,
        };
    }
  }
  
  /// Get status colors
  static Map<String, Color> getStatusColors(String status) {
    switch (status.toUpperCase()) {
      case 'BELUM':
      case 'NOT_STARTED':
        return {
          'primary': statusBelum,
          'background': statusBelumBg,
          'border': statusBelumBorder,
          'text': statusBelumText,
        };
      case 'PROGRESS':
      case 'IN_PROGRESS':
        return {
          'primary': statusProgress,
          'background': statusProgressBg,
          'border': statusProgressBorder,
          'text': statusProgressText,
        };
      case 'SELESAI':
      case 'DONE':
      case 'COMPLETED':
        return {
          'primary': statusSelesai,
          'background': statusSelesaiBg,
          'border': statusSelesaiBorder,
          'text': statusSelesaiText,
        };
      default:
        return {
          'primary': iconSecondary,
          'background': cardBackground,
          'border': cardBorder,
          'text': textSubtitle,
        };
    }
  }
}