import os
from django.db import models
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.utils.translation import gettext_lazy as _

class UserManager(BaseUserManager):
    def create_user(self, email, admission_number, password=None, **extra_fields):
        if not email and not admission_number:
            raise ValueError(_('Either college email or admission number must be provided'))
        
        email = self.normalize_email(email) if email else ''
        user = self.model(email=email, admission_number=admission_number.strip().upper(), **extra_fields)
        if password:
            user.set_password(password)
        else:
            user.set_unusable_password()
        user.save(using=self._db)
        return user

    def create_superuser(self, email, admission_number='ADMIN001', password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('role', 'admin')

        if extra_fields.get('is_staff') is not True:
            raise ValueError(_('Superuser must have is_staff=True.'))
        if extra_fields.get('is_superuser') is not True:
            raise ValueError(_('Superuser must have is_superuser=True.'))

        return self.create_user(email, admission_number, password, **extra_fields)

class User(AbstractUser):
    ROLE_CHOICES = [
        ('student', 'Student'),
        ('club_lead', 'Club Lead / Coordinator'),
        ('faculty_head', 'Faculty Coordinator'),
        ('admin', 'Administrator'),
    ]

    username = None  # Using admission_number or email as identifier
    admission_number = models.CharField(max_length=40, unique=True, db_index=True)
    email = models.EmailField(_('email address'), unique=True, db_index=True)
    full_name = models.CharField(max_length=150, blank=True)
    
    # College Academic Details
    department = models.CharField(max_length=100, default='Computer Science & Engineering')
    year = models.CharField(max_length=20, default='3rd Year')
    section = models.CharField(max_length=10, blank=True, default='A')
    roll_number = models.CharField(max_length=40, blank=True)
    
    # Profile & Contact
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='student')
    phone_number = models.CharField(max_length=15, blank=True)
    avatar_url = models.URLField(max_length=500, blank=True)
    
    # SIM Authentication Flags
    is_sim_verified = models.BooleanField(default=True)
    sim_last_synced = models.DateTimeField(auto_now=True)

    objects = UserManager()

    USERNAME_FIELD = 'admission_number'
    REQUIRED_FIELDS = ['email']

    def __str__(self):
        return f"{self.full_name or self.admission_number} ({self.admission_number})"
