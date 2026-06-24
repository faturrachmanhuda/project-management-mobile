/**
 * API Service untuk integrasi dengan Django Backend
 *
 * Uncomment dan gunakan fungsi-fungsi di bawah untuk mengganti localStorage
 * dengan API calls ke backend Django.
 */

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api';

// Helper untuk get auth token dari localStorage
const getAuthToken = (): string | null => {
  return localStorage.getItem('auth_token');
};

// Helper untuk set auth headers
const getAuthHeaders = (): HeadersInit => {
  const token = getAuthToken();
  return {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
  };
};

// ==================== AUTH API ====================

export const authAPI = {
  async register(name: string, nim: string, email: string, password: string) {
    const response = await fetch(`${API_URL}/auth/register/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name, nim, email, password }),
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || 'Pendaftaran gagal');
    }

    // Simpan token dan user data
    localStorage.setItem('auth_token', data.token);
    localStorage.setItem('user_data', JSON.stringify(data.user));

    return data;
  },

  async login(email: string, password: string) {
    const response = await fetch(`${API_URL}/auth/login/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || 'Login gagal');
    }

    // Simpan token dan user data
    localStorage.setItem('auth_token', data.token);
    localStorage.setItem('user_data', JSON.stringify(data.user));

    return data;
  },

  logout() {
    localStorage.removeItem('auth_token');
    localStorage.removeItem('user_data');
  },

  getCurrentUser() {
    const userData = localStorage.getItem('user_data');
    return userData ? JSON.parse(userData) : null;
  },

  isAuthenticated(): boolean {
    return !!getAuthToken();
  },
};

// ==================== PROJECTS API ====================

export const projectsAPI = {
  async getAll() {
    const response = await fetch(`${API_URL}/projects/`, {
      headers: getAuthHeaders(),
    });

    if (!response.ok) {
      throw new Error('Gagal mengambil data projects');
    }

    return response.json();
  },

  async getById(id: string) {
    const response = await fetch(`${API_URL}/projects/${id}/`, {
      headers: getAuthHeaders(),
    });

    if (!response.ok) {
      throw new Error('Project tidak ditemukan');
    }

    return response.json();
  },

  async create(projectData: {
    name: string;
    description: string;
    location: string;
    start_date: string;
    end_date: string;
    executor: string;
    supervisor: string;
  }) {
    const response = await fetch(`${API_URL}/projects/`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify({
        ...projectData,
        start_date: projectData.start_date,
        end_date: projectData.end_date,
      }),
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || 'Gagal membuat project');
    }

    return response.json();
  },

  async update(id: string, projectData: Partial<{
    name: string;
    description: string;
    location: string;
    start_date: string;
    end_date: string;
    executor: string;
    supervisor: string;
  }>) {
    const response = await fetch(`${API_URL}/projects/${id}/`, {
      method: 'PATCH',
      headers: getAuthHeaders(),
      body: JSON.stringify(projectData),
    });

    if (!response.ok) {
      throw new Error('Gagal mengupdate project');
    }

    return response.json();
  },

  async rename(id: string, name: string) {
    const response = await fetch(`${API_URL}/projects/${id}/rename/`, {
      method: 'PATCH',
      headers: getAuthHeaders(),
      body: JSON.stringify({ name }),
    });

    if (!response.ok) {
      throw new Error('Gagal rename project');
    }

    return response.json();
  },

  async close(id: string) {
    const response = await fetch(`${API_URL}/projects/${id}/close/`, {
      method: 'PATCH',
      headers: getAuthHeaders(),
    });

    if (!response.ok) {
      throw new Error('Gagal menutup project');
    }

    return response.json();
  },

  async delete(id: string) {
    const response = await fetch(`${API_URL}/projects/${id}/`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
    });

    if (!response.ok) {
      throw new Error('Gagal menghapus project');
    }

    return true;
  },
};

// ==================== WORKS API ====================

export const worksAPI = {
  async getByProjectId(projectId: string) {
    const response = await fetch(`${API_URL}/works/by_project/?project_id=${projectId}`, {
      headers: getAuthHeaders(),
    });

    if (!response.ok) {
      throw new Error('Gagal mengambil data works');
    }

    return response.json();
  },

  async getById(id: string) {
    const response = await fetch(`${API_URL}/works/${id}/`, {
      headers: getAuthHeaders(),
    });

    if (!response.ok) {
      throw new Error('Work tidak ditemukan');
    }

    return response.json();
  },

  async create(workData: {
    project_id: string;
    name: string;
    description: string;
    location: string;
    start_date: string;
    end_date: string;
    executor: string;
    supervisor: string;
    category: 'engineering' | 'creation' | 'implementation';
  }) {
    const response = await fetch(`${API_URL}/works/`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(workData),
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || 'Gagal membuat work');
    }

    return response.json();
  },

  async update(id: string, workData: Partial<{
    name: string;
    description: string;
    location: string;
    start_date: string;
    end_date: string;
    executor: string;
    supervisor: string;
    category: 'engineering' | 'creation' | 'implementation';
  }>) {
    const response = await fetch(`${API_URL}/works/${id}/`, {
      method: 'PATCH',
      headers: getAuthHeaders(),
      body: JSON.stringify(workData),
    });

    if (!response.ok) {
      throw new Error('Gagal mengupdate work');
    }

    return response.json();
  },

  async rename(id: string, name: string) {
    const response = await fetch(`${API_URL}/works/${id}/rename/`, {
      method: 'PATCH',
      headers: getAuthHeaders(),
      body: JSON.stringify({ name }),
    });

    if (!response.ok) {
      throw new Error('Gagal rename work');
    }

    return response.json();
  },

  async delete(id: string) {
    const response = await fetch(`${API_URL}/works/${id}/`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
    });

    if (!response.ok) {
      throw new Error('Gagal menghapus work');
    }

    return true;
  },
};

