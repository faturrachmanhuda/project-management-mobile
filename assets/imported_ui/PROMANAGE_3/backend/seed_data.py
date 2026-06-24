import os
import django
import sys
from datetime import datetime, timedelta

# Setup Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
django.setup()

from api.models import User, Project, Work, Activity

def seed_data():
    # 1. Get or Create User
    user, created = User.objects.get_or_create(
        email='admin@promanage.com',
        defaults={
            'name': 'Admin ProManage',
            'nim': '12345678',
            'is_staff': True,
            'is_superuser': True
        }
    )
    if created:
        user.set_password('admin123')
        user.save()
        print("User created: admin@promanage.com / admin123")
    else:
        print("User already exists")

    # 2. Create Projects
    projects_data = [
        {
            'name': 'Pembangunan Smart City ITB',
            'description': 'Implementasi IoT untuk manajemen energi di area kampus ITB.',
            'location': 'Bandung',
            'status': 'Aktif',
            'executor': 'Tim Telkom',
            'supervisor': 'Prof. Bambang'
        },
        {
            'name': 'Sistem Antrean Puskesmas',
            'description': 'Aplikasi web untuk manajemen antrean pasien di Puskesmas.',
            'location': 'Jakarta',
            'status': 'Selesai',
            'executor': 'Mhs Magang',
            'supervisor': 'Dr. Siti'
        },
        {
            'name': 'Audit Keamanan Server',
            'description': 'Melakukan pengujian penetrasi pada server database utama.',
            'location': 'Yogyakarta',
            'status': 'Tertunda',
            'executor': 'Cyber Team',
            'supervisor': 'Bapak Iwan'
        }
    ]

    for p_data in projects_data:
        project, _ = Project.objects.get_or_create(
            name=p_data['name'],
            user=user,
            defaults={
                'description': p_data['description'],
                'location': p_data['location'],
                'start_date': datetime.now().date() - timedelta(days=30),
                'end_date': datetime.now().date() + timedelta(days=30),
                'executor': p_data['executor'],
                'supervisor': p_data['supervisor'],
                'status': p_data['status']
            }
        )

        # 3. Create Works for each project
        works_data = [
            {'name': 'Analisis Kebutuhan', 'cat': 'engineering'},
            {'name': 'Perancangan UI/UX', 'cat': 'creation'},
            {'name': 'Implementasi Fitur', 'cat': 'implementation'}
        ]

        for w_data in works_data:
            work, _ = Work.objects.get_or_create(
                name=f"{w_data['name']} - {project.name[:10]}",
                project=project,
                defaults={
                    'description': f"Detail untuk {w_data['name']}",
                    'location': project.location,
                    'start_date': datetime.now().date(),
                    'end_date': datetime.now().date() + timedelta(days=10),
                    'executor': project.executor,
                    'supervisor': project.supervisor,
                    'category': w_data['cat']
                }
            )

            # 4. Create Activities for each work
            activities_data = [
                {'name': 'Riset Dokumen', 'exec': 'Budi', 'done': True},
                {'name': 'Wawancara User', 'exec': 'Lani', 'done': True},
                {'name': 'Penulisan Laporan', 'exec': 'Budi', 'done': False},
                {'name': 'Presentasi', 'exec': 'Agus', 'done': False},
            ]

            for a_data in activities_data:
                Activity.objects.get_or_create(
                    name=f"{a_data['name']} ({work.name[:5]})",
                    work=work,
                    defaults={
                        'execution_time': '2 Jam',
                        'executor': a_data['exec'],
                        'done': a_data['done']
                    }
                )

    print("Successfully seeded Proyek, Pekerjaan, and Aktivitas!")

if __name__ == '__main__':
    seed_data()
