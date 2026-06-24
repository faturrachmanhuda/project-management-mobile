import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/modelbikinproyek.dart';

class PdfExportHelper {
  /// Format date string from 'yyyy-MM-dd' to 'dd/MM/yyyy' if possible
  static String _formatDate(String dateStr) {
    if (dateStr.isEmpty || dateStr == '-') return '-';
    // Handle date ranges (e.g. "2026-02-01 - 2026-07-15")
    if (dateStr.contains(' - ')) {
      final parts = dateStr.split(' - ');
      return '${_formatDate(parts[0])} s/d ${_formatDate(parts[1])}';
    }
    try {
      final parsed = DateTime.parse(dateStr.trim());
      return "${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}";
    } catch (_) {
      return dateStr;
    }
  }

  /// Calculate project progress based on completed activities
  static int _hitungProgresProyek(Proyek proyek) {
    final total = proyek.daftarKegiatan.length;
    if (total == 0) return 0;
    final selesai = proyek.daftarKegiatan.where((a) => a.selesai).length;
    return ((selesai / total) * 100).round();
  }

  /// Replicates Django's export_project_pdf
  static Future<void> printProjectReport(Proyek proyek) async {
    final pdf = pw.Document();
    final progresVal = _hitungProgresProyek(proyek);
    final now = DateTime.now();
    final timeStr = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(
          marginBottom: 40,
          marginTop: 40,
          marginLeft: 30,
          marginRight: 30,
        ),
        build: (context) {
          return [
            // Header
            pw.Center(
              child: pw.Text(
                "PROMANAGE - LAPORAN DETAIL PROGRES PROYEK",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#991b1b'),
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Project Summary Section
            pw.Container(
              width: double.infinity,
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColor.fromHex('#991b1b'), width: 1),
                ),
              ),
              padding: const pw.EdgeInsets.only(bottom: 6),
              margin: const pw.EdgeInsets.only(bottom: 12),
              child: pw.Text(
                "1. INFORMASI PROYEK",
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#991b1b'),
                ),
              ),
            ),

            // Summary Table Layout
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(120),
                1: const pw.FixedColumnWidth(430),
              },
              children: [
                _buildSummaryRow("Nama Proyek:", proyek.nama),
                _buildSummaryRow("Deskripsi:", proyek.deskripsi),
                _buildSummaryRow("Lokasi:", proyek.lokasi),
                _buildSummaryRow(
                  "Timeline:",
                  proyek.tanggalSelesai.isNotEmpty
                      ? "${_formatDate(proyek.tanggalMulai)} s/d ${_formatDate(proyek.tanggalSelesai)}"
                      : _formatDate(proyek.tanggalMulai),
                ),
                _buildSummaryRow("Status:", proyek.status, isBoldValue: true),
                _buildSummaryRow("Total Progres:", "$progresVal%"),
                _buildSummaryRow("Pelaksana:", proyek.tim),
                _buildSummaryRow("Supervisor:", proyek.pengawas),
              ],
            ),
            pw.SizedBox(height: 25),

            // Detailed Progress Section Header
            pw.Container(
              width: double.infinity,
              margin: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Text(
                "2. RINCIAN REALISASI & EVALUASI",
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#1f2937'),
                ),
              ),
            ),

            // Detailed Progress Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(110),
                1: const pw.FixedColumnWidth(140),
                2: const pw.FixedColumnWidth(60),
                3: const pw.FixedColumnWidth(60),
                4: const pw.FixedColumnWidth(180),
              },
              children: _buildDetailedRows(proyek),
            ),
            pw.SizedBox(height: 40),

            // Signature Section
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(275),
                1: const pw.FixedColumnWidth(275),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Center(
                      child: pw.Text("Dibuat Oleh,", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                    ),
                    pw.Center(
                      child: pw.Text("Disetujui Oleh,", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.SizedBox(height: 50),
                    pw.SizedBox(height: 50),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Center(
                      child: pw.Text("( ${proyek.tim} )", style: const pw.TextStyle(fontSize: 8)),
                    ),
                    pw.Center(
                      child: pw.Text("( ${proyek.pengawas} )", style: const pw.TextStyle(fontSize: 8)),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Center(
                      child: pw.Text("Pelaksana Proyek", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                    ),
                    pw.Center(
                      child: pw.Text("Supervisor / Pembimbing", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Footer Timestamp
            pw.Text(
              "Dokumen ini digenerate secara otomatis oleh ProManage pada $timeStr",
              style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 8, color: PdfColors.grey),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: "Report_${proyek.nama.replaceAll(' ', '_')}.pdf",
    );
  }

  /// Replicates Django's export_all_pdf
  static Future<void> printGlobalReport(List<Proyek> projects, Map<String, dynamic> user) async {
    final pdf = pw.Document();
    final totalProjects = projects.length;
    final doneProjects = projects.where((p) => p.status == 'Selesai' || p.isTertutup).length;
    final now = DateTime.now();
    final timeStr = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    final dateStr = "${now.day} ${_getMonthName(now.month)} ${now.year}";

    final userName = user['name'] ?? user['username'] ?? user['namaLengkap'] ?? 'User';
    final userNim = user['nim'] ?? '-';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(
          marginBottom: 40,
          marginTop: 40,
          marginLeft: 40,
          marginRight: 40,
        ),
        build: (context) {
          return [
            // Branding Header
            pw.Center(
              child: pw.Text(
                "PROMANAGE - LAPORAN KOMPREHENSIF PORTOFOLIO",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#991b1b'),
                ),
              ),
            ),
            pw.SizedBox(height: 15),

            // Header Meta Table
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(80),
                1: const pw.FixedColumnWidth(180),
                2: const pw.FixedColumnWidth(100),
                3: const pw.FixedColumnWidth(170),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Text("Dibuat untuk:", style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(userName, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.Text("Total Proyek:", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#991b1b'))),
                    pw.Text(totalProjects.toString(), style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text("Tanggal:", style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(dateStr, style: const pw.TextStyle(fontSize: 9)),
                    pw.Text("Proyek Selesai:", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#991b1b'))),
                    pw.Text(doneProjects.toString(), style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Section I: Summary
            pw.Text(
              "I. RINGKASAN STATUS PORTOFOLIO",
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1f2937')),
            ),
            pw.SizedBox(height: 10),

            // Portfolio summary table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(160),
                1: const pw.FixedColumnWidth(110),
                2: const pw.FixedColumnWidth(140),
                3: const pw.FixedColumnWidth(60),
                4: const pw.FixedColumnWidth(60),
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColor.fromHex('#991b1b')),
                  children: [
                    _buildHeaderCell("Nama Proyek"),
                    _buildHeaderCell("Lokasi"),
                    _buildHeaderCell("Timeline"),
                    _buildHeaderCell("Progres"),
                    _buildHeaderCell("Status"),
                  ],
                ),
                // Project rows
                ...projects.map((p) {
                  final prog = _hitungProgresProyek(p);
                  final timeline = p.tanggalSelesai.isNotEmpty
                      ? "${_formatDate(p.tanggalMulai)} - ${_formatDate(p.tanggalSelesai)}"
                      : _formatDate(p.tanggalMulai);
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(p.nama, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(p.lokasi, style: const pw.TextStyle(fontSize: 8)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(timeline, style: const pw.TextStyle(fontSize: 8)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Center(child: pw.Text("$prog%", style: const pw.TextStyle(fontSize: 8))),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Center(child: pw.Text(p.status, style: const pw.TextStyle(fontSize: 8))),
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 25),

            // Section II: Detail Breakdown
            pw.Text(
              "II. DETAIL RINCIAN SETIAP PROYEK",
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1f2937')),
            ),

            ...projects.expand((p) {
              final limitDesc = p.deskripsi.length > 200
                  ? "${p.deskripsi.substring(0, 200)}..."
                  : p.deskripsi;
              return [
                pw.SizedBox(height: 15),
                pw.Text(
                  "PROYEK: ${p.nama.toUpperCase()}",
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  limitDesc,
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
                ),
                pw.SizedBox(height: 5),
                if (p.daftarPekerjaan.isEmpty)
                  pw.Text(
                    "Belum ada detail aktivitas untuk proyek ini.",
                    style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic),
                  )
                else
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
                    columnWidths: {
                      0: const pw.FixedColumnWidth(100),
                      1: const pw.FixedColumnWidth(140),
                      2: const pw.FixedColumnWidth(60),
                      3: const pw.FixedColumnWidth(60),
                      4: const pw.FixedColumnWidth(170),
                    },
                    children: [
                      // Sub-table Header
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColor.fromHex('#374151')),
                        children: [
                          _buildHeaderCell("Pekerjaan"),
                          _buildHeaderCell("Aktivitas"),
                          _buildHeaderCell("Waktu"),
                          _buildHeaderCell("Status"),
                          _buildHeaderCell("Evaluasi"),
                        ],
                      ),
                      ..._buildGlobalDetailedRows(p),
                    ],
                  ),
              ];
            }),
          ];
        },
      ),
    );

    // lembar pengesahan page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter.copyWith(
          marginBottom: 40,
          marginTop: 40,
          marginLeft: 40,
          marginRight: 40,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 50),
              pw.Text(
                "LEMBAR PENGESAHAN PORTOFOLIO",
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1f2937')),
              ),
              pw.SizedBox(height: 40),
              pw.Table(
                columnWidths: {
                  0: const pw.FixedColumnWidth(275),
                  1: const pw.FixedColumnWidth(275),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Center(
                        child: pw.Text("Penanggung Jawab Portofolio,", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                      ),
                      pw.Center(
                        child: pw.Text("Mengetahui,", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.SizedBox(height: 60),
                      pw.SizedBox(height: 60),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Center(
                        child: pw.Text("( $userName )", style: const pw.TextStyle(fontSize: 8)),
                      ),
                      pw.Center(
                        child: pw.Text("( __________________________ )", style: const pw.TextStyle(fontSize: 8)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Center(
                        child: pw.Text("NIM: $userNim", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                      ),
                      pw.Center(
                        child: pw.Text("Supervisor / Koordinator", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Spacer(),
              pw.Text(
                "Laporan ini dihasilkan secara sistem oleh ProManage pada $timeStr",
                style: pw.TextStyle(fontStyle: pw.FontStyle.italic, fontSize: 8, color: PdfColors.grey),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: "Global_Portfolio_Report.pdf",
    );
  }

  /// Builds the table rows for the detailed progress report
  static List<pw.TableRow> _buildDetailedRows(Proyek proyek) {
    final List<pw.TableRow> rows = [];

    // Header row
    rows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColor.fromHex('#991b1b')),
        children: [
          _buildHeaderCell("Pekerjaan"),
          _buildHeaderCell("Aktivitas"),
          _buildHeaderCell("Waktu"),
          _buildHeaderCell("Status"),
          _buildHeaderCell("Evaluasi & Rencana"),
        ],
      ),
    );

    for (var work in proyek.daftarPekerjaan) {
      final activities = proyek.daftarKegiatan.where((a) => a.idPekerjaan == work.id).toList();

      final workInfo = pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(work.nama, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
          pw.SizedBox(height: 2),
          pw.Text(
            "(${_formatDate(work.tanggalMulai)} - ${_formatDate(work.tanggalSelesai)})",
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey),
          ),
        ],
      );

      if (activities.isEmpty) {
        rows.add(
          pw.TableRow(
            children: [
              pw.Padding(padding: const pw.EdgeInsets.all(6), child: workInfo),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text("Belum ada aktivitas", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
              ),
              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text("-", style: const pw.TextStyle(fontSize: 8)))),
              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Center(child: pw.Text("-", style: const pw.TextStyle(fontSize: 8)))),
              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text("-", style: const pw.TextStyle(fontSize: 8))),
            ],
          ),
        );
        continue;
      }

      for (var idx = 0; idx < activities.length; idx++) {
        final activity = activities[idx];
        final statusText = activity.selesai ? "SELESAI" : "PROSES";
        final evalContent = "Eval: ${activity.evaluasi.isNotEmpty ? activity.evaluasi : '-'}\nRencana: ${activity.rencanaTambahan.isNotEmpty ? activity.rencanaTambahan : '-'}";

        rows.add(
          pw.TableRow(
            children: [
              // Display work title only on the first activity row
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: idx == 0 ? workInfo : pw.SizedBox.shrink(),
              ),
              // Activity info
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(activity.namaKegiatan, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                    pw.SizedBox(height: 2),
                    pw.Text("Pelaksana: ${activity.pelaksana}", style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey)),
                  ],
                ),
              ),
              // Execution Time
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(activity.waktuPelaksanaan, style: const pw.TextStyle(fontSize: 8)),
              ),
              // Status
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Center(
                  child: pw.Text(
                    statusText,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8,
                      color: activity.selesai ? PdfColor.fromHex('#166534') : PdfColor.fromHex('#854d0e'),
                    ),
                  ),
                ),
              ),
              // Evaluation and Plans
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(evalContent, style: const pw.TextStyle(fontSize: 8)),
              ),
            ],
          ),
        );
      }
    }

    return rows;
  }

  /// Builds detailed rows for global report
  static List<pw.TableRow> _buildGlobalDetailedRows(Proyek proyek) {
    final List<pw.TableRow> rows = [];

    for (var work in proyek.daftarPekerjaan) {
      final activities = proyek.daftarKegiatan.where((a) => a.idPekerjaan == work.id).toList();

      final workInfo = pw.Text(work.nama, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7));

      if (activities.isEmpty) {
        rows.add(
          pw.TableRow(
            children: [
              pw.Padding(padding: const pw.EdgeInsets.all(5), child: workInfo),
              pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("-", style: const pw.TextStyle(fontSize: 7))),
              pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text("-", style: const pw.TextStyle(fontSize: 7)))),
              pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Center(child: pw.Text("-", style: const pw.TextStyle(fontSize: 7)))),
              pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text("-", style: const pw.TextStyle(fontSize: 7))),
            ],
          ),
        );
        continue;
      }

      for (var idx = 0; idx < activities.length; idx++) {
        final activity = activities[idx];
        final statusText = activity.selesai ? "SELESAI" : "PROSES";
        final evalText = activity.evaluasi.isNotEmpty ? activity.evaluasi : "-";

        rows.add(
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: idx == 0 ? workInfo : pw.SizedBox.shrink(),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(activity.namaKegiatan, style: const pw.TextStyle(fontSize: 7)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(activity.waktuPelaksanaan, style: const pw.TextStyle(fontSize: 7)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Center(
                  child: pw.Text(
                    statusText,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 7,
                      color: activity.selesai ? PdfColor.fromHex('#166534') : PdfColor.fromHex('#854d0e'),
                    ),
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(evalText, style: const pw.TextStyle(fontSize: 7)),
              ),
            ],
          ),
        );
      }
    }

    return rows;
  }

  /// Helper row for project summary list
  static pw.TableRow _buildSummaryRow(String label, String value, {bool isBoldValue = false}) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: isBoldValue ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  /// Helper for Table header cell styling
  static pw.Widget _buildHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Center(
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
            fontSize: 8,
          ),
        ),
      ),
    );
  }

  /// Get Indonesian month name
  static String _getMonthName(int month) {
    const months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember"
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return "";
  }
}
