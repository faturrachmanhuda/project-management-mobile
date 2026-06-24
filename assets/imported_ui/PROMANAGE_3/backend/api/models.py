from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
import uuid


class UserManager(BaseUserManager):
    def create_user(self, email, nim, name, password=None):
        if not email:
            raise ValueError('User harus memiliki email')
        if not nim:
            raise ValueError('User harus memiliki NIM')

        email = self.normalize_email(email)
        user = self.model(email=email, nim=nim, name=name)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, nim, name, password=None):
        user = self.create_user(email, nim, name, password)
        user.is_staff = True
        user.is_superuser = True
        user.save(using=self._db)
        return user


class User(AbstractBaseUser, PermissionsMixin):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email = models.EmailField(unique=True, max_length=255)
    nim = models.CharField(max_length=20, unique=True, verbose_name='NIM')
    name = models.CharField(max_length=255)
    profile_picture = models.ImageField(upload_to='profile_pictures/', blank=True, null=True)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['nim', 'name']

    class Meta:
        db_table = 'users'
        verbose_name = 'User'
        verbose_name_plural = 'Users'

    def __str__(self):
        return self.email


class Project(models.Model):
    STATUS_CHOICES = [
        ('Aktif', 'Aktif'),
        ('Selesai', 'Selesai'),
        ('Tertunda', 'Tertunda'),
    ]

    id = models.CharField(primary_key=True, max_length=50, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='projects')
    name = models.CharField(max_length=255)
    description = models.TextField()
    location = models.CharField(max_length=255)
    start_date = models.DateField()
    end_date = models.DateField()
    executor = models.CharField(max_length=255)
    supervisor = models.CharField(max_length=255)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='Aktif')
    is_closed = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'projects'
        ordering = ['-created_at']

    def save(self, *args, **kwargs):
        if not self.id:
            import uuid
            self.id = uuid.uuid4().hex
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name

    @property
    def total_activities(self):
        from .models import Activity
        return Activity.objects.filter(work__project=self).count()

    @property
    def done_activities(self):
        from .models import Activity
        return Activity.objects.filter(work__project=self, done=True).count()

    @property
    def progress(self):
        total = self.total_activities
        if total == 0:
            return 0
        return round((self.done_activities / total) * 100)


class Work(models.Model):
    id = models.CharField(primary_key=True, max_length=50, editable=False)
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='works')
    name = models.CharField(max_length=255)
    CATEGORY_CHOICES = [
        ('engineering', 'Engineering'),
        ('creation', 'Creation'),
        ('implementation', 'Implementation'),
    ]
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES, default='engineering')
    description = models.TextField()
    location = models.CharField(max_length=255)
    start_date = models.DateField()
    end_date = models.DateField()
    executor = models.CharField(max_length=255)
    supervisor = models.CharField(max_length=255)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'works'
        ordering = ['-created_at']

    def save(self, *args, **kwargs):
        if not self.id:
            import uuid
            self.id = uuid.uuid4().hex
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name

    @property
    def total_activities(self):
        return self.activities.count()

    @property
    def done_activities(self):
        return self.activities.filter(done=True).count()

    @property
    def progress(self):
        total = self.total_activities
        if total == 0:
            return 0
        return round((self.done_activities / total) * 100)


class Activity(models.Model):
    id = models.CharField(primary_key=True, max_length=50, editable=False)
    work = models.ForeignKey(Work, on_delete=models.CASCADE, related_name='activities')
    name = models.CharField(max_length=255)
    execution_time = models.CharField(max_length=255)
    executor = models.CharField(max_length=255)
    done = models.BooleanField(default=False)
    evaluation = models.TextField(blank=True, null=True)
    additional_plan = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'activities'
        ordering = ['-created_at']
        verbose_name_plural = 'Activities'

    def save(self, *args, **kwargs):
        if not self.id:
            import uuid
            self.id = uuid.uuid4().hex
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name


class ActivityFile(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    activity = models.ForeignKey(Activity, on_delete=models.CASCADE, related_name='files')
    file = models.FileField(upload_to='activity_files/%Y/%m/%d/')
    file_size = models.IntegerField(null=True, blank=True)
    uploaded_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'activity_files'
        ordering = ['-uploaded_at']

    def __str__(self):
        return f"File for {self.activity.name}"


class TaskSubmission(models.Model):
    CATEGORY_CHOICES = [
        ('engineers', 'Engineers'),
        ('creation', 'Creation'),
        ('implementation', 'Implementation'),
    ]

    STATUS_CHOICES = [
        ('draft', 'Draft'),
        ('submitted', 'Submitted'),
        ('reviewed', 'Reviewed'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES, default='engineers')
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True, null=True)
    file = models.FileField(upload_to='submissions/%Y/%m/%d/', blank=True, null=True)
    submitted_by = models.CharField(max_length=255)
    project_name = models.CharField(max_length=255, blank=True, null=True)
    project_id = models.CharField(max_length=100, blank=True, null=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='submitted')
    deadline_date = models.DateField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'task_submissions'
        ordering = ['-created_at']

    def __str__(self):
        return f"[{self.get_category_display()}] {self.title}"

    @property
    def is_late(self):
        from django.utils import timezone
        if self.deadline_date and self.status == 'submitted':
            return timezone.now().date() > self.deadline_date
        return False


class SurveyResponse(models.Model):
    """PSSUQ Usability Survey Response (Version 3 - 19 items)"""
    MODULE_CHOICES = [
        ('project_management', 'Project Management'),
        ('intelligence_creation', 'Intelligence Creation'),
        ('intelligence_engineering', 'Intelligence Engineering'),
        ('dataset_management', 'Dataset Management'),
        ('system_implementation', 'System Implementation'),
    ]
    GENDER_CHOICES = [
        ('L', 'Laki-laki'),
        ('P', 'Perempuan'),
    ]
    EDUCATION_CHOICES = [
        ('sma', 'SMA/SMK'),
        ('d3', 'D3'),
        ('s1', 'S1'),
        ('s2', 'S2'),
        ('s3', 'S3'),
    ]
    EXPERIENCE_CHOICES = [
        ('lt1', '< 1 tahun'),
        ('1-2', '1 - 2 tahun'),
        ('3-5', '3 - 5 tahun'),
        ('gt5', '> 5 tahun'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    # --- Profil Pengguna ---
    respondent_name = models.CharField(max_length=255)
    respondent_age = models.PositiveIntegerField()
    respondent_gender = models.CharField(max_length=1, choices=GENDER_CHOICES)
    respondent_education = models.CharField(max_length=5, choices=EDUCATION_CHOICES)
    respondent_occupation = models.CharField(max_length=255)
    respondent_experience = models.CharField(max_length=5, choices=EXPERIENCE_CHOICES)
    module_tested = models.CharField(max_length=50, choices=MODULE_CHOICES)

    # --- PSSUQ Items (1-7 scale: 1=Strongly Agree, 7=Strongly Disagree) ---
    # System Usefulness (Q1-Q8)
    q1  = models.PositiveSmallIntegerField()  # Mudah diselesaikan
    q2  = models.PositiveSmallIntegerField()  # Sederhana digunakan
    q3  = models.PositiveSmallIntegerField()  # Mudah dipelajari
    q4  = models.PositiveSmallIntegerField()  # Bermanfaat
    q5  = models.PositiveSmallIntegerField()  # Pesan error membantu
    q6  = models.PositiveSmallIntegerField()  # Informasi tepat waktu
    q7  = models.PositiveSmallIntegerField()  # Informasi mudah dipahami
    q8  = models.PositiveSmallIntegerField()  # Informasi efektif membantu
    # Information Quality (Q9-Q15)
    q9  = models.PositiveSmallIntegerField()  # Informasi yang disajikan jelas
    q10 = models.PositiveSmallIntegerField()  # Informasi mudah dibaca
    q11 = models.PositiveSmallIntegerField()  # Format informasi sesuai
    q12 = models.PositiveSmallIntegerField()  # Layar teratur dan terorganisir
    q13 = models.PositiveSmallIntegerField()  # Antarmuka menyenangkan
    q14 = models.PositiveSmallIntegerField()  # Semua fungsi sesuai harapan
    q15 = models.PositiveSmallIntegerField()  # Secara keseluruhan puas
    # Interface Quality (Q16-Q18)
    q16 = models.PositiveSmallIntegerField()  # Kemampuan sistem sesuai kebutuhan
    q17 = models.PositiveSmallIntegerField()  # Sistem mudah digunakan
    q18 = models.PositiveSmallIntegerField()  # Sistem dirancang dengan baik
    # Overall (Q19)
    q19 = models.PositiveSmallIntegerField()  # Puas secara keseluruhan

    notes = models.TextField(blank=True, null=True)
    submitted_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'survey_responses'
        ordering = ['-submitted_at']

    def __str__(self):
        return f"{self.respondent_name} - {self.get_module_tested_display()}"

    @property
    def sysuse(self):
        """System Usefulness subscale score (Q1-Q8)"""
        items = [self.q1, self.q2, self.q3, self.q4, self.q5, self.q6, self.q7, self.q8]
        return round(sum(items) / len(items), 2)

    @property
    def infoqual(self):
        """Information Quality subscale score (Q9-Q15)"""
        items = [self.q9, self.q10, self.q11, self.q12, self.q13, self.q14, self.q15]
        return round(sum(items) / len(items), 2)

    @property
    def interqual(self):
        """Interface Quality subscale score (Q16-Q18)"""
        items = [self.q16, self.q17, self.q18]
        return round(sum(items) / len(items), 2)

    @property
    def overall_score(self):
        """Overall PSSUQ score (Q1-Q19)"""
        items = [
            self.q1, self.q2, self.q3, self.q4, self.q5, self.q6, self.q7, self.q8,
            self.q9, self.q10, self.q11, self.q12, self.q13, self.q14, self.q15,
            self.q16, self.q17, self.q18, self.q19
        ]
        return round(sum(items) / len(items), 2)
