import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import api from '../services/api';

export interface Activity {
  id: string;
  name: string;
  executionTime: string;
  executor: string;
  done: boolean;
  evaluation?: string;
  additionalPlan?: string;
  fileUrls?: { id: string; url: string; name: string; size: number }[];
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
  progress?: number;
  totalActivities?: number;
  doneActivities?: number;
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
  progress?: number;
  totalActivities?: number;
  doneActivities?: number;
}

interface ProjectContextType {
  projects: Project[];
  loading: boolean;
  refreshProjects: () => Promise<void>;
  addProject: (project: Omit<Project, 'id' | 'status' | 'isClosed'>) => Promise<string>;
  deleteProject: (projectId: string) => Promise<void>;
  closeProject: (projectId: string) => Promise<void>;
  renameProject: (projectId: string, name: string) => Promise<void>;
  addWork: (work: Omit<Work, 'id' | 'activities'>) => Promise<string>;
  deleteWork: (workId: string) => Promise<void>;
  renameWork: (workId: string, name: string) => Promise<void>;
  addActivity: (workId: string, activity: Omit<Activity, 'id'>) => Promise<void>;
  updateActivity: (workId: string, activityId: string, updates: Partial<Activity>) => Promise<void>;
  deleteActivity: (workId: string, activityId: string) => Promise<void>;
  getProjectById: (projectId: string) => Promise<Project | undefined>;
  getWorksByProjectId: (projectId: string) => Promise<Work[]>;
}

const ProjectContext = createContext<ProjectContextType | undefined>(undefined);

export function ProjectProvider({ children }: { children: ReactNode }) {
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);

  const mapProject = (p: any): Project => ({
    id: p.id,
    name: p.name,
    description: p.description,
    location: p.location,
    startDate: p.start_date,
    endDate: p.end_date,
    executor: p.executor,
    supervisor: p.supervisor,
    status: p.status,
    isClosed: p.is_closed,
    progress: p.progress,
    totalActivities: p.total_activities,
    doneActivities: p.done_activities
  });

  const mapWork = (w: any): Work => ({
    id: w.id,
    projectId: w.project_id,
    name: w.name,
    description: w.description,
    location: w.location,
    startDate: w.start_date,
    endDate: w.end_date,
    executor: w.executor,
    supervisor: w.supervisor,
    category: w.category,
    activities: w.activities?.map(mapActivity) || [],
    progress: w.progress,
    totalActivities: w.total_activities,
    doneActivities: w.done_activities
  });

  const mapActivity = (a: any): Activity => ({
    id: a.id,
    name: a.name,
    executionTime: a.execution_time,
    executor: a.executor,
    done: a.done,
    evaluation: a.evaluation,
    additionalPlan: a.additional_plan,
    fileUrls: a.file_urls
  });

  const refreshProjects = async () => {
    try {
      const data = await api.projects.getAll();
      setProjects(data.map(mapProject));
    } catch (err) {
      console.error('Failed to fetch projects:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    refreshProjects();
  }, []);

  const addProject = async (projectData: Omit<Project, 'id' | 'status' | 'isClosed'>) => {
    const data = await api.projects.create({
      name: projectData.name,
      description: projectData.description,
      location: projectData.location,
      start_date: projectData.startDate,
      end_date: projectData.endDate,
      executor: projectData.executor,
      supervisor: projectData.supervisor
    });
    const newProject = mapProject(data);
    setProjects(prev => [newProject, ...prev]);
    return newProject.id;
  };

  const deleteProject = async (projectId: string) => {
    await api.projects.delete(projectId);
    setProjects(prev => prev.filter(p => p.id !== projectId));
  };

  const closeProject = async (projectId: string) => {
    const data = await api.projects.close(projectId);
    setProjects(prev => prev.map(p => p.id === projectId ? mapProject(data) : p));
  };

  const renameProject = async (projectId: string, name: string) => {
    const data = await api.projects.rename(projectId, name);
    setProjects(prev => prev.map(p => p.id === projectId ? mapProject(data) : p));
  };

  const addWork = async (workData: Omit<Work, 'id' | 'activities'>) => {
    const data = await api.works.create({
      project_id: workData.projectId,
      name: workData.name,
      description: workData.description,
      location: workData.location,
      start_date: workData.startDate,
      end_date: workData.endDate,
      executor: workData.executor,
      supervisor: workData.supervisor,
      category: workData.category
    });
    return data.id;
  };

  const deleteWork = async (workId: string) => {
    await api.works.delete(workId);
  };

  const renameWork = async (workId: string, name: string) => {
    await api.works.rename(workId, name);
  };

  const addActivity = async (workId: string, activityData: Omit<Activity, 'id'>) => {
    await api.activities.create({
      work_id: workId,
      name: activityData.name,
      execution_time: activityData.executionTime,
      executor: activityData.executor,
      done: activityData.done
    });
  };

  const updateActivity = async (workId: string, activityId: string, updates: Partial<Activity>) => {
    const apiUpdates: any = { ...updates };
    if (updates.executionTime) {
      apiUpdates.execution_time = updates.executionTime;
      delete apiUpdates.executionTime;
    }
    await api.activities.update(activityId, apiUpdates);
  };

  const deleteActivity = async (workId: string, activityId: string) => {
    await api.activities.delete(activityId);
  };

  const getProjectById = async (projectId: string) => {
    try {
      const data = await api.projects.getById(projectId);
      return mapProject(data);
    } catch {
      return undefined;
    }
  };

  const getWorksByProjectId = async (projectId: string) => {
    const data = await api.works.getByProjectId(projectId);
    return data.map(mapWork);
  };

  return (
    <ProjectContext.Provider
      value={{
        projects,
        loading,
        refreshProjects,
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