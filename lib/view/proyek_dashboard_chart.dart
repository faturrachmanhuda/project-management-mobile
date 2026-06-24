import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/modelbikinproyek.dart';
import '../utils/design_tokens.dart';
import '../viewmodel/bikinproyek_viewmodel.dart';

class ProyekDashboardChart extends StatefulWidget {
  const ProyekDashboardChart({super.key});

  @override
  State<ProyekDashboardChart> createState() => _ProyekDashboardChartState();
}

class _ProyekDashboardChartState extends State<ProyekDashboardChart> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProyekViewModel>();
    final proyekList = vm.daftarProyek;

    if (vm.sedangMemuat && proyekList.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (proyekList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
          const Icon(Icons.analytics_outlined, color: DesignColors.primary, size: 36),
              const SizedBox(height: 8),
              Text(
                vm.pesanError != null
                    ? 'Data grafik belum bisa dimuat'
                    : 'Belum ada data proyek untuk ditampilkan',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              if (vm.pesanError != null) ...[
                const SizedBox(height: 8),
                Text(
                  vm.pesanError!,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: vm.muatUlang,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final totalProyek = proyekList.length;
    int totalPekerjaan = 0;
    int totalAktivitas = 0;
    int aktivitasSelesai = 0;
    int aktifCount = 0;
    int selesaiCount = 0;
    int tertundaCount = 0;

    final Map<String, int> pekerjaanPerProyek = {};

    for (final proyek in proyekList) {
      final status = proyek.status.toLowerCase();
      if (status == 'aktif') {
        aktifCount++;
      } else if (status == 'selesai') {
        selesaiCount++;
      } else {
        tertundaCount++;
      }

      totalPekerjaan += proyek.daftarPekerjaan.length;
      if (proyek.nama.isNotEmpty) {
        pekerjaanPerProyek[proyek.nama] = proyek.daftarPekerjaan.length;
      }

      totalAktivitas += proyek.daftarKegiatan.length;
      for (final aktivitas in proyek.daftarKegiatan) {
        if (aktivitas.selesai) {
          aktivitasSelesai++;
        }
      }
    }

    final progresAktivitas =
        totalAktivitas > 0 ? (aktivitasSelesai / totalAktivitas) * 100 : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1180;
        final isMobile = constraints.maxWidth < 650;
        final summaryCardWidth = isMobile ? 180.0 : (constraints.maxWidth - 24) / 3;
        final chartCardWidth = isMobile ? 300.0 : (constraints.maxWidth - 24) / 3;

        Widget buildSummaryCards() {
          final cards = [
            SizedBox(
              width: summaryCardWidth,
              child: _SummaryCard(
                title: 'TOTAL PROYEK',
                value: totalProyek.toString(),
                icon: Icons.layers,
                color: DesignColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: summaryCardWidth,
              child: _SummaryCard(
                title: 'PEKERJAAN',
                value: totalPekerjaan.toString(),
                icon: Icons.work,
                color: DesignColors.info,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: summaryCardWidth,
              child: _SummaryCard(
                title: 'AKTIVITAS',
                value: totalAktivitas.toString(),
                icon: Icons.check_box,
                color: DesignColors.warning,
              ),
            ),
          ];

          if (isMobile) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(children: cards),
            );
          }
          return Row(children: cards);
        }

        Widget buildChartCards() {
          final cards = [
            SizedBox(
              width: isWide ? null : chartCardWidth,
              child: _StatusProyekCard(
                aktif: aktifCount,
                selesai: selesaiCount,
                tertunda: tertundaCount,
                total: totalProyek,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: isWide ? null : chartCardWidth,
              child: _GrafikPekerjaanCard(data: pekerjaanPerProyek),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: isWide ? null : chartCardWidth,
              child: _RealisasiAktivitasCard(
                total: totalAktivitas,
                selesai: aktivitasSelesai,
                progres: progresAktivitas,
              ),
            ),
          ];

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cards[0]),
                cards[1], // Spacer
                Expanded(child: cards[2]),
                cards[3], // Spacer
                Expanded(child: cards[4]),
              ],
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: cards,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_outlined, color: DesignColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Analisis Manajemen Proyek',
                  style: TextStyle(
                    fontSize: isWide ? 20 : 16,
                    fontWeight: FontWeight.w800,
                    color: DesignColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            buildSummaryCards(),
            const SizedBox(height: 14),
            buildChartCards(),
            const SizedBox(height: 14),
            _DetailProgresTable(proyekList: proyekList),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesignColors.borderMuted),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusProyekCard extends StatelessWidget {
  final int aktif;
  final int selesai;
  final int tertunda;
  final int total;

  const _StatusProyekCard({
    required this.aktif,
    required this.selesai,
    required this.tertunda,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'STATUS PROYEK',
      child: Column(
        children: [
          SizedBox(
            height: 156,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 50,
                sections: [
                  if (aktif > 0)
                    PieChartSectionData(
                      color: DesignColors.statusActive,
                      value: aktif.toDouble(),
                      radius: 22,
                      showTitle: false,
                    ),
                  if (selesai > 0)
                    PieChartSectionData(
                      color: DesignColors.statusDone,
                      value: selesai.toDouble(),
                      radius: 22,
                      showTitle: false,
                    ),
                  if (tertunda > 0)
                    PieChartSectionData(
                      color: DesignColors.warning,
                      value: tertunda.toDouble(),
                      radius: 22,
                      showTitle: false,
                    ),
                  if (total == 0)
                    PieChartSectionData(
                      color: DesignColors.surfaceSoft,
                      value: 1,
                      radius: 22,
                      showTitle: false,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: [
              _Indicator(color: DesignColors.statusActive, text: 'Aktif'),
              if (selesai > 0) _Indicator(color: DesignColors.statusDone, text: 'Selesai'),
              if (tertunda > 0)
                _Indicator(color: DesignColors.warning, text: 'Tertunda'),
            ],
          ),
        ],
      ),
    );
  }
}

class _RealisasiAktivitasCard extends StatelessWidget {
  final int total;
  final int selesai;
  final double progres;

  const _RealisasiAktivitasCard({
    required this.total,
    required this.selesai,
    required this.progres,
  });

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'REALISASI AKTIVITAS',
      child: Column(
        children: [
          SizedBox(
            height: 156,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 50,
                    startDegreeOffset: 270,
                    sections: [
                      PieChartSectionData(
                        color: DesignColors.primary,
                        value: selesai > 0 ? selesai.toDouble() : 0,
                        radius: 18,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        color: DesignColors.surfaceSoft,
                        value: total > 0 ? (total - selesai).toDouble() : 1,
                        radius: 18,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${progres.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'SELESAI',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$selesai DARI $total AKTIVITAS SELESAI',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailProgresTable extends StatelessWidget {
  final List<Proyek> proyekList;

  const _DetailProgresTable({required this.proyekList});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return DesignColors.statusDone;
      case 'tertunda':
        return DesignColors.warning;
      default:
        return DesignColors.statusActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesignColors.borderMuted),
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
          const Text(
            'DETAIL PROGRES PER PROYEK',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'NAMA PROYEK',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'STATUS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'PROGRES REALISASI',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          if (proyekList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Belum ada data proyek',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...proyekList.map((proyek) {
              final totalAktivitas = proyek.daftarKegiatan.length;
              final selesaiAktivitas =
                  proyek.daftarKegiatan.where((aktivitas) => aktivitas.selesai).length;
              final progres = totalAktivitas > 0
                  ? selesaiAktivitas / totalAktivitas
                  : 0.0;
              final statusColor = _statusColor(proyek.status);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        proyek.nama,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          proyek.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progres,
                                minHeight: 7,
                                backgroundColor: DesignColors.surfaceSoft,
                                color: DesignColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 32,
                            child: Text(
                              '${(progres * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DesignColors.borderMuted),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: DesignColors.hint,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;

  const _Indicator({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _GrafikPekerjaanCard extends StatelessWidget {
  final Map<String, int> data;

  const _GrafikPekerjaanCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY =
        data.isEmpty ? 1.0 : (data.values.fold(0, (m, v) => v > m ? v : m) + 1).toDouble();
    final entries = data.entries.toList();

    return _ChartCard(
      title: 'GRAFIK PEKERJAAN',
      child: SizedBox(
        height: 188,
        child: BarChart(
          BarChartData(
            alignment: entries.length > 3
                ? BarChartAlignment.spaceBetween
                : BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= entries.length) {
                      return const SizedBox.shrink();
                    }

                    var text = entries[index].key;
                    if (text.length > 10) {
                      text = '${text.substring(0, 8)}...';
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26,
                  interval: 1,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                ),
              ),
              topTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: DesignColors.surfaceSoft, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(entries.length, (i) {
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: entries[i].value.toDouble(),
                    color: DesignColors.primary,
                    width: 18,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
