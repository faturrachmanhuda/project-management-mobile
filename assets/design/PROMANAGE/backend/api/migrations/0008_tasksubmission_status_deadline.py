from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0006_rename_uploaded_by_tasksubmission_submitted_by_and_more'),
        ('api', '0007_add_tasksubmission'),
    ]

    operations = [
        migrations.AddField(
            model_name='tasksubmission',
            name='status',
            field=models.CharField(choices=[('draft', 'Draft'), ('submitted', 'Submitted'), ('reviewed', 'Reviewed'), ('approved', 'Approved'), ('rejected', 'Rejected')], default='submitted', max_length=20),
        ),
        migrations.AddField(
            model_name='tasksubmission',
            name='deadline_date',
            field=models.DateField(blank=True, null=True),
        ),
        migrations.AddField(
            model_name='tasksubmission',
            name='updated_at',
            field=models.DateTimeField(auto_now=True),
        ),
    ]
