from rest_framework import serializers
from .models import Event, EventRegistration

class EventSerializer(serializers.ModelSerializer):
    club_name = serializers.CharField(source='club.name', read_only=True)
    club_logo = serializers.CharField(source='club.logo_url', read_only=True)
    registrations_count = serializers.SerializerMethodField()
    is_registered = serializers.SerializerMethodField()

    class Meta:
        model = Event
        fields = [
            'id', 'title', 'slug', 'description', 'category', 'banner_url',
            'venue', 'start_time', 'end_time', 'registration_deadline',
            'registration_fee', 'is_registration_open', 'max_seats',
            'tags', 'club', 'club_name', 'club_logo', 'registrations_count',
            'is_registered', 'created_at'
        ]

    def get_registrations_count(self, obj):
        return obj.registrations.count()

    def get_is_registered(self, obj):
        user = self.context.get('request', None) and self.context['request'].user
        if user and user.is_authenticated:
            return obj.registrations.filter(user=user).exists()
        return False

class EventRegistrationSerializer(serializers.ModelSerializer):
    event_title = serializers.CharField(source='event.title', read_only=True)
    event_banner = serializers.CharField(source='event.banner_url', read_only=True)
    event_venue = serializers.CharField(source='event.venue', read_only=True)
    event_start_time = serializers.DateTimeField(source='event.start_time', read_only=True)

    class Meta:
        model = EventRegistration
        fields = [
            'id', 'event', 'event_title', 'event_banner', 'event_venue',
            'event_start_time', 'ticket_code', 'registered_at', 'status'
        ]
