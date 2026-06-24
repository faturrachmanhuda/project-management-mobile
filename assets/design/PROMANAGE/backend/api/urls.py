from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    RegisterView, LoginView, UserViewSet,
    ProjectViewSet, WorkViewSet, ActivityViewSet, ActivityFileViewSet, TaskSubmissionViewSet,
    health_check,
    home_view, about_view, projects_view, profile_view,
    project_detail_view, work_detail_view, submissions_page
)
from .views_export import (
    export_project_excel, export_project_pdf,
    export_all_excel, export_all_pdf
)

router = DefaultRouter()
router.register(r'api/users', UserViewSet, basename='user')
router.register(r'api/projects', ProjectViewSet, basename='project')
router.register(r'api/works', WorkViewSet, basename='work')
router.register(r'api/activities', ActivityViewSet, basename='activity')
router.register(r'api/activity-files', ActivityFileViewSet, basename='activity-file')
router.register(r'api/task-submissions', TaskSubmissionViewSet, basename='task-submission')

urlpatterns = [
    # Template Views (HTML Pages)
    path('', home_view, name='home'),
    path('about/', about_view, name='about'),
    path('projects/', projects_view, name='projects'),
    path('profile/', profile_view, name='profile'),
    path('projects/<str:project_id>/', project_detail_view, name='project_detail'),
    path('works/<str:work_id>/', work_detail_view, name='work_detail'),
    path('submissions/', submissions_page, name='submissions'),

    # API endpoints
    path('api/auth/register/', RegisterView.as_view(), name='register'),
    path('api/auth/login/', LoginView.as_view(), name='login'),
    path('api/health/', health_check, name='health'),

    # Export Endpoints (Isolated from Router)
    path('api/reports/all/pdf/', export_all_pdf, name='export_all_pdf'),
    path('api/reports/all/excel/', export_all_excel, name='export_all_excel'),
    path('api/reports/project/<str:project_id>/excel/', export_project_excel, name='export_project_excel'),
    path('api/reports/project/<str:project_id>/pdf/', export_project_pdf, name='export_pdf'),

    # React API Compatibility Layer
    path('api/projects/export/pdf/', export_all_pdf),
    path('api/projects/export/excel/', export_all_excel),
    path('api/projects/<str:project_id>/export/excel/', export_project_excel),
    path('api/projects/<str:project_id>/export/pdf/', export_project_pdf),

    # Router URLs (API)
    path('', include(router.urls)),
]
