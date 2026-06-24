import { useState } from 'react';
import { useNavigate, useParams } from 'react-router';
import { Header } from '../components/Header';
import {
  Plus,
  Trash2,
  Calendar,
  MapPin,
  Users,
  User,
  CheckCircle,
  ArrowLeft,
  Lock,
  AlertTriangle,
  Search
} from 'lucide-react';
import { useProjects } from '../context/ProjectContext';
import { toast } from 'sonner';
import { InlineEdit } from '../components/InlineEdit';

export function ProjectDetail() {
  const navigate = useNavigate();
  const { id } = useParams();
  const {
    getProjectById,
    getWorksByProjectId,
    closeProject,
    addWork,
    deleteWork,
    renameWork,
    renameProject,
  } = useProjects();

  const project = id ? getProjectById(id) : undefined;
  const works = id ? getWorksByProjectId(id) : [];

  const [activeTab, setActiveTab] = useState<'engineering' | 'creation' | 'implementation'>('engineering');
  const [showWorkModal, setShowWorkModal] = useState(false);
  const [showCloseConfirm, setShowCloseConfirm] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');

  const [workForm, setWorkForm] = useState({
    name: '',
    description: '',
    location: '',
    startDate: '',
    endDate: '',
    executor: '',
    supervisor: '',
    category: 'engineering' as 'engineering' | 'creation' | 'implementation'
  });

  if (!project || !id) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center px-4">
        <div className="text-center">
          <p className="text-gray-600 mb-4">Proyek tidak ditemukan</p>
          <button
            onClick={() => navigate('/projects')}
            className="text-red-800 hover:underline"
          >
            Kembali ke Daftar Proyek
          </button>
        </div>
      </div>
    );
  }

  const handleCreateWork = (e: React.FormEvent) => {
    e.preventDefault();
    addWork({ projectId: id, ...workForm });
    setShowWorkModal(false);
    setWorkForm({
      name: '',
      description: '',
      location: '',
      startDate: '',
      endDate: '',
      executor: '',
      supervisor: '',
      category: activeTab
    });
    toast.success('Pekerjaan berhasil dibuat!');
  };

  const handleDeleteWork = (e: React.MouseEvent, workId: string) => {
    e.stopPropagation();
    if (confirm('Apakah Anda yakin ingin menghapus pekerjaan ini?')) {
      deleteWork(workId);
    }
  };

  const handleCloseProject = () => {
    closeProject(id);
    setShowCloseConfirm(false);
  };

  const filteredWorks = works.filter(work => {
    const matchesTab = work.category === activeTab;
    const matchesSearch =
      work.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      work.description.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesTab && matchesSearch;
  });

  const tabs = [
    { key: 'engineering', label: 'Intelligence Engineering' },
    { key: 'creation', label: 'Intelligence Creation' },
    { key: 'implementation', label: 'Implementation' },
  ] as const;

  return (
    <div className="min-h-screen bg-gray-50">
      <Header />

      {/* Project Header */}
      <section className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 py-6 md:px-12 lg:px-20 md:py-8">
          <button
            onClick={() => navigate('/projects')}
            className="flex items-center gap-2 text-gray-600 hover:text-red-800 mb-4 md:mb-6 transition-colors text-sm"
          >
            <ArrowLeft className="w-4 h-4" />
            Kembali ke Daftar Proyek
          </button>

          <div className="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-4 mb-4">
            <div className="flex-1 min-w-0">
              <h1 className="text-2xl sm:text-3xl md:text-4xl font-bold text-gray-900 mb-2 break-words">
                <InlineEdit
                  value={project.name}
                  onSave={(newName) => { renameProject(id, newName); toast.success(`Nama proyek diubah menjadi "${newName}"`); }}
                  className="break-words"
                  inputClassName="text-2xl font-bold"
                  disabled={project.isClosed}
                />
              </h1>
              <p className="text-gray-600 text-sm sm:text-base mb-4">{project.description}</p>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 md:gap-4 text-sm">
                <div className="flex items-center gap-2 text-gray-600">
                  <MapPin className="w-4 h-4 shrink-0" />
                  <span className="truncate">{project.location}</span>
                </div>
                <div className="flex items-center gap-2 text-gray-600">
                  <Calendar className="w-4 h-4 shrink-0" />
                  <span>{project.startDate} - {project.endDate}</span>
                </div>
                <div className="flex items-center gap-2 text-gray-600">
                  <Users className="w-4 h-4 shrink-0" />
                  <span className="truncate">Pelaksana: {project.executor}</span>
                </div>
                <div className="flex items-center gap-2 text-gray-600">
                  <User className="w-4 h-4 shrink-0" />
                  <span className="truncate">Supervisor: {project.supervisor}</span>
                </div>
              </div>
            </div>

            <div className="shrink-0">
              {project.isClosed ? (
                <div className="bg-red-100 text-red-800 px-4 py-2.5 rounded-lg font-medium flex items-center gap-2 text-sm">
                  <Lock className="w-4 h-4" />
                  Proyek Ditutup
                </div>
              ) : (
                <button
                  onClick={() => setShowCloseConfirm(true)}
                  className="bg-red-800 hover:bg-red-900 text-white px-4 py-2.5 rounded-lg font-medium flex items-center gap-2 transition-colors text-sm whitespace-nowrap"
                >
                  <Lock className="w-4 h-4" />
                  Tutup Proyek
                </button>
              )}
            </div>
          </div>
        </div>
      </section>

      {/* Tabs — horizontally scrollable on mobile */}
      <section className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 md:px-12 lg:px-20">
          <div className="flex overflow-x-auto scrollbar-none gap-1 -mb-px">
            {tabs.map((tab) => (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className={`py-3 px-3 sm:px-4 border-b-2 font-medium transition-colors whitespace-nowrap text-sm sm:text-base shrink-0 ${
                  activeTab === tab.key
                    ? 'border-red-800 text-red-800'
                    : 'border-transparent text-gray-600 hover:text-gray-900'
                }`}
              >
                {tab.label}
              </button>
            ))}
          </div>
        </div>
      </section>

      {/* Content */}
      <section className="px-4 py-8 sm:px-6 md:px-12 lg:px-20 md:py-12">
        <div className="max-w-7xl mx-auto">
          <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3 mb-5 md:mb-6">
            <h2 className="text-xl sm:text-2xl font-bold text-gray-900">Daftar Pekerjaan</h2>

            <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-2 sm:gap-3 w-full sm:w-auto">
              <div className="relative flex-1 sm:w-56">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Search className="h-4 w-4 text-gray-400" />
                </div>
                <input
                  type="text"
                  placeholder="Cari pekerjaan..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="block w-full pl-9 pr-3 py-2 border border-gray-300 rounded-lg bg-white placeholder-gray-500 focus:outline-none focus:ring-1 focus:ring-red-800 focus:border-red-800 text-sm"
                />
              </div>
              {!project.isClosed && (
                <button
                  onClick={() => {
                    setWorkForm(prev => ({ ...prev, category: activeTab }));
                    setShowWorkModal(true);
                  }}
                  className="bg-red-800 hover:bg-red-900 text-white px-4 py-2 rounded-lg font-medium flex items-center justify-center gap-2 transition-colors text-sm whitespace-nowrap"
                >
                  <Plus className="w-4 h-4" />
                  Buat Pekerjaan
                </button>
              )}
            </div>
          </div>

          {filteredWorks.length === 0 ? (
            <div className="bg-white rounded-xl p-10 text-center border border-gray-200">
              <CheckCircle className="w-14 h-14 text-gray-300 mx-auto mb-4" />
              <p className="text-gray-500 text-sm sm:text-base">
                {searchQuery ? 'Pekerjaan tidak ditemukan.' : 'Belum ada pekerjaan di kategori ini. Mulai dengan membuat pekerjaan baru!'}
              </p>
            </div>
          ) : (
            <div className="space-y-4 md:space-y-6">
              {filteredWorks.map((work) => (
                <div
                  key={work.id}
                  onClick={() => navigate(`/project/${id}/work/${work.id}`)}
                  className="bg-white rounded-xl p-4 sm:p-6 shadow-sm border border-gray-200 cursor-pointer hover:shadow-md hover:border-red-200 transition-all duration-200"
                >
                  <div className="flex justify-between items-start gap-3 mb-3">
                    <div className="flex-1 min-w-0">
                      <h3 className="text-lg sm:text-xl font-bold text-gray-900 mb-1 break-words">
                        <InlineEdit
                          value={work.name}
                          onSave={(newName) => { renameWork(work.id, newName); toast.success(`Nama pekerjaan diubah menjadi "${newName}"`); }}
                          className="break-words"
                          inputClassName="text-lg font-bold"
                          disabled={project.isClosed}
                        />
                      </h3>
                      <p className="text-gray-600 text-sm mb-3 line-clamp-2">{work.description}</p>
                      <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-sm text-gray-600">
                        <div className="flex items-center gap-2">
                          <MapPin className="w-4 h-4 shrink-0" />
                          <span className="truncate">{work.location}</span>
                        </div>
                        <div className="flex items-center gap-2">
                          <Calendar className="w-4 h-4 shrink-0" />
                          <span>{work.startDate} - {work.endDate}</span>
                        </div>
                        <div className="flex items-center gap-2">
                          <Users className="w-4 h-4 shrink-0" />
                          <span className="truncate">Pelaksana: {work.executor}</span>
                        </div>
                        <div className="flex items-center gap-2">
                          <User className="w-4 h-4 shrink-0" />
                          <span className="truncate">Supervisor: {work.supervisor}</span>
                        </div>
                      </div>
                    </div>
                    {!project.isClosed && (
                      <button
                        onClick={(e) => handleDeleteWork(e, work.id)}
                        className="text-red-600 hover:text-red-800 p-1.5 transition-colors z-10 relative shrink-0"
                      >
                        <Trash2 className="w-5 h-5" />
                      </button>
                    )}
                  </div>

                  <div className="border-t border-gray-100 pt-3 mt-1">
                    <span className="text-sm font-medium text-red-800 hover:text-red-900 transition-colors inline-flex items-center gap-1">
                      Lihat {work.activities.length} aktivitas &rarr;
                    </span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </section>

      {/* Create Work Modal */}
      {showWorkModal && (
        <div
          className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4"
          onClick={() => setShowWorkModal(false)}
        >
          <div
            className="bg-white rounded-2xl p-5 sm:p-8 max-w-2xl w-full shadow-2xl max-h-[90vh] overflow-y-auto"
            onClick={(e) => e.stopPropagation()}
          >
            <h3 className="text-xl sm:text-2xl font-bold text-gray-900 mb-5">Buat Pekerjaan Baru</h3>
            <form onSubmit={handleCreateWork} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">Nama Pekerjaan *</label>
                <input
                  type="text"
                  required
                  value={workForm.name}
                  onChange={(e) => setWorkForm({ ...workForm, name: e.target.value })}
                  className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">Deskripsi *</label>
                <textarea
                  required
                  value={workForm.description}
                  onChange={(e) => setWorkForm({ ...workForm, description: e.target.value })}
                  rows={3}
                  className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">Tempat *</label>
                <input
                  type="text"
                  required
                  value={workForm.location}
                  onChange={(e) => setWorkForm({ ...workForm, location: e.target.value })}
                  className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                />
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1.5">Tanggal Mulai *</label>
                  <input
                    type="date"
                    required
                    value={workForm.startDate}
                    onChange={(e) => setWorkForm({ ...workForm, startDate: e.target.value })}
                    className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1.5">Tanggal Selesai *</label>
                  <input
                    type="date"
                    required
                    value={workForm.endDate}
                    onChange={(e) => setWorkForm({ ...workForm, endDate: e.target.value })}
                    className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                  />
                </div>
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1.5">Pelaksana *</label>
                  <input
                    type="text"
                    required
                    value={workForm.executor}
                    onChange={(e) => setWorkForm({ ...workForm, executor: e.target.value })}
                    className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1.5">Supervisor *</label>
                  <input
                    type="text"
                    required
                    value={workForm.supervisor}
                    onChange={(e) => setWorkForm({ ...workForm, supervisor: e.target.value })}
                    className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                  />
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">Kategori *</label>
                <select
                  required
                  value={workForm.category}
                  onChange={(e) => setWorkForm({ ...workForm, category: e.target.value as 'engineering' | 'creation' | 'implementation' })}
                  className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                >
                  <option value="engineering">Intelligence Engineering</option>
                  <option value="creation">Intelligence Creation</option>
                  <option value="implementation">Implementation</option>
                </select>
              </div>
              <div className="flex gap-3 pt-2">
                <button
                  type="button"
                  onClick={() => setShowWorkModal(false)}
                  className="flex-1 px-4 py-2.5 border border-gray-300 rounded-lg font-medium text-gray-700 hover:bg-gray-50 transition-colors text-sm"
                >
                  Batal
                </button>
                <button
                  type="submit"
                  className="flex-1 px-4 py-2.5 bg-red-800 text-white rounded-lg font-medium hover:bg-red-900 transition-colors text-sm"
                >
                  Buat Pekerjaan
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Close Project Confirmation */}
      {showCloseConfirm && (
        <div
          className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4"
          onClick={() => setShowCloseConfirm(false)}
        >
          <div
            className="bg-white rounded-2xl p-6 sm:p-8 max-w-md w-full shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="text-center mb-6">
              <div className="w-14 h-14 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <AlertTriangle className="w-7 h-7 text-red-800" />
              </div>
              <h3 className="text-xl sm:text-2xl font-bold text-gray-900 mb-2">Tutup Proyek?</h3>
              <p className="text-gray-600 text-sm sm:text-base">
                Setelah proyek ditutup, Anda tidak dapat menambah atau menghapus pekerjaan dan aktivitas lagi.
              </p>
            </div>
            <div className="flex gap-3">
              <button
                onClick={() => setShowCloseConfirm(false)}
                className="flex-1 px-4 py-2.5 border border-gray-300 rounded-lg font-medium text-gray-700 hover:bg-gray-50 transition-colors text-sm"
              >
                Batal
              </button>
              <button
                onClick={handleCloseProject}
                className="flex-1 px-4 py-2.5 bg-red-800 text-white rounded-lg font-medium hover:bg-red-900 transition-colors text-sm"
              >
                Ya, Tutup Proyek
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}