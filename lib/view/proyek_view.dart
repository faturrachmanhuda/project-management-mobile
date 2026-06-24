import 'package:flutter/material.dart';

import '../models/modelbikinproyek.dart';
import '../utils/design_tokens.dart';

/// Widget yang menampilkan daftar proyek dari model utama [Proyek].
/// Sebelumnya widget ini menggunakan dummy ViewModel (ProyekViewModel lama)
/// yang memiliki data statis dan tidak terhubung ke sistem utama.
class ProyekView extends StatelessWidget {
  const ProyekView({super.key, required this.daftarProyek});

  final List<Proyek> daftarProyek;

  @override
  Widget build(BuildContext context) {
    if (daftarProyek.isEmpty) {
      return const Center(child: Text('Belum ada proyek.'));
    }
    return Column(
      children: daftarProyek.map((proyek) {
        // Hitung progress berdasarkan kegiatan yang selesai
        final totalKegiatan = proyek.daftarKegiatan.length;
        final kegiatanSelesai =
            proyek.daftarKegiatan.where((k) => k.selesai).length;
        final progress = totalKegiatan > 0
            ? (kegiatanSelesai / totalKegiatan * 100)
            : (proyek.isTertutup ? 100.0 : 0.0);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE1EBE8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      proyek.nama,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${progress.toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                proyek.deskripsi,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: progress / 100,
                  backgroundColor: DesignColors.surfaceSoft,
                  color: DesignColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('PM: ${proyek.pengawas.isNotEmpty ? proyek.pengawas : "-"}'),
                  const SizedBox(width: 14),
                  Text('Tim: ${proyek.tim.isNotEmpty ? proyek.tim : "-"}'),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
