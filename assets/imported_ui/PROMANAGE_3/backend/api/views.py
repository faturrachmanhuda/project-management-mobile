from rest_framework import viewsets, status, generics
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from django.contrib.auth import authenticate
from django.shortcuts import render
from .models import User, Project, Work, Activity, ActivityFile, SurveyResponse
from .serializers import (
    UserSerializer, RegisterSerializer, LoginSerializer,
    ProjectSerializer, ProjectCreateSerializer,
    WorkSerializer, WorkCreateSerializer,
    ActivitySerializer, ActivityFileSerializer,
    TaskSubmissionSerializer, SurveyResponseSerializer
)
from .authentication import generate_jwt
from .permissions import IsOwner


# ==================== TEMPLATE VIEWS ====================

def home_view(request):
    """Render home page"""
    return render(request, 'home.html')


def about_view(request):
    """Render about page"""
    return render(request, 'about.html')


def projects_view(request):
    """Render projects page"""
    return render(request, 'projects.html')


def project_detail_view(request, project_id):
    """Render project detail page"""
    return render(request, 'project_detail.html', {'project_id': project_id})


def work_detail_view(request, work_id):
    """Render work detail page"""
    return render(request, 'work_detail.html', {'work_id': work_id})


def profile_view(request):
    """Render profile page"""
    return render(request, 'profile.html')


# ==================== API VIEWS ====================


class RegisterView(generics.CreateAPIView):
    """User registration endpoint"""
    permission_classes = [AllowAny]
    serializer_class = RegisterSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)

        if serializer.is_valid():
            user = serializer.save()
            token = generate_jwt(user)

            return Response({
                'success': True,
                'token': token,
                'user': UserSerializer(user).data
            }, status=status.HTTP_201_CREATED)

        errors = serializer.errors
        message = 'Pendaftaran gagal'

        if 'email' in errors:
            message = 'Email sudah terdaftar.'
        elif 'nim' in errors:
            message = 'NIM sudah terdaftar.'

        return Response({
            'success': False,
            'error': message
        }, status=status.HTTP_400_BAD_REQUEST)


class LoginView(generics.GenericAPIView):
    """User login endpoint"""
    permission_classes = [AllowAny]
    serializer_class = LoginSerializer

    def post(self, request):
        email = request.data.get('email', '').lower()
        password = request.data.get('password', '')

        try:
            user = User.objects.get(email=email)
            if not user.check_password(password):
                return Response({
                    'success': False,
                    'error': 'Email atau kata sandi tidak sesuai.'
                }, status=status.HTTP_401_UNAUTHORIZED)

            token = generate_jwt(user)

            return Response({
                'success': True,
                'token': token,
                'user': UserSerializer(user).data
            })

        except User.DoesNotExist:
            return Response({
                'success': False,
                'error': 'Email atau kata sandi tidak sesuai.'
            }, status=status.HTTP_401_UNAUTHORIZED)


