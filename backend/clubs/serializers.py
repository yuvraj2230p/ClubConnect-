from rest_framework import serializers
from .models import Club, ClubMembership, Announcement

class AnnouncementSerializer(serializers.ModelSerializer):
    club_name = serializers.CharField(source='club.name', read_only=True)

    class Meta:
        model = Announcement
        fields = ['id', 'club', 'club_name', 'title', 'content', 'is_pinned', 'created_at']

class ClubSerializer(serializers.ModelSerializer):
    members_count = serializers.SerializerMethodField()
    is_joined = serializers.SerializerMethodField()

    class Meta:
        model = Club
        fields = [
            'id', 'name', 'slug', 'tagline', 'description', 'category',
            'logo_url', 'cover_image_url', 'faculty_coordinator',
            'recruitment_status', 'instagram_handle', 'linkedin_url',
            'members_count', 'is_joined', 'created_at'
        ]

    def get_members_count(self, obj):
        return obj.memberships.filter(status='active').count()

    def get_is_joined(self, obj):
        user = self.context.get('request', None) and self.context['request'].user
        if user and user.is_authenticated:
            return obj.memberships.filter(user=user, status='active').exists()
        return False
