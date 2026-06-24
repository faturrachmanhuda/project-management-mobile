import { useState, useMemo } from 'react';
import {
  X, BarChart3, FolderKanban, Briefcase, CheckCircle2, Circle,
  ChevronDown, ChevronRight, Filter, Download, Image as ImageIcon,
  ClipboardList, MapPin, Calendar, Users, FileText
} from 'lucide-react';
import { useProjects, Project, Work } from '../context/ProjectContext';

interface TaskReportModalProps {
  onClose: () => void;
}

type FilterStatus = 'all' | 'done' | 'undone';

const categoryLabel: Record<Work['category'], string> = {
  engineering: 'Rekayasa',
  creation: 'Kreasi',
  implementation: 'Implementasi',
};

const categoryColor: Record<Work['category'], string> = {
  engineering: 'bg-blue-100 text-blue-800',
  creation: 'bg-purple-100 text-purple-800',
  implementation: 'bg-orange-100 text-orange-800',
};

function formatDate(dateStr: string) {
  if (!dateStr) return '-';
  return new Date(dateStr).toLocaleDateString('id-ID', {
    day: 'numeric', month: 'long', year: 'numeric'
  });
}

export function TaskReportModal({ onClose }: TaskReportModalProps) {
  const { projects, works } = useProjects();
  const [selectedProjectId, setSelectedProjectId] = useState<string>('all');
  const [filterStatus, setFilterStatus] = useState<FilterStatus>('all');
  const [expandedProjects, setExpandedProjects] = useState<Set<string>>(new Set(projects.map(p => p.id)));
  const [expandedWorks, setExpandedWorks] = useState<Set<string>>(new Set());
  const [lightboxPhoto, setLightboxPhoto] = useState<string | null>(null);

  const toggleProject = (id: string) => {
    setExpandedProjects(prev => {
      const next = new Set(prev);
      next.has(id) ? next.delete(id) : next.add(id);
      return next;
    });
  };

  const toggleWork = (id: string) => {
    setExpandedWorks(prev => {
      const next = new Set(prev);
      next.has(id) ? next.delete(id) : next.add(id);
      return next;
    });
  };

  const displayedProjects: Project[] = useMemo(() => {
    if (selectedProjectId === 'all') return projects;
    return projects.filter(p => p.id === selectedProjectId);
  }, [projects, selectedProjectId]);

  const getWorksForProject = (projectId: string) =>
    works.filter(w => w.projectId === projectId);

  const getFilteredActivities = (work: Work) => {
    switch (filterStatus) {
      case 'done': return work.activities.filter(a => a.done);
      case 'undone': return work.activities.filter(a => !a.done);
      default: return work.activities;
    }
  };

  // Summary stats
  const stats = useMemo(() => {
    const relevantWorks = selectedProjectId === 'all'
      ? works
      : works.filter(w => w.projectId === selectedProjectId);
    const allActivities = relevantWorks.flatMap(w => w.activities);
    const done = allActivities.filter(a => a.done).length;
    return {
      projects: displayedProjects.length,
      works: relevantWorks.length,
      total: allActivities.length,
      done,
      undone: allActivities.length - done,
      pct: allActivities.length > 0 ? Math.round((done / allActivities.length) * 100) : 0,
    };
  }, [works, selectedProjectId, displayedProjects]);

  const handlePrint = () => {
    window.print();
  };

  return (
    <>
      <div
        className="fixed inset-0 bg-black/50 flex items-end sm:items-center justify-center z-50 p-0 sm:p-4"
        onClick={onClose}
      >
        <div
          className="bg-white rounded-t-2xl sm:rounded-2xl w-full sm:max-w-4xl shadow-2xl max-h-[95vh] sm:max-h-[90vh] flex flex-col"
          onClick={e => e.stopPropagation()}
        >
          {/* Header */}
          <div className="px-5 sm:px-8 pt-5 pb-4 border-b border-gray-100 shrink-0">
            <div className="w-10 h-1 bg-gray-300 rounded-full mx-auto mb-4 sm:hidden" />
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-9 h-9 bg-red-800 rounded-lg flex items-center justify-center">
                  <BarChart3 className="w-5 h-5 text-white" />
                </div>
                <div>
                  <h2 className="text-lg font-bold text-gray-900">Laporan Tugas</h2>
                  <p className="text-xs text-gray-500 mt-0.5">Ringkasan aktivitas berdasarkan proyek</p>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <button
                  onClick={handlePrint}
                  title="Cetak Laporan"
                  className="hidden sm:flex items-center gap-1.5 text-sm font-medium text-gray-600 hover:text-red-800 hover:bg-red-50 px-3 py-2 rounded-lg transition-colors border border-gray-200 hover:border-red-200"
                >
                  <Download className="w-4 h-4" />
                  Cetak
                </button>
                <button
                  onClick={onClose}
                  className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
                >
                  <X className="w-5 h-5 text-gray-500" />
                </button>
              </div>
            </div>
          </div>

          {/* Filters */}
          <div className="px-5 sm:px-8 py-3 border-b border-gray-100 shrink-0 flex flex-col sm:flex-row gap-2 sm:gap-4">
            {/* Project filter */}
            <div className="flex items-center gap-2 min-w-0">
              <FolderKanban className="w-4 h-4 text-gray-400 shrink-0" />
              <select
                value={selectedProjectId}
                onChange={e => setSelectedProjectId(e.target.value)}
                className="text-sm border border-gray-200 rounded-lg px-3 py-1.5 text-gray-700 focus:outline-none focus:ring-1 focus:ring-red-800 focus:border-red-800 bg-white flex-1 sm:flex-none sm:min-w-[200px]"
              >
                <option value="all">Semua Proyek</option>
                {projects.map(p => (
                  <option key={p.id} value={p.id}>{p.name}</option>
                ))}
              </select>
            </div>

            {/* Status filter */}
            <div className="flex items-center gap-2">
              <Filter className="w-4 h-4 text-gray-400 shrink-0" />
              <div className="flex rounded-lg overflow-hidden border border-gray-200">
                {(['all', 'done', 'undone'] as FilterStatus[]).map(s => (
                  <button
                    key={s}
                    onClick={() => setFilterStatus(s)}
                    className={`px-3 py-1.5 text-sm font-medium transition-colors ${
                      filterStatus === s
                        ? 'bg-red-800 text-white'
                        : 'bg-white text-gray-600 hover:bg-gray-50'
                    }`}
                  >
                    {s === 'all' ? 'Semua' : s === 'done' ? 'Selesai' : 'Belum'}
                  </button>
                ))}
              </div>
            </div>
          </div>

          {/* Summary Stats */}
          <div className="px-5 sm:px-8 py-3 bg-gray-50 border-b border-gray-100 shrink-0">
            <div className="grid grid-cols-4 gap-2 sm:gap-4">
              <div className="text-center">
                <p className="text-lg sm:text-2xl font-bold text-gray-900">{stats.projects}</p>
                <p className="text-xs text-gray-500 mt-0.5">Proyek</p>
              </div>
              <div className="text-center">
                <p className="text-lg sm:text-2xl font-bold text-gray-900">{stats.works}</p>
                <p className="text-xs text-gray-500 mt-0.5">Pekerjaan</p>
              </div>
              <div className="text-center">
                <p className="text-lg sm:text-2xl font-bold text-green-700">{stats.done}</p>
                <p className="text-xs text-gray-500 mt-0.5">Selesai</p>
              </div>
              <div className="text-center">
                <p className="text-lg sm:text-2xl font-bold text-red-800">{stats.undone}</p>
                <p className="text-xs text-gray-500 mt-0.5">Belum</p>
              </div>
            </div>

            {/* Progress bar */}
            {stats.total > 0 && (
              <div className="mt-3">
                <div className="flex justify-between items-center mb-1">
                  <span className="text-xs text-gray-500">Progress Keseluruhan</span>
                  <span className="text-xs font-semibold text-gray-700">{stats.pct}%</span>
                </div>
                <div className="h-2 bg-gray-200 rounded-full overflow-hidden">
                  <div
                    className="h-full bg-red-800 rounded-full transition-all"
                    style={{ width: `${stats.pct}%` }}
                  />
                </div>
              </div>
            )}
          </div>

          {/* Content */}
          <div className="flex-1 overflow-y-auto px-5 sm:px-8 py-4 space-y-4">
            {displayedProjects.length === 0 && (
              <div className="text-center py-16">
                <FolderKanban className="w-12 h-12 text-gray-300 mx-auto mb-3" />
                <p className="text-gray-500">Belum ada proyek tersedia.</p>
              </div>
            )}

            {displayedProjects.map(project => {
              const projectWorks = getWorksForProject(project.id);
              const allActs = projectWorks.flatMap(w => w.activities);
              const doneCount = allActs.filter(a => a.done).length;
              const pct = allActs.length > 0 ? Math.round((doneCount / allActs.length) * 100) : 0;
              const isExpanded = expandedProjects.has(project.id);

              return (
                <div key={project.id} className="border border-gray-200 rounded-xl overflow-hidden">
                  {/* Project row */}
                  <button
                    className="w-full flex items-center gap-3 px-4 py-4 bg-gray-50 hover:bg-gray-100 transition-colors text-left"
                    onClick={() => toggleProject(project.id)}
                  >
                    <div className="w-8 h-8 bg-red-800 rounded-lg flex items-center justify-center shrink-0">
                      <FolderKanban className="w-4 h-4 text-white" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 flex-wrap">
                        <p className="font-semibold text-gray-900 truncate">{project.name}</p>
                        <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${
                          project.status === 'Aktif' ? 'bg-green-100 text-green-800'
                          : project.status === 'Selesai' ? 'bg-blue-100 text-blue-800'
                          : 'bg-yellow-100 text-yellow-800'
                        }`}>
                          {project.status}
                        </span>
                      </div>
                      <div className="flex items-center gap-3 mt-1">
                        <span className="text-xs text-gray-500">{projectWorks.length} pekerjaan · {allActs.length} aktivitas</span>
                        <span className="text-xs text-green-700 font-medium">{doneCount} selesai ({pct}%)</span>
                      </div>
                      {allActs.length > 0 && (
                        <div className="h-1.5 bg-gray-200 rounded-full overflow-hidden mt-2 w-full max-w-xs">
                          <div className="h-full bg-red-800 rounded-full" style={{ width: `${pct}%` }} />
                        </div>
                      )}
                    </div>
                    <div className="shrink-0 text-gray-400">
                      {isExpanded ? <ChevronDown className="w-4 h-4" /> : <ChevronRight className="w-4 h-4" />}
                    </div>
                  </button>

                  {/* Project meta info */}
                  {isExpanded && (
                    <div className="border-t border-gray-100">
                      <div className="px-4 py-2 bg-white flex flex-wrap gap-x-4 gap-y-1 text-xs text-gray-500 border-b border-dashed border-gray-100">
                        <span className="flex items-center gap-1"><MapPin className="w-3 h-3" /> {project.location}</span>
                        <span className="flex items-center gap-1"><Calendar className="w-3 h-3" /> {formatDate(project.startDate)} – {formatDate(project.endDate)}</span>
                        <span className="flex items-center gap-1"><Users className="w-3 h-3" /> {project.executor}</span>
                        <span className="flex items-center gap-1"><ClipboardList className="w-3 h-3" /> Pembimbing: {project.supervisor}</span>
                      </div>

                      {/* Works */}
                      {projectWorks.length === 0 && (
                        <div className="px-4 py-6 text-center text-sm text-gray-400">Belum ada pekerjaan.</div>
                      )}

                      {projectWorks.map(work => {
                        const filteredActs = getFilteredActivities(work);
                        const workDone = work.activities.filter(a => a.done).length;
                        const workPct = work.activities.length > 0
                          ? Math.round((workDone / work.activities.length) * 100) : 0;
                        const isWorkExpanded = expandedWorks.has(work.id);

                        return (
                          <div key={work.id} className="border-t border-gray-100">
                            {/* Work row */}
                            <button
                              className="w-full flex items-center gap-3 px-4 py-3 hover:bg-gray-50 transition-colors text-left"
                              onClick={() => toggleWork(work.id)}
                            >
                              <div className="w-6 h-6 bg-gray-200 rounded flex items-center justify-center shrink-0">
                                <Briefcase className="w-3.5 h-3.5 text-gray-600" />
                              </div>
                              <div className="flex-1 min-w-0">
                                <div className="flex items-center gap-2 flex-wrap">
                                  <p className="text-sm font-medium text-gray-800 truncate">{work.name}</p>
                                  <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${categoryColor[work.category]}`}>
                                    {categoryLabel[work.category]}
                                  </span>
                                </div>
                                <p className="text-xs text-gray-500 mt-0.5">
                                  {work.activities.length} aktivitas · {workDone} selesai ({workPct}%)
                                </p>
                              </div>
                              <div className="shrink-0 text-gray-400">
                                {isWorkExpanded ? <ChevronDown className="w-4 h-4" /> : <ChevronRight className="w-4 h-4" />}
                              </div>
                            </button>

                            {/* Activities */}
                            {isWorkExpanded && (
                              <div className="bg-gray-50 px-4 pb-3 space-y-2">
                                {filteredActs.length === 0 && (
                                  <p className="text-xs text-gray-400 py-3 text-center">
                                    Tidak ada aktivitas yang sesuai filter.
                                  </p>
                                )}
                                {filteredActs.map(activity => (
                                  <div
                                    key={activity.id}
                                    className={`bg-white rounded-lg border p-3 ${
                                      activity.done ? 'border-green-200' : 'border-gray-200'
                                    }`}
                                  >
                                    <div className="flex items-start gap-2">
                                      <div className="mt-0.5 shrink-0">
                                        {activity.done
                                          ? <CheckCircle2 className="w-4 h-4 text-green-600" />
                                          : <Circle className="w-4 h-4 text-gray-400" />}
                                      </div>
                                      <div className="flex-1 min-w-0">
                                        <p className={`text-sm font-medium ${activity.done ? 'text-green-800' : 'text-gray-800'}`}>
                                          {activity.name}
                                        </p>
                                        <div className="flex flex-wrap gap-x-3 gap-y-0.5 mt-1 text-xs text-gray-500">
                                          <span>Waktu: {activity.executionTime}</span>
                                          <span>Pelaksana: {activity.executor}</span>
                                        </div>

                                        {/* Evaluation */}
                                        {activity.evaluation && (
                                          <div className="mt-2 p-2 bg-blue-50 rounded border border-blue-100">
                                            <p className="text-xs font-medium text-blue-800 flex items-center gap-1 mb-0.5">
                                              <FileText className="w-3 h-3" /> Evaluasi Realisasi
                                            </p>
                                            <p className="text-xs text-blue-700">{activity.evaluation}</p>
                                          </div>
                                        )}

                                        {/* Additional Plan */}
                                        {activity.additionalPlan && (
                                          <div className="mt-1.5 p-2 bg-amber-50 rounded border border-amber-100">
                                            <p className="text-xs font-medium text-amber-800 flex items-center gap-1 mb-0.5">
                                              <ClipboardList className="w-3 h-3" /> Rencana Tindak Lanjut
                                            </p>
                                            <p className="text-xs text-amber-700">{activity.additionalPlan}</p>
                                          </div>
                                        )}

                                        {/* Photos */}
                                        {activity.photos && activity.photos.length > 0 && (
                                          <div className="mt-2">
                                            <p className="text-xs font-medium text-gray-600 flex items-center gap-1 mb-1">
                                              <ImageIcon className="w-3 h-3" /> Dokumentasi ({activity.photos.length} foto)
                                            </p>
                                            <div className="flex flex-wrap gap-1.5">
                                              {activity.photos.slice(0, 6).map((photo, idx) => (
                                                <button
                                                  key={idx}
                                                  onClick={() => setLightboxPhoto(photo)}
                                                  className="w-14 h-14 rounded overflow-hidden border border-gray-200 hover:border-red-400 transition-colors shrink-0"
                                                >
                                                  <img
                                                    src={photo}
                                                    alt={`Foto ${idx + 1}`}
                                                    className="w-full h-full object-cover"
                                                  />
                                                </button>
                                              ))}
                                              {activity.photos.length > 6 && (
                                                <div className="w-14 h-14 rounded border border-gray-200 bg-gray-100 flex items-center justify-center text-xs text-gray-500 font-medium shrink-0">
                                                  +{activity.photos.length - 6}
                                                </div>
                                              )}
                                            </div>
                                          </div>
                                        )}
                                      </div>

                                      {/* Status badge */}
                                      <span className={`shrink-0 text-xs px-2 py-0.5 rounded-full font-medium ${
                                        activity.done ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-600'
                                      }`}>
                                        {activity.done ? 'Selesai' : 'Belum'}
                                      </span>
                                    </div>
                                  </div>
                                ))}
                              </div>
                            )}
                          </div>
                        );
                      })}
                    </div>
                  )}
                </div>
              );
            })}
          </div>

          {/* Footer */}
          <div className="px-5 sm:px-8 py-3 border-t border-gray-100 shrink-0 flex justify-end">
            <button
              onClick={onClose}
              className="px-4 py-2 text-sm font-medium text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition-colors"
            >
              Tutup
            </button>
          </div>
        </div>
      </div>

      {/* Lightbox */}
      {lightboxPhoto && (
        <div
          className="fixed inset-0 bg-black/80 flex items-center justify-center z-[60] p-4"
          onClick={() => setLightboxPhoto(null)}
        >
          <div className="relative max-w-2xl w-full" onClick={e => e.stopPropagation()}>
            <img
              src={lightboxPhoto}
              alt="Dokumentasi"
              className="w-full max-h-[80vh] object-contain rounded-xl"
            />
            <button
              onClick={() => setLightboxPhoto(null)}
              className="absolute top-2 right-2 bg-black/60 hover:bg-black/80 text-white rounded-full p-1.5 transition-colors"
            >
              <X className="w-5 h-5" />
            </button>
          </div>
        </div>
      )}
    </>
  );
}
