import 'package:flutter/material.dart';

import '../models/pekerjaan_model.dart';
import '../viewmodel/pekerjaan_viewmodel.dart';

class PekerjaanView extends StatelessWidget {
  const PekerjaanView({super.key, required this.viewModel});

  final PekerjaanViewModel viewModel;

  Color _badgeColor(String status) {
    switch (status) {
      case 'Selesai':
        return const Color(0xFF1F8F56);
      case 'Review':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFFB45309);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1EBE8)),
      ),
      child: Column(
        children: viewModel.daftarPekerjaan.map((task) {
          return _TaskTile(task: task, badgeColor: _badgeColor(task.status));
        }).toList(),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.badgeColor});

  final PekerjaanModel task;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    final dueDate =
        '${task.tenggatWaktu.day.toString().padLeft(2, '0')}-${task.tenggatWaktu.month.toString().padLeft(2, '0')}-${task.tenggatWaktu.year}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF8FBFA),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.judul,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'PIC: ${task.penanggungJawab} • Prioritas: ${task.prioritas}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Deadline: $dueDate',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              task.status,
              style: TextStyle(color: badgeColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
