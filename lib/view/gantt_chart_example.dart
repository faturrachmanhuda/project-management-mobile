import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/bikinproyek_viewmodel.dart';
import 'gantt_chart_widget.dart';

/// Contoh halaman yang menampilkan Gantt Chart untuk proyek tertentu
class GanttChartExamplePage extends StatelessWidget {
  final String proyekId;

  const GanttChartExamplePage({super.key, required this.proyekId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline Pekerjaan'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Consumer<ProyekViewModel>(
        builder: (context, viewModel, _) {
          // Cari proyek dengan ID yang sesuai
          final proyekList = viewModel.daftarProyek
              .where((p) => p.id == proyekId)
              .toList();

          final proyek = proyekList.isNotEmpty
              ? proyekList.first
              : (viewModel.daftarProyek.isNotEmpty
                    ? viewModel.daftarProyek.first
                    : null);

          if (proyek == null) {
            return const Center(child: Text('Proyek tidak ditemukan'));
          }

          if (proyek.daftarPekerjaan.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pekerjaan untuk proyek ini',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Proyek
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proyek.nama,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        proyek.deskripsi,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            proyek.lokasi,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Gantt Chart
                SimpleGanttChart(jobs: proyek.daftarPekerjaan),
              ],
            ),
          );
        },
      ),
    );
  }
}
