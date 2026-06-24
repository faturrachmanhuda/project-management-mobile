"""
Script untuk membuat test data di database Django
Run: python manage.py shell < create_test_data.py
"""

from api.models import User, Project, Work, Activity
from datetime import date, timedelta

print("Creating test data...")

# Create test user
user, created = User.objects.get_or_create(
    email='test@promanage.com',
    defaults={
        'nim': 'TEST001',
        'name': 'Test User'
    }
)
if created:
    user.set_password('password123')
    user.save()
    print(f"✓ Created user: {user.email}")
else:
    print(f"✓ User already exists: {user.email}")

# Create test project
project, created = Project.objects.get_or_create(
    name='Sistem Informasi Perpustakaan',
    user=user,
    defaults={
        'description': 'Pengembangan sistem manajemen perpustakaan digital untuk kampus',
        'location': 'Kampus Utama',
        'start_date': date.today(),
        'end_date': date.today() + timedelta(days=180),
        'executor': 'Tim A',
        'supervisor': 'Dr. Ahmad Dahlan',
    }
)
if created:
    print(f"✓ Created project: {project.name}")
else:
    print(f"✓ Project already exists: {project.name}")

# Create test work
work, created = Work.objects.get_or_create(
    name='Analisis Sistem',
    project=project,
    defaults={
        'description': 'Analisis kebutuhan sistem perpustakaan',
        'location': 'Ruang Lab',
        'start_date': date.today(),
        'end_date': date.today() + timedelta(days=30),
        'executor': 'Tim Frontend',
        'supervisor': 'Budi Santoso',
        'category': 'engineering'
    }
)
if created:
    print(f"✓ Created work: {work.name}")
else:
    print(f"✓ Work already exists: {work.name}")

# Create test activities
activities_data = [
    {
        'name': 'Interview stakeholder',
        'execution_time': '2 jam',
        'executor': 'John Doe',
    },
    {
        'name': 'Membuat use case diagram',
        'execution_time': '3 jam',
        'executor': 'Jane Smith',
    },
    {
        'name': 'Review requirements',
        'execution_time': '1 jam',
        'executor': 'Bob Wilson',
    }
]

for act_data in activities_data:
    activity, created = Activity.objects.get_or_create(
        name=act_data['name'],
        work=work,
        defaults={
            'execution_time': act_data['execution_time'],
            'executor': act_data['executor'],
            'done': False
        }
    )
    if created:
        print(f"✓ Created activity: {activity.name}")

print("\n=== Test Data Summary ===")
print(f"User: {user.email} / password123")
print(f"Projects: {Project.objects.filter(user=user).count()}")
print(f"Works: {Work.objects.filter(project__user=user).count()}")
print(f"Activities: {Activity.objects.filter(work__project__user=user).count()}")
print("\nTest data created successfully!")
