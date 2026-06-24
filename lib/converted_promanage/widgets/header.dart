import 'package:flutter/material.dart';
import '../../utils/design_tokens.dart';

 
class ConvertedHeader extends StatelessWidget {
  const ConvertedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 860;
    return Container(
      decoration: BoxDecoration(
        color: DesignColors.surface,
        border: Border(bottom: BorderSide(color: DesignColors.borderMuted)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: DesignColors.primary, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.folder_rounded, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Text('ProManage', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: DesignColors.textPrimary)),
          const Spacer(),
          if (isWide) ...[
            TextButton(onPressed: () {}, child: const Text('Beranda', style: AppTypography.labelMedium)),
            const SizedBox(width: 12),
            TextButton(onPressed: () {}, child: const Text('Proyek', style: AppTypography.labelMedium)),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.description_outlined, size: 18),
              label: const Text('Laporan Tugas', style: TextStyle(fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: DesignColors.primary,
                side: BorderSide(color: DesignColors.borderAlt),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ] else ...[
            IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
          ]
        ],
      ),
    );
  }
}
