from api.models import TaskSubmission
from django.utils import timezone
from datetime import timedelta

TaskSubmission.objects.create(
    category='creation',
    title='Laporan Desain UI/UX ProManage V2',
    description='Berikut adalah lampiran hasil akhir desain antarmuka aplikasi ProManage versi 2.0 yang telah selesai dibuat. Termasuk file aset Figma dan prototype.',
    submitted_by='Budi Desainer',
    status='submitted',
    deadline_date=(timezone.now() + timedelta(days=2)).date()
)
print("Dummy submission created!")