// ==================== ACTIVITIES API ====================

export const activitiesAPI = {
  async getByWorkId(workId: string) {
    const response = await fetch(`${API_URL}/activities/by_work/?work_id=${workId}`, {
      headers: getAuthHeaders(),
    });

    if (!response.ok) {
      throw new Error('Gagal mengambil data activities');
    }

    return response.json();
  },

  async getById(id: string) {
    const response = await fetch(`${API_URL}/activities/${id}/`, {
      headers: getAuthHeaders(),
    });

    if (!response.ok) {
      throw new Error('Activity tidak ditemukan');
    }

    return response.json();
  },

  async create(activityData: {
    work_id: string;
    name: string;
    execution_time: string;
    executor: string;
    done?: boolean;
    evaluation?: string;
    additional_plan?: string;
    photos?: string[]; // Base64 encoded images
  }) {
    const response = await fetch(`${API_URL}/activities/`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify({
        ...activityData,
        done: activityData.done ?? false,
      }),
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || 'Gagal membuat activity');
    }

    return response.json();
  },

  async update(id: string, activityData: Partial<{
    name: string;
    execution_time: string;
    executor: string;
    done: boolean;
    evaluation: string;
    additional_plan: string;
    photos: string[];
  }>) {
    const response = await fetch(`${API_URL}/activities/${id}/`, {
      method: 'PATCH',
      headers: getAuthHeaders(),
      body: JSON.stringify(activityData),
    });

    if (!response.ok) {
      throw new Error('Gagal mengupdate activity');
    }

    return response.json();
  },

  async toggleDone(id: string) {
    const response = await fetch(`${API_URL}/activities/${id}/toggle_done/`, {
      method: 'PATCH',
      headers: getAuthHeaders(),
    });

    if (!response.ok) {
      throw new Error('Gagal toggle status activity');
    }

    return response.json();
  },

  async delete(id: string) {
    const response = await fetch(`${API_URL}/activities/${id}/`, {
      method: 'DELETE',
      headers: getAuthHeaders(),
    });

    if (!response.ok) {
      throw new Error('Gagal menghapus activity');
    }

    return true;
  },
};

// ==================== ANALYTICS API ====================

export const analyticsAPI = {
  async getDashboardStats() {
    const response = await fetch(`${API_URL}/projects/dashboard_stats/`, {
      headers: getAuthHeaders(),
    });

    if (!response.ok) {
      throw new Error('Gagal mengambil statistik dashboard');
    }

    return response.json();
  },
};

// ==================== EXPORT API ====================

export const exportAPI = {
  async downloadExcel(projectId: string, projectName: string) {
    const response = await fetch(`${API_URL}/projects/${projectId}/export/excel/`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Gagal download Excel');
    const blob = await response.blob();
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `Report_${projectName.replace(/\s+/g, '_')}.xlsx`;
    document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
  },
  async downloadPdf(projectId: string, projectName: string) {
    const response = await fetch(`${API_URL}/projects/${projectId}/export/pdf/`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Gagal download PDF');
    const blob = await response.blob();
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `Report_${projectName.replace(/\s+/g, '_')}.pdf`;
    document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
  },
  async downloadAllExcel() {
    const response = await fetch(`${API_URL}/projects/export/excel/`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Gagal download Excel Global');
    const blob = await response.blob();
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `Global_Report_Promanage.xlsx`;
    document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
  },
  async downloadAllPdf() {
    const response = await fetch(`${API_URL}/projects/export/pdf/`, {
      headers: getAuthHeaders(),
    });
    if (!response.ok) throw new Error('Gagal download PDF Global');
    const blob = await response.blob();
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `Global_Report_Promanage.pdf`;
    document.body.appendChild(a);
    a.click();
    window.URL.revokeObjectURL(url);
  }
};

// ==================== HEALTH CHECK ====================

export const healthCheck = async () => {
  try {
    const response = await fetch(`${API_URL}/health/`, {
      headers: getAuthHeaders(),
    });
    return response.ok;
  } catch {
    return false;
  }
};

// Export all APIs
export default {
  auth: authAPI,
  projects: projectsAPI,
  works: worksAPI,
  activities: activitiesAPI,
  analytics: analyticsAPI,
  export: exportAPI,
  healthCheck,
};
