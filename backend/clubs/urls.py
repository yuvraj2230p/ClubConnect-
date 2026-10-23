from django.urls import path
from .views import (
    ClubListView, ClubDetailView, JoinClubView, LeaveClubView,
    AnnouncementListView, PresidentDashboardView,
    ClubPostListCreateView, ClubPostDeleteView,
    ClubAdmissionSettingsView, ClubAnnouncementCreateView
)

urlpatterns = [
    path('', ClubListView.as_view(), name='club_list'),
    path('announcements/', AnnouncementListView.as_view(), name='announcement_list'),
    path('<slug:slug>/', ClubDetailView.as_view(), name='club_detail'),
    path('<slug:slug>/join/', JoinClubView.as_view(), name='join_club'),
    path('<slug:slug>/leave/', LeaveClubView.as_view(), name='leave_club'),
    
    # President / Admin Club Management Dashboard
    path('<slug:slug>/dashboard/', PresidentDashboardView.as_view(), name='president_dashboard'),
    path('<slug:slug>/posts/', ClubPostListCreateView.as_view(), name='club_posts'),
    path('<slug:slug>/posts/<int:post_id>/', ClubPostDeleteView.as_view(), name='club_post_delete'),
    path('<slug:slug>/announcements/create/', ClubAnnouncementCreateView.as_view(), name='club_announcement_create'),
    path('<slug:slug>/admission-settings/', ClubAdmissionSettingsView.as_view(), name='club_admission_settings'),
]
