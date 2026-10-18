import uuid
from django.db import models
from django.conf import settings
from clubs.models import Club

class Event(models.Model):
    CATEGORY_CHOICES = [
        ('hackathon', 'Hackathon & Coding'),
        ('workshop', 'Workshop & Bootcamp'),
        ('cultural', 'Cultural & Fest'),
        ('seminar', 'Guest Lecture & Seminar'),
        ('competition', 'Contest & Challenge'),
        ('sports', 'Sports Meet'),
    ]

    club = models.ForeignKey(Club, on_delete=models.CASCADE, related_name='events')
    title = models.CharField(max_length=200)
    slug = models.SlugField(max_length=200, unique=True)
    description = models.TextField()
    category = models.CharField(max_length=30, choices=CATEGORY_CHOICES, default='hackathon')
    
    banner_url = models.URLField(max_length=500, blank=True)
    venue = models.CharField(max_length=150, default='Main Audi, Academic Block-1, GL Bajaj')
    
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()
    registration_deadline = models.DateTimeField()
    
    registration_fee = models.DecimalField(max_digits=8, decimal_places=2, default=0.00)
    is_registration_open = models.BooleanField(default=True)
    max_seats = models.PositiveIntegerField(default=150)
    tags = models.CharField(max_length=255, blank=True, help_text="Comma-separated tags")

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} ({self.club.name})"

class EventRegistration(models.Model):
    STATUS_CHOICES = [
        ('confirmed', 'Registration Confirmed'),
        ('attended', 'Attended'),
        ('cancelled', 'Cancelled'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    event = models.ForeignKey(Event, on_delete=models.CASCADE, related_name='registrations')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='event_registrations')
    ticket_code = models.CharField(max_length=30, unique=True)
    registered_at = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='confirmed')

    class Meta:
        unique_together = ('event', 'user')

    def save(self, *args, **kwargs):
        if not self.ticket_code:
            self.ticket_code = f"GLB-{uuid.uuid4().hex[:8].upper()}"
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.user.full_name} -> {self.event.title} [{self.ticket_code}]"
