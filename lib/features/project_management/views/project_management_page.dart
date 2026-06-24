import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pm_entities.dart';
import '../viewmodels/project_management_viewmodel.dart';

class ProjectManagementPage extends StatefulWidget {
  const ProjectManagementPage({super.key});

  @override
  State<ProjectManagementPage> createState() => _ProjectManagementPageState();
}

class _ProjectManagementPageState extends State<ProjectManagementPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ProjectManagementViewModel>().loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProjectManagementViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MVVM Project Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            onPressed: () => _showProjectDialog(context, vm),
          ),
        ],
      ),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (vm.error != null)
                  Text(vm.error!, style: const TextStyle(color: Colors.red)),
                ...vm.projects.map((p) => _projectTile(context, vm, p)),
              ],
            ),
    );
  }

  Widget _projectTile(
    BuildContext context,
    ProjectManagementViewModel vm,
    PmProject project,
  ) {
    return Card(
      child: ExpansionTile(
        title: Text(project.name),
        subtitle: Text(project.description),
        onExpansionChanged: (expanded) {
          if (expanded) {
            vm.loadWorks(project.id);
          }
        },
        children: [
          Row(
            children: [
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: () => _showWorkDialog(context, vm, project.id),
                icon: const Icon(Icons.add_task),
                label: const Text('Tambah Pekerjaan'),
              ),
            ],
          ),
          ...vm.worksForProject(project.id).map((w) => _workTile(context, vm, w)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _workTile(
    BuildContext context,
    ProjectManagementViewModel vm,
    PmWork work,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        color: const Color(0xfff8f9ff),
        child: ExpansionTile(
          title: Text(work.name),
          subtitle: Text(work.executor),
          onExpansionChanged: (expanded) {
            if (expanded) {
              vm.loadActivities(work.id);
            }
          },
          children: [
            Row(
              children: [
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => _showActivityDialog(context, vm, work.id),
                  icon: const Icon(Icons.playlist_add),
                  label: const Text('Tambah Aktivitas'),
                ),
              ],
            ),
            ...vm.activitiesForWork(work.id).map(
              (a) => ListTile(
                title: Text(a.name),
                subtitle: Text('${a.executor}   ${a.executionTime}'),
                trailing: Icon(
                  a.done ? Icons.check_circle : Icons.schedule,
                  color: a.done ? Colors.green : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showProjectDialog(BuildContext context, ProjectManagementViewModel vm) async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController();
    final desc = TextEditingController();
    final location = TextEditingController();
    final executor = TextEditingController();
    final supervisor = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Proyek'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(name, 'Nama Proyek'),
                _field(desc, 'Deskripsi'),
                _field(location, 'Lokasi'),
                _field(executor, 'Pelaksana'),
                _field(supervisor, 'Supervisor'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              await vm.createProject(
                name: name.text,
                description: desc.text,
                location: location.text,
                startDate: DateTime.now().toIso8601String(),
                endDate: DateTime.now().add(const Duration(days: 30)).toIso8601String(),
                executor: executor.text,
                supervisor: supervisor.text,
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _showWorkDialog(
    BuildContext context,
    ProjectManagementViewModel vm,
    String projectId,
  ) async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController();
    final desc = TextEditingController();
    final location = TextEditingController();
    final executor = TextEditingController();
    final supervisor = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Pekerjaan'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(name, 'Nama Pekerjaan'),
                _field(desc, 'Deskripsi'),
                _field(location, 'Lokasi'),
                _field(executor, 'Pelaksana'),
                _field(supervisor, 'Supervisor'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              await vm.createWork(
                projectId: projectId,
                name: name.text,
                description: desc.text,
                location: location.text,
                startDate: DateTime.now().toIso8601String(),
                endDate: DateTime.now().add(const Duration(days: 14)).toIso8601String(),
                executor: executor.text,
                supervisor: supervisor.text,
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _showActivityDialog(
    BuildContext context,
    ProjectManagementViewModel vm,
    String workId,
  ) async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController();
    final executor = TextEditingController();
    final evaluation = TextEditingController();
    final additionalPlan = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buat Aktivitas'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(name, 'Nama Aktivitas'),
                _field(executor, 'Pelaksana'),
                _field(evaluation, 'Evaluasi (opsional)', required: false),
                _field(additionalPlan, 'Rencana Tambahan (opsional)', required: false),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              await vm.createActivity(
                workId: workId,
                name: name.text,
                executionTime: DateTime.now().toIso8601String(),
                executor: executor.text,
                evaluation: evaluation.text,
                additionalPlan: additionalPlan.text,
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(labelText: label),
        validator: (v) {
          if (!required) return null;
          if (v == null || v.trim().isEmpty) return '$label wajib diisi';
          return null;
        },
      ),
    );
  }
}
