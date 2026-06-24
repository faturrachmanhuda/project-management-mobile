import 'package:flutter/material.dart';
import '../../utils/design_tokens.dart';
import '../../../utils/design_tokens.dart' show AppTypography;

class ConvertedWorkCard extends StatelessWidget {
  final String name;
  final String description;
  final String location;
  final String startDate;
  final String endDate;
  final int progress;
  final int doneActivities;
  final int totalActivities;

  const ConvertedWorkCard({
    super.key,
    required this.name,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.progress,
    required this.doneActivities,
    required this.totalActivities,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DesignColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: DesignColors.borderMuted)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTypography.h3),
              const SizedBox(height: 6),
              Text(description, style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              const Spacer(),
              Row(children: [const Icon(Icons.location_on_outlined, size: 16, color: DesignColors.hint), const SizedBox(width: 6), Text(location, style: AppTypography.caption)]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: _progressBar()),
                const SizedBox(width: 8),
                Text('$progress%', style: const TextStyle(fontWeight: FontWeight.w800, color: DesignColors.primary)),
              ]),
              const SizedBox(height: 6),
              Text('$doneActivities / $totalActivities Aktivitas', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressBar() {
    return Container(
      height: 8,
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
      child: FractionallySizedBox(
        widthFactor: (progress / 100).clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(decoration: BoxDecoration(color: DesignColors.primary, borderRadius: BorderRadius.circular(8))),
      ),
    );
  }
}
