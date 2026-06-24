import { createBrowserRouter } from 'react-router';
import { Home } from './pages/Home';
import { AboutUs } from './pages/AboutUs';
import { ProjectManagement } from './pages/ProjectManagement';
import { ProjectDetail } from './pages/ProjectDetail';
import { WorkDetail } from './pages/WorkDetail';
import { Dashboard } from './pages/Dashboard';
import { AuthGuard } from './components/AuthGuard';

function GuardedProjectManagement() {
  return <AuthGuard><ProjectManagement /></AuthGuard>;
}

function GuardedDashboard() {
  return <AuthGuard><Dashboard /></AuthGuard>;
}

function GuardedProjectDetail() {
  return <AuthGuard><ProjectDetail /></AuthGuard>;
}

function GuardedWorkDetail() {
  return <AuthGuard><WorkDetail /></AuthGuard>;
}

export const router = createBrowserRouter([
  {
    path: '/',
    Component: Home,
  },
  {
    path: '/about',
    Component: AboutUs,
  },
  {
    path: '/dashboard',
    Component: GuardedDashboard,
  },
  {
    path: '/projects',
    Component: GuardedProjectManagement,
  },
  {
    path: '/project/:id',
    Component: GuardedProjectDetail,
  },
  {
    path: '/project/:projectId/work/:workId',
    Component: GuardedWorkDetail,
  },
]);
