import { useState } from 'react';
import { ImageWithFallback } from '../components/figma/ImageWithFallback';
import { CheckSquare, Calendar, BarChart3, Lock, FolderKanban, ArrowRight } from 'lucide-react';
import { Header } from '../components/Header';
import { useNavigate } from 'react-router';
import { LoginModal } from '../components/LoginModal';
import { useAuth } from '../context/AuthContext';

export function Home() {
  const { isAuthenticated } = useAuth();
  const navigate = useNavigate();
  const [showLogin, setShowLogin] = useState(false);

  const features = [
    {
      icon: FolderKanban,
      title: 'Profil Proyek',
      description: 'Kelola informasi lengkap proyek meliputi nama, deskripsi, tempat, tanggal, pelaksana, dan supervisor untuk dokumentasi yang terstruktur.',
    },
    {
      icon: CheckSquare,
      title: 'Pekerjaan dalam Proyek',
      description: 'Atur dan monitor setiap pekerjaan dengan detail nama, deskripsi, lokasi, timeline, serta pembagian pelaksana dan supervisor.',
    },
    {
      icon: Calendar,
      title: 'Perencanaan Aktivitas',
      description: 'Rencanakan setiap aktivitas dengan menentukan nama kegiatan, jadwal waktu pelaksanaan, dan siapa pelaksana yang bertanggung jawab.',
    },
    {
      icon: BarChart3,
      title: 'Pemantauan Realisasi',
      description: 'Evaluasi pelaksanaan aktivitas secara berkala dan susun rencana tambahan untuk memastikan proyek berjalan sesuai target.',
    },
    {
      icon: Lock,
      title: 'Penutupan Proyek',
      description: 'Finalisasi proyek dengan sistem kunci otomatis yang memastikan tidak ada pekerjaan atau aktivitas yang dapat ditambahkan.',
    },
  ];

  const handleMulaiSekarang = () => {
    if (isAuthenticated) {
      navigate('/projects');
    } else {
      setShowLogin(true);
    }
  };

  return (
    <div className="min-h-screen bg-white">
      <Header onLoginClick={() => setShowLogin(true)} />

      {/* Hero Section */}
      <section className="px-4 py-10 sm:px-6 md:px-12 lg:px-20 md:py-16">
        <div className="max-w-7xl mx-auto">
          <div className="grid md:grid-cols-2 gap-8 md:gap-12 items-center">
            <div className="text-center md:text-left">
              <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold text-gray-900 mb-4 md:mb-6">
                Manajemen Proyek
                <span className="block text-red-800 mt-1 md:mt-2">Mahasiswa</span>
              </h2>
              <p className="text-base sm:text-lg text-gray-600 mb-6 md:mb-8 max-w-lg mx-auto md:mx-0">
                Platform kolaborasi yang memudahkan mahasiswa dalam mengelola,
                merencanakan, dan memantau setiap tahapan proyek dengan sistematis
                dan terorganisir.
              </p>
              <button
                onClick={handleMulaiSekarang}
                className="inline-flex items-center gap-2 bg-red-800 hover:bg-red-900 text-white px-6 py-3 sm:px-8 rounded-lg font-medium transition-colors"
              >
                Mulai Sekarang
                <ArrowRight className="w-4 h-4" />
              </button>
            </div>
            <div className="relative mt-6 md:mt-0">
              <div className="aspect-[4/3] rounded-2xl overflow-hidden shadow-xl">
                <ImageWithFallback
                  src="https://images.unsplash.com/photo-1758270705317-3ef6142d306f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzdHVkZW50cyUyMHRlYW13b3JrJTIwY29sbGFib3JhdGlvbiUyMHByb2plY3R8ZW58MXx8fHwxNzcyNDQ2NjgzfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
                  alt="Kolaborasi tim mahasiswa"
                  className="w-full h-full object-cover"
                />
              </div>
              <div className="absolute -bottom-4 -left-4 w-20 h-20 bg-red-800/10 rounded-full blur-2xl"></div>
              <div className="absolute -top-4 -right-4 w-28 h-28 bg-red-800/10 rounded-full blur-2xl"></div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="px-4 py-14 sm:px-6 md:px-12 lg:px-20 md:py-20 bg-gray-50">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-10 md:mb-16">
            <h3 className="text-2xl sm:text-3xl md:text-4xl font-bold text-gray-900 mb-3 md:mb-4">
              Kemampuan Aplikasi
            </h3>
            <p className="text-base sm:text-lg text-gray-600 max-w-2xl mx-auto">
              Lima fitur utama yang dirancang khusus untuk membantu mahasiswa
              mengelola proyek dari awal hingga selesai
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6">
            {features.map((feature, index) => {
              const Icon = feature.icon;
              return (
                <div
                  key={index}
                  className="bg-white rounded-xl p-5 md:p-6 shadow-sm hover:shadow-md transition-shadow border border-gray-100"
                >
                  <div className="w-11 h-11 md:w-12 md:h-12 bg-red-800 rounded-lg flex items-center justify-center mb-4">
                    <Icon className="w-5 h-5 md:w-6 md:h-6 text-white" />
                  </div>
                  <h4 className="text-lg md:text-xl font-bold text-gray-900 mb-2 md:mb-3">
                    {feature.title}
                  </h4>
                  <p className="text-sm md:text-base text-gray-600 leading-relaxed">
                    {feature.description}
                  </p>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* CTA Banner */}
      <section className="px-4 py-12 sm:px-6 md:px-12 lg:px-20 bg-red-800">
        <div className="max-w-3xl mx-auto text-center">
          <h3 className="text-2xl sm:text-3xl font-bold text-white mb-3">
            Siap Mengelola Proyek Anda?
          </h3>
          <p className="text-red-200 text-base mb-6">
            Bergabunglah dan mulai kelola proyek mahasiswa Anda secara lebih terstruktur.
          </p>
          <button
            onClick={handleMulaiSekarang}
            className="inline-flex items-center gap-2 bg-white text-red-800 hover:bg-red-50 px-6 py-3 rounded-lg font-medium transition-colors"
          >
            Mulai Sekarang
            <ArrowRight className="w-4 h-4" />
          </button>
        </div>
      </section>

      {/* Footer */}
      <footer className="px-4 py-6 sm:px-6 md:px-12 lg:px-20 border-t border-gray-200">
        <div className="max-w-7xl mx-auto text-center text-gray-600 text-sm">
          <p>© 2026 ProManage. Platform Manajemen Proyek Mahasiswa.</p>
        </div>
      </footer>

      {/* Login Modal */}
      <LoginModal open={showLogin} onClose={() => setShowLogin(false)} />
    </div>
  );
}
