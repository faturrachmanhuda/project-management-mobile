import { useState } from 'react';
import { useNavigate, useParams } from 'react-router';
import { Header } from '../components/Header';
import {
  Plus, Trash2, Calendar, MapPin, Users, User,
  CheckCircle, CheckCircle2, Clock, ArrowLeft, BarChart, X, Info, Edit3, Search, Image as ImageIcon, Upload
} from 'lucide-react';
import { useProjects } from '../context/ProjectContext';
import type { Activity } from '../context/ProjectContext';
import { toast } from 'sonner';
import { InlineEdit } from '../components/InlineEdit';

export function WorkDetail() {
  const navigate = useNavigate();
  const { projectId, workId } = useParams();
  const { getProjectById, works, addActivity, updateActivity, deleteActivity } = useProjects();

  const project = projectId ? getProjectById(projectId) : undefined;
  const work = works.find(w => w.id === workId);

  const [showActivityModal, setShowActivityModal] = useState(false);
  const [showRealizationModal, setShowRealizationModal] = useState(false);
  const [showRequirementModal, setShowRequirementModal] = useState(false);
  const [searchActivityQuery, setSearchActivityQuery] = useState('');
  const [searchMonitoringQuery, setSearchMonitoringQuery] = useState('');
  const [evaluationModalState, setEvaluationModalState] = useState<{
    isOpen: boolean; activityId: string | null; evaluation: string; additionalPlan: string;
  }>({ isOpen: false, activityId: null, evaluation: '', additionalPlan: '' });

  const [photoModalState, setPhotoModalState] = useState<{
    isOpen: boolean;
    activityId: string | null;
    photos: string[];
  }>({ isOpen: false, activityId: null, photos: [] });

  const [activityForm, setActivityForm] = useState({
    name: '', executionTime: '', executor: '',
    done: false,
    evaluation: '', additionalPlan: ''
  });

  if (!project || !work) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center px-4">
        <div className="text-center">
          <p className="text-gray-600 mb-4">Pekerjaan tidak ditemukan</p>
          <button onClick={() => navigate(`/project/${projectId}`)} className="text-red-800 hover:underline">
            Kembali ke Detail Proyek
          </button>
        </div>
      </div>
    );
  }

  const handleCreateActivity = (e: React.FormEvent) => {
    e.preventDefault();
    if (!workId) return;
    addActivity(workId, activityForm);
    setShowActivityModal(false);
    setActivityForm({ name: '', executionTime: '', executor: '', done: false, evaluation: '', additionalPlan: '' });
    toast.success('Aktivitas berhasil dibuat!');
  };

  const handleToggleDone = (activityId: string, currentDone: boolean) => {
    if (!workId) return;
    updateActivity(workId, activityId, { done: !currentDone });
    toast.success(!currentDone ? 'Aktivitas ditandai selesai!' : 'Aktivitas dibatalkan.');
  };

  const handleUpdateEvaluation = (e: React.FormEvent) => {
    e.preventDefault();
    if (!workId || !evaluationModalState.activityId) return;
    updateActivity(workId, evaluationModalState.activityId, {
      evaluation: evaluationModalState.evaluation,
      additionalPlan: evaluationModalState.additionalPlan
    });
    setEvaluationModalState({ isOpen: false, activityId: null, evaluation: '', additionalPlan: '' });
    toast.success('Evaluasi berhasil disimpan!');
  };

  const handleDeleteActivity = (activityId: string) => {
    if (confirm('Apakah Anda yakin ingin menghapus aktivitas ini?')) {
      deleteActivity(work.id, activityId);
    }
  };

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (!files || files.length === 0) return;

    const MAX_FILE_SIZE = 9 * 1024 * 1024; // 9MB
    const MAX_FILES = 20;
    
    const currentPhotosCount = photoModalState.photos.length;
    if (currentPhotosCount + files.length > MAX_FILES) {
      toast.error(`Maksimal ${MAX_FILES} file. Anda sudah memiliki ${currentPhotosCount} file.`);
      return;
    }

    const newPhotos: string[] = [];
    
    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      
      // Check file size
      if (file.size > MAX_FILE_SIZE) {
        toast.error(`File "${file.name}" melebihi ukuran maksimal 9MB.`);
        continue;
      }

      // Check file type
      if (!file.type.startsWith('image/')) {
        toast.error(`File "${file.name}" bukan file gambar.`);
        continue;
      }

      // Convert to base64
      const reader = new FileReader();
      await new Promise((resolve) => {
        reader.onload = (event) => {
          if (event.target?.result) {
            newPhotos.push(event.target.result as string);
          }
          resolve(null);
        };
        reader.readAsDataURL(file);
      });
    }

    if (newPhotos.length > 0) {
      setPhotoModalState(prev => ({
        ...prev,
        photos: [...prev.photos, ...newPhotos]
      }));
      toast.success(`${newPhotos.length} foto berhasil ditambahkan!`);
    }
  };

  const handleRemovePhoto = (index: number) => {
    setPhotoModalState(prev => ({
      ...prev,
      photos: prev.photos.filter((_, i) => i !== index)
    }));
  };

  const handleSavePhotos = () => {
    if (!workId || !photoModalState.activityId) return;
    
    updateActivity(workId, photoModalState.activityId, {
      photos: photoModalState.photos
    });
    
    setPhotoModalState({ isOpen: false, activityId: null, photos: [] });
    toast.success('Foto berhasil disimpan!');
  };

  const handleOpenPhotoModal = (activityId: string, currentPhotos: string[] = []) => {
    setPhotoModalState({
      isOpen: true,
      activityId,
      photos: [...currentPhotos]
    });
  };

  const filteredActivities = work.activities.filter(activity =>
    activity.name.toLowerCase().includes(searchActivityQuery.toLowerCase()) ||
    activity.executor.toLowerCase().includes(searchActivityQuery.toLowerCase())
  );

  const filteredMonitoringActivities = work.activities.filter(activity =>
    activity.name.toLowerCase().includes(searchMonitoringQuery.toLowerCase()) ||
    activity.executor.toLowerCase().includes(searchMonitoringQuery.toLowerCase())
  );

  return (
    <div className="min-h-screen bg-gray-50">
      <Header />

      {/* Work Header */}
      <section className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 py-6 md:px-12 lg:px-20 md:py-8">
          <button
            onClick={() => navigate(`/project/${projectId}`)}
            className="flex items-center gap-2 text-gray-600 hover:text-red-800 mb-4 md:mb-6 transition-colors text-sm"
          >
            <ArrowLeft className="w-4 h-4" />
            Kembali ke Detail Proyek
          </button>

          <div className="flex-1 min-w-0">
            <div className="flex flex-wrap items-center gap-2 mb-2">
              <h1 className="text-2xl sm:text-3xl md:text-4xl font-bold text-gray-900 break-words">
                {work.name}
              </h1>
              <span className="px-2.5 py-1 bg-gray-100 text-gray-600 rounded-full text-xs sm:text-sm font-medium border border-gray-200 shrink-0">
                {work.category === 'engineering' ? 'Intelligence Engineering' :
                 work.category === 'creation' ? 'Intelligence Creation' : 'Implementation'}
              </span>
            </div>
            <p className="text-gray-600 mb-4 text-sm sm:text-base">{work.description}</p>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 md:gap-4 text-sm">
              <div className="flex items-center gap-2 text-gray-600">
                <MapPin className="w-4 h-4 shrink-0" />
                <span className="truncate">{work.location}</span>
              </div>
              <div className="flex items-center gap-2 text-gray-600">
                <Calendar className="w-4 h-4 shrink-0" />
                <span>{work.startDate} - {work.endDate}</span>
              </div>
              <div className="flex items-center gap-2 text-gray-600">
                <Users className="w-4 h-4 shrink-0" />
                <span className="truncate">Pelaksana: {work.executor}</span>
              </div>
              <div className="flex items-center gap-2 text-gray-600">
                <User className="w-4 h-4 shrink-0" />
                <span className="truncate">Supervisor: {work.supervisor}</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Content */}
      <section className="px-4 py-8 sm:px-6 md:px-12 lg:px-20 md:py-12">
        <div className="max-w-7xl mx-auto">

          {/* Header area */}
          <div className="flex flex-col gap-3 mb-5 md:mb-6">
            <h2 className="text-xl sm:text-2xl font-bold text-gray-900">Daftar Aktivitas</h2>

            {/* Search + action buttons */}
            <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-2 sm:gap-3">
              <div className="relative flex-1 sm:max-w-xs">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Search className="h-4 w-4 text-gray-400" />
                </div>
                <input
                  type="text"
                  placeholder="Cari aktivitas..."
                  value={searchActivityQuery}
                  onChange={(e) => setSearchActivityQuery(e.target.value)}
                  className="block w-full pl-9 pr-3 py-2 border border-gray-300 rounded-lg bg-white placeholder-gray-500 focus:outline-none focus:ring-1 focus:ring-red-800 focus:border-red-800 text-sm"
                />
              </div>

              <div className="flex items-center gap-2">
                <button
                  onClick={() => setShowRealizationModal(true)}
                  className="flex-1 sm:flex-none bg-white border border-red-800 text-red-800 hover:bg-red-50 px-3 sm:px-4 py-2 rounded-lg font-medium flex items-center justify-center gap-2 transition-colors text-sm"
                >
                  <BarChart className="w-4 h-4 shrink-0" />
                  <span>Pantau Realisasi</span>
                </button>
                {!project.isClosed && (
                  <button
                    onClick={() => setShowRequirementModal(true)}
                    className="flex-1 sm:flex-none bg-red-800 hover:bg-red-900 text-white px-3 sm:px-4 py-2 rounded-lg font-medium flex items-center justify-center gap-2 transition-colors text-sm whitespace-nowrap"
                  >
                    <Plus className="w-4 h-4 shrink-0" />
                    <span>Tambah Aktivitas</span>
                  </button>
                )}
              </div>
            </div>
          </div>

          {filteredActivities.length === 0 ? (
            <div className="bg-white rounded-xl p-10 text-center border border-gray-200">
              <CheckCircle className="w-14 h-14 text-gray-300 mx-auto mb-4" />
              <p className="text-gray-500 text-sm sm:text-base">
                {searchActivityQuery ? 'Aktivitas tidak ditemukan.' : 'Belum ada aktivitas. Mulai dengan membuat aktivitas baru!'}
              </p>
            </div>
          ) : (
            <div className="grid gap-4 md:gap-6">
              {filteredActivities.map((activity) => (
                <div
                  key={activity.id}
                  className={`bg-white rounded-xl p-4 sm:p-6 shadow-sm border transition-all ${activity.done ? 'border-green-200 bg-green-50/30' : 'border-gray-200'}`}
                >
                  <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4">
                    <div className="flex-1 min-w-0">
                      <div className="flex flex-wrap items-center gap-2 mb-2">
                        <h3 className={`text-lg sm:text-xl font-bold ${activity.done ? 'line-through text-gray-400' : 'text-gray-900'}`}>
                          <InlineEdit
                            value={activity.name}
                            onSave={(newName) => {
                              if (!workId) return;
                              updateActivity(workId, activity.id, { name: newName });
                              toast.success(`Nama aktivitas diubah menjadi "${newName}"`);
                            }}
                            className={activity.done ? 'line-through text-gray-400' : ''}
                            inputClassName="text-lg font-bold"
                            disabled={project.isClosed}
                          />
                        </h3>
                        {activity.done && (
                          <span className="inline-flex items-center gap-1 px-2.5 py-1 bg-green-100 text-green-700 rounded-full text-xs font-bold shrink-0">
                            <CheckCircle2 className="w-3.5 h-3.5" />
                            Done
                          </span>
                        )}
                      </div>

                      <div className="flex flex-wrap gap-3 sm:gap-4 text-sm text-gray-600 mt-2">
                        <div className="flex items-center gap-2">
                          <Clock className="w-4 h-4 shrink-0" />
                          <span>Waktu: {activity.executionTime}</span>
                        </div>
                        <div className="flex items-center gap-2">
                          <User className="w-4 h-4 shrink-0" />
                          <span>Pelaksana: {activity.executor}</span>
                        </div>
                      </div>

                      {(activity.evaluation || activity.additionalPlan) && (
                        <div className="mt-4 pt-4 border-t border-gray-100 grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-4">
                          {activity.evaluation && (
                            <div>
                              <span className="block text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1">Evaluasi</span>
                              <p className="text-sm text-gray-700">{activity.evaluation}</p>
                            </div>
                          )}
                          {activity.additionalPlan && (
                            <div>
                              <span className="block text-xs font-semibold text-gray-500 uppercase tracking-wider mb-1">Rencana Tindak Lanjut</span>
                              <p className="text-sm text-gray-700">{activity.additionalPlan}</p>
                            </div>
                          )}
                        </div>
                      )}

                      {/* Photos Section */}
                      {activity.photos && activity.photos.length > 0 && (
                        <div className="mt-4 pt-4 border-t border-gray-100">
                          <span className="block text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2">Dokumentasi</span>
                          <div className="flex flex-wrap gap-2">
                            {activity.photos.slice(0, 3).map((photo, idx) => (
                              <div key={idx} className="w-20 h-20 rounded-lg overflow-hidden border border-gray-200">
                                <img src={photo} alt={`Foto ${idx + 1}`} className="w-full h-full object-cover" />
                              </div>
                            ))}
                            {activity.photos.length > 3 && (
                              <div className="w-20 h-20 rounded-lg bg-gray-100 border border-gray-200 flex items-center justify-center">
                                <span className="text-xs font-semibold text-gray-600">+{activity.photos.length - 3}</span>
                              </div>
                            )}
                          </div>
                        </div>
                      )}

                      {/* Upload Photo Button */}
                      <div className="mt-4 pt-4 border-t border-gray-100">
                        <button
                          onClick={() => handleOpenPhotoModal(activity.id, activity.photos)}
                          className="flex items-center gap-2 text-sm font-medium text-blue-600 hover:text-blue-700 transition-colors"
                        >
                          <ImageIcon className="w-4 h-4" />
                          <span>{activity.photos && activity.photos.length > 0 ? 'Lihat & Kelola Foto' : 'Upload Foto Dokumentasi'}</span>
                        </button>
                      </div>
                    </div>

                    {/* Actions */}
                    <div className="flex items-center gap-2 self-start shrink-0">
                      {/* Mark as Done / Done toggle */}
                      {!project.isClosed && (
                        <button
                          onClick={() => handleToggleDone(activity.id, activity.done)}
                          className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold border transition-all ${
                            activity.done
                              ? 'bg-green-100 text-green-700 border-green-300 hover:bg-green-200'
                              : 'bg-white text-gray-600 border-gray-300 hover:border-green-400 hover:text-green-600 hover:bg-green-50'
                          }`}
                        >
                          <CheckCircle2 className="w-3.5 h-3.5" />
                          {activity.done ? 'Done' : 'Mark as Done'}
                        </button>
                      )}

                      {activity.done && !project.isClosed && (
                        <span className="text-xs text-gray-400 italic hidden sm:inline">Klik untuk batal</span>
                      )}

                      {!project.isClosed && (
                        <button
                          onClick={() => handleDeleteActivity(activity.id)}
                          className="text-red-600 hover:text-red-800 p-1.5 transition-colors"
                          title="Hapus Aktivitas"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </section>

      {/* Requirement Modal */}
      {showRequirementModal && (
        <div
          className="fixed inset-0 bg-black/50 flex items-end sm:items-center justify-center z-50 p-0 sm:p-4"
          onClick={() => setShowRequirementModal(false)}
        >
          <div className="bg-white rounded-t-2xl sm:rounded-2xl p-6 sm:p-8 max-w-md w-full shadow-2xl" onClick={(e) => e.stopPropagation()}>
            <div className="w-10 h-1 bg-gray-300 rounded-full mx-auto mb-5 sm:hidden"></div>
            <div className="flex items-center gap-3 mb-5">
              <div className="w-10 h-10 bg-blue-50 text-blue-600 rounded-full flex items-center justify-center shrink-0">
                <Info className="w-5 h-5" />
              </div>
              <h3 className="text-xl sm:text-2xl font-bold text-gray-900">Syarat Aktivitas</h3>
            </div>
            <div className="mb-6 text-gray-600 text-sm sm:text-base">
              <p className="mb-4">Sebelum menambah aktivitas, pastikan Anda telah menyiapkan informasi berikut:</p>
              <ul className="space-y-3">
                {[
                  { title: 'Nama Aktivitas', desc: 'Deskripsi spesifik tentang apa yang akan dilakukan.' },
                  { title: 'Waktu Pelaksanaan', desc: 'Target waktu kapan aktivitas ini harus dijalankan.' },
                  { title: 'Pelaksana Aktivitas', desc: 'Siapa yang akan bertanggung jawab menyelesaikannya.' },
                ].map((item, i) => (
                  <li key={i} className="flex items-start gap-3">
                    <div className="mt-1.5 w-1.5 h-1.5 bg-red-800 rounded-full shrink-0"></div>
                    <span className="text-sm"><strong>{item.title}</strong><br />{item.desc}</span>
                  </li>
                ))}
              </ul>
            </div>
            <div className="flex gap-3">
              <button onClick={() => setShowRequirementModal(false)}
                className="flex-1 px-4 py-2.5 text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg font-medium transition-colors text-sm"
              >Batal</button>
              <button onClick={() => { setShowRequirementModal(false); setShowActivityModal(true); }}
                className="flex-1 px-4 py-2.5 text-white bg-red-800 hover:bg-red-900 rounded-lg font-medium transition-colors text-sm"
              >Mengerti & Lanjut</button>
            </div>
          </div>
        </div>
      )}

      {/* Create Activity Modal */}
      {showActivityModal && (
        <div
          className="fixed inset-0 bg-black/50 flex items-end sm:items-center justify-center z-50 p-0 sm:p-4"
          onClick={() => setShowActivityModal(false)}
        >
          <div className="bg-white rounded-t-2xl sm:rounded-2xl p-6 sm:p-8 max-w-md w-full shadow-2xl" onClick={(e) => e.stopPropagation()}>
            <div className="w-10 h-1 bg-gray-300 rounded-full mx-auto mb-5 sm:hidden"></div>
            <h3 className="text-xl sm:text-2xl font-bold text-gray-900 mb-5">Tambah Aktivitas</h3>
            <form onSubmit={handleCreateActivity} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">Nama Aktivitas</label>
                <input type="text" required value={activityForm.name}
                  onChange={(e) => setActivityForm({ ...activityForm, name: e.target.value })}
                  className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-red-800 text-sm"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">Waktu Pelaksanaan</label>
                <input type="text" required placeholder="Mis: Minggu ke-1" value={activityForm.executionTime}
                  onChange={(e) => setActivityForm({ ...activityForm, executionTime: e.target.value })}
                  className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-red-800 text-sm"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">Pelaksana</label>
                <input type="text" required value={activityForm.executor}
                  onChange={(e) => setActivityForm({ ...activityForm, executor: e.target.value })}
                  className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-red-800 text-sm"
                />
              </div>
              <div className="flex gap-3 pt-2">
                <button type="button" onClick={() => setShowActivityModal(false)}
                  className="flex-1 px-4 py-2.5 text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg font-medium transition-colors text-sm"
                >Batal</button>
                <button type="submit"
                  className="flex-1 px-4 py-2.5 text-white bg-red-800 hover:bg-red-900 rounded-lg font-medium transition-colors text-sm"
                >Simpan</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Realization Modal */}
      {showRealizationModal && (
        <div
          className="fixed inset-0 bg-black/50 flex items-end sm:items-center justify-center z-50 p-0 sm:p-4"
          onClick={() => setShowRealizationModal(false)}
        >
          <div className="bg-white rounded-t-2xl sm:rounded-2xl w-full sm:max-w-4xl shadow-2xl flex flex-col max-h-[90vh]" onClick={(e) => e.stopPropagation()}>
            <div className="w-10 h-1 bg-gray-300 rounded-full mx-auto mt-3 mb-1 sm:hidden"></div>
            <div className="p-4 sm:p-6 border-b border-gray-200 flex flex-col sm:flex-row sm:items-center justify-between gap-3 shrink-0">
              <div>
                <h3 className="text-xl sm:text-2xl font-bold text-gray-900">Pantau Realisasi Aktivitas</h3>
                <p className="text-gray-600 mt-1 text-sm">Evaluasi dan rencana tambahan untuk mencapai target.</p>
              </div>
              <div className="flex items-center gap-3 w-full sm:w-auto">
                <div className="relative flex-1 sm:w-52">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <Search className="h-4 w-4 text-gray-400" />
                  </div>
                  <input type="text" placeholder="Cari aktivitas..." value={searchMonitoringQuery}
                    onChange={(e) => setSearchMonitoringQuery(e.target.value)}
                    className="block w-full pl-9 pr-3 py-2 text-sm border border-gray-300 rounded-lg bg-gray-50 placeholder-gray-500 focus:outline-none focus:bg-white focus:ring-1 focus:ring-red-800 focus:border-red-800"
                  />
                </div>
                <button onClick={() => setShowRealizationModal(false)}
                  className="text-gray-500 hover:bg-gray-100 p-2 rounded-full transition-colors"
                ><X className="w-5 h-5" /></button>
              </div>
            </div>

            <div className="p-4 sm:p-6 overflow-y-auto flex-1 bg-gray-50">
              {filteredMonitoringActivities.length === 0 ? (
                <div className="text-center py-10 bg-white rounded-xl border border-gray-200">
                  <CheckCircle className="w-14 h-14 text-gray-300 mx-auto mb-4" />
                  <p className="text-gray-500 text-sm">{searchMonitoringQuery ? 'Aktivitas tidak ditemukan.' : 'Belum ada aktivitas untuk dipantau.'}</p>
                </div>
              ) : (
                <div className="space-y-4 sm:space-y-6">
                  {filteredMonitoringActivities.map((activity) => (
                    <div key={activity.id} className="bg-white border border-gray-200 shadow-sm rounded-xl overflow-hidden">
                      <div className="px-4 sm:px-6 py-3 sm:py-4 border-b border-gray-100 flex flex-wrap justify-between items-center gap-2">
                        <h4 className="font-bold text-base sm:text-lg text-gray-900">{activity.name}</h4>
                        {activity.done ? (
                          <span className="inline-flex items-center gap-1.5 px-3 py-1 bg-green-100 text-green-700 rounded-full text-xs font-bold">
                            <CheckCircle2 className="w-3.5 h-3.5" />
                            Done
                          </span>
                        ) : (
                          <span className="px-3 py-1 bg-gray-100 text-gray-500 rounded-full text-xs font-bold">
                            Belum selesai
                          </span>
                        )}
                      </div>
                      <div className="p-4 sm:p-6 grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                          <h5 className="text-xs font-bold text-gray-500 uppercase tracking-wider mb-3">Perencanaan</h5>
                          <div className="space-y-3">
                            <div className="flex items-start gap-3">
                              <div className="bg-gray-100 p-2 rounded-lg shrink-0"><Clock className="w-4 h-4 text-gray-600" /></div>
                              <div>
                                <span className="block text-xs font-medium text-gray-500 mb-0.5">Waktu Pelaksanaan</span>
                                <span className="text-gray-900 text-sm">{activity.executionTime}</span>
                              </div>
                            </div>
                            <div className="flex items-start gap-3">
                              <div className="bg-gray-100 p-2 rounded-lg shrink-0"><User className="w-4 h-4 text-gray-600" /></div>
                              <div>
                                <span className="block text-xs font-medium text-gray-500 mb-0.5">Pelaksana</span>
                                <span className="text-gray-900 text-sm">{activity.executor}</span>
                              </div>
                            </div>
                          </div>
                        </div>
                        <div>
                          <div className="flex items-center justify-between mb-3">
                            <h5 className="text-xs font-bold text-gray-500 uppercase tracking-wider">Realisasi & Evaluasi</h5>
                            {!project.isClosed && (
                              <button
                                onClick={() => setEvaluationModalState({ isOpen: true, activityId: activity.id, evaluation: activity.evaluation || '', additionalPlan: activity.additionalPlan || '' })}
                                className="flex items-center gap-1.5 text-xs font-semibold text-red-700 hover:text-red-900 bg-red-50 hover:bg-red-100 px-3 py-1.5 rounded-full transition-colors"
                              >
                                <Edit3 className="w-3.5 h-3.5" />
                                {activity.evaluation || activity.additionalPlan ? 'Edit' : 'Isi Evaluasi'}
                              </button>
                            )}
                          </div>
                          <div className="space-y-3">
                            <div>
                              <span className="font-semibold text-gray-700 block mb-1.5 text-sm">Evaluasi Hasil:</span>
                              <div className="bg-gray-50 p-3 rounded-lg border border-gray-100 text-gray-700 text-sm">
                                {activity.evaluation ? activity.evaluation : <span className="italic text-gray-400">Belum ada evaluasi.</span>}
                              </div>
                            </div>
                            <div>
                              <span className="font-semibold text-gray-700 block mb-1.5 text-sm">Rencana Tindak Lanjut:</span>
                              <div className="bg-gray-50 p-3 rounded-lg border border-gray-100 text-gray-700 text-sm">
                                {activity.additionalPlan ? activity.additionalPlan : <span className="italic text-gray-400">Belum ada rencana tindak lanjut.</span>}
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>

            <div className="p-4 sm:p-6 border-t border-gray-200 flex justify-end shrink-0">
              <button onClick={() => setShowRealizationModal(false)}
                className="px-5 py-2 bg-gray-100 text-gray-700 hover:bg-gray-200 rounded-lg font-medium transition-colors text-sm"
              >Tutup</button>
            </div>
          </div>
        </div>
      )}

      {/* Evaluation Form Modal */}
      {evaluationModalState.isOpen && (
        <div
          className="fixed inset-0 bg-black/50 flex items-end sm:items-center justify-center z-[60] p-0 sm:p-4"
          onClick={() => setEvaluationModalState(prev => ({ ...prev, isOpen: false }))}
        >
          <div className="bg-white rounded-t-2xl sm:rounded-2xl p-6 sm:p-8 max-w-md w-full shadow-2xl" onClick={(e) => e.stopPropagation()}>
            <div className="w-10 h-1 bg-gray-300 rounded-full mx-auto mb-5 sm:hidden"></div>
            <h3 className="text-xl sm:text-2xl font-bold text-gray-900 mb-5">Isi Evaluasi Aktivitas</h3>
            <form onSubmit={handleUpdateEvaluation} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">Evaluasi Hasil</label>
                <textarea
                  value={evaluationModalState.evaluation}
                  onChange={(e) => setEvaluationModalState({ ...evaluationModalState, evaluation: e.target.value })}
                  className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-red-800 text-sm"
                  rows={4}
                  placeholder="Ceritakan hasil pelaksanaan aktivitas, kendala yang dihadapi, atau capaian..."
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1.5">Rencana Tindak Lanjut</label>
                <textarea
                  value={evaluationModalState.additionalPlan}
                  onChange={(e) => setEvaluationModalState({ ...evaluationModalState, additionalPlan: e.target.value })}
                  className="w-full px-4 py-2.5 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-800 focus:border-red-800 text-sm"
                  rows={4}
                  placeholder="Langkah apa yang perlu diambil selanjutnya berdasarkan evaluasi di atas?"
                />
              </div>
              <div className="flex gap-3 pt-2">
                <button type="button" onClick={() => setEvaluationModalState(prev => ({ ...prev, isOpen: false }))}
                  className="flex-1 px-4 py-2.5 text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg font-medium transition-colors text-sm"
                >Batal</button>
                <button type="submit"
                  className="flex-1 px-4 py-2.5 text-white bg-red-800 hover:bg-red-900 rounded-lg font-medium transition-colors text-sm"
                >Simpan Evaluasi</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Photo Modal */}
      {photoModalState.isOpen && (
        <div
          className="fixed inset-0 bg-black/50 flex items-end sm:items-center justify-center z-[60] p-0 sm:p-4"
          onClick={() => setPhotoModalState(prev => ({ ...prev, isOpen: false }))}
        >
          <div className="bg-white rounded-t-2xl sm:rounded-2xl p-6 sm:p-8 max-w-2xl w-full shadow-2xl" onClick={(e) => e.stopPropagation()}>
            <div className="w-10 h-1 bg-gray-300 rounded-full mx-auto mb-5 sm:hidden"></div>
            <div className="flex items-center justify-between mb-5">
              <h3 className="text-xl sm:text-2xl font-bold text-gray-900">Kelola Foto Dokumentasi</h3>
              <button
                onClick={() => setPhotoModalState(prev => ({ ...prev, isOpen: false }))}
                className="text-gray-500 hover:bg-gray-100 p-2 rounded-full transition-colors sm:block hidden"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
            
            <div className="space-y-5">
              {/* Upload Area */}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-3">File submissions</label>
                <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 bg-gray-50 hover:bg-gray-100 transition-colors">
                  <input
                    id="photo-upload"
                    type="file"
                    multiple
                    accept="image/*"
                    onChange={handleFileUpload}
                    className="hidden"
                  />
                  <label
                    htmlFor="photo-upload"
                    className="cursor-pointer flex flex-col items-center justify-center"
                  >
                    <div className="flex items-center gap-3 mb-3">
                      <div className="p-3 bg-white border border-gray-200 rounded-lg">
                        <Upload className="w-5 h-5 text-gray-600" />
                      </div>
                      <div className="p-3 bg-white border border-gray-200 rounded-lg">
                        <ImageIcon className="w-5 h-5 text-gray-600" />
                      </div>
                      <div className="p-3 bg-white border border-gray-200 rounded-lg">
                        <Upload className="w-5 h-5 text-gray-600" />
                      </div>
                    </div>
                    <span className="text-sm text-gray-500">
                      {photoModalState.photos.length === 0 ? 'Files' : `${photoModalState.photos.length} file(s) uploaded`}
                    </span>
                  </label>
                </div>
                <p className="text-xs text-gray-500 mt-2 text-right">
                  Setiap file memiliki batas maksimum 9 MB, dengan jumlah unggahan maksimal 20 file.
                </p>
              </div>

              {/* Photos Grid */}
              {photoModalState.photos.length > 0 && (
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-3">
                    Foto yang diupload ({photoModalState.photos.length})
                  </label>
                  <div className="grid grid-cols-3 sm:grid-cols-4 gap-3 max-h-64 overflow-y-auto p-2 border border-gray-200 rounded-lg">
                    {photoModalState.photos.map((photo, idx) => (
                      <div key={idx} className="relative group">
                        <div className="aspect-square rounded-lg overflow-hidden border-2 border-gray-200">
                          <img src={photo} alt={`Foto ${idx + 1}`} className="w-full h-full object-cover" />
                        </div>
                        <button
                          onClick={() => handleRemovePhoto(idx)}
                          className="absolute top-1 right-1 bg-red-600 hover:bg-red-700 text-white p-1.5 rounded-full opacity-0 group-hover:opacity-100 transition-opacity"
                          title="Hapus foto"
                        >
                          <X className="w-3 h-3" />
                        </button>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Action Buttons */}
              <div className="flex gap-3 pt-2">
                <button 
                  type="button" 
                  onClick={() => setPhotoModalState({ isOpen: false, activityId: null, photos: [] })}
                  className="flex-1 px-4 py-2.5 text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg font-medium transition-colors text-sm"
                >
                  Cancel
                </button>
                <button 
                  type="button" 
                  onClick={handleSavePhotos}
                  className="flex-1 px-4 py-2.5 text-white bg-red-800 hover:bg-red-900 rounded-lg font-medium transition-colors text-sm"
                >
                  Save changes
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}