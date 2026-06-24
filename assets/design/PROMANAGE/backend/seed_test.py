import os
import django
import sys
from datetime import datetime, timedelta

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.models import User, Project, Work, Activity

def seed_test_user_data():
    email = 'test@promanage.com'
    try:
        user = User.objects.get(email=email)
        print(f"Found user: {email}")
    except User.objects.model.DoesNotExist:
        user = User.objects.create(
            email=email,
            name='MUHAMMAD RIZKI',
            nim='12345678',
        )
        user.set_password('test123')
        user.save()
        print(f"Created user: {email}")

    # Get all projects for this user
    projects = Project.objects.filter(user=user)
    if not projects.exists():
        # Create a sample project if none exists
        Project.objects.create(
            name='INFROMATIKA JAYA',
            description='Proyek Utama Informatika',
            location='Kampus',
            user=user,
            start_date=datetime.now().date(),
            end_date=datetime.now().date() + timedelta(days=30),
            executor='Tim Rizki',
            supervisor='Dosen Pembimbing',
            status='Aktif'
        )
        projects = Project.objects.filter(user=user)

    print(f"Processing {projects.count()} projects for {email}...")

    for project in projects:
        # Ensure 3 works for each project
        works_data = [
            {'name': 'Analisis Sistem', 'cat': 'engineering'},
            {'name': 'Desain Database', 'cat': 'creation'},
            {'name': 'Coding Backend', 'cat': 'implementation'}
        ]

        for w_data in works_data:
            work, created = Work.objects.get_or_create(
                name=f"{w_data['name']} - {project.name}",
                project=project,
                defaults={
                    'description': f"Pekerjaan untuk {project.name}",
                    'location': project.location,
                    'start_date': datetime.now().date(),
                    'end_date': datetime.now().date() + timedelta(days=7),
                    'executor': project.executor,
                    'supervisor': project.supervisor,
                    'category': w_data['cat']
                }
            )
            if created:
                print(f"  Created work: {work.name}")

            # Ensure 3 activities for each work
            activities_data = [
                {'name': 'Riset Awal', 'done': True},
                {'name': 'Drafting', 'done': True},
                {'name': 'Finalisasi', 'done': False},
            ]

            for a_data in activities_data:
                activity, a_created = Activity.objects.get_or_create(
                    name=f"{a_data['name']} untuk {work.name[:10]}",
                    work=work,
                    defaults={
                        'execution_time': '1 Jam',
                        'executor': 'Tim',
                        'done': a_data['done']
                    }
                )
                if a_created:
                    print(f"    Created activity: {activity.name}")

    print("DONE! Data for test@promanage.com has been populated.")

if __name__ == '__main__':
    seed_test_user_data()
