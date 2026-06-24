import { useState, useEffect } from 'react';
import { Header } from '../components/Header';
import { 
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, 
  PieChart, Pie, Cell, Legend 
} from 'recharts';
import { 
  LayoutDashboard, TrendingUp, CheckCircle2, AlertCircle, Clock, 
  Briefcase, Activity, Target, Download
} from 'lucide-react';
import api from '../services/api';
import { toast } from 'sonner';

export function Dashboard() {
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const data = await api.analytics.getDashboardStats();
        setStats(data);
      } catch (err) {
        console.error('Failed to fetch dashboard stats:', err);
        toast.error('Gagal memuat data statistik.');
      } finally {
        setLoading(false);
      }
    };
    fetchStats();
  }, []);

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50">
        <Header />
        <div className="flex flex-col items-center justify-center h-[60vh]">
          <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-red-800 mb-4"></div>
          <p className="text-gray-500 font-medium">Menganalisis data proyek...</p>
        </div>
      </div>
    );
  }

  if (!stats) return null;

  // Data mapping for charts
  const statusData = Object.entries(stats.portfolio.status).map(([name, value]) => ({ name, value }));
  const categoryData = Object.entries(stats.works.categories).map(([name, value]) => ({ 
    name: name === 'engineering' ? 'Engineering' : name === 'creation' ? 'Creation' : 'Implementation', 
    count: value 
  }));

  const COLORS = ['#991b1b', '#1e40af', '#ca8a04', '#166534'];

  return (
    <div className="min-h-screen bg-gray-50 pb-12">
      <Header />
      
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-20 py-8">
        <div className="flex items-center gap-3 mb-8">
          <div className="w-12 h-12 bg-red-800 rounded-xl flex items-center justify-center shadow-lg shadow-red-800/20">
            <LayoutDashboard className="w-6 h-6 text-white" />
          </div>
          <div>
            <h1 className="text-3xl font-bold text-gray-900">Dashboard Proyek</h1>
            <p className="text-gray-600">Ringkasan performa dan progres seluruh proyek Anda</p>
          </div>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
          <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
            <div className="flex items-center justify-between mb-4">
              <div className="w-10 h-10 bg-red-50 text-red-800 rounded-lg flex items-center justify-center">
                <Briefcase className="w-5 h-5" />
              </div>
              <span className="text-xs font-medium text-gray-400">Total Proyek</span>
            </div>
            <p className="text-3xl font-bold text-gray-900">{stats.summary.total_projects}</p>
            <p className="text-xs text-gray-500 mt-1">Proyek terdaftar</p>
          </div>

          <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
            <div className="flex items-center justify-between mb-4">
              <div className="w-10 h-10 bg-blue-50 text-blue-800 rounded-lg flex items-center justify-center">
                <Activity className="w-5 h-5" />
              </div>
              <span className="text-xs font-medium text-gray-400">Pekerjaan</span>
            </div>
            <p className="text-3xl font-bold text-gray-900">{stats.summary.total_works}</p>
            <p className="text-xs text-gray-500 mt-1">Total lingkup kerja</p>
          </div>

          <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
            <div className="flex items-center justify-between mb-4">
              <div className="w-10 h-10 bg-green-50 text-green-800 rounded-lg flex items-center justify-center">
                <CheckCircle2 className="w-5 h-5" />
              </div>
              <span className="text-xs font-medium text-gray-400">Aktivitas Selesai</span>
            </div>
            <p className="text-3xl font-bold text-gray-900">{stats.activities.done}</p>
            <p className="text-xs text-gray-500 mt-1">Dari {stats.activities.total} aktivitas</p>
          </div>

          <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
            <div className="flex items-center justify-between mb-4">
              <div className="w-10 h-10 bg-yellow-50 text-yellow-800 rounded-lg flex items-center justify-center">
                <Target className="w-5 h-5" />
              </div>
              <span className="text-xs font-medium text-gray-400">Total Progress</span>
            </div>
            <p className="text-3xl font-bold text-gray-900">{stats.activities.percent}%</p>
            <div className="w-full bg-gray-100 h-1.5 rounded-full mt-2 overflow-hidden">
              <div className="bg-yellow-500 h-full" style={{ width: `${stats.activities.percent}%` }}></div>
            </div>
          </div>
        </div>

        {/* Charts Section */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
          {/* Status Distribution */}
          <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
            <h3 className="text-lg font-bold text-gray-900 mb-6 flex items-center gap-2">
              <AlertCircle className="w-5 h-5 text-red-800" />
              Status Portofolio
            </h3>
            <div className="h-[300px] w-full">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={statusData}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={100}
                    paddingAngle={5}
                    dataKey="value"
                  >
                    {statusData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                  <Legend />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Category Distribution */}
          <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
            <h3 className="text-lg font-bold text-gray-900 mb-6 flex items-center gap-2">
              <TrendingUp className="w-5 h-5 text-red-800" />
              Distribusi Kategori Pekerjaan
            </h3>
            <div className="h-[300px] w-full">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={categoryData}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} />
                  <XAxis dataKey="name" />
                  <YAxis />
                  <Tooltip />
                  <Bar dataKey="count" fill="#991b1b" radius={[4, 4, 0, 0]} barSize={40} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>

        {/* Project Breakdown Table */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
          <div className="px-6 py-5 border-b border-gray-100 flex items-center justify-between">
            <h3 className="text-lg font-bold text-gray-900">Detail Progress Proyek</h3>
            <Clock className="w-5 h-5 text-gray-400" />
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead>
                <tr className="bg-gray-50 text-xs font-bold text-gray-500 uppercase tracking-wider">
                  <th className="px-6 py-4">Nama Proyek</th>
                  <th className="px-6 py-4">Status</th>
                  <th className="px-6 py-4">Progres</th>
                  <th className="px-6 py-4 text-right">Aksi</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {stats.project_breakdown.map((project: any, i: number) => (
                  <tr key={i} className="hover:bg-gray-50 transition-colors">
                    <td className="px-6 py-4 font-medium text-gray-900">{project.name}</td>
                    <td className="px-6 py-4">
                      <span className={`px-2.5 py-1 rounded-full text-xs font-medium ${
                        project.status === 'Aktif' ? 'bg-green-100 text-green-800' : 
                        project.status === 'Selesai' ? 'bg-blue-100 text-blue-800' : 'bg-yellow-100 text-yellow-800'
                      }`}>
                        {project.status}
                      </span>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="flex-1 bg-gray-100 h-1.5 rounded-full overflow-hidden min-w-[100px]">
                          <div 
                            className="bg-red-800 h-full" 
                            style={{ width: `${project.progress}%` }}
                          ></div>
                        </div>
                        <span className="text-sm font-bold text-gray-700">{project.progress}%</span>
                      </div>
                    </td>
                    <td className="px-6 py-4 text-right">
                       <div className="flex items-center justify-end gap-2">
                          <button 
                            onClick={() => api.export.downloadPdf(project.id, project.name)}
                            className="p-2 text-gray-400 hover:text-red-800 transition-colors"
                            title="Export PDF"
                          >
                            <Download className="w-4 h-4" />
                          </button>
                       </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </main>
    </div>
  );
}
