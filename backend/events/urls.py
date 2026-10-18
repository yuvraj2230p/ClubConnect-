from django.urls import path
from .views import EventListView, EventDetailView, RegisterEventView, MyRegistrationsView

urlpatterns = [
    path('', EventListView.as_view(), name='event_list'),
    path('my-tickets/', MyRegistrationsView.as_view(), name='my_registrations'),
    path('<slug:slug>/', EventDetailView.as_view(), name='event_detail'),
    path('<slug:slug>/register/', RegisterEventView.as_view(), name='register_event'),
]
