import 'package:flutter/material.dart';
import '../../utils/design_tokens.dart';
import '../../models/modelbikinproyek.dart';

typedef ActivityCallback = void Function(ItemKegiatan activity);

class WorkDetailCard extends StatefulWidget {
  final ItemPekerjaan work;
  final Proyek project;
  final ActivityCallback? onAddActivity;

  const WorkDetailCard({super.key, required this.work, required this.project, this.onAddActivity});

  @override
  State<WorkDetailCard> createState() => _WorkDetailCardState();
}

class _WorkDetailCardState extends State<WorkDetailCard> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // compute activity counts
    final activities = widget.project.daftarKegiatan.where((k) => k.idPekerjaan == widget.work.id).toList();
    final total = activities.length;
    final done = activities.where((a) => a.selesai).length;
    final prog = total == 0 ? 0 : ((done / total) * 100).round();

    return Material(
      color: DesignColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: DesignColors.borderMuted)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(widget.work.nama, style: AppTypography.h3)),
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFFE4E6), borderRadius: BorderRadius.circular(20)), child: const Text('BELUM', style: TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w700))),
              ],
            ),
            const SizedBox(height: 6),
            Text(widget.work.deskripsi, style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            TabBar(
              controller: _tabController,
              labelColor: DesignColors.primary,
              unselectedLabelColor: DesignColors.hint,
              indicatorColor: DesignColors.primary,
              indicatorWeight: 3,
              labelStyle: AppTypography.labelMedium,
              unselectedLabelStyle: AppTypography.caption,
              padding: const EdgeInsets.symmetric(vertical: 0),
              tabs: const [Tab(text: 'AKTIVITAS'), Tab(text: 'STATUS & BUKTI'), Tab(text: 'AKSI')],
            ),
            const SizedBox(height: 8),
            Builder(builder: (context) {
              final w = MediaQuery.of(context).size.width;
              final panelHeight = w < 600 ? 300.0 : 220.0;
              return SizedBox(
                height: panelHeight,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Padding(padding: const EdgeInsets.only(top: 8), child: _buildActivitiesTab(activities)),
                    Padding(padding: const EdgeInsets.only(top: 8), child: _buildStatusTab(total, done, prog)),
                    Padding(padding: const EdgeInsets.only(top: 8), child: _buildActionsTab()),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesTab(List<ItemKegiatan> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: activities.isEmpty
              ? Center(child: Text('Belum ada aktivitas', style: AppTypography.caption))
              : ListView.separated(
                  itemCount: activities.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (_, idx) {
                    final a = activities[idx];
                    return Row(
                      children: [
                        Checkbox(value: a.selesai, onChanged: (_) {}),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a.namaKegiatan, style: AppTypography.bodyLarge), Text('${a.waktuPelaksanaan} · ${a.pelaksana}', style: AppTypography.caption)])),
                      ],
                    );
                  },
                ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: _onTambahAktivitas, style: ElevatedButton.styleFrom(backgroundColor: DesignColors.surface, foregroundColor: DesignColors.primary, elevation: 0, side: BorderSide(color: DesignColors.borderMuted)), child: const Text('+ Tambah Aktivitas')),
      ],
    );
  }

  Widget _buildStatusTab(int total, int done, int prog) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PROGRESS PEKERJAAN', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(children: [Expanded(child: _simpleProgress(prog)), const SizedBox(width: 12), Text('$prog%', style: const TextStyle(fontWeight: FontWeight.w800, color: DesignColors.primary))]),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)), child: Text('0 File\nTotal bukti dari semua aktivitas', style: AppTypography.caption)),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFDF2F2), borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Informasi Pekerjaan', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text('Pelaksana: ${widget.work.pelaksana}'), Text('Pengawas: ${widget.work.pengawas}'), Text('Kategori: -')])),
        ],
      ),
    );
  }

  Widget _buildActionsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton.icon(onPressed: () {}, icon: const Icon(Icons.open_in_new), label: const Text('Lihat Detail Lengkap')),
          const SizedBox(height: 8),
          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: const Text('Edit Pekerjaan'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFF7ED), foregroundColor: Colors.black)),
          const SizedBox(height: 8),
          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.delete_outline), label: const Text('Hapus Pekerjaan'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFEBEE), foregroundColor: Colors.black)),
        ],
      ),
    );
  }

  Widget _simpleProgress(int percent) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(height: 8, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)), child: FractionallySizedBox(widthFactor: (percent / 100).clamp(0.0, 1.0), alignment: Alignment.centerLeft, child: Container(decoration: BoxDecoration(color: DesignColors.primary, borderRadius: BorderRadius.circular(8))))),
      const SizedBox(height: 6),
      Text('${doneActivities} / ${totalActivities} Aktivitas Selesai', style: const TextStyle(fontSize: 11, color: DesignColors.hint, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
    ]);
  }

  int get totalActivities => widget.project.daftarKegiatan.where((k) => k.idPekerjaan == widget.work.id).length;
  int get doneActivities => widget.project.daftarKegiatan.where((k) => k.idPekerjaan == widget.work.id && k.selesai).length;

  Future<void> _onTambahAktivitas() async {
    final result = await showDialog<ItemKegiatan>(context: context, builder: (_) => _AddActivityDialog(defaultWorkId: widget.work.id, defaultProjectId: widget.project.id));
    if (result != null) {
      // pass to parent
      widget.onAddActivity?.call(result);
      setState(() {});
    }
  }
}

class _AddActivityDialog extends StatefulWidget {
  final String defaultWorkId;
  final String defaultProjectId;
  const _AddActivityDialog({required this.defaultWorkId, required this.defaultProjectId});

  @override
  State<_AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<_AddActivityDialog> {
  final _formKey = GlobalKey<FormState>();
  String nama = '';
  String waktu = '';
  String pelaksana = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Aktivitas'),
      content: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(decoration: const InputDecoration(labelText: 'Nama Aktivitas'), onSaved: (v) => nama = v ?? ''),
          TextFormField(decoration: const InputDecoration(labelText: 'Waktu'), onSaved: (v) => waktu = v ?? ''),
          TextFormField(decoration: const InputDecoration(labelText: 'Pelaksana'), onSaved: (v) => pelaksana = v ?? ''),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')), ElevatedButton(onPressed: _onSubmit, child: const Text('Tambah'))],
    );
  }

  void _onSubmit() {
    _formKey.currentState?.save();
    final newAct = ItemKegiatan(id: DateTime.now().millisecondsSinceEpoch.toString(), idProyek: widget.defaultProjectId, idPekerjaan: widget.defaultWorkId, pekerjaan: '', namaKegiatan: nama, waktuPelaksanaan: waktu, pelaksana: pelaksana, selesai: false);
    Navigator.of(context).pop(newAct);
  }
}
