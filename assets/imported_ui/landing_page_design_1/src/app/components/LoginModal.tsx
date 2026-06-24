import { useState, useEffect, useRef } from 'react';
import { X, Eye, EyeOff, FolderKanban, Mail, Lock, User, Hash, LogIn, UserPlus } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { useNavigate } from 'react-router';
import { toast } from 'sonner';

interface LoginModalProps {
  open?: boolean;
  onClose: () => void;
}

type Tab = 'login' | 'register';

export function LoginModal({ open, onClose }: LoginModalProps) {
  const { login, register } = useAuth();
  const navigate = useNavigate();
  const [tab, setTab] = useState<Tab>('login');

  // Login state
  const [loginEmail, setLoginEmail] = useState('');
  const [loginPassword, setLoginPassword] = useState('');
  const [showLoginPass, setShowLoginPass] = useState(false);
  const [loginLoading, setLoginLoading] = useState(false);
  const [loginErrors, setLoginErrors] = useState<{ email?: string; password?: string; general?: string }>({});

  // Register state
  const [regName, setRegName] = useState('');
  const [regNim, setRegNim] = useState('');
  const [regEmail, setRegEmail] = useState('');
  const [regPassword, setRegPassword] = useState('');
  const [regConfirm, setRegConfirm] = useState('');
  const [showRegPass, setShowRegPass] = useState(false);
  const [showRegConfirm, setShowRegConfirm] = useState(false);
  const [regLoading, setRegLoading] = useState(false);
  const [regErrors, setRegErrors] = useState<Record<string, string>>({});

  const overlayRef = useRef<HTMLDivElement>(null);

  // Reset state when modal opens
  useEffect(() => {
    if (open) {
      setTab('login');
      setLoginEmail(''); setLoginPassword(''); setLoginErrors({});
      setRegName(''); setRegNim(''); setRegEmail(''); setRegPassword(''); setRegConfirm(''); setRegErrors({});
      setShowLoginPass(false); setShowRegPass(false); setShowRegConfirm(false);
    }
  }, [open]);

  // Close on ESC
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); };
    if (open) window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [open, onClose]);

  // Lock scroll
  useEffect(() => {
    if (open) document.body.style.overflow = 'hidden';
    else document.body.style.overflow = '';
    return () => { document.body.style.overflow = ''; };
  }, [open]);

  if (open === false) return null;

  /* ---------- VALIDATION ---------- */
  const validateEmail = (email: string) =>
    /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);

  const validateLogin = () => {
    const errs: typeof loginErrors = {};
    if (!loginEmail.trim()) errs.email = 'Email wajib diisi.';
    else if (!validateEmail(loginEmail)) errs.email = 'Format email tidak valid.';
    if (!loginPassword) errs.password = 'Kata sandi wajib diisi.';
    setLoginErrors(errs);
    return Object.keys(errs).length === 0;
  };

  const validateRegister = () => {
    const errs: Record<string, string> = {};
    if (!regName.trim()) errs.name = 'Nama wajib diisi.';
    if (!regNim.trim()) errs.nim = 'NIM wajib diisi.';
    else if (!/^\d{6,15}$/.test(regNim.trim())) errs.nim = 'NIM harus berupa angka (6–15 digit).';
    if (!regEmail.trim()) errs.email = 'Email wajib diisi.';
    else if (!validateEmail(regEmail)) errs.email = 'Format email tidak valid.';
    if (!regPassword) errs.password = 'Kata sandi wajib diisi.';
    else if (regPassword.length < 6) errs.password = 'Kata sandi minimal 6 karakter.';
    if (!regConfirm) errs.confirm = 'Konfirmasi kata sandi wajib diisi.';
    else if (regConfirm !== regPassword) errs.confirm = 'Kata sandi tidak cocok.';
    setRegErrors(errs);
    return Object.keys(errs).length === 0;
  };

  /* ---------- HANDLERS ---------- */
  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateLogin()) return;
    setLoginLoading(true);
    const res = await login(loginEmail.trim(), loginPassword);
    setLoginLoading(false);
    if (res.success) {
      toast.success('Berhasil masuk! Selamat datang 👋');
      onClose();
      navigate('/projects');
    } else {
      setLoginErrors({ general: res.error });
    }
  };

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateRegister()) return;
    setRegLoading(true);
    const res = await register(regName.trim(), regNim.trim(), regEmail.trim(), regPassword);
    setRegLoading(false);
    if (res.success) {
      toast.success('Akun berhasil dibuat! Selamat datang 🎉');
      onClose();
      navigate('/projects');
    } else {
      setRegErrors({ general: res.error ?? '' });
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center">
      {/* Backdrop */}
      <div
        ref={overlayRef}
        className="absolute inset-0 bg-black/50 backdrop-blur-sm"
        onClick={onClose}
      />

      {/* Modal / Bottom Sheet */}
      <div className="relative w-full sm:max-w-md bg-white sm:rounded-2xl rounded-t-2xl shadow-2xl overflow-hidden animate-slide-up sm:animate-none sm:scale-100 max-h-[95vh] overflow-y-auto">
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-5 border-b border-gray-100">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 bg-red-800 rounded-lg flex items-center justify-center">
              <FolderKanban className="w-5 h-5 text-white" />
            </div>
            <div>
              <p className="font-bold text-gray-900 text-base">ProManage</p>
              <p className="text-xs text-gray-500">Platform Manajemen Proyek Mahasiswa</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-2 rounded-lg text-gray-400 hover:text-gray-600 hover:bg-gray-100 transition-colors"
            aria-label="Tutup"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Tab Switch */}
        <div className="flex mx-6 mt-5 bg-gray-100 rounded-xl p-1 gap-1">
          <button
            onClick={() => { setTab('login'); setLoginErrors({}); }}
            className={`flex-1 flex items-center justify-center gap-2 py-2.5 rounded-lg text-sm font-medium transition-all ${
              tab === 'login'
                ? 'bg-white text-red-800 shadow-sm'
                : 'text-gray-500 hover:text-gray-700'
            }`}
          >
            <LogIn className="w-4 h-4" />
            Masuk
          </button>
          <button
            onClick={() => { setTab('register'); setRegErrors({}); }}
            className={`flex-1 flex items-center justify-center gap-2 py-2.5 rounded-lg text-sm font-medium transition-all ${
              tab === 'register'
                ? 'bg-white text-red-800 shadow-sm'
                : 'text-gray-500 hover:text-gray-700'
            }`}
          >
            <UserPlus className="w-4 h-4" />
            Daftar
          </button>
        </div>

        {/* ===== LOGIN FORM ===== */}
        {tab === 'login' && (
          <form onSubmit={handleLogin} className="px-6 py-5 space-y-4">
            <div>
              <p className="font-bold text-gray-900 text-lg">Selamat Datang Kembali</p>
              <p className="text-sm text-gray-500 mt-0.5">Masuk untuk mengelola proyek Anda</p>
            </div>

            {loginErrors.general && (
              <div className="bg-red-50 border border-red-200 rounded-lg px-4 py-3 text-sm text-red-700">
                {loginErrors.general}
              </div>
            )}

            {/* Email */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Email</label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  type="email"
                  value={loginEmail}
                  onChange={(e) => { setLoginEmail(e.target.value); setLoginErrors((p) => ({ ...p, email: undefined })); }}
                  placeholder="mahasiswa@email.com"
                  className={`w-full pl-10 pr-4 py-2.5 rounded-lg border text-sm bg-white outline-none transition-colors ${
                    loginErrors.email
                      ? 'border-red-400 focus:border-red-500 focus:ring-2 focus:ring-red-100'
                      : 'border-gray-200 focus:border-red-800 focus:ring-2 focus:ring-red-100'
                  }`}
                />
              </div>
              {loginErrors.email && <p className="text-xs text-red-600 mt-1">{loginErrors.email}</p>}
            </div>

            {/* Password */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Kata Sandi</label>
              <div className="relative">
                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  type={showLoginPass ? 'text' : 'password'}
                  value={loginPassword}
                  onChange={(e) => { setLoginPassword(e.target.value); setLoginErrors((p) => ({ ...p, password: undefined })); }}
                  placeholder="Masukkan kata sandi"
                  className={`w-full pl-10 pr-11 py-2.5 rounded-lg border text-sm bg-white outline-none transition-colors ${
                    loginErrors.password
                      ? 'border-red-400 focus:border-red-500 focus:ring-2 focus:ring-red-100'
                      : 'border-gray-200 focus:border-red-800 focus:ring-2 focus:ring-red-100'
                  }`}
                />
                <button
                  type="button"
                  onClick={() => setShowLoginPass((p) => !p)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                  tabIndex={-1}
                >
                  {showLoginPass ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
              {loginErrors.password && <p className="text-xs text-red-600 mt-1">{loginErrors.password}</p>}
            </div>

            <button
              type="submit"
              disabled={loginLoading}
              className="w-full bg-red-800 hover:bg-red-900 disabled:bg-red-300 text-white py-3 rounded-lg text-sm font-medium transition-colors flex items-center justify-center gap-2 mt-2"
            >
              {loginLoading ? (
                <>
                  <span className="w-4 h-4 border-2 border-white/40 border-t-white rounded-full animate-spin" />
                  Memproses...
                </>
              ) : (
                <>
                  <LogIn className="w-4 h-4" />
                  Masuk
                </>
              )}
            </button>

            <p className="text-center text-xs text-gray-500 pb-1">
              Belum punya akun?{' '}
              <button
                type="button"
                onClick={() => setTab('register')}
                className="text-red-800 font-medium hover:underline"
              >
                Daftar sekarang
              </button>
            </p>
          </form>
        )}

        {/* ===== REGISTER FORM ===== */}
        {tab === 'register' && (
          <form onSubmit={handleRegister} className="px-6 py-5 space-y-4">
            <div>
              <p className="font-bold text-gray-900 text-lg">Buat Akun Baru</p>
              <p className="text-sm text-gray-500 mt-0.5">Daftarkan diri untuk mulai mengelola proyek</p>
            </div>

            {regErrors.general && (
              <div className="bg-red-50 border border-red-200 rounded-lg px-4 py-3 text-sm text-red-700">
                {regErrors.general}
              </div>
            )}

            {/* Nama */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Nama Lengkap</label>
              <div className="relative">
                <User className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  type="text"
                  value={regName}
                  onChange={(e) => { setRegName(e.target.value); setRegErrors((p) => ({ ...p, name: '' })); }}
                  placeholder="Nama lengkap Anda"
                  className={`w-full pl-10 pr-4 py-2.5 rounded-lg border text-sm bg-white outline-none transition-colors ${
                    regErrors.name
                      ? 'border-red-400 focus:border-red-500 focus:ring-2 focus:ring-red-100'
                      : 'border-gray-200 focus:border-red-800 focus:ring-2 focus:ring-red-100'
                  }`}
                />
              </div>
              {regErrors.name && <p className="text-xs text-red-600 mt-1">{regErrors.name}</p>}
            </div>

            {/* NIM */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">NIM</label>
              <div className="relative">
                <Hash className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  type="text"
                  value={regNim}
                  onChange={(e) => { setRegNim(e.target.value); setRegErrors((p) => ({ ...p, nim: '' })); }}
                  placeholder="Nomor Induk Mahasiswa"
                  className={`w-full pl-10 pr-4 py-2.5 rounded-lg border text-sm bg-white outline-none transition-colors ${
                    regErrors.nim
                      ? 'border-red-400 focus:border-red-500 focus:ring-2 focus:ring-red-100'
                      : 'border-gray-200 focus:border-red-800 focus:ring-2 focus:ring-red-100'
                  }`}
                />
              </div>
              {regErrors.nim && <p className="text-xs text-red-600 mt-1">{regErrors.nim}</p>}
            </div>

            {/* Email */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Email</label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  type="email"
                  value={regEmail}
                  onChange={(e) => { setRegEmail(e.target.value); setRegErrors((p) => ({ ...p, email: '' })); }}
                  placeholder="mahasiswa@email.com"
                  className={`w-full pl-10 pr-4 py-2.5 rounded-lg border text-sm bg-white outline-none transition-colors ${
                    regErrors.email
                      ? 'border-red-400 focus:border-red-500 focus:ring-2 focus:ring-red-100'
                      : 'border-gray-200 focus:border-red-800 focus:ring-2 focus:ring-red-100'
                  }`}
                />
              </div>
              {regErrors.email && <p className="text-xs text-red-600 mt-1">{regErrors.email}</p>}
            </div>

            {/* Password */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Kata Sandi</label>
              <div className="relative">
                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  type={showRegPass ? 'text' : 'password'}
                  value={regPassword}
                  onChange={(e) => { setRegPassword(e.target.value); setRegErrors((p) => ({ ...p, password: '' })); }}
                  placeholder="Minimal 6 karakter"
                  className={`w-full pl-10 pr-11 py-2.5 rounded-lg border text-sm bg-white outline-none transition-colors ${
                    regErrors.password
                      ? 'border-red-400 focus:border-red-500 focus:ring-2 focus:ring-red-100'
                      : 'border-gray-200 focus:border-red-800 focus:ring-2 focus:ring-red-100'
                  }`}
                />
                <button
                  type="button"
                  onClick={() => setShowRegPass((p) => !p)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                  tabIndex={-1}
                >
                  {showRegPass ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
              {regErrors.password && <p className="text-xs text-red-600 mt-1">{regErrors.password}</p>}
            </div>

            {/* Confirm Password */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1.5">Konfirmasi Kata Sandi</label>
              <div className="relative">
                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <input
                  type={showRegConfirm ? 'text' : 'password'}
                  value={regConfirm}
                  onChange={(e) => { setRegConfirm(e.target.value); setRegErrors((p) => ({ ...p, confirm: '' })); }}
                  placeholder="Ulangi kata sandi"
                  className={`w-full pl-10 pr-11 py-2.5 rounded-lg border text-sm bg-white outline-none transition-colors ${
                    regErrors.confirm
                      ? 'border-red-400 focus:border-red-500 focus:ring-2 focus:ring-red-100'
                      : 'border-gray-200 focus:border-red-800 focus:ring-2 focus:ring-red-100'
                  }`}
                />
                <button
                  type="button"
                  onClick={() => setShowRegConfirm((p) => !p)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                  tabIndex={-1}
                >
                  {showRegConfirm ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
              {regErrors.confirm && <p className="text-xs text-red-600 mt-1">{regErrors.confirm}</p>}
            </div>

            <button
              type="submit"
              disabled={regLoading}
              className="w-full bg-red-800 hover:bg-red-900 disabled:bg-red-300 text-white py-3 rounded-lg text-sm font-medium transition-colors flex items-center justify-center gap-2 mt-2"
            >
              {regLoading ? (
                <>
                  <span className="w-4 h-4 border-2 border-white/40 border-t-white rounded-full animate-spin" />
                  Memproses...
                </>
              ) : (
                <>
                  <UserPlus className="w-4 h-4" />
                  Buat Akun
                </>
              )}
            </button>

            <p className="text-center text-xs text-gray-500 pb-1">
              Sudah punya akun?{' '}
              <button
                type="button"
                onClick={() => setTab('login')}
                className="text-red-800 font-medium hover:underline"
              >
                Masuk di sini
              </button>
            </p>
          </form>
        )}
      </div>

      <style>{`
        @keyframes slide-up {
          from { transform: translateY(100%); }
          to { transform: translateY(0); }
        }
        .animate-slide-up {
          animation: slide-up 0.3s ease-out;
        }
      `}</style>
    </div>
  );
}