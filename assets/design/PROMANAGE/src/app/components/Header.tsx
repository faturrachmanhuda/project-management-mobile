import { useState } from 'react';
import { FolderKanban, Menu, X, LogOut, User, ChevronDown } from 'lucide-react';
import { Link, useLocation, useNavigate } from 'react-router';
import { useAuth } from '../context/AuthContext';
import { toast } from 'sonner';
import { LoginModal } from './LoginModal';

interface HeaderProps {
  onLoginClick?: () => void;
}

export function Header({ onLoginClick }: HeaderProps) {
  const [menuOpen, setMenuOpen] = useState(false);
  const [userDropOpen, setUserDropOpen] = useState(false);
  const [showLoginModal, setShowLoginModal] = useState(false);
  const location = useLocation();
  const navigate = useNavigate();
  const { user, isAuthenticated, logout } = useAuth();

  const navLinks = [
    { to: '/', label: 'Beranda' },
    { to: '/dashboard', label: 'Dashboard', requireAuth: true },
    { to: '/projects', label: 'Proyek', requireAuth: true },
    { to: '/about', label: 'Tentang Kami' },
  ];

  const isActive = (path: string) => location.pathname === path;

  const openLogin = () => {
    if (onLoginClick) onLoginClick();
    else setShowLoginModal(true);
  };

  const handleNavClick = (link: { to: string; requireAuth?: boolean }) => {
    setMenuOpen(false);
    if (link.requireAuth && !isAuthenticated) {
      openLogin();
      return;
    }
    navigate(link.to);
  };

  const handleLogout = () => {
    logout();
    setUserDropOpen(false);
    setMenuOpen(false);
    toast.success('Berhasil keluar. Sampai jumpa! 👋');
    navigate('/');
  };

  return (
    <header className="bg-white border-b border-gray-100 sticky top-0 z-40">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-20">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <Link to="/" className="flex items-center gap-2.5 shrink-0">
            <div className="w-9 h-9 bg-red-800 rounded-lg flex items-center justify-center">
              <FolderKanban className="w-5 h-5 text-white" />
            </div>
            <span className="text-xl font-bold text-gray-900">ProManage</span>
          </Link>

          {/* Desktop Nav */}
          <nav className="hidden md:flex items-center gap-1">
            {navLinks.map((link) => (
              <button
                key={link.to}
                onClick={() => handleNavClick(link)}
                className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                  isActive(link.to)
                    ? 'bg-red-50 text-red-800'
                    : 'text-gray-600 hover:text-red-800 hover:bg-gray-50'
                }`}
              >
                {link.label}
              </button>
            ))}
          </nav>

          {/* Desktop Auth */}
          <div className="hidden md:flex items-center gap-3">
            {isAuthenticated && user ? (
              <div className="relative">
                <button
                  onClick={() => setUserDropOpen((p) => !p)}
                  className="flex items-center gap-2.5 px-3 py-2 rounded-lg hover:bg-gray-50 transition-colors"
                >
                  <div className="w-8 h-8 bg-red-800 rounded-full flex items-center justify-center shrink-0">
                    <span className="text-white text-xs font-bold">
                      {user.name.charAt(0).toUpperCase()}
                    </span>
                  </div>
                  <div className="text-left">
                    <p className="text-sm font-medium text-gray-900 leading-tight">{user.name}</p>
                    <p className="text-xs text-gray-500 leading-tight">NIM {user.nim}</p>
                  </div>
                  <ChevronDown className={`w-4 h-4 text-gray-400 transition-transform ${userDropOpen ? 'rotate-180' : ''}`} />
                </button>

                {userDropOpen && (
                  <>
                    <div className="fixed inset-0 z-10" onClick={() => setUserDropOpen(false)} />
                    <div className="absolute right-0 mt-1 w-52 bg-white rounded-xl shadow-lg border border-gray-100 py-1 z-20">
                      <div className="px-4 py-3 border-b border-gray-100">
                        <p className="text-sm font-medium text-gray-900">{user.name}</p>
                        <p className="text-xs text-gray-500">{user.email}</p>
                      </div>
                      <button
                        onClick={handleLogout}
                        className="w-full flex items-center gap-2 px-4 py-2.5 text-sm text-red-700 hover:bg-red-50 transition-colors"
                      >
                        <LogOut className="w-4 h-4" />
                        Keluar
                      </button>
                    </div>
                  </>
                )}
              </div>
            ) : (
              <button
                onClick={openLogin}
                className="flex items-center gap-2 bg-red-800 hover:bg-red-900 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors"
              >
                <User className="w-4 h-4" />
                Masuk
              </button>
            )}
          </div>

          {/* Mobile Hamburger */}
          <button
            className="md:hidden p-2 rounded-lg text-gray-600 hover:bg-gray-100 transition-colors"
            onClick={() => setMenuOpen(!menuOpen)}
            aria-label="Toggle menu"
          >
            {menuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
          </button>
        </div>

        {/* Mobile Dropdown */}
        {menuOpen && (
          <div className="md:hidden pb-4 border-t border-gray-100 pt-2">
            {navLinks.map((link) => (
              <button
                key={link.to}
                onClick={() => handleNavClick(link)}
                className={`w-full text-left block px-4 py-3 rounded-lg font-medium transition-colors mb-1 ${
                  isActive(link.to)
                    ? 'bg-red-50 text-red-800'
                    : 'text-gray-600 hover:text-red-800 hover:bg-gray-50'
                }`}
              >
                {link.label}
              </button>
            ))}

            {/* Mobile Auth */}
            <div className="mt-2 pt-2 border-t border-gray-100">
              {isAuthenticated && user ? (
                <>
                  <div className="flex items-center gap-3 px-4 py-3">
                    <div className="w-9 h-9 bg-red-800 rounded-full flex items-center justify-center shrink-0">
                      <span className="text-white text-sm font-bold">
                        {user.name.charAt(0).toUpperCase()}
                      </span>
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-900">{user.name}</p>
                      <p className="text-xs text-gray-500">NIM {user.nim}</p>
                    </div>
                  </div>
                  <button
                    onClick={handleLogout}
                    className="w-full flex items-center gap-2 px-4 py-3 text-sm text-red-700 hover:bg-red-50 rounded-lg transition-colors"
                  >
                    <LogOut className="w-4 h-4" />
                    Keluar dari Akun
                  </button>
                </>
              ) : (
                <button
                  onClick={openLogin}
                  className="w-full flex items-center justify-center gap-2 bg-red-800 text-white px-4 py-3 rounded-lg text-sm font-medium transition-colors"
                >
                  <User className="w-4 h-4" />
                  Masuk / Daftar
                </button>
              )}
            </div>
          </div>
        )}
      </div>
      {showLoginModal && <LoginModal onClose={() => setShowLoginModal(false)} />}
    </header>
  );
}