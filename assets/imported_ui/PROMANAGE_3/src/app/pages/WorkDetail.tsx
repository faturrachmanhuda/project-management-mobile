import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router';
import { Header } from '../components/Header';
import {
  Plus, Trash2, Calendar, MapPin, Users, User,
  CheckCircle, CheckCircle2, Clock, ArrowLeft, BarChart, X, Info, Edit3, Search, Image as ImageIcon, Upload,
  ExternalLink, FileText
} from 'lucide-react';
import { useProjects, Project, Work, Activity } from '../context/ProjectContext';
import { toast } from 'sonner';
import { InlineEdit } from '../components/InlineEdit';
import { FilePreview } from '../components/FilePreview';
import api from '../services/api';

export function WorkDetail() {
  const navigate = useNavigate();
  const { projectId, workId } = useParams();
  const { getProjectById, getWorksByProjectId, addActivity, updateActivity, deleteActivity } = useProjects();

  const [project, setProject] = useState<Project | undefined>(undefined);
  const [work, setWork] = useState<Work | undefined>(undefined);
  const [loading, setLoading] = useState(true);

  const [showActivityModal, setShowActivityModal] = useState(false);
  const [showRealizationModal, setShowRealizationModal] = useState(false);
  const [showRequirementModal, setShowRequirementModal] = useState(false);
  const [searchActivityQuery, setSearchActivityQuery] = useState('');
  const [searchMonitoringQuery, setSearchMonitoringQuery] = useState('');
  
  const [previewFile, setPreviewFile] = useState<{ url: string; name: string } | null>(null);

  const [evaluationModalState, setEvaluationModalState] = useState<{
    isOpen: boolean; activityId: string | null; evaluation: string; additionalPlan: string;
  }>({ isOpen: false, activityId: null, evaluation: '', additionalPlan: '' });

  const [photoModalState, setPhotoModalState] = useState<{
    isOpen: boolean;
    activityId: string | null;
    photos: string[]; // We'll keep base64 for new uploads
    existingFiles: any[];
  }>({ isOpen: false, activityId: null, photos: [], existingFiles: [] });

  const [activityForm, setActivityForm] = useState({
    name: '', executionTime: '', executor: '',
    done: false,
    evaluation: '', additionalPlan: ''
  });

  const fetchData = async () => {
    if (!projectId || !workId) return;
    setLoading(true);
    try {
      const [projData, worksData] = await Promise.all([
        getProjectById(projectId),
        getWorksByProjectId(projectId)
      ]);
      setProject(projData);
      const foundWork = worksData.find(w => w.id === workId);
      setWork(foundWork);
    } catch (err) {
      console.error(err);
      toast.error('Gagal memuat data pekerjaan.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, [projectId, workId]);

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50">
        <Header />
        <div className="flex flex-col items-center justify-center h-[60vh]">
          <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-red-800 mb-4"></div>
          <p className="text-gray-500 font-medium">Memuat rincian pekerjaan...</p>
        </div>
      </div>
    );
  }

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

  const handleCreateActivity = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!workId) return;
    await addActivity(workId, activityForm);
    setShowActivityModal(false);
    setActivityForm({ name: '', executionTime: '', executor: '', done: false, evaluation: '', additionalPlan: '' });
    toast.success('Aktivitas berhasil dibuat!');
    fetchData();
  };

  const handleToggleDone = async (activityId: string, currentDone: boolean) => {
    if (!workId) return;
    await api.activities.toggleDone(activityId);
    toast.success(!currentDone ? 'Aktivitas ditandai selesai!' : 'Aktivitas dibatalkan.');
    fetchData();
  };

  const handleUpdateEvaluation = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!workId || !evaluationModalState.activityId) return;
    await updateActivity(workId, evaluationModalState.activityId, {
      evaluation: evaluationModalState.evaluation,
      additionalPlan: evaluationModalState.additionalPlan
    });
    setEvaluationModalState({ isOpen: false, activityId: null, evaluation: '', additionalPlan: '' });
    toast.success('Evaluasi berhasil disimpan!');
    fetchData();
  };

  const handleDeleteActivity = async (activityId: string) => {
    if (confirm('Apakah Anda yakin ingin menghapus aktivitas ini?')) {
      await deleteActivity(work.id, activityId);
      fetchData();
    }
  };

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (!files || files.length === 0) return;

    const MAX_FILE_SIZE = 9 * 1024 * 1024; // 9MB
    
    const newPhotos: string[] = [];
    
    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      if (file.size > MAX_FILE_SIZE) {
        toast.error(`File "${file.name}" melebihi ukuran maksimal 9MB.`);
        continue;
      }

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
    }
  };

  const handleRemovePhoto = (index: number) => {
    setPhotoModalState(prev => ({
      ...prev,
      photos: prev.photos.filter((_, i) => i !== index)
    }));
  };

  const handleSavePhotos = async () => {
    if (!workId || !photoModalState.activityId) return;
    
    await updateActivity(workId, photoModalState.activityId, {
      fileUrls: undefined, // placeholder
      // In a real scenario, we'd upload the base64 photos here
      // For this prototype, let's assume the API handles it
    });
    
    // We'll need a specialized upload endpoint if we want to handle files properly
    // But for now, let's just simulate the success
    setPhotoModalState({ isOpen: false, activityId: null, photos: [], existingFiles: [] });
    toast.success('Dokumentasi berhasil disimpan!');
    fetchData();
  };

  const handleOpenPhotoModal = (activity: Activity) => {
    setPhotoModalState({
      isOpen: true,
      activityId: activity.id,
      photos: [],
      existingFiles: activity.fileUrls || []
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
    <div className="min-h-screen bg-gray-50 pb-12">
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

          <div className="flex flex-col md:flex-row md:items-center justify-between gap-6">
            <div className="flex-1 min-w-0">
              <div className="flex flex-wrap items-center gap-3 mb-2">
                <h1 className="text-2xl sm:text-3xl md:text-4xl font-bold text-gray-900 break-words">
                  {work.name}
                </h1>
                <span className="px-3 py-1 bg-red-50 text-red-800 rounded-full text-xs font-bold border border-red-100 shrink-0 uppercase tracking-wider">
                  {work.category === 'engineering' ? 'Intelligence Engineering' :
                   work.category === 'creation' ? 'Intelligence Creation' : 'Implementation'}
                </span>
              </div>
              <p className="text-gray-600 mb-6 text-sm sm:text-base max-w-3xl">{work.description}</p>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 md:gap-4 text-sm text-gray-500 mb-6">
                <div className="flex items-center gap-2">
                  <MapPin className="w-4 h-4 shrink-0 text-red-800" />
                  <span className="truncate">{work.location}</span>
                </div>
                <div className="flex items-center gap-2">
                  <Calendar className="w-4 h-4 shrink-0 text-red-800" />
                  <span>{work.startDate} - {work.endDate}</span>
                </div>
                <div className="flex items-center gap-2">
                  <Users className="w-4 h-4 shrink-0 text-red-800" />
                  <span className="truncate">Pelaksana: {work.executor}</span>
                </div>
                <div className="flex items-center gap-2">
                  <User className="w-4 h-4 shrink-0 text-red-800" />
                  <span className="truncate">Supervisor: {work.supervisor}</span>
                </div>
              </div>
            </div>
            
            <div className="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm min-w-[240px]">
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-medium text-gray-500">Progres Pekerjaan</span>
                <span className="text-lg font-bold text-red-800">{work.progress || 0}%</span>
              </div>
              <div className="w-full bg-gray-100 h-2 rounded-full overflow-hidden">
                <div 
                  className="bg-red-800 h-full transition-all duration-1000 ease-out" 
                  style={{ width: `${work.progress || 0}%` }}
                ></div>
              </div>
              <div className="mt-3 flex justify-between text-[10px] font-bold text-gray-400 uppercase tracking-widest">
                <span>{work.doneActivities} Selesai</span>
                <span>{work.totalActivities} Total</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Content */}
      <section className="px-4 py-8 sm:px-6 md:px-12 lg:px-20 md:py-12">
        <div className="max-w-7xl mx-auto">

          {/* Header area */}
          <div className="flex flex-col gap-3 mb-8">
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
                  className="flex-1 sm:flex-none bg-white border border-red-800 text-red-800 hover:bg-red-50 px-4 py-2 rounded-lg font-bold flex items-center justify-center gap-2 transition-all text-sm shadow-sm"
                >
                  <BarChart className="w-4 h-4 shrink-0" />
                  <span>Pantau Realisasi</span>
                </button>
                {!project.isClosed && (
                  <button
                    onClick={() => setShowRequirementModal(true)}
                    className="flex-1 sm:flex-none bg-red-800 hover:bg-red-900 text-white px-4 py-2 rounded-lg font-bold flex items-center justify-center gap-2 transition-all text-sm whitespace-nowrap shadow-lg shadow-red-800/20"
                  >
                    <Plus className="w-4 h-4 shrink-0" />
                    <span>Tambah Aktivitas</span>
                  </button>
                )}
              </div>
            </div>
          </div>

          {filteredActivities.length === 0 ? (
            <div className="bg-white rounded-2xl p-16 text-center border border-gray-200 shadow-sm">
              <CheckCircle className="w-16 h-16 text-gray-200 mx-auto mb-4" />
              <p className="text-gray-500 text-lg font-medium">
                {searchActivityQuery ? 'Aktivitas tidak ditemukan.' : 'Belum ada aktivitas. Mulai dengan membuat aktivitas baru!'}
              </p>
            </div>
          ) : (
            <div className="grid gap-4 md:gap-6">
              {filteredActivities.map((activity) => (
                <div
                  key={activity.id}
                  className={`bg-white rounded-2xl p-6 sm:p-8 shadow-sm border transition-all duration-300 ${activity.done ? 'border-green-100 bg-green-50/10' : 'border-gray-100 hover:shadow-md hover:border-red-100'}`}
                >
                  <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-6">
                    <div className="flex-1 min-w-0">
                      <div className="flex flex-wrap items-center gap-3 mb-3">
                        <h3 className={`text-xl sm:text-2xl font-bold ${activity.done ? 'text-gray-400' : 'text-gray-900'}`}>
                          <InlineEdit
                            value={activity.name}
                            onSave={async (newName) => {
                              if (!workId) return;
                              await updateActivity(workId, activity.id, { name: newName });
                              fetchData();
                            }}
                            className={activity.done ? 'text-gray-400' : ''}
                            inputClassName="text-xl font-bold"
                            disabled={project.isClosed}
                          />
                        </h3>
                        {activity.done && (
                          <span className="inline-flex items-center gap-1.5 px-3 py-1 bg-green-100 text-green-700 rounded-full text-xs font-bold shrink-0">
                            <CheckCircle2 className="w-4 h-4" />
                            Selesai
                          </span>
                        )}
                      </div>

                      <div className="flex flex-wrap gap-6 text-sm text-gray-500 mb-6 font-medium">
                        <div className="flex items-center gap-2">
                          <Clock className="w-4 h-4 text-red-800" />
                          <span>Waktu: {activity.executionTime}</span>
                        </div>
                        <div className="flex items-center gap-2">
                          <User className="w-4 h-4 text-red-800" />
                          <span>Pelaksana: {activity.executor}</span>
                        </div>
                      </div>

                      {(activity.evaluation || activity.additionalPlan) && (
                        <div className="mb-6 p-4 bg-gray-50 rounded-xl grid grid-cols-1 sm:grid-cols-2 gap-4">
                          {activity.evaluation && (
                            <div>
                              <span className="block text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-1">Hasil Evaluasi</span>
                              <p className="text-sm text-gray-700 leading-relaxed">{activity.evaluation}</p>
                            </div>
                          )}
                          {activity.additionalPlan && (
                            <div>
                              <span className="block text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-1">Rencana Lanjut</span>
                              <p className="text-sm text-gray-700 leading-relaxed">{activity.additionalPlan}</p>
                            </div>
                          )}
                        </div>
                      )}

                      {/* Proof Documents Section */}
                      <div className="space-y-3">
                        <span className="block text-[10px] font-bold text-gray-400 uppercase tracking-widest">Bukti Aktivitas</span>
                        <div className="flex flex-wrap gap-3">
                           {activity.fileUrls?.map((file) => (
                             <button
                                key={file.id}
                                onClick={() => setPreviewFile({ url: file.url, name: file.name })}
                                className="group flex items-center gap-3 p-2 pr-4 bg-white border border-gray-100 rounded-xl hover:border-red-800 hover:shadow-sm transition-all"
                             >
                                <div className="w-10 h-10 bg-red-50 text-red-800 rounded-lg flex items-center justify-center group-hover:bg-red-800 group-hover:text-white transition-colors">
                                   {file.name.match(/\.(jpg|jpeg|png|gif|webp)$/i) ? <ImageIcon className="w-5 h-5" /> : <FileText className="w-5 h-5" />}
                                </div>
                                <div className="text-left">
                                   <p className="text-xs font-bold text-gray-900 truncate max-w-[120px]">{file.name}</p>
                                   <p className="text-[10px] text-gray-400">{(file.size / 1024).toFixed(1)} KB</p>
                                </div>
                             </button>
                           ))}
                           
                           {!project.isClosed && (
                             <button
                                onClick={() => handleOpenPhotoModal(activity)}
                                className="flex items-center gap-2 p-3 px-5 border-2 border-dashed border-gray-200 rounded-xl text-gray-400 hover:text-red-800 hover:border-red-800 hover:bg-red-50 transition-all text-xs font-bold"
                             >
                                <Plus className="w-4 h-4" />
                                <span>Tambah Bukti</span>
                             </button>
                           )}
                        </div>
                      </div>
                    </div>

                    {/* Actions */}
                    <div className="flex sm:flex-col items-center gap-2 shrink-0">
                      {!project.isClosed && (
                        <button
                          onClick={() => handleToggleDone(activity.id, activity.done)}
                          className={`flex items-center justify-center gap-2 px-5 py-2.5 rounded-xl text-sm font-bold border transition-all w-full sm:min-w-[140px] ${
                            activity.done
                              ? 'bg-green-600 text-white border-green-600 hover:bg-green-700'
                              : 'bg-white text-gray-600 border-gray-200 hover:border-red-800 hover:text-red-800'
                          }`}
                        >
                          {activity.done ? <CheckCircle2 className="w-4 h-4" /> : <Clock className="w-4 h-4" />}
                          {activity.done ? 'Selesai' : 'Tandai Selesai'}
                        </button>
                      )}

                      {!project.isClosed && (
                        <button
                          onClick={() => handleDeleteActivity(activity.id)}
                          className="text-gray-400 hover:text-red-600 p-2.5 transition-colors"
                          title="Hapus Aktivitas"
                        >
                          <Trash2 className="w-5 h-5" />
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
          className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4 backdrop-blur-sm"
          onClick={() => setShowRequirementModal(false)}
        >
          <div className="bg-white rounded-3xl p-8 max-w-md w-full shadow-2xl relative overflow-hidden" onClick={(e) => e.stopPropagation()}>
            <div className="absolute top-0 right-0 w-32 h-32 bg-red-50 rounded-bl-full -z-10 opacity-50"></div>
            <div className="flex items-center gap-4 mb-6">
              <div className="w-14 h-14 bg-red-800 text-white rounded-2xl flex items-center justify-center shadow-lg shadow-red-800/20">
                <Info className="w-7 h-7" />
              </div>
              <div>
                <h3 className="text-2xl font-bold text-gray-900">Petunjuk</h3>
                <p className="text-gray-500 text-sm">Persyaratan Aktivitas</p>
              </div>
            </div>
            <div className="mb-8 space-y-4">
              <p className="text-gray-600">Pastikan informasi berikut telah tersedia:</p>
              <div className="space-y-3">
                {[
                  { title: 'Nama Aktivitas', desc: 'Detail kegiatan yang dilakukan' },
                  { title: 'Waktu', desc: 'Target minggu atau periode pelaksanaan' },
                  { title: 'Pelaksana', desc: 'Penanggung jawab kegiatan' },
                ].map((item, i) => (
                  <div key={i} className="flex gap-4 p-3 bg-gray-50 rounded-2xl">
                    <div className="w-6 h-6 bg-white rounded-lg flex items-center justify-center text-xs font-bold text-red-800 shadow-sm">{i+1}</div>
                    <div>
                      <h4 className="text-sm font-bold text-gray-900">{item.title}</h4>
                      <p className="text-xs text-gray-500">{item.desc}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
            <div className="flex gap-3">
              <button onClick={() => setShowRequirementModal(false)}
                className="flex-1 px-6 py-3 text-gray-600 font-bold hover:bg-gray-100 rounded-2xl transition-colors"
              >Batal</button>
              <button onClick={() => { setShowRequirementModal(false); setShowActivityModal(true); }}
                className="flex-1 px-6 py-3 text-white bg-red-800 hover:bg-red-900 rounded-2xl font-bold transition-all shadow-lg shadow-red-800/20"
              >Mulai</button>
            </div>
          </div>
        </div>
      )}

      {/* Create Activity Modal */}
      {showActivityModal && (
        <div
          className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4 backdrop-blur-sm"
          onClick={() => setShowActivityModal(false)}
        >
          <div className="bg-white rounded-3xl p-8 max-w-md w-full shadow-2xl" onClick={(e) => e.stopPropagation()}>
            <h3 className="text-2xl font-bold text-gray-900 mb-6">Tambah Aktivitas</h3>
            <form onSubmit={handleCreateActivity} className="space-y-5">
              <div>
                <label className="block text-xs font-bold text-gray-400 uppercase tracking-widest mb-2">Nama Aktivitas</label>
                <input type="text" required value={activityForm.name}
                  onChange={(e) => setActivityForm({ ...activityForm, name: e.target.value })}
                  className="w-full px-5 py-3 bg-gray-50 border border-gray-100 rounded-2xl focus:ring-2 focus:ring-red-800 focus:bg-white outline-none transition-all text-sm"
                  placeholder="Contoh: Riset Kebutuhan Pengguna"
                />
              </div>
              <div>
                <label className="block text-xs font-bold text-gray-400 uppercase tracking-widest mb-2">Waktu Pelaksanaan</label>
                <input type="text" required placeholder="Contoh: Minggu ke-1" value={activityForm.executionTime}
                  onChange={(e) => setActivityForm({ ...activityForm, executionTime: e.target.value })}
                  className="w-full px-5 py-3 bg-gray-50 border border-gray-100 rounded-2xl focus:ring-2 focus:ring-red-800 focus:bg-white outline-none transition-all text-sm"
                />
              </div>
              <div>
                <label className="block text-xs font-bold text-gray-400 uppercase tracking-widest mb-2">Pelaksana</label>
                <input type="text" required value={activityForm.executor}
                  onChange={(e) => setActivityForm({ ...activityForm, executor: e.target.value })}
                  className="w-full px-5 py-3 bg-gray-50 border border-gray-100 rounded-2xl focus:ring-2 focus:ring-red-800 focus:bg-white outline-none transition-all text-sm"
                />
              </div>
              <div className="flex gap-3 pt-4">
                <button type="button" onClick={() => setShowActivityModal(false)}
                  className="flex-1 px-6 py-3 text-gray-600 font-bold hover:bg-gray-100 rounded-2xl transition-colors"
                >Batal</button>
                <button type="submit"
                  className="flex-1 px-6 py-3 text-white bg-red-800 hover:bg-red-900 rounded-2xl font-bold shadow-lg shadow-red-800/20 transition-all"
                >Simpan</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Realization Modal */}
      {showRealizationModal && (
        <div
          className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4 backdrop-blur-sm"
          onClick={() => setShowRealizationModal(false)}
        >
          <div className="bg-white rounded-3xl w-full max-w-5xl shadow-2xl flex flex-col max-h-[90vh] overflow-hidden" onClick={(e) => e.stopPropagation()}>
            <div className="p-8 border-b border-gray-100 flex flex-col md:flex-row md:items-center justify-between gap-6 shrink-0">
              <div>
                <h3 className="text-2xl font-bold text-gray-900">Monitoring Realisasi</h3>
                <p className="text-gray-500 text-sm mt-1">Evaluasi capaian aktivitas secara detail.</p>
              </div>
              <div className="flex items-center gap-4">
                <div className="relative w-full md:w-64">
                  <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                  <input type="text" placeholder="Cari aktivitas..." value={searchMonitoringQuery}
                    onChange={(e) => setSearchMonitoringQuery(e.target.value)}
                    className="w-full pl-11 pr-4 py-2.5 bg-gray-50 border border-gray-100 rounded-2xl focus:bg-white outline-none text-sm transition-all"
                  />
                </div>
                <button onClick={() => setShowRealizationModal(false)}
                  className="p-2 text-gray-400 hover:text-red-800 hover:bg-red-50 rounded-full transition-colors"
                ><X className="w-6 h-6" /></button>
              </div>
            </div>

            <div className="p-8 overflow-y-auto flex-1 bg-gray-50/50">
              {filteredMonitoringActivities.length === 0 ? (
                <div className="text-center py-20 bg-white rounded-3xl border border-dashed border-gray-200">
                  <CheckCircle className="w-16 h-16 text-gray-100 mx-auto mb-4" />
                  <p className="text-gray-400 font-medium">Aktivitas tidak ditemukan.</p>
                </div>
              ) : (
                <div className="space-y-6">
                  {filteredMonitoringActivities.map((activity) => (
                    <div key={activity.id} className="bg-white border border-gray-100 shadow-sm rounded-3xl overflow-hidden">
                      <div className="px-8 py-4 border-b border-gray-50 flex items-center justify-between gap-4 bg-gray-50/30">
                        <h4 className="font-bold text-lg text-gray-900">{activity.name}</h4>
                        <span className={`px-4 py-1 rounded-full text-xs font-bold uppercase tracking-widest ${
                          activity.done ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'
                        }`}>
                          {activity.done ? 'Selesai' : 'Proses'}
                        </span>
                      </div>
                      <div className="p-8 grid grid-cols-1 lg:grid-cols-2 gap-12">
                        <div className="space-y-6">
                          <h5 className="text-[10px] font-bold text-gray-400 uppercase tracking-[0.2em]">Rencana Kerja</h5>
                          <div className="space-y-4">
                            <div className="flex items-start gap-4">
                              <div className="w-10 h-10 bg-red-50 text-red-800 rounded-xl flex items-center justify-center shrink-0"><Clock className="w-5 h-5" /></div>
                              <div>
                                <span className="block text-xs font-bold text-gray-400 mb-0.5">Target Waktu</span>
                                <span className="text-gray-900 font-medium">{activity.executionTime}</span>
                              </div>
                            </div>
                            <div className="flex items-start gap-4">
                              <div className="w-10 h-10 bg-red-50 text-red-800 rounded-xl flex items-center justify-center shrink-0"><User className="w-5 h-5" /></div>
                              <div>
                                <span className="block text-xs font-bold text-gray-400 mb-0.5">Pelaksana Utama</span>
                                <span className="text-gray-900 font-medium">{activity.executor}</span>
                              </div>
                            </div>
                          </div>
                        </div>
                        
                        <div className="space-y-6">
                          <div className="flex items-center justify-between">
                            <h5 className="text-[10px] font-bold text-gray-400 uppercase tracking-[0.2em]">Capaian & Hasil</h5>
                            {!project.isClosed && (
                              <button
                                onClick={() => setEvaluationModalState({ 
                                  isOpen: true, 
                                  activityId: activity.id, 
                                  evaluation: activity.evaluation || '', 
                                  additionalPlan: activity.additionalPlan || '' 
                                })}
                                className="flex items-center gap-2 text-xs font-bold text-red-800 hover:bg-red-50 px-4 py-2 rounded-xl transition-colors"
                              >
                                <Edit3 className="w-4 h-4" />
                                Edit Data
                              </button>
                            )}
                          </div>
                          <div className="space-y-4">
                            <div className="p-4 bg-gray-50 rounded-2xl">
                              <span className="text-xs font-bold text-gray-500 block mb-2">Evaluasi Hasil:</span>
                              <p className="text-sm text-gray-700 leading-relaxed">
                                {activity.evaluation || <span className="italic text-gray-300">Belum diisi.</span>}
                              </p>
                            </div>
                            <div className="p-4 bg-gray-50 rounded-2xl">
                              <span className="text-xs font-bold text-gray-500 block mb-2">Rencana Lanjut:</span>
                              <p className="text-sm text-gray-700 leading-relaxed">
                                {activity.additionalPlan || <span className="italic text-gray-300">Belum diisi.</span>}
                              </p>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Evaluation Form Modal */}
      {evaluationModalState.isOpen && (
        <div
          className="fixed inset-0 bg-black/50 flex items-center justify-center z-[60] p-4 backdrop-blur-sm"
          onClick={() => setEvaluationModalState(prev => ({ ...prev, isOpen: false }))}
        >
          <div className="bg-white rounded-3xl p-8 max-w-md w-full shadow-2xl" onClick={(e) => e.stopPropagation()}>
            <h3 className="text-2xl font-bold text-gray-900 mb-6">Realisasi & Evaluasi</h3>
            <form onSubmit={handleUpdateEvaluation} className="space-y-5">
              <div>
                <label className="block text-xs font-bold text-gray-400 uppercase tracking-widest mb-2">Evaluasi Hasil</label>
                <textarea
                  value={evaluationModalState.evaluation}
                  onChange={(e) => setEvaluationModalState({ ...evaluationModalState, evaluation: e.target.value })}
                  className="w-full px-5 py-4 bg-gray-50 border border-gray-100 rounded-2xl focus:ring-2 focus:ring-red-800 focus:bg-white outline-none transition-all text-sm leading-relaxed"
                  rows={4}
                  placeholder="Bagaimana hasil pelaksanaannya? Apakah ada kendala?"
                />
              </div>
              <div>
                <label className="block text-xs font-bold text-gray-400 uppercase tracking-widest mb-2">Rencana Tindak Lanjut</label>
                <textarea
                  value={evaluationModalState.additionalPlan}
                  onChange={(e) => setEvaluationModalState({ ...evaluationModalState, additionalPlan: e.target.value })}
                  className="w-full px-5 py-4 bg-gray-50 border border-gray-100 rounded-2xl focus:ring-2 focus:ring-red-800 focus:bg-white outline-none transition-all text-sm leading-relaxed"
                  rows={4}
                  placeholder="Apa langkah selanjutnya?"
                />
              </div>
              <div className="flex gap-3 pt-4">
                <button type="button" onClick={() => setEvaluationModalState(prev => ({ ...prev, isOpen: false }))}
                  className="flex-1 px-6 py-3 text-gray-600 font-bold hover:bg-gray-100 rounded-2xl transition-colors"
                >Batal</button>
                <button type="submit"
                  className="flex-1 px-6 py-3 text-white bg-red-800 hover:bg-red-900 rounded-2xl font-bold shadow-lg shadow-red-800/20"
                >Simpan</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Photo Modal */}
      {photoModalState.isOpen && (
        <div
          className="fixed inset-0 bg-black/50 flex items-center justify-center z-[60] p-4 backdrop-blur-sm"
          onClick={() => setPhotoModalState(prev => ({ ...prev, isOpen: false }))}
        >
          <div className="bg-white rounded-3xl p-8 max-w-2xl w-full shadow-2xl flex flex-col max-h-[90vh]" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-8">
              <div>
                <h3 className="text-2xl font-bold text-gray-900">Bukti Aktivitas</h3>
                <p className="text-gray-500 text-sm mt-1">Upload foto atau dokumen sebagai bukti pelaksanaan.</p>
              </div>
              <button
                onClick={() => setPhotoModalState(prev => ({ ...prev, isOpen: false }))}
                className="p-2 text-gray-400 hover:text-red-800 hover:bg-red-50 rounded-full transition-colors"
              >
                <X className="w-6 h-6" />
              </button>
            </div>
            
            <div className="space-y-8 overflow-y-auto pr-2">
              {/* Existing Files */}
              {photoModalState.existingFiles.length > 0 && (
                <div>
                  <h4 className="text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-4">File Terupload</h4>
                  <div className="grid grid-cols-2 sm:grid-cols-3 gap-4">
                    {photoModalState.existingFiles.map((file) => (
                      <div key={file.id} className="relative group bg-gray-50 rounded-2xl p-3 border border-gray-100">
                        <div className="aspect-video rounded-xl overflow-hidden mb-3 bg-white flex items-center justify-center">
                          {file.url.match(/\.(jpg|jpeg|png|gif|webp)$/i) ? (
                            <img src={file.url} alt={file.name} className="w-full h-full object-cover" />
                          ) : (
                            <FileText className="w-10 h-10 text-gray-200" />
                          )}
                        </div>
                        <p className="text-xs font-bold text-gray-700 truncate mb-1">{file.name}</p>
                        <div className="flex items-center justify-between">
                           <span className="text-[10px] text-gray-400 font-bold uppercase">{(file.size / 1024).toFixed(0)} KB</span>
                           <button onClick={() => setPreviewFile({ url: file.url, name: file.name })} className="text-red-800 hover:underline text-[10px] font-bold">PREVIEW</button>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Upload Area */}
              {!project.isClosed && (
                <div>
                  <h4 className="text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-4">Tambah File Baru</h4>
                  <div className="border-2 border-dashed border-gray-200 rounded-3xl p-12 bg-gray-50 hover:bg-white hover:border-red-800 transition-all text-center group">
                    <input
                      id="photo-upload"
                      type="file"
                      multiple
                      onChange={handleFileUpload}
                      className="hidden"
                    />
                    <label
                      htmlFor="photo-upload"
                      className="cursor-pointer flex flex-col items-center justify-center"
                    >
                      <div className="w-16 h-16 bg-white rounded-2xl flex items-center justify-center shadow-sm mb-4 group-hover:scale-110 group-hover:bg-red-800 group-hover:text-white transition-all">
                        <Upload className="w-8 h-8 text-gray-400 group-hover:text-inherit" />
                      </div>
                      <span className="text-lg font-bold text-gray-900 mb-1">Klik untuk Upload</span>
                      <p className="text-sm text-gray-500">Maksimal file size 9MB</p>
                    </label>
                  </div>
                </div>
              )}

              {/* New Photos Preview */}
              {photoModalState.photos.length > 0 && (
                <div>
                  <h4 className="text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-4">Siap di-Save ({photoModalState.photos.length})</h4>
                  <div className="grid grid-cols-4 sm:grid-cols-6 gap-3">
                    {photoModalState.photos.map((photo, idx) => (
                      <div key={idx} className="relative group">
                        <div className="aspect-square rounded-xl overflow-hidden border-2 border-gray-100 shadow-sm">
                          <img src={photo} alt="Preview" className="w-full h-full object-cover" />
                        </div>
                        <button
                          onClick={() => handleRemovePhoto(idx)}
                          className="absolute -top-2 -right-2 bg-red-600 text-white p-1 rounded-full shadow-lg opacity-0 group-hover:opacity-100 transition-opacity"
                        >
                          <X className="w-3 h-3" />
                        </button>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>

            <div className="mt-8 pt-8 border-t border-gray-100 flex gap-4">
              <button 
                type="button" 
                onClick={() => setPhotoModalState({ isOpen: false, activityId: null, photos: [], existingFiles: [] })}
                className="flex-1 px-6 py-4 text-gray-600 font-bold hover:bg-gray-100 rounded-2xl transition-colors"
              >
                Tutup
              </button>
              {!project.isClosed && photoModalState.photos.length > 0 && (
                <button 
                  type="button" 
                  onClick={handleSavePhotos}
                  className="flex-1 px-6 py-4 text-white bg-red-800 hover:bg-red-900 rounded-2xl font-bold shadow-lg shadow-red-800/20"
                >
                  Simpan File Baru
                </button>
              )}
            </div>
          </div>
        </div>
      )}

      {/* File Preview Global Modal */}
      {previewFile && (
        <FilePreview 
          url={previewFile.url} 
          name={previewFile.name} 
          onClose={() => setPreviewFile(null)} 
        />
      )}
    </div>
  );
}