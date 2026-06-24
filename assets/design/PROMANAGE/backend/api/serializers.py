from rest_framework import serializers
from .models import User, Project, Work, Activity, ActivityFile, TaskSubmission
import base64
import uuid
from django.core.files.base import ContentFile



class Base64ImageField(serializers.ImageField):
    def to_internal_value(self, data):
        if isinstance(data, str) and ';base64,' in data:
            try:
                format, imgstr = data.split(';base64,')
                ext = format.split('/')[-1]
                if 'jpeg' in ext: ext = 'jpg'
                
                decoded_file = base64.b64decode(imgstr)
                file_name = f"{uuid.uuid4().hex[:8]}.{ext}"
                data = ContentFile(decoded_file, name=file_name)
            except Exception:
                raise serializers.ValidationError("Invalid image data")

        return super().to_internal_value(data)


class UserSerializer(serializers.ModelSerializer):

    profile_picture_url = serializers.SerializerMethodField(read_only=True)
    profile_picture = Base64ImageField(write_only=True, required=False)

    class Meta:
        model = User
        fields = ['id', 'name', 'email', 'nim', 'profile_picture', 'profile_picture_url']
        read_only_fields = ['id']

    def get_profile_picture_url(self, obj):
        if obj.profile_picture:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.profile_picture.url)
            return obj.profile_picture.url
        return None


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)

    class Meta:
        model = User
        fields = ['name', 'nim', 'email', 'password']

    def create(self, validated_data):
        user = User.objects.create_user(
            email=validated_data['email'],
            nim=validated_data['nim'],
            name=validated_data['name'],
            password=validated_data['password']
        )
        return user


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)


class ActivityFileSerializer(serializers.ModelSerializer):
    file_url = serializers.SerializerMethodField()

    class Meta:
        model = ActivityFile
        fields = ['id', 'file', 'file_url', 'uploaded_at']
        read_only_fields = ['id', 'uploaded_at']

    def get_file_url(self, obj):
        if obj.file:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.file.url)
        return None


class ActivitySerializer(serializers.ModelSerializer):
    work_id = serializers.ReadOnlyField(source='work.id')
    files = serializers.ListField(
        child=serializers.JSONField(),
        write_only=True,
        required=False,
        allow_empty=True
    )
    file_urls = serializers.SerializerMethodField(read_only=True)

    class Meta:
        model = Activity
        fields = [
            'id', 'work_id', 'name', 'execution_time', 'executor',
            'done', 'evaluation', 'additional_plan',
            'files', 'file_urls', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_file_urls(self, obj):
        request = self.context.get('request')
        files = obj.files.all()
        return [{
            'id': f.id,
            'url': request.build_absolute_uri(f.file.url),
            'name': f.file.name.split('/')[-1].split('_', 1)[-1] if '_' in f.file.name else f.file.name.split('/')[-1],
            'size': f.file_size
        } for f in files] if request else []

    def _process_files(self, activity, files_data):
        if not files_data:
            return

        # NEW RULE: Strictly 1 file. Block if already exists.
        if activity.files.exists():
            raise serializers.ValidationError({'files': 'BUKTI SUDAH ADA. Silakan hapus bukti lama terlebih dahulu.'})

        # Only process the first file provided
        file_item = files_data[0]
        name = None
        file_base64 = None

        if isinstance(file_item, dict):
            name = file_item.get('name')
            file_base64 = file_item.get('data')
        else:
            file_base64 = file_item

        if file_base64 and ';base64,' in file_base64:
            try:
                format, filestr = file_base64.split(';base64,')
                ext = format.split('/')[-1]
                # Handle common mime types
                if 'jpeg' in ext: ext = 'jpg'
                elif 'mpeg' in ext: ext = 'mp3'
                elif 'webm' in ext:
                    if name and name.endswith('.mp4'): ext = 'mp4'
                    elif name and name.endswith('.mp3'): ext = 'mp3'
                    else: ext = 'webm'
                elif 'octet-stream' in ext:
                    if name and '.' in name: ext = name.split('.')[-1]
                
                decoded_file = base64.b64decode(filestr)
                file_size = len(decoded_file)
                
                if file_size > 5 * 1024 * 1024:
                    raise serializers.ValidationError({'files': 'Ukuran file maksimal 5MB.'})

                if not name:
                    name = f"bukti.{ext}"
                
                unique_name = f"{uuid.uuid4().hex[:8]}_{name}"
                data = ContentFile(decoded_file, name=unique_name)
                ActivityFile.objects.create(activity=activity, file=data, file_size=file_size)
            except Exception as e:
                pass

    def create(self, validated_data):
        files_data = validated_data.pop('files', [])
        activity = Activity.objects.create(**validated_data)
        self._process_files(activity, files_data)
        return activity

    def update(self, instance, validated_data):
        files_data = validated_data.pop('files', None)

        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        if files_data is not None:
            self._process_files(instance, files_data)

        return instance


class WorkSerializer(serializers.ModelSerializer):
    project_id = serializers.ReadOnlyField(source='project.id')
    activities = ActivitySerializer(many=True, read_only=True)

    progress = serializers.ReadOnlyField()
    total_activities = serializers.ReadOnlyField()
    done_activities = serializers.ReadOnlyField()

    class Meta:
        model = Work
        fields = [
            'id', 'project_id', 'name', 'description', 'location',
            'start_date', 'end_date', 'executor', 'supervisor',
            'activities', 'progress', 'total_activities', 
            'done_activities', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class WorkCreateSerializer(serializers.ModelSerializer):
    project_id = serializers.CharField(write_only=True)

    class Meta:
        model = Work
        fields = [
            'project_id', 'name', 'description', 'location',
            'start_date', 'end_date', 'executor', 'supervisor'
        ]

    def create(self, validated_data):
        project_id = validated_data.pop('project_id')
        project = Project.objects.get(id=project_id, user=self.context['request'].user)
        work = Work.objects.create(project=project, **validated_data)
        return work


class ProjectSerializer(serializers.ModelSerializer):
    works = WorkSerializer(many=True, read_only=True)

    progress = serializers.ReadOnlyField()
    total_activities = serializers.ReadOnlyField()
    done_activities = serializers.ReadOnlyField()

    class Meta:
        model = Project
        fields = [
            'id', 'name', 'description', 'location',
            'start_date', 'end_date', 'executor', 'supervisor',
            'status', 'is_closed', 'works', 'progress', 
            'total_activities', 'done_activities', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class ProjectCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Project
        fields = [
            'name', 'description', 'location',
            'start_date', 'end_date', 'executor', 'supervisor'
        ]

    def create(self, validated_data):
        user = self.context['request'].user
        project = Project.objects.create(user=user, **validated_data)
        return project


class TaskSubmissionSerializer(serializers.ModelSerializer):
    file_url = serializers.SerializerMethodField(read_only=True)
    is_late = serializers.ReadOnlyField()
    file = serializers.FileField(write_only=True, required=False, allow_null=True)

    class Meta:
        model = TaskSubmission
        fields = [
            'id', 'category', 'title', 'description',
            'file', 'file_url', 'submitted_by',
            'project_name', 'project_id',
            'status', 'deadline_date', 'is_late',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']

    def get_file_url(self, obj):
        if obj.file:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.file.url)
            return obj.file.url
        return None

    def to_internal_value(self, data):
        # Handle base64 file upload if provided as base64 string
        if 'file' in data and isinstance(data['file'], str) and ';base64,' in data['file']:
            try:
                format, filestr = data['file'].split(';base64,')
                ext = format.split('/')[-1]
                if 'jpeg' in ext: ext = 'jpg'
                elif 'mpeg' in ext: ext = 'mp3'
                elif 'octet-stream' in ext: ext = 'bin'
                
                decoded_file = base64.b64decode(filestr)
                file_name = f"{uuid.uuid4().hex[:8]}.{ext}"
                data['file'] = ContentFile(decoded_file, name=file_name)
            except Exception:
                raise serializers.ValidationError({"file": "Invalid file data"})
                
        return super().to_internal_value(data)


class SurveyResponseSerializer(serializers.ModelSerializer):
    sysuse = serializers.ReadOnlyField()
    infoqual = serializers.ReadOnlyField()
    interqual = serializers.ReadOnlyField()
    overall_score = serializers.ReadOnlyField()

    class Meta:
        from .models import SurveyResponse
        model = SurveyResponse
        fields = [
            'id',
            # profil
            'respondent_name', 'respondent_age', 'respondent_gender',
            'respondent_education', 'respondent_occupation',
            'respondent_experience', 'module_tested',
            # 19 butir PSSUQ
            'q1','q2','q3','q4','q5','q6','q7','q8',
            'q9','q10','q11','q12','q13','q14','q15',
            'q16','q17','q18','q19',
            # skor turunan
            'sysuse', 'infoqual', 'interqual', 'overall_score',
            'notes', 'submitted_at',
        ]
        read_only_fields = ['id', 'submitted_at']

    def validate(self, data):
        for i in range(1, 20):
            val = data.get(f'q{i}')
            if val is not None and not (1 <= val <= 7):
                raise serializers.ValidationError({f'q{i}': 'Nilai harus antara 1 dan 7.'})
        return data



