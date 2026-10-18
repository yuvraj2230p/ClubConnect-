from django.db import models
from django.conf import settings

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
    
    lead = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name='led_clubs')
    faculty_coordinator = models.CharField(max_length=150, blank=True, default='Dr. Faculty Lead')
    recruitment_status = models.CharField(max_length=20, choices=RECRUITMENT_CHOICES, default='open')
    
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

    def __str__(self):
        return f"{self.user} - {self.club.name} ({self.role})"

class Announcement(models.Model):
    club = models.ForeignKey(Club, on_delete=models.CASCADE, related_name='announcements')
    title = models.CharField(max_length=255)
    content = models.TextField()
    is_pinned = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"[{self.club.name}] {self.title}"
