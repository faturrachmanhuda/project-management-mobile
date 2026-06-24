import { createContext, useContext, useState, useEffect, ReactNode } from 'react';

export interface User {
  id: string;
  name: string;
  email: string;
  nim: string; // Nomor Induk Mahasiswa
}

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<{ success: boolean; error?: string }>;
  register: (name: string, nim: string, email: string, password: string) => Promise<{ success: boolean; error?: string }>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | null>(null);

const USERS_KEY = 'promanage_users';
const SESSION_KEY = 'promanage_session';

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    const session = localStorage.getItem(SESSION_KEY);
    if (session) {
      try {
        setUser(JSON.parse(session));
      } catch {
        localStorage.removeItem(SESSION_KEY);
      }
    }
  }, []);

  const getUsers = (): Array<User & { password: string }> => {
    const raw = localStorage.getItem(USERS_KEY);
    if (!raw) return [];
    try { return JSON.parse(raw); } catch { return []; }
  };

  const login = async (email: string, password: string): Promise<{ success: boolean; error?: string }> => {
    const users = getUsers();
    const found = users.find(
      (u) => u.email.toLowerCase() === email.toLowerCase() && u.password === password
    );
    if (!found) {
      return { success: false, error: 'Email atau kata sandi tidak sesuai.' };
    }
    const { password: _p, ...userData } = found;
    setUser(userData);
    localStorage.setItem(SESSION_KEY, JSON.stringify(userData));
    return { success: true };
  };

  const register = async (
    name: string,
    nim: string,
    email: string,
    password: string
  ): Promise<{ success: boolean; error?: string }> => {
    const users = getUsers();
    if (users.find((u) => u.email.toLowerCase() === email.toLowerCase())) {
      return { success: false, error: 'Email sudah terdaftar.' };
    }
    if (users.find((u) => u.nim === nim)) {
      return { success: false, error: 'NIM sudah terdaftar.' };
    }
    const newUser: User & { password: string } = {
      id: crypto.randomUUID(),
      name: name.trim(),
      nim: nim.trim(),
      email: email.trim().toLowerCase(),
      password,
    };
    localStorage.setItem(USERS_KEY, JSON.stringify([...users, newUser]));
    const { password: _p, ...userData } = newUser;
    setUser(userData);
    localStorage.setItem(SESSION_KEY, JSON.stringify(userData));
    return { success: true };
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem(SESSION_KEY);
  };

  return (
    <AuthContext.Provider value={{ user, isAuthenticated: !!user, login, register, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within an AuthProvider');
  return ctx;
}
