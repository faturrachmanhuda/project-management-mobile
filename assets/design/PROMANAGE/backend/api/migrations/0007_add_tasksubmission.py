from django.db import migrations, models
import uuid

class Migration(migrations.Migration):
    dependencies = [
        ('api', '0004_user_profile_picture'),
    ]

    operations = [
        migrations.CreateModel(
            name='TaskSubmission',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('category', models.CharField(choices=[('engineers', 'Engineers'), ('creation', 'Creation'), ('implementation', 'Implementation')], default='engineers', max_length=50)),
                ('title', models.CharField(max_length=255)),
                ('description', models.TextField(blank=True, null=True)),
                ('file', models.FileField(blank=True, null=True, upload_to='submissions/%Y/%m/%d/')),
                ('submitted_by', models.CharField(max_length=255)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
            ],
            options={
                'db_table': 'task_submissions',
                'ordering': ['-created_at'],
            },
        ),
    ]