class UserViewSet(viewsets.ReadOnlyModelViewSet):
    """User viewset - read only"""
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return User.objects.filter(id=self.request.user.id)

    @action(detail=False, methods=['get'])
    def me(self, request):
        """Get current user info"""
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)

    @action(detail=False, methods=['patch', 'put'])
    def update_profile(self, request):
        """Update current user profile and picture"""
        user = request.user
        serializer = self.get_serializer(user, data=request.data, partial=True, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ProjectViewSet(viewsets.ModelViewSet):
    """Project CRUD endpoints"""
    permission_classes = [IsAuthenticated, IsOwner]

    def get_serializer_class(self):
        if self.action == 'create':
            return ProjectCreateSerializer
        return ProjectSerializer

    def get_queryset(self):
        return Project.objects.filter(user=self.request.user)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            project = serializer.save()
            return Response(
                ProjectSerializer(project).data,
                status=status.HTTP_201_CREATED
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['patch'])
    def close(self, request, pk=None):
        """Close a project"""
        project = self.get_object()
        project.is_closed = True
        project.save()
        return Response(ProjectSerializer(project).data)

    @action(detail=True, methods=['patch'])
    def rename(self, request, pk=None):
        """Rename a project"""
        project = self.get_object()
        name = request.data.get('name')
        if not name:
            return Response({'error': 'Name is required'}, status=status.HTTP_400_BAD_REQUEST)

        project.name = name
        project.save()
        return Response(ProjectSerializer(project).data)

    @action(detail=False, methods=['get'])
    def dashboard_stats(self, request):
        """Get comprehensive analytics for project management dashboard"""
        from django.db.models import Count, Q
        from datetime import datetime, timedelta

        user = self.request.user
        projects = Project.objects.filter(user=user)
        works = Work.objects.filter(project__user=user)
        activities = Activity.objects.filter(work__project__user=user)

        # 1. Project Status Distribution
        status_counts = projects.values('status').annotate(count=Count('id'))
        status_map = {item['status']: item['count'] for item in status_counts}

        # 2. Activity Completion (The "Real" Progress)
        total_activities = activities.count()
        done_activities = activities.filter(done=True).count()
        progress_percent = round((done_activities / total_activities * 100) if total_activities > 0 else 0, 1)

        work_counts = works.values('project__name').annotate(count=Count('id'))
        works_per_project = {item['project__name']: item['count'] for item in work_counts}

        # 4. Individual Project Progress (Deep Dive)
        project_details = []
        for p in projects:
            p_activities = activities.filter(work__project=p)
            p_total = p_activities.count()
            p_done = p_activities.filter(done=True).count()
            p_progress = round((p_done / p_total * 100) if p_total > 0 else 0)
            
            project_details.append({
                'name': p.name,
                'status': p.status,
                'progress': p_progress,
                'total_activities': p_total
            })

        return Response({
            'summary': {
                'total_projects': projects.count(),
                'total_works': works.count(),
                'total_activities': total_activities,
            },
            'portfolio': {
                'status': status_map,
                'works_per_project': works_per_project,
            },
            'activities': {
                'percent': progress_percent,
                'done': done_activities,
                'total': total_activities
            },
            'project_breakdown': project_details
        })


class WorkViewSet(viewsets.ModelViewSet):
    """Work CRUD endpoints"""
    permission_classes = [IsAuthenticated, IsOwner]

    def get_serializer_class(self):
        if self.action == 'create':
            return WorkCreateSerializer
        return WorkSerializer

    def get_queryset(self):
        # Filter works by user's projects
        return Work.objects.filter(project__user=self.request.user)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            work = serializer.save()
            return Response(
                WorkSerializer(work).data,
                status=status.HTTP_201_CREATED
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['patch'])
    def rename(self, request, pk=None):
        """Rename a work"""
        work = self.get_object()
        name = request.data.get('name')
        if not name:
            return Response({'error': 'Name is required'}, status=status.HTTP_400_BAD_REQUEST)

        work.name = name
        work.save()
        return Response(WorkSerializer(work).data)

    @action(detail=False, methods=['get'])
    def by_project(self, request):
        """Get works by project ID"""
        project_id = request.query_params.get('project_id')
        if not project_id:
            return Response({'error': 'project_id is required'}, status=status.HTTP_400_BAD_REQUEST)

        works = self.get_queryset().filter(project_id=project_id)
        serializer = self.get_serializer(works, many=True)
        return Response(serializer.data)


class ActivityViewSet(viewsets.ModelViewSet):
    """Activity CRUD endpoints"""
    serializer_class = ActivitySerializer
    permission_classes = [IsAuthenticated, IsOwner]

    def get_queryset(self):
        return Activity.objects.filter(work__project__user=self.request.user)

    def create(self, request, *args, **kwargs):
        work_id = request.data.get('work_id')
        if not work_id:
            return Response({'error': 'work_id is required'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            work = Work.objects.get(id=work_id, project__user=request.user)
        except Work.DoesNotExist:
            return Response({'error': 'Work not found'}, status=status.HTTP_404_NOT_FOUND)

        serializer = self.get_serializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            activity = serializer.save(work=work)
            return Response(
                ActivitySerializer(activity, context={'request': request}).data,
                status=status.HTTP_201_CREATED
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=True, methods=['patch'])
    def toggle_done(self, request, pk=None):
        """Toggle activity done status"""
        activity = self.get_object()
        activity.done = not activity.done
        activity.save()
        return Response(ActivitySerializer(activity, context={'request': request}).data)

    @action(detail=False, methods=['get'])
    def by_work(self, request):
        """Get activities by work ID"""
        work_id = request.query_params.get('work_id')
        if not work_id:
            return Response({'error': 'work_id is required'}, status=status.HTTP_400_BAD_REQUEST)

        activities = self.get_queryset().filter(work_id=work_id)
        serializer = self.get_serializer(activities, many=True, context={'request': request})
        return Response(serializer.data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def health_check(request):
    """Health check endpoint"""
    return Response({
        'status': 'OK',
        'user': str(request.user),
        'message': 'API is running'
    })
class ActivityFileViewSet(viewsets.ModelViewSet):
    """ActivityFile CRUD endpoints"""
    queryset = ActivityFile.objects.all()
    serializer_class = ActivityFileSerializer
    permission_classes = [IsAuthenticated, IsOwner]

    def get_queryset(self):
        return ActivityFile.objects.filter(activity__work__project__user=self.request.user)

class TaskSubmissionViewSet(viewsets.ModelViewSet):
    """TaskSubmission CRUD endpoints"""
    permission_classes = [IsAuthenticated]
    serializer_class = TaskSubmissionSerializer

    def get_queryset(self):
        from .models import TaskSubmission
        queryset = TaskSubmission.objects.all()
        category = self.request.query_params.get('category', None)
        status_filter = self.request.query_params.get('status', None)
        if category:
            queryset = queryset.filter(category=category)
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        return queryset

    @action(detail=True, methods=['patch'])
    def update_status(self, request, pk=None):
        """Update submission status"""
        submission = self.get_object()
        new_status = request.data.get('status')
        if new_status not in ['draft', 'submitted', 'reviewed', 'approved', 'rejected']:
            return Response({'error': 'Status tidak valid'}, status=status.HTTP_400_BAD_REQUEST)
        submission.status = new_status
        submission.save()
        return Response(TaskSubmissionSerializer(submission, context={'request': request}).data)

    @action(detail=False, methods=['get'])
    def stats(self, request):
        """Get submission statistics per category"""
        from django.db.models import Count, Q
        from .models import TaskSubmission

        categories = ['engineers', 'creation', 'implementation']
        result = {}
        for cat in categories:
            qs = TaskSubmission.objects.filter(category=cat)
            result[cat] = {
                'total': qs.count(),
                'submitted': qs.filter(status='submitted').count(),
                'approved': qs.filter(status='approved').count(),
                'rejected': qs.filter(status='rejected').count(),
                'reviewed': qs.filter(status='reviewed').count(),
                'draft': qs.filter(status='draft').count(),
            }
        return Response(result)


def submissions_page(request):
    return render(request, 'submissions.html')


# ==================== SURVEY VIEWS ====================

class SurveyResponseViewSet(viewsets.ModelViewSet):
    """PSSUQ Survey submission and retrieval"""
    serializer_class = SurveyResponseSerializer
    permission_classes = [AllowAny]   # Responden tidak perlu login

    def get_queryset(self):
        return SurveyResponse.objects.all()

    @action(detail=False, methods=['get'], permission_classes=[IsAuthenticated])
    def stats(self, request):
        """Aggregate PSSUQ statistics per module"""
        from django.db.models import Avg, Count
        qs = SurveyResponse.objects.all()
        total = qs.count()

        # per-module breakdown
        modules = ['project_management', 'intelligence_creation',
                   'intelligence_engineering', 'dataset_management',
                   'system_implementation']
        breakdown = []
        for mod in modules:
            mqs = qs.filter(module_tested=mod)
            if not mqs.exists():
                continue
            items = list(mqs.values_list(
                'q1','q2','q3','q4','q5','q6','q7','q8',
                'q9','q10','q11','q12','q13','q14','q15',
                'q16','q17','q18','q19'
            ))
            all_vals = [v for row in items for v in row]
            overall = round(sum(all_vals) / len(all_vals), 2) if all_vals else 0

            # subscales
            sysuse_vals = [v for row in items for v in row[:8]]
            infoqual_vals = [v for row in items for v in row[8:15]]
            interqual_vals = [v for row in items for v in row[15:18]]

            breakdown.append({
                'module': mod,
                'count': mqs.count(),
                'overall': overall,
                'sysuse': round(sum(sysuse_vals)/len(sysuse_vals), 2) if sysuse_vals else 0,
                'infoqual': round(sum(infoqual_vals)/len(infoqual_vals), 2) if infoqual_vals else 0,
                'interqual': round(sum(interqual_vals)/len(interqual_vals), 2) if interqual_vals else 0,
            })

        return Response({
            'total_respondents': total,
            'breakdown': breakdown,
        })


def survey_page(request):
    return render(request, 'survey.html')


def survey_results_page(request):
    return render(request, 'survey_results.html')
