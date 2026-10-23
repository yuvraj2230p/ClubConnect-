from rest_framework import serializers
from .models import Club, ClubMembership, Announcement, ClubPost

class ClubPostSerializer(serializers.ModelSerializer):
    club_name = serializers.CharField(source='club.name', read_only=True)
    club_slug = serializers.CharField(source='club.slug', read_only=True)
    author_name = serializers.CharField(source='author.full_name', read_only=True)

    class Meta:
        model = ClubPost
        fields = [
            'id', 'club', 'club_name', 'club_slug', 'title', 'caption',
            'media_type', 'media_url', 'video_url', 'thumbnail_url',
            'instagram_post_url', 'author', 'author_name',
            'likes_count', 'views_count', 'created_at'
        ]

class AnnouncementSerializer(serializers.ModelSerializer):
    club_name = serializers.CharField(source='club.name', read_only=True)
    club_slug = serializers.CharField(source='club.slug', read_only=True)

    class Meta:
        model = Announcement
        fields = ['id', 'club', 'club_name', 'club_slug', 'title', 'content', 'is_pinned', 'created_at']

class ClubMemberSerializer(serializers.ModelSerializer):
    user_name = serializers.CharField(source='user.full_name', read_only=True)
    user_email = serializers.CharField(source='user.email', read_only=True)
    user_admission_number = serializers.CharField(source='user.admission_number', read_only=True)
    user_department = serializers.CharField(source='user.department', read_only=True)
    user_year = serializers.CharField(source='user.year', read_only=True)
    user_avatar = serializers.CharField(source='user.avatar_url', read_only=True)

    class Meta:
        model = ClubMembership
        fields = [
            'id', 'user', 'user_name', 'user_email', 'user_admission_number',
            'user_department', 'user_year', 'user_avatar', 'role', 'status', 'joined_at'
        ]

class ClubSerializer(serializers.ModelSerializer):
    members_count = serializers.SerializerMethodField()
    is_joined = serializers.SerializerMethodField()
    is_president = serializers.SerializerMethodField()
    president_details = serializers.SerializerMethodField()
    posts = ClubPostSerializer(many=True, read_only=True)
    can_join = serializers.SerializerMethodField()
    active_membership_club = serializers.SerializerMethodField()

    class Meta:
        model = Club
        fields = [
            'id', 'name', 'slug', 'tagline', 'description', 'category',
            'logo_url', 'cover_image_url', 'faculty_coordinator',
            'recruitment_status', 'instagram_handle', 'linkedin_url',
            'admission_procedure', 'registration_start_date', 'registration_end_date',
            'registration_link', 'recruitment_eligibility',
            'president', 'president_details', 'is_president',
            'members_count', 'is_joined', 'can_join', 'active_membership_club',
            'posts', 'created_at'
        ]

    def get_members_count(self, obj):
        return obj.memberships.filter(status='active').count()

    def get_is_joined(self, obj):
        user = self.context.get('request', None) and self.context['request'].user
        if user and user.is_authenticated:
            return obj.memberships.filter(user=user, status='active').exists()
        return False

    def get_is_president(self, obj):
        user = self.context.get('request', None) and self.context['request'].user
        if not user or not user.is_authenticated:
            return False
        return (obj.president == user) or (obj.lead == user) or (user.role == 'admin') or user.is_staff

    def get_president_details(self, obj):
        pres = obj.president or obj.lead
        if pres:
            return {
                "name": pres.full_name or pres.admission_number,
                "admission_number": pres.admission_number,
                "email": pres.email,
                "avatar_url": pres.avatar_url,
                "department": pres.department,
            }
        return None

    def get_can_join(self, obj):
        user = self.context.get('request', None) and self.context['request'].user
        if not user or not user.is_authenticated:
            return True
        # A student can only join if they have NO active membership in ANY other club
        active_other = ClubMembership.objects.filter(user=user, status='active').exclude(club=obj).exists()
        return not active_other

    def get_active_membership_club(self, obj):
        user = self.context.get('request', None) and self.context['request'].user
        if not user or not user.is_authenticated:
            return None
        active = ClubMembership.objects.filter(user=user, status='active').first()
        if active:
            return {
                "name": active.club.name,
                "slug": active.club.slug,
                "role": active.role
            }
        return None
