import { useState } from 'react';
import { FolderKanban, Menu, X, LogOut, User, Camera } from 'lucide-react';
import { Link, useLocation, useNavigate } from 'react-router';
import { useAuth } from '../context/AuthContext';
import { toast } from 'sonner';
import { LoginModal } from './LoginModal';
import { ProfilePhotoModal } from './ProfilePhotoModal';

interface HeaderProps {
  onLoginClick?: () => void;
}

export function Header({ onLoginClick }: HeaderProps) {
  const [menuOpen, setMenuOpen] = useState(false);
  const [userDropOpen, setUserDropOpen] = useState(false);
  const [showLoginModal, setShowLoginModal] = useState(false);
  const [showPhotoModal, setShowPhotoModal] = useState(false);
  const location = useLocation();
  const navigate = useNavigate();
  const { user, isAuthenticated, logout, updateProfilePhoto } = useAuth();

  const navLinks = [
    { to: '/', label: 'Beranda' },
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
    <header className="bg-white border-b border-gray-100 sticky top-0 z-40 shadow-sm">
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
                  className="group relative w-10 h-10 rounded-full overflow-hidden ring-2 ring-transparent hover:ring-gray-200 transition-all hover:shadow-md active:ring-red-800"
                >
                  {user.photoUrl ? (
                    <img
                      src={user.photoUrl}
                      alt={user.name}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <div className="w-full h-full bg-gradient-to-br from-red-800 to-red-900 flex items-center justify-center">
                      <span className="text-white text-sm font-bold">
                        {user.name.charAt(0).toUpperCase()}
                      </span>
                    </div>
                  )}
                </button>

                {userDropOpen && (
                  <>
                    <div className="fixed inset-0 z-10" onClick={() => setUserDropOpen(false)} />
                    <div className="absolute right-0 mt-2 w-80 bg-white rounded-xl shadow-2xl border border-gray-100 z-20 animate-in fade-in slide-in-from-top-2 duration-200">
                      {/* User Info Header */}
                      <div className="px-5 py-4">
                        <div className="flex items-start gap-4">
                          <button
                            onClick={() => {
                              setShowPhotoModal(true);
                              setUserDropOpen(false);
                            }}
                            className="relative group/avatar shrink-0"
                          >
                            <div className="w-16 h-16 rounded-full overflow-hidden ring-4 ring-gray-50 group-hover/avatar:ring-gray-200 transition-all">
                              {user.photoUrl ? (
                                <img
                                  src={user.photoUrl}
                                  alt={user.name}
                                  className="w-full h-full object-cover"
                                />
                              ) : (
                                <div className="w-full h-full bg-gradient-to-br from-red-800 to-red-900 flex items-center justify-center">
                                  <span className="text-white text-xl font-bold">
                                    {user.name.charAt(0).toUpperCase()}
                                  </span>
                                </div>
                              )}
                            </div>
                            <div className="absolute -bottom-0.5 -right-0.5 w-6 h-6 bg-white rounded-full flex items-center justify-center shadow-md group-hover/avatar:bg-red-50 transition-colors">
                              <Camera className="w-3.5 h-3.5 text-gray-600 group-hover/avatar:text-red-800" />
                            </div>
                          </button>
                          <div className="flex-1 min-w-0 pt-1">
                            <p className="text-base font-semibold text-gray-900 truncate">{user.name}</p>
                            <p className="text-sm text-gray-600 truncate mt-0.5">{user.email}</p>
                            <p className="text-xs text-gray-500 mt-1">NIM {user.nim}</p>
                          </div>
                        </div>
                      </div>

                      {/* Divider */}
                      <div className="h-px bg-gray-100" />

                      {/* Menu Items */}
                      <div className="py-1.5">
                        <button
                          onClick={handleLogout}
                          className="w-full flex items-center gap-3 px-5 py-3 text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors"
                        >
                          <LogOut className="w-4.5 h-4.5" />
                          Keluar
                        </button>
                      </div>
                    </div>
                  </>
                )}
              </div>
            ) : (
              <button
                onClick={openLogin}
                className="flex items-center gap-2 bg-red-800 hover:bg-red-900 text-white px-4 py-2 rounded-lg text-sm font-medium transition-all hover:shadow-md active:scale-[0.98]"
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
                  <button
                    onClick={() => {
                      setShowPhotoModal(true);
                      setMenuOpen(false);
                    }}
                    className="w-full flex items-center gap-3 px-4 py-3 hover:bg-gray-50 rounded-lg transition-colors"
                  >
                    <div className="relative">
                      <div className="w-12 h-12 rounded-full overflow-hidden ring-2 ring-gray-100">
                        {user.photoUrl ? (
                          <img
                            src={user.photoUrl}
                            alt={user.name}
                            className="w-full h-full object-cover"
                          />
                        ) : (
                          <div className="w-full h-full bg-gradient-to-br from-red-800 to-red-900 flex items-center justify-center">
                            <span className="text-white text-sm font-bold">
                              {user.name.charAt(0).toUpperCase()}
                            </span>
                          </div>
                        )}
                      </div>
                      <div className="absolute -bottom-0.5 -right-0.5 w-5 h-5 bg-white rounded-full flex items-center justify-center shadow-sm">
                        <Camera className="w-3 h-3 text-gray-600" />
                      </div>
                    </div>
                    <div className="flex-1 text-left">
                      <p className="text-sm font-medium text-gray-900">{user.name}</p>
                      <p className="text-xs text-gray-500 mt-0.5">{user.email}</p>
                      <p className="text-xs text-gray-500">NIM {user.nim}</p>
                    </div>
                  </button>
                  <button
                    onClick={handleLogout}
                    className="w-full flex items-center gap-2 px-4 py-3 text-sm font-medium text-red-700 hover:bg-red-50 rounded-lg transition-colors mt-1"
                  >
                    <LogOut className="w-4 h-4" />
                    Keluar dari Akun
                  </button>
                </>
              ) : (
                <button
                  onClick={openLogin}
                  className="w-full flex items-center justify-center gap-2 bg-red-800 text-white px-4 py-3 rounded-lg text-sm font-medium transition-all hover:shadow-md active:scale-[0.98]"
                >
                  <User className="w-4 h-4" />
                  Masuk / Daftar
                </button>
              )}
            </div>
          </div>
        )}
      </div>

      {/* Modals */}
      {showLoginModal && <LoginModal onClose={() => setShowLoginModal(false)} />}
      {showPhotoModal && user && (
        <ProfilePhotoModal
          currentPhotoUrl={user.photoUrl}
          userName={user.name}
          onClose={() => setShowPhotoModal(false)}
          onSave={(photoUrl) => {
            updateProfilePhoto(photoUrl);
            setShowPhotoModal(false);
          }}
        />
      )}
    </header>
  );
}