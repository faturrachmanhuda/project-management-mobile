import { createContext, useContext, useState, useEffect, ReactNode } from 'react';

export interface Activity {
  id: string;
  name: string;
  executionTime: string;
  executor: string;
  done: boolean;
  evaluation?: string;
  additionalPlan?: string;
  photos?: string[]; // Base64 encoded photos
}

export interface Work {
  id: string;
  projectId: string;
  name: string;
  description: string;
  location: string;
  startDate: string;
  endDate: string;
  executor: string;
  supervisor: string;
  category: 'engineering' | 'creation' | 'implementation';
  activities: Activity[];
}

export interface Project {
  id: string;
  name: string;
  description: string;
  location: string;
  startDate: string;
  endDate: string;
  executor: string;
  supervisor: string;
  status: 'Aktif' | 'Selesai' | 'Tertunda';
  isClosed: boolean;
}

interface ProjectContextType {
  projects: Project[];
  works: Work[];
  addProject: (project: Omit<Project, 'id' | 'status' | 'isClosed'>) => string;
  deleteProject: (projectId: string) => void;
  closeProject: (projectId: string) => void;
  renameProject: (projectId: string, name: string) => void;
  addWork: (work: Omit<Work, 'id' | 'activities'>) => string;
  deleteWork: (workId: string) => void;
  renameWork: (workId: string, name: string) => void;
  addActivity: (workId: string, activity: Omit<Activity, 'id'>) => void;
  updateActivity: (workId: string, activityId: string, updates: Partial<Activity>) => void;
  deleteActivity: (workId: string, activityId: string) => void;
  getProjectById: (projectId: string) => Project | undefined;
  getWorksByProjectId: (projectId: string) => Work[];
}

const ProjectContext = createContext<ProjectContextType | undefined>(undefined);

export function ProjectProvider({ children }: { children: ReactNode }) {
  const [projects, setProjects] = useState<Project[]>(() => {
    const stored = localStorage.getItem('projects');
    return stored ? JSON.parse(stored) : [
      {
        id: '1',
        name: 'Sistem Informasi Perpustakaan',
        description: 'Pengembangan sistem manajemen perpustakaan digital untuk kampus',
        location: 'Kampus Utama',
        startDate: '2026-01-15',
        endDate: '2026-06-30',
        executor: 'Tim A',
        supervisor: 'Dr. Ahmad Dahlan',
        status: 'Aktif',
        isClosed: false
      },
      {
        id: '2',
        name: 'Aplikasi Smart Parking',
        description: 'Aplikasi mobile untuk manajemen parkir kampus berbasis IoT',
        location: 'Area Parkir Kampus',
        startDate: '2026-02-01',
        endDate: '2026-07-15',
        executor: 'Tim B',
        supervisor: 'Prof. Siti Nurhaliza',
        status: 'Aktif',
        isClosed: false
      }
    ];
  });

  const [works, setWorks] = useState<Work[]>(() => {
    const stored = localStorage.getItem('works');
    return stored ? JSON.parse(stored) : [];
  });

  useEffect(() => {
    localStorage.setItem('projects', JSON.stringify(projects));
  }, [projects]);

  useEffect(() => {
    localStorage.setItem('works', JSON.stringify(works));
  }, [works]);

  const addProject = (projectData: Omit<Project, 'id' | 'status' | 'isClosed'>) => {
    const newProject: Project = {
      id: Date.now().toString(),
      ...projectData,
      status: 'Aktif',
      isClosed: false
    };
    setProjects([...projects, newProject]);
    return newProject.id;
  };

  const deleteProject = (projectId: string) => {
    setProjects(projects.filter(p => p.id !== projectId));
    setWorks(works.filter(w => w.projectId !== projectId));
  };

  const closeProject = (projectId: string) => {
    setProjects(projects.map(p => 
      p.id === projectId ? { ...p, isClosed: true } : p
    ));
  };

  const renameProject = (projectId: string, name: string) => {
    setProjects(projects.map(p => 
      p.id === projectId ? { ...p, name } : p
    ));
  };

  const addWork = (workData: Omit<Work, 'id' | 'activities'>) => {
    const newWork: Work = {
      id: Date.now().toString(),
      ...workData,
      activities: []
    };
    setWorks([...works, newWork]);
    return newWork.id;
  };

  const deleteWork = (workId: string) => {
    setWorks(works.filter(w => w.id !== workId));
  };

  const renameWork = (workId: string, name: string) => {
    setWorks(works.map(w => 
      w.id === workId ? { ...w, name } : w
    ));
  };

  const addActivity = (workId: string, activityData: Omit<Activity, 'id'>) => {
    const newActivity: Activity = {
      id: Date.now().toString(),
      ...activityData,
      done: activityData.done ?? false
    };
    setWorks(works.map(w => 
      w.id === workId 
        ? { ...w, activities: [...w.activities, newActivity] }
        : w
    ));
  };

  const updateActivity = (workId: string, activityId: string, updates: Partial<Activity>) => {
    setWorks(works.map(w => 
      w.id === workId
        ? { 
            ...w, 
            activities: w.activities.map(a => 
              a.id === activityId ? { ...a, ...updates } : a
            ) 
          }
        : w
    ));
  };

  const deleteActivity = (workId: string, activityId: string) => {
    setWorks(works.map(w => 
      w.id === workId
        ? { ...w, activities: w.activities.filter(a => a.id !== activityId) }
        : w
    ));
  };

  const getProjectById = (projectId: string) => {
    return projects.find(p => p.id === projectId);
  };

  const getWorksByProjectId = (projectId: string) => {
    return works.filter(w => w.projectId === projectId);
  };

  return (
    <ProjectContext.Provider
      value={{
        projects,
        works,
        addProject,
        deleteProject,
        closeProject,
        renameProject,
        addWork,
        deleteWork,
        renameWork,
        addActivity,
        updateActivity,
        deleteActivity,
        getProjectById,
        getWorksByProjectId
      }}
    >
      {children}
    </ProjectContext.Provider>
  );
}

export function useProjects() {
  const context = useContext(ProjectContext);
  if (context === undefined) {
    throw new Error('useProjects must be used within a ProjectProvider');
  }
  return context;
}