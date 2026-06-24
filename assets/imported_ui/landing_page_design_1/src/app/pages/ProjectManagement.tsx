import { useState } from 'react';
import { Plus, FolderKanban, Calendar, MapPin, Users, Trash2, Search, ArrowRight, ArrowLeft, Briefcase, CheckCircle2, X, BarChart3 } from 'lucide-react';
import { Link } from 'react-router';
import { useProjects, Work, Activity } from '../context/ProjectContext';
import { toast } from 'sonner';
import { Header } from '../components/Header';
import { ImageWithFallback } from '../components/figma/ImageWithFallback';
import { InlineEdit } from '../components/InlineEdit';
import { TaskReportModal } from '../components/TaskReportModal';

type TempWork = Omit<Work, 'id' | 'projectId' | 'activities'>;
type TempActivity = Omit<Activity, 'id'>;

export function ProjectManagement() {
  const { projects, addProject, addWork, addActivity, deleteProject, renameProject } = useProjects();
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [showReportModal, setShowReportModal] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [currentStep, setCurrentStep] = useState(1);

  const [projectData, setProjectData] = useState({
    name: '', description: '', location: '', startDate: '', endDate: '', executor: '', supervisor: ''
  });

  const [tempWorks, setTempWorks] = useState<TempWork[]>([]);
  const [workFormData, setWorkFormData] = useState<TempWork>({
    name: '', description: '', location: '', startDate: '', endDate: '', executor: '', supervisor: '', category: 'engineering'
  });

  const [tempActivities, setTempActivities] = useState<{ [workIndex: number]: TempActivity[] }>({});
  const [selectedWorkIndex, setSelectedWorkIndex] = useState(0);
  const [activityFormData, setActivityFormData] = useState<TempActivity>({
    name: '', executionTime: '', executor: '', done: false
  });

  const resetWizard = () => {
    setCurrentStep(1);
    setProjectData({ name: '', description: '', location: '', startDate: '', endDate: '', executor: '', supervisor: '' });
    setTempWorks([]);
    setWorkFormData({ name: '', description: '', location: '', startDate: '', endDate: '', executor: '', supervisor: '', category: 'engineering' });
    setTempActivities({});
    setSelectedWorkIndex(0);
    setActivityFormData({ name: '', executionTime: '', executor: '', done: false });
  };

  const handleStep1Next = (e: React.FormEvent) => {
    e.preventDefault();
    setCurrentStep(2);
    toast.success('Data proyek berhasil disimpan! Silakan tambahkan pekerjaan.');
  };

  const handleAddWork = (e: React.FormEvent) => {
    e.preventDefault();
    setTempWorks([...tempWorks, workFormData]);
    setWorkFormData({ name: '', description: '', location: '', startDate: '', endDate: '', executor: '', supervisor: '', category: 'engineering' });
    toast.success(`Pekerjaan "${workFormData.name}" berhasil ditambahkan!`);
  };

  const handleRemoveWork = (index: number) => {
    const newWorks = tempWorks.filter((_, i) => i !== index);
    setTempWorks(newWorks);
    const newActivities = { ...tempActivities };
    delete newActivities[index];
    setTempActivities(newActivities);
    toast.info('Pekerjaan berhasil dihapus.');
  };

  const handleStep2Next = () => {
    if (tempWorks.length === 0) {
      toast.error('Minimal tambahkan 1 pekerjaan untuk melanjutkan.');
      return;
    }
    setCurrentStep(3);
    toast.success('Pekerjaan berhasil disimpan! Sekarang tambahkan aktivitas untuk setiap pekerjaan.');
  };

  const handleAddActivity = (e: React.FormEvent) => {
    e.preventDefault();
    const currentActivities = tempActivities[selectedWorkIndex] || [];
    setTempActivities({ ...tempActivities, [selectedWorkIndex]: [...currentActivities, activityFormData] });
    setActivityFormData({ name: '', executionTime: '', executor: '', done: false });
    toast.success(`Aktivitas "${activityFormData.name}" berhasil ditambahkan!`);
  };

  const handleRemoveActivity = (workIndex: number, activityIndex: number) => {
    const currentActivities = tempActivities[workIndex] || [];
    const newActivities = currentActivities.filter((_, i) => i !== activityIndex);
    setTempActivities({ ...tempActivities, [workIndex]: newActivities });
    toast.info('Aktivitas berhasil dihapus.');
  };

  const handleFinalSubmit = () => {
    const newProjectId = addProject(projectData);
    tempWorks.forEach((work, index) => {
      const workId = addWork({ ...work, projectId: newProjectId });
      const activities = tempActivities[index] || [];
      activities.forEach((activity) => addActivity(workId, activity));
    });
    toast.success('Proyek berhasil dibuat dengan semua pekerjaan dan aktivitas!');
    setShowCreateModal(false);
    resetWizard();
  };

  const handleStep3Next = () => {
    const worksWithoutActivities = tempWorks.filter((_, index) => !tempActivities[index] || tempActivities[index].length === 0);
    if (worksWithoutActivities.length > 0) {
      toast.error('Setiap pekerjaan harus memiliki minimal 1 aktivitas!');
      return;
    }
    handleFinalSubmit();
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'Aktif': return 'bg-green-100 text-green-800';
      case 'Selesai': return 'bg-blue-100 text-blue-800';
      case 'Tertunda': return 'bg-yellow-100 text-yellow-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const handleDeleteProject = (e: React.MouseEvent, projectId: string) => {
    e.preventDefault();
    if (confirm('Apakah Anda yakin ingin menghapus proyek ini? Semua pekerjaan dan aktivitas di dalamnya akan ikut terhapus.')) {
      deleteProject(projectId);
    }
  };

  const handleRenameProject = (e: React.MouseEvent | Event, projectId: string, newName: string) => {
    renameProject(projectId, newName);
    toast.success(`Nama proyek berhasil diubah menjadi "${newName}"`);
  };

  const filteredProjects = projects.filter(project =>
    project.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    project.description.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const steps = [
    { num: 1, label: 'Data Proyek' },
    { num: 2, label: 'Tambah Pekerjaan' },
    { num: 3, label: 'Tambah Aktivitas' },
  ];

  return (
    <div className="min-h-screen bg-gray-50">
      <Header />

      {/* Hero Section */}
      <section className="relative h-52 sm:h-72 md:h-96 overflow-hidden">
        <ImageWithFallback
          src="https://images.unsplash.com/photo-1758270705317-3ef6142d306f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzdHVkZW50cyUyMHRlYW13b3JrJTIwY29sbGFib3JhdGlvbiUyMHByb2plY3R8ZW58MXx8fHwxNzcyNDQ2NjgzfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
          alt="Tim kerja mahasiswa"
          className="w-full h-full object-cover"
        />
        <div className="absolute inset-0 bg-gradient-to-r from-black/70 to-black/50"></div>
        <div className="absolute inset-0 flex items-center justify-center px-4">
          <div className="text-center text-white">
            <h1 className="text-2xl sm:text-4xl md:text-5xl lg:text-6xl font-bold mb-2 md:mb-4">Manajemen Proyek</h1>
            <p className="text-sm sm:text-lg md:text-xl text-gray-200">Kelola Proyek Mahasiswa dengan Efisien</p>
          </div>
        </div>
      </section>

      {/* Projects List Section */}
      <section className="px-4 py-8 sm:px-6 md:px-12 lg:px-20 md:py-16">
        <div className="max-w-7xl mx-auto">
          <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-6 md:mb-8">
            <div>
              <h2 className="text-2xl sm:text-3xl font-bold text-gray-900 mb-1">Daftar Proyek</h2>
              <p className="text-gray-600 text-sm sm:text-base">Kelola dan pantau semua proyek Anda</p>
            </div>

            <div className="flex items-center gap-2 sm:gap-4 w-full sm:w-auto">
              <div className="relative flex-1 sm:w-56">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Search className="h-4 w-4 text-gray-400" />
                </div>
                <input
                  type="text"
                  placeholder="Cari proyek..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="block w-full pl-9 pr-3 py-2 border border-gray-300 rounded-lg bg-white placeholder-gray-500 focus:outline-none focus:ring-1 focus:ring-red-800 focus:border-red-800 text-sm"
                />
              </div>
              <button
                onClick={() => setShowReportModal(true)}
                className="flex items-center gap-2 border border-gray-300 hover:border-red-800 text-gray-700 hover:text-red-800 hover:bg-red-50 px-3 sm:px-4 py-2 rounded-lg font-medium transition-colors whitespace-nowrap text-sm"
              >
                <BarChart3 className="w-4 h-4" />
                <span className="hidden sm:inline">Laporan</span>
              </button>
              <button
                onClick={() => setShowCreateModal(true)}
                className="bg-red-800 hover:bg-red-900 text-white px-3 sm:px-5 py-2 rounded-lg font-medium flex items-center gap-2 transition-colors whitespace-nowrap text-sm"
              >
                <Plus className="w-4 h-4" />
                <span>Buat Proyek</span>
              </button>
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6">
            {filteredProjects.map((project) => (
              <div
                key={project.id}
                className="bg-white rounded-xl p-4 sm:p-6 shadow-sm hover:shadow-lg transition-shadow border border-gray-100 group relative"
              >
                <Link to={`/project/${project.id}`} className="block">
                  <div className="flex items-start justify-between mb-4 pr-8">
                    <div className="w-10 h-10 sm:w-12 sm:h-12 bg-red-800 rounded-lg flex items-center justify-center shrink-0">
                      <FolderKanban className="w-5 h-5 sm:w-6 sm:h-6 text-white" />
                    </div>
                    <span className={`px-2.5 py-1 rounded-full text-xs font-medium ${getStatusColor(project.status)}`}>
                      {project.status}
                    </span>
                  </div>
                  <h3 className="text-lg sm:text-xl font-bold text-gray-900 mb-2 group-hover:text-red-800 transition-colors">
                    <InlineEdit
                      value={project.name}
                      onSave={(newName) => { renameProject(project.id, newName); toast.success(`Nama proyek diubah menjadi "${newName}"`); }}
                      className="line-clamp-2 break-words"
                      inputClassName="text-lg font-bold"
                      disabled={project.isClosed}
                    />
                  </h3>
                  <p className="text-gray-600 text-sm mb-4 line-clamp-2">{project.description}</p>
                  <div className="space-y-1.5 text-sm text-gray-500">
                    <div className="flex items-center gap-2">
                      <MapPin className="w-4 h-4 shrink-0" />
                      <span className="truncate">{project.location}</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <Calendar className="w-4 h-4 shrink-0" />
                      <span>{project.startDate} - {project.endDate}</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <Users className="w-4 h-4 shrink-0" />
                      <span className="truncate">{project.executor}</span>
                    </div>
                  </div>
                </Link>
                <button
                  onClick={(e) => handleDeleteProject(e, project.id)}
                  className="absolute top-3 right-3 bg-white hover:bg-red-50 text-red-600 hover:text-red-800 p-1.5 rounded-lg shadow-sm border border-red-200 transition-colors z-10"
                  title="Hapus Proyek"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>
            ))}
          </div>

          {filteredProjects.length === 0 && (
            <div className="text-center py-12 md:py-16">
              <FolderKanban className="w-14 h-14 text-gray-300 mx-auto mb-4" />
              <p className="text-gray-500 text-base md:text-lg">
                {searchQuery ? 'Proyek tidak ditemukan.' : 'Belum ada proyek. Mulai dengan membuat proyek baru!'}
              </p>
            </div>
          )}
        </div>
      </section>

      {/* Task Report Modal */}
      {showReportModal && (
        <TaskReportModal onClose={() => setShowReportModal(false)} />
      )}

      {/* Create Project Wizard Modal */}
      {showCreateModal && (
        <div
          className="fixed inset-0 bg-black/50 flex items-end sm:items-center justify-center z-50 p-0 sm:p-4"
          onClick={() => { setShowCreateModal(false); resetWizard(); }}
        >
          <div
            className="bg-white rounded-t-2xl sm:rounded-2xl w-full sm:max-w-2xl md:max-w-3xl shadow-2xl max-h-[95vh] sm:max-h-[90vh] flex flex-col"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Modal Header */}
            <div className="px-4 sm:px-8 pt-5 pb-4 border-b border-gray-100 shrink-0">
              {/* Drag handle for mobile */}
              <div className="w-10 h-1 bg-gray-300 rounded-full mx-auto mb-4 sm:hidden"></div>

              {/* Step Indicator */}
              <div className="flex items-center justify-between">
                {steps.map((step, i) => (
                  <div key={step.num} className="flex items-center flex-1">
                    <div className="flex items-center gap-1.5 sm:gap-2">
                      <div className={`w-8 h-8 sm:w-9 sm:h-9 rounded-full flex items-center justify-center font-bold text-sm transition-colors ${
                        currentStep >= step.num ? 'bg-red-800 text-white' : 'bg-gray-200 text-gray-500'
                      }`}>
                        {currentStep > step.num ? <CheckCircle2 className="w-4 h-4 sm:w-5 sm:h-5" /> : step.num}
                      </div>
                      <span className={`font-medium text-xs sm:text-sm hidden xs:inline sm:inline transition-colors ${
                        currentStep >= step.num ? 'text-red-800' : 'text-gray-400'
                      }`}>{step.label}</span>
                    </div>
                    {i < steps.length - 1 && (
                      <div className={`flex-1 h-0.5 mx-1 sm:mx-2 transition-colors ${currentStep > step.num ? 'bg-red-800' : 'bg-gray-200'}`}></div>
                    )}
                  </div>
                ))}
              </div>
            </div>

            {/* Scrollable Content */}
            <div className="overflow-y-auto flex-1 px-4 sm:px-8 py-5">

              {/* Step 1: Project Data */}
              {currentStep === 1 && (
                <>
                  <h3 className="text-xl sm:text-2xl font-bold text-gray-900 mb-5">Data Proyek</h3>
                  <form onSubmit={handleStep1Next} className="space-y-4">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1.5">Nama Proyek *</label>
                      <input
                        type="text" required value={projectData.name}
                        onChange={(e) => setProjectData({ ...projectData, name: e.target.value })}
                        className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                        placeholder="Masukkan nama proyek"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1.5">Deskripsi *</label>
                      <textarea
                        required value={projectData.description}
                        onChange={(e) => setProjectData({ ...projectData, description: e.target.value })}
                        rows={3}
                        className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                        placeholder="Deskripsikan proyek Anda"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1.5">Tempat *</label>
                      <input
                        type="text" required value={projectData.location}
                        onChange={(e) => setProjectData({ ...projectData, location: e.target.value })}
                        className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                        placeholder="Lokasi pelaksanaan proyek"
                      />
                    </div>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1.5">Tanggal Mulai *</label>
                        <input type="date" required value={projectData.startDate}
                          onChange={(e) => setProjectData({ ...projectData, startDate: e.target.value })}
                          className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1.5">Tanggal Selesai *</label>
                        <input type="date" required value={projectData.endDate}
                          onChange={(e) => setProjectData({ ...projectData, endDate: e.target.value })}
                          className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                        />
                      </div>
                    </div>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1.5">Pelaksana Proyek *</label>
                        <input type="text" required value={projectData.executor}
                          onChange={(e) => setProjectData({ ...projectData, executor: e.target.value })}
                          className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                          placeholder="Nama pelaksana atau tim"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1.5">Supervisor Proyek *</label>
                        <input type="text" required value={projectData.supervisor}
                          onChange={(e) => setProjectData({ ...projectData, supervisor: e.target.value })}
                          className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                          placeholder="Nama supervisor"
                        />
                      </div>
                    </div>
                    <div className="flex gap-3 pt-2">
                      <button type="button"
                        onClick={() => { setShowCreateModal(false); resetWizard(); }}
                        className="flex-1 px-4 py-2.5 border border-gray-300 rounded-lg font-medium text-gray-700 hover:bg-gray-50 transition-colors text-sm"
                      >Batal</button>
                      <button type="submit"
                        className="flex-1 px-4 py-2.5 bg-red-800 text-white rounded-lg font-medium hover:bg-red-900 transition-colors flex items-center justify-center gap-2 text-sm"
                      >Selanjutnya <ArrowRight className="w-4 h-4" /></button>
                    </div>
                  </form>
                </>
              )}

              {/* Step 2: Add Works */}
              {currentStep === 2 && (
                <>
                  <h3 className="text-xl sm:text-2xl font-bold text-gray-900 mb-1">Tambah Pekerjaan</h3>
                  <p className="text-gray-600 text-sm mb-5">Tambahkan pekerjaan untuk proyek "{projectData.name}"</p>

                  {tempWorks.length > 0 && (
                    <div className="mb-5 bg-green-50 border border-green-200 rounded-lg p-3 sm:p-4">
                      <h4 className="font-medium text-green-900 mb-3 flex items-center gap-2 text-sm">
                        <CheckCircle2 className="w-4 h-4" />
                        Pekerjaan yang sudah ditambahkan ({tempWorks.length})
                      </h4>
                      <div className="space-y-2">
                        {tempWorks.map((work, index) => (
                          <div key={index} className="flex items-center justify-between bg-white p-2.5 sm:p-3 rounded-lg gap-2">
                            <div className="flex items-center gap-2 min-w-0">
                              <Briefcase className="w-4 h-4 text-red-800 shrink-0" />
                              <div className="min-w-0">
                                <p className="font-medium text-gray-900 text-sm truncate">{work.name}</p>
                                <p className="text-xs text-gray-500">{work.category === 'engineering' ? 'Intelligence Engineering' : work.category === 'creation' ? 'Intelligence Creation' : 'Implementation'}</p>
                              </div>
                            </div>
                            <button type="button" onClick={() => handleRemoveWork(index)}
                              className="text-red-600 hover:text-red-800 p-1.5 hover:bg-red-50 rounded-lg transition-colors shrink-0"
                            ><X className="w-4 h-4" /></button>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}

                  <form onSubmit={handleAddWork} className="space-y-3 sm:space-y-4 mb-5">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1.5">Nama Pekerjaan *</label>
                      <input type="text" required value={workFormData.name}
                        onChange={(e) => setWorkFormData({ ...workFormData, name: e.target.value })}
                        className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                        placeholder="Masukkan nama pekerjaan"
                      />
                    </div>
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1.5">Deskripsi *</label>
                      <textarea required value={workFormData.description}
                        onChange={(e) => setWorkFormData({ ...workFormData, description: e.target.value })}
                        rows={2}
                        className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                        placeholder="Deskripsikan pekerjaan"
                      />
                    </div>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1.5">Tempat *</label>
                        <input type="text" required value={workFormData.location}
                          onChange={(e) => setWorkFormData({ ...workFormData, location: e.target.value })}
                          className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                          placeholder="Lokasi pekerjaan"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1.5">Kategori *</label>
                        <select required value={workFormData.category}
                          onChange={(e) => setWorkFormData({ ...workFormData, category: e.target.value as 'engineering' | 'creation' | 'implementation' })}
                          className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                        >
                          <option value="engineering">Intelligence Engineering</option>
                          <option value="creation">Intelligence Creation</option>
                          <option value="implementation">Implementation</option>
                        </select>
                      </div>
                    </div>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1.5">Tanggal Mulai *</label>
                        <input type="date" required value={workFormData.startDate}
                          onChange={(e) => setWorkFormData({ ...workFormData, startDate: e.target.value })}
                          className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1.5">Tanggal Selesai *</label>
                        <input type="date" required value={workFormData.endDate}
                          onChange={(e) => setWorkFormData({ ...workFormData, endDate: e.target.value })}
                          className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                        />
                      </div>
                    </div>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1.5">Pelaksana *</label>
                        <input type="text" required value={workFormData.executor}
                          onChange={(e) => setWorkFormData({ ...workFormData, executor: e.target.value })}
                          className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                          placeholder="Nama pelaksana"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1.5">Supervisor *</label>
                        <input type="text" required value={workFormData.supervisor}
                          onChange={(e) => setWorkFormData({ ...workFormData, supervisor: e.target.value })}
                          className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                          placeholder="Nama supervisor"
                        />
                      </div>
                    </div>
                    <button type="submit"
                      className="w-full px-4 py-2.5 bg-green-600 text-white rounded-lg font-medium hover:bg-green-700 transition-colors flex items-center justify-center gap-2 text-sm"
                    ><Plus className="w-4 h-4" /> Tambah Pekerjaan</button>
                  </form>

                  <div className="flex gap-3 pt-4 border-t">
                    <button type="button" onClick={() => setCurrentStep(1)}
                      className="flex-1 px-4 py-2.5 border border-gray-300 rounded-lg font-medium text-gray-700 hover:bg-gray-50 transition-colors flex items-center justify-center gap-2 text-sm"
                    ><ArrowLeft className="w-4 h-4" /> Kembali</button>
                    <button type="button" onClick={handleStep2Next} disabled={tempWorks.length === 0}
                      className="flex-1 px-4 py-2.5 bg-red-800 text-white rounded-lg font-medium hover:bg-red-900 transition-colors flex items-center justify-center gap-2 disabled:bg-gray-300 disabled:cursor-not-allowed text-sm"
                    >Selanjutnya <ArrowRight className="w-4 h-4" /></button>
                  </div>
                </>
              )}

              {/* Step 3: Add Activities */}
              {currentStep === 3 && (
                <>
                  <h3 className="text-xl sm:text-2xl font-bold text-gray-900 mb-1">Tambah Aktivitas</h3>
                  <p className="text-gray-600 text-sm mb-5">Tambahkan aktivitas untuk setiap pekerjaan</p>

                  <div className="mb-5">
                    <label className="block text-sm font-medium text-gray-700 mb-1.5">Pilih Pekerjaan *</label>
                    <select value={selectedWorkIndex}
                      onChange={(e) => setSelectedWorkIndex(Number(e.target.value))}
                      className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                    >
                      {tempWorks.map((work, index) => (
                        <option key={index} value={index}>
                          {work.name} {tempActivities[index] && tempActivities[index].length > 0 ? `(${tempActivities[index].length} aktivitas)` : '(belum ada aktivitas)'}
                        </option>
                      ))}
                    </select>
                  </div>

                  {tempActivities[selectedWorkIndex] && tempActivities[selectedWorkIndex].length > 0 && (
                    <div className="mb-5 bg-green-50 border border-green-200 rounded-lg p-3 sm:p-4">
                      <h4 className="font-medium text-green-900 mb-3 flex items-center gap-2 text-sm">
                        <CheckCircle2 className="w-4 h-4" />
                        Aktivitas untuk "{tempWorks[selectedWorkIndex].name}" ({tempActivities[selectedWorkIndex].length})
                      </h4>
                      <div className="space-y-2">
                        {tempActivities[selectedWorkIndex].map((activity, index) => (
                          <div key={index} className="flex items-center justify-between bg-white p-2.5 rounded-lg gap-2">
                            <div className="min-w-0">
                              <p className="font-medium text-gray-900 text-sm truncate">{activity.name}</p>
                              <p className="text-xs text-gray-500">{activity.executor} • {activity.executionTime}</p>
                            </div>
                            <button type="button" onClick={() => handleRemoveActivity(selectedWorkIndex, index)}
                              className="text-red-600 hover:text-red-800 p-1.5 hover:bg-red-50 rounded-lg transition-colors shrink-0"
                            ><X className="w-4 h-4" /></button>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}

                  <form onSubmit={handleAddActivity} className="space-y-3 sm:space-y-4 mb-5">
                    <div>
                      <label className="block text-sm font-medium text-gray-700 mb-1.5">Nama Aktivitas *</label>
                      <input type="text" required value={activityFormData.name}
                        onChange={(e) => setActivityFormData({ ...activityFormData, name: e.target.value })}
                        className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                        placeholder="Masukkan nama aktivitas"
                      />
                    </div>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1.5">Waktu Pelaksanaan *</label>
                        <input type="text" required value={activityFormData.executionTime}
                          onChange={(e) => setActivityFormData({ ...activityFormData, executionTime: e.target.value })}
                          className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                          placeholder="Contoh: 2 jam, 1 hari"
                        />
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1.5">Pelaksana *</label>
                        <input type="text" required value={activityFormData.executor}
                          onChange={(e) => setActivityFormData({ ...activityFormData, executor: e.target.value })}
                          className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-transparent text-sm"
                          placeholder="Nama pelaksana"
                        />
                      </div>
                    </div>
                    <button type="submit"
                      className="w-full px-4 py-2.5 bg-green-600 text-white rounded-lg font-medium hover:bg-green-700 transition-colors flex items-center justify-center gap-2 text-sm"
                    ><Plus className="w-4 h-4" /> Tambah Aktivitas</button>
                  </form>

                  {/* Ringkasan */}
                  <div className="mb-5 bg-blue-50 border border-blue-200 rounded-lg p-3 sm:p-4">
                    <h4 className="font-medium text-blue-900 mb-3 text-sm">Ringkasan</h4>
                    <div className="space-y-1.5 text-xs sm:text-sm">
                      {tempWorks.map((work, index) => {
                        const activityCount = tempActivities[index]?.length || 0;
                        const hasActivities = activityCount > 0;
                        return (
                          <div key={index} className={`flex items-center justify-between p-2 rounded ${hasActivities ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
                            <span className="truncate mr-2">{work.name}</span>
                            <span className="font-medium shrink-0">
                              {hasActivities ? `✓ ${activityCount} aktivitas` : '✗ Belum ada'}
                            </span>
                          </div>
                        );
                      })}
                    </div>
                  </div>

                  <div className="flex gap-3 pt-4 border-t">
                    <button type="button" onClick={() => setCurrentStep(2)}
                      className="flex-1 px-4 py-2.5 border border-gray-300 rounded-lg font-medium text-gray-700 hover:bg-gray-50 transition-colors flex items-center justify-center gap-2 text-sm"
                    ><ArrowLeft className="w-4 h-4" /> Kembali</button>
                    <button type="button" onClick={handleStep3Next}
                      className="flex-1 px-4 py-2.5 bg-red-800 text-white rounded-lg font-medium hover:bg-red-900 transition-colors flex items-center justify-center gap-2 text-sm"
                    ><CheckCircle2 className="w-4 h-4" /> Buat Proyek</button>
                  </div>
                </>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}