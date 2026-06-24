from django.contrib import admin
from .models import User, Project, Work, Activity, ActivityFile


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ['email', 'name', 'nim', 'is_active', 'created_at']
    search_fields = ['email', 'name', 'nim']
    list_filter = ['is_active', 'created_at']
    readonly_fields = ['created_at', 'updated_at']


@admin.register(Project)
class ProjectAdmin(admin.ModelAdmin):
    list_display = ['name', 'status', 'executor', 'start_date', 'end_date']
    search_fields = ['name', 'description', 'user__email']
    list_filter = ['status', 'is_closed', 'created_at']
    readonly_fields = ['created_at', 'updated_at']


@admin.register(Work)
class WorkAdmin(admin.ModelAdmin):

    search_fields = ['name', 'description', 'project__name']
    list_filter = ['created_at']
    readonly_fields = ['created_at', 'updated_at']


@admin.register(Activity)
class ActivityAdmin(admin.ModelAdmin):
    list_display = ['name', 'work', 'executor', 'done', 'execution_time']
    search_fields = ['name', 'work__name', 'executor']
    list_filter = ['done', 'created_at']
    readonly_fields = ['created_at', 'updated_at']


@admin.register(ActivityFile)
class ActivityFileAdmin(admin.ModelAdmin):
    list_display = ['activity', 'file', 'uploaded_at']
    search_fields = ['activity__name']
    list_filter = ['uploaded_at']
