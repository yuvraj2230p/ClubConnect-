from django.urls import path
from .views import ClubListView, ClubDetailView, JoinClubView, AnnouncementListView

urlpatterns = [
    path('', ClubListView.as_view(), name='club_list'),
    path('announcements/', AnnouncementListView.as_view(), name='announcement_list'),
    path('<slug:slug>/', ClubDetailView.as_view(), name='club_detail'),
    path('<slug:slug>/join/', JoinClubView.as_view(), name='join_club'),
]
