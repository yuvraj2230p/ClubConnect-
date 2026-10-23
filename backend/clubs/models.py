from django.db import models
from django.conf import settings
from django.core.exceptions import ValidationError

class Club(models.Model):
    CATEGORY_CHOICES = [
        ('technical', 'Technical & Coding'),
        ('cultural', 'Cultural & Arts'),
        ('social', 'Social & Leadership'),
        ('robotics', 'Robotics & Hardware'),
        ('sports', 'Sports & Fitness'),
        ('literary', 'Literary & Media'),
    ]

    RECRUITMENT_CHOICES = [
        ('open', 'Recruiting Open'),
        ('closed', 'Recruitment Closed'),
        ('auditions', 'Auditions Ongoing'),
    ]

    name = models.CharField(max_length=150, unique=True)
    slug = models.SlugField(max_length=150, unique=True)
    tagline = models.CharField(max_length=255, blank=True)
    description = models.TextField()
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES, default='technical')
    
    logo_url = models.URLField(max_length=500, blank=True)
    cover_image_url = models.URLField(max_length=500, blank=True)
    
    # Leadership & Administration
    lead = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name='led_clubs')
    president = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name='presided_clubs')
    faculty_coordinator = models.CharField(max_length=150, blank=True, default='Dr. Faculty Lead')
    
    # Recruitment & Admission Details (Configured by Club President)
    recruitment_status = models.CharField(max_length=20, choices=RECRUITMENT_CHOICES, default='open')
    admission_procedure = models.TextField(blank=True, help_text="Detailed steps defined by the President to enter the club")
    registration_start_date = models.DateField(null=True, blank=True)
    registration_end_date = models.DateField(null=True, blank=True)
    registration_link = models.URLField(max_length=500, blank=True)
    recruitment_eligibility = models.CharField(max_length=255, blank=True, default="Open to all GLBITM B.Tech / MCA batches")
    
    instagram_handle = models.CharField(max_length=100, blank=True)
    linkedin_url = models.URLField(max_length=300, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

class ClubMembership(models.Model):
    ROLE_CHOICES = [
        ('member', 'General Member'),
        ('core', 'Core Team'),
        ('domain_head', 'Domain Head'),
        ('vice_lead', 'Vice Coordinator'),
        ('lead', 'President / Lead'),
    ]

    STATUS_CHOICES = [
        ('pending', 'Pending Review'),
        ('active', 'Active Member'),
        ('alumni', 'Alumni'),
        ('rejected', 'Rejected'),
    ]

    club = models.ForeignKey(Club, on_delete=models.CASCADE, related_name='memberships')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='club_memberships')
    role = models.CharField(max_length=30, choices=ROLE_CHOICES, default='member')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='active')
    joined_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('club', 'user')

    def clean(self):
        super().clean()
        # Strictly enforce: A student can only be an active member of ONE club
        if self.status == 'active':
            existing = ClubMembership.objects.filter(user=self.user, status='active')
            if self.pk:
                existing = existing.exclude(pk=self.pk)
            if existing.exists():
                active_club = existing.first().club.name
                raise ValidationError(f"A student can only be a member of ONE club. You are currently an active member of '{active_club}'.")

    def save(self, *args, **kwargs):
        self.clean()
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.user} - {self.club.name} ({self.role})"

class Announcement(models.Model):
    club = models.ForeignKey(Club, on_delete=models.CASCADE, related_name='announcements')
    title = models.CharField(max_length=255)
    content = models.TextField()
    is_pinned = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-is_pinned', '-created_at']

    def __str__(self):
        return f"[{self.club.name}] {self.title}"

class ClubPost(models.Model):
    MEDIA_TYPE_CHOICES = [
        ('image', 'Photo'),
        ('video', 'Video / Reel'),
    ]

    club = models.ForeignKey(Club, on_delete=models.CASCADE, related_name='posts')
    title = models.CharField(max_length=255, blank=True)
    caption = models.TextField()
    media_type = models.CharField(max_length=20, choices=MEDIA_TYPE_CHOICES, default='image')
    media_url = models.CharField(max_length=500)
    video_url = models.CharField(max_length=500, blank=True)
    thumbnail_url = models.CharField(max_length=500, blank=True)
    instagram_post_url = models.URLField(max_length=500, blank=True)
    author = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True)
    likes_count = models.PositiveIntegerField(default=0)
    views_count = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"[{self.club.name}] {self.media_type.upper()}: {self.title or self.caption[:25]}"
