import 'package:flutter/material.dart';
import '../models/modelbikinproyek.dart';

class SimpleGanttChart extends StatelessWidget {
  final List<ItemPekerjaan> jobs;
  final List<ItemKegiatan> activities;

  const SimpleGanttChart({
    super.key,
    required this.jobs,
    this.activities = const [],
  });

  /// Calculate completion percentage for a specific job based on its activities
  double _jobProgress(ItemPekerjaan job) {
    final jobActivities = activities.where(
      (a) => a.idPekerjaan == job.id || a.pekerjaan == job.nama,
    ).toList();
    if (jobActivities.isEmpty) return 0.0;
    final done = jobActivities.where((a) => a.selesai).length;
    return done / jobActivities.length;
  }

  Color _progressColor(double progress) {
    if (progress >= 1.0) return const Color(0xFF16A34A); // green
    if (progress >= 0.5) return const Color(0xFFF59E0B); // orange/yellow
    if (progress > 0) return const Color(0xFFDC2626); // red
    return const Color(0xFFDC2626); // red for 0%
  }

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate min/max dates
    DateTime? minDate;
    DateTime? maxDate;

    for (var job in jobs) {
      try {
        if (job.tanggalMulai.isNotEmpty) {
          final start = DateTime.parse(job.tanggalMulai);
          if (minDate == null || start.isBefore(minDate)) {
            minDate = start;
          }
        }
        if (job.tanggalSelesai.isNotEmpty) {
          final end = DateTime.parse(job.tanggalSelesai);
          if (maxDate == null || end.isAfter(maxDate)) {
            maxDate = end;
          }
        }
      } catch (e) {
        // Ignore parse errors
      }
    }

    if (minDate == null || maxDate == null) {
      return const SizedBox.shrink();
    }

    // Add margin
    minDate = minDate.subtract(const Duration(days: 2));
    maxDate = maxDate.add(const Duration(days: 2));

    final totalDays = maxDate.difference(minDate).inDays;
    if (totalDays <= 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        _buildLegend(),
        const SizedBox(height: 20),

        // Chart
        LayoutBuilder(
          builder: (context, constraints) {
            final chartWidth = constraints.maxWidth;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...jobs.map((job) {
                  DateTime? start;
                  DateTime? end;
                  try {
                    if (job.tanggalMulai.isNotEmpty) start = DateTime.parse(job.tanggalMulai);
                    if (job.tanggalSelesai.isNotEmpty) end = DateTime.parse(job.tanggalSelesai);
                  } catch (e) {
                    // Invalid date
                  }

                  if (start == null || end == null) return const SizedBox.shrink();

                  final offsetDays = start.difference(minDate!).inDays;
                  final durationDays = end.difference(start).inDays.clamp(1, double.infinity);

                  final double leftOffset = (offsetDays / totalDays) * chartWidth;
                  final double barWidth = (durationDays / totalDays) * chartWidth;

                  final progress = _jobProgress(job);
                  final progressPercent = (progress * 100).round();
                  final progressColor = _progressColor(progress);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.nama,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Stacked bar: gray background + colored progress
                        Stack(
                          children: [
                            // Full timeline background
                            Container(
                              height: 28,
                              width: chartWidth,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            // Job duration bar (gray)
                            Positioned(
                              left: leftOffset.clamp(0, chartWidth),
                              child: Container(
                                height: 28,
                                width: barWidth.clamp(0, chartWidth - leftOffset.clamp(0, chartWidth)),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2E8F0),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                            // Progress bar overlay
                            if (progress > 0)
                              Positioned(
                                left: leftOffset.clamp(0, chartWidth),
                                child: Container(
                                  height: 28,
                                  width: (barWidth * progress).clamp(0, chartWidth - leftOffset.clamp(0, chartWidth)),
                                  decoration: BoxDecoration(
                                    color: progressColor,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: [
                                      BoxShadow(
                                        color: progressColor.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Percentage label
                        Padding(
                          padding: EdgeInsets.only(left: leftOffset.clamp(0, chartWidth - 40)),
                          child: Text(
                            '$progressPercent%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Date axis
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _buildDateLabels(minDate!, maxDate!, chartWidth),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _legendItem(const Color(0xFFE2E8F0), 'DURASI TOTAL'),
        _legendItem(const Color(0xFFDC2626), 'PROGRES < 50%'),
        _legendItem(const Color(0xFFF59E0B), 'PROGRES 50-99%'),
        _legendItem(const Color(0xFF16A34A), 'SELESAI 100%'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: color == const Color(0xFFE2E8F0)
                ? Border.all(color: Colors.grey.shade300)
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDateLabels(DateTime minDate, DateTime maxDate, double chartWidth) {
    final totalDays = maxDate.difference(minDate).inDays;
    // Show ~4-6 date labels depending on width
    final labelCount = (chartWidth / 120).floor().clamp(2, 6);
    final interval = totalDays ~/ (labelCount - 1);

    final labels = <Widget>[];
    for (int i = 0; i < labelCount; i++) {
      final date = minDate.add(Duration(days: i * interval));
      labels.add(
        Text(
          '${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)}',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return labels;
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }
}
