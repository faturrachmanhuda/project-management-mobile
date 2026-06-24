import 'package:flutter/material.dart';
import '../widgets/work_detail_card.dart';
import '../widgets/broadcast_colors.dart';
import '../utils/design_tokens.dart';
import '../models/modelbikinproyek.dart';

/// Page showing work details with broadcast-styled cards
class WorkDetailPage extends StatefulWidget {
  final String projectId;
  final String projectTitle;
  
  const WorkDetailPage({
    super.key,
    required this.projectId,
    required this.projectTitle,
  });

  @override
  State<WorkDetailPage> createState() => _WorkDetailPageState();
}

class _WorkDetailPageState extends State<WorkDetailPage> {
  List<ItemPekerjaan> _works = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadWorks();
  }
  
  Future<void> _loadWorks() async {
    // Simulate loading from API
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Sample data matching the screenshot style
    setState(() {
      _works = [
        ItemPekerjaan(
          id: '1',
          idProyek: widget.projectId,
          judulProyek: widget.projectTitle,
          nama: 'asdas', // Matching screenshot
          deskripsi: 'Implementation evaluation for project component',
          lokasi: 'Site Location A',
          tanggalMulai: '2026-06-23',
          tanggalSelesai: '2026-06-25',
          pelaksana: 'Team Alpha',
          pengawas: 'Supervisor Beta',
          isTersinkron: true,
        ),
        ItemPekerjaan(
          id: '2',
          idProyek: widget.projectId,
          judulProyek: widget.projectTitle,
          nama: 'dfadf', // Matching screenshot
          deskripsi: 'Control system implementation and testing',
          lokasi: 'Site Location B',
          tanggalMulai: '2026-06-24',
          tanggalSelesai: '2026-06-28',
          pelaksana: 'Team Beta',
          pengawas: 'Supervisor Gamma',
          isTersinkron: true,
        ),
        ItemPekerjaan(
          id: '3',
          idProyek: widget.projectId,
          judulProyek: widget.projectTitle,
          nama: 'System Integration',
          deskripsi: 'Final system integration and deployment',
          lokasi: 'Main Office',
          tanggalMulai: '2026-06-26',
          tanggalSelesai: '2026-07-02',
          pelaksana: 'Integration Team',
          pengawas: 'Project Manager',
          isTersinkron: false,
        ),
      ];
      _isLoading = false;
    });
  }
  
  String _getWorkStatus(ItemPekerjaan work) {
    final now = DateTime.now();
    final startDate = DateTime.tryParse(work.tanggalMulai);
    final endDate = DateTime.tryParse(work.tanggalSelesai);
    
    if (startDate == null || endDate == null) return 'BELUM';
    
    if (now.isBefore(startDate)) {
      return 'BELUM';
    } else if (now.isAfter(endDate)) {
      return 'SELESAI';
    } else {
      return 'PROGRESS';
    }
  }
  
  String _getBroadcastType(int index) {
    // Simulate different broadcast types
    final types = ['IE', 'IC', 'IMPLEMENTATION'];
    return types[index % types.length];
  }
  
  List<Map<String, dynamic>> _getActivities(ItemPekerjaan work) {
    // Sample activities for each work
    return [
      {
        'name': 'Site preparation and setup',
        'time': '09:00',
        'completed': true,
      },
      {
        'name': 'Initial component testing',
        'time': '13:13', // Matching screenshot
        'completed': _getWorkStatus(work) == 'SELESAI',
      },
      {
        'name': 'Documentation review',
        'time': '15:30',
        'completed': false,
      },
    ];
  }
  
  void _editWork(ItemPekerjaan work) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit work: ${work.nama}')),
    );
  }
  
  void _deleteWork(ItemPekerjaan work) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pekerjaan'),
        content: Text('Yakin ingin menghapus pekerjaan "${work.nama}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _works.removeWhere((w) => w.id == work.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Pekerjaan "${work.nama}" dihapus')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: BroadcastColors.statusBelum,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
  
  void _viewWorkDetails(ItemPekerjaan work) {
    // Navigate to specific work detail
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View details: ${work.nama}')),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.almostWhite,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Pekerjaan',
              style: AppTypography.h3.copyWith(
                color: BroadcastColors.textTitle,
                fontSize: 18,
              ),
            ),
            Text(
              widget.projectTitle,
              style: AppTypography.bodySmall.copyWith(
                color: BroadcastColors.textSubtitle,
                fontSize: 13,
              ),
            ),
          ],
        ),
        backgroundColor: DesignColors.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: BroadcastColors.textTitle,
        ),
      ),
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _works.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 64,
                        color: BroadcastColors.iconMuted,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada pekerjaan',
                        style: AppTypography.bodyLarge.copyWith(
                          color: BroadcastColors.textSubtitle,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: DesignColors.bg,
                          borderRadius: BorderRadius.circular(Radii.medium),
                          border: Border.all(
                            color: BroadcastColors.cardBorder,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.folder_outlined,
                                  color: BroadcastColors.iconPrimary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.projectTitle,
                                    style: AppTypography.h3.copyWith(
                                      color: BroadcastColors.textTitle,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                InfoRow(
                                  icon: Icons.assignment_outlined,
                                  text: '${_works.length} pekerjaan',
                                ),
                                const SizedBox(width: 16),
                                InfoRow(
                                  icon: Icons.sync,
                                  text: '${_works.where((w) => w.isTersinkron).length} tersinkron',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Works list
                      Text(
                        'Daftar Pekerjaan',
                        style: AppTypography.h3.copyWith(
                          color: BroadcastColors.textTitle,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Work cards
                      ...List.generate(_works.length, (index) {
                        final work = _works[index];
                        final broadcastType = _getBroadcastType(index);
                        final status = _getWorkStatus(work);
                        final activities = _getActivities(work);
                        
                        return ProjectWorkCard(
                          workTitle: work.nama,
                          projectTitle: work.judulProyek,
                          broadcastType: broadcastType,
                          status: status,
                          startDate: work.tanggalMulai,
                          endDate: work.tanggalSelesai,
                          activityCount: activities.length,
                          activities: activities,
                          onEdit: () => _editWork(work),
                          onDelete: () => _deleteWork(work),
                          onTap: () => _viewWorkDetails(work),
                        );
                      }),
                    ],
                  ),
                ),
      
      // Floating action button for adding new work
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tambah pekerjaan baru')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Pekerjaan'),
        backgroundColor: BroadcastColors.iePrimary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

/// Example usage page showing different card variations
class WorkCardExamplesPage extends StatelessWidget {
  const WorkCardExamplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.almostWhite,
      appBar: AppBar(
        title: const Text('Work Card Examples'),
        backgroundColor: DesignColors.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Card Variations',
              style: AppTypography.h2.copyWith(
                color: BroadcastColors.textTitle,
              ),
            ),
            const SizedBox(height: 16),
            
            // IE type card (matching screenshot)
            WorkDetailCard(
              title: 'asdas', // Exact from screenshot
              broadcastType: 'IE',
              status: 'BELUM',
              dateRange: '2026-06-23 - 2026-06-25',
              activityCount: 1,
              activities: [
                const ActivitySummaryItem(
                  name: 'dfadf',
                  time: '13:13',
                  isCompleted: false,
                ),
              ],
              onEdit: () {},
              onDelete: () {},
            ),
            
            // IC type card
            WorkDetailCard(
              title: 'Control System Setup',
              broadcastType: 'IC',
              status: 'PROGRESS',
              dateRange: '2026-06-24 - 2026-06-28',
              activityCount: 3,
              activities: [
                const ActivitySummaryItem(
                  name: 'Hardware installation',
                  time: '08:00',
                  isCompleted: true,
                ),
                const ActivitySummaryItem(
                  name: 'Software configuration',
                  time: '14:30',
                  isCompleted: false,
                ),
              ],
              onEdit: () {},
              onDelete: () {},
            ),
            
            // Implementation type card
            WorkDetailCard(
              title: 'Final Implementation',
              broadcastType: 'IMPLEMENTATION',
              status: 'SELESAI',
              dateRange: '2026-06-26 - 2026-07-02',
              activityCount: 5,
              activities: [
                const ActivitySummaryItem(
                  name: 'System deployment',
                  time: '10:15',
                  isCompleted: true,
                ),
                const ActivitySummaryItem(
                  name: 'User training',
                  time: '16:45',
                  isCompleted: true,
                ),
                const ActivitySummaryItem(
                  name: 'Documentation handover',
                  time: '17:30',
                  isCompleted: true,
                ),
              ],
              onEdit: () {},
              onDelete: () {},
            ),
          ],
        ),
      ),
    );
  }
}