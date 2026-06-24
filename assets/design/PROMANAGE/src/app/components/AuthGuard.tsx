import { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { useNavigate } from 'react-router';
import { LoginModal } from './LoginModal';
import { FolderKanban } from 'lucide-react';

interface AuthGuardProps {
  children: React.ReactNode;
}

export function AuthGuard({ children }: AuthGuardProps) {
  const { isAuthenticated } = useAuth();
  const navigate = useNavigate();
  const [showLogin, setShowLogin] = useState(false);

  useEffect(() => {
    if (!isAuthenticated) {
      setShowLogin(true);
    }
  }, [isAuthenticated]);

  if (!isAuthenticated) {
    return (
      <div className="min-h-screen bg-gray-50 flex flex-col items-center justify-center p-4">
        <div className="text-center mb-6">
          <div className="w-14 h-14 bg-red-800 rounded-2xl flex items-center justify-center mx-auto mb-4">
            <FolderKanban className="w-8 h-8 text-white" />
          </div>
          <h2 className="text-xl font-bold text-gray-900 mb-2">Masuk untuk Melanjutkan</h2>
          <p className="text-gray-500 text-sm">Silakan masuk atau daftar untuk mengakses halaman ini.</p>
        </div>
        <button
          onClick={() => setShowLogin(true)}
          className="bg-red-800 hover:bg-red-900 text-white px-6 py-3 rounded-lg font-medium transition-colors"
        >
          Masuk / Daftar
        </button>
        <LoginModal
          open={showLogin}
          onClose={() => {
            setShowLogin(false);
            if (!isAuthenticated) navigate('/');
          }}
        />
      </div>
    );
  }

  return <>{children}</>;
}
