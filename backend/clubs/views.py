from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from .models import Club, ClubMembership, Announcement, ClubPost
from .serializers import (
    ClubSerializer, AnnouncementSerializer,
    ClubPostSerializer, ClubMemberSerializer
)

class ClubListView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        category = request.query_params.get('category')
        search = request.query_params.get('search')
        
        clubs = Club.objects.all().order_by('name')
        if category:
            clubs = clubs.filter(category=category)
        if search:
            clubs = clubs.filter(name__icontains=search)
            
        serializer = ClubSerializer(clubs, many=True, context={'request': request})
        return Response(serializer.data)

class ClubDetailView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, slug):
        try:
            club = Club.objects.get(slug=slug)
        except Club.DoesNotExist:
            return Response({"error": "Club not found"}, status=status.HTTP_404_NOT_FOUND)

        serializer = ClubSerializer(club, context={'request': request})
        announcements = Announcement.objects.filter(club=club).order_by('-is_pinned', '-created_at')[:10]
        announcement_data = AnnouncementSerializer(announcements, many=True).data

        posts = ClubPost.objects.filter(club=club).order_by('-created_at')
        post_data = ClubPostSerializer(posts, many=True).data

        data = serializer.data
        data['announcements'] = announcement_data
        data['posts'] = post_data
        return Response(data)

class JoinClubView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, slug):
        try:
            club = Club.objects.get(slug=slug)
        except Club.DoesNotExist:
            return Response({"error": "Club not found"}, status=status.HTTP_404_NOT_FOUND)

        # 1. Check if already a member of this club
        existing_same = ClubMembership.objects.filter(club=club, user=request.user, status='active').first()
        if existing_same:
            return Response({
                "message": f"You are already an active member of {club.name}.",
                "role": existing_same.role,
                "is_member": True
            }, status=status.HTTP_200_OK)

        # 2. STRICT RULE: A student can only be a member of ONE club
        existing_other = ClubMembership.objects.filter(user=request.user, status='active').exclude(club=club).first()
        if existing_other:
            return Response({
                "error": f"College Policy Violation: A student can only be an active member of ONE club at a time. You are currently an active member of '{existing_other.club.name}'. Please leave '{existing_other.club.name}' before joining {club.name}.",
                "current_club": existing_other.club.name,
                "current_club_slug": existing_other.club.slug,
                "can_join": False
            }, status=status.HTTP_400_BAD_REQUEST)

        # 3. Create the single club membership
        membership, created = ClubMembership.objects.get_or_create(
            club=club,
            user=request.user,
            defaults={'role': 'member', 'status': 'active'}
        )
        if not created and membership.status != 'active':
            membership.status = 'active'
            membership.save()

        return Response({
            "message": f"🎉 Congratulations! You have officially joined {club.name}!",
            "club_name": club.name,
            "role": membership.role,
            "is_member": True
        }, status=status.HTTP_201_CREATED)

class LeaveClubView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, slug):
        try:
            club = Club.objects.get(slug=slug)
        except Club.DoesNotExist:
            return Response({"error": "Club not found"}, status=status.HTTP_404_NOT_FOUND)

        membership = ClubMembership.objects.filter(club=club, user=request.user).first()
        if not membership:
            return Response({"error": f"You are not a member of {club.name}."}, status=status.HTTP_400_BAD_REQUEST)

        membership.delete()
        return Response({
            "message": f"You have successfully left {club.name}. You are now free to join another club.",
            "club_name": club.name,
            "can_join_other": True
        }, status=status.HTTP_200_OK)

# ========================================================
# PRESIDENT / ADMIN DASHBOARD ENDPOINTS
# ========================================================
def is_president_or_admin(user, club):
    if not user or not user.is_authenticated:
        return False
    # Strictly the assigned president or lead of THIS specific club
    if user == club.president or user == club.lead:
        return True
    # Or a superuser/admin
    if user.is_staff or user.role == 'admin':
        return True
    return False

class PresidentDashboardView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, slug):
        try:
            club = Club.objects.get(slug=slug)
        except Club.DoesNotExist:
            return Response({"error": "Club not found"}, status=status.HTTP_404_NOT_FOUND)

        if not is_president_or_admin(request.user, club):
            return Response({
                "error": f"Access denied. Only the President or Admin of '{club.name}' can access this dashboard."
            }, status=status.HTTP_403_FORBIDDEN)

        members = ClubMembership.objects.filter(club=club).order_by('-joined_at')
        posts = ClubPost.objects.filter(club=club).order_by('-created_at')
        announcements = Announcement.objects.filter(club=club).order_by('-is_pinned', '-created_at')

        club_serializer = ClubSerializer(club, context={'request': request})
        members_serializer = ClubMemberSerializer(members, many=True)
        posts_serializer = ClubPostSerializer(posts, many=True)
        announcements_serializer = AnnouncementSerializer(announcements, many=True)

        total_members = members.filter(status='active').count()
        total_photos = posts.filter(media_type='image').count()
        total_videos = posts.filter(media_type='video').count()

        return Response({
            "club": club_serializer.data,
            "president": {
                "name": request.user.full_name or request.user.admission_number,
                "admission_number": request.user.admission_number,
                "email": request.user.email,
                "role": "President & Administrator"
            },
            "analytics": {
                "total_members": total_members,
                "total_posts": posts.count(),
                "total_photos": total_photos,
                "total_videos": total_videos,
                "recruitment_status": club.recruitment_status,
                "registration_start_date": club.registration_start_date,
                "registration_end_date": club.registration_end_date,
            },
            "members": members_serializer.data,
            "posts": posts_serializer.data,
            "announcements": announcements_serializer.data,
        })

class ClubPostListCreateView(APIView):
    def get_permissions(self):
        if self.request.method == 'GET':
            return [AllowAny()]
        return [IsAuthenticated()]

    def get(self, request, slug):
        try:
            club = Club.objects.get(slug=slug)
        except Club.DoesNotExist:
            return Response({"error": "Club not found"}, status=status.HTTP_404_NOT_FOUND)

        posts = ClubPost.objects.filter(club=club).order_by('-created_at')
        serializer = ClubPostSerializer(posts, many=True)
        return Response(serializer.data)

    def post(self, request, slug):
        try:
            club = Club.objects.get(slug=slug)
        except Club.DoesNotExist:
            return Response({"error": "Club not found"}, status=status.HTTP_404_NOT_FOUND)

        if not is_president_or_admin(request.user, club):
            return Response({
                "error": "Only the President or designated Admin of this club can publish posts."
            }, status=status.HTTP_403_FORBIDDEN)

        title = request.data.get('title', '').strip()
        caption = request.data.get('caption', '').strip()
        media_type = request.data.get('media_type', 'image')
        media_url = request.data.get('media_url', '').strip()
        video_url = request.data.get('video_url', '').strip()
        thumbnail_url = request.data.get('thumbnail_url', '').strip()
        instagram_post_url = request.data.get('instagram_post_url', '').strip()

        if not caption:
            return Response({"error": "Caption is required for the post."}, status=status.HTTP_400_BAD_REQUEST)
        if not media_url and not video_url:
            return Response({"error": "Media URL or Video URL is required."}, status=status.HTTP_400_BAD_REQUEST)

        post = ClubPost.objects.create(
            club=club,
            title=title,
            caption=caption,
            media_type=media_type,
            media_url=media_url or thumbnail_url or video_url,
            video_url=video_url,
            thumbnail_url=thumbnail_url or media_url,
            instagram_post_url=instagram_post_url,
            author=request.user,
        )

        return Response(ClubPostSerializer(post).data, status=status.HTTP_201_CREATED)

class ClubPostDeleteView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, slug, post_id):
        try:
            club = Club.objects.get(slug=slug)
            post = ClubPost.objects.get(id=post_id, club=club)
        except (Club.DoesNotExist, ClubPost.DoesNotExist):
            return Response({"error": "Post or Club not found"}, status=status.HTTP_404_NOT_FOUND)

        if not is_president_or_admin(request.user, club):
            return Response({"error": "Unauthorized to delete this post."}, status=status.HTTP_403_FORBIDDEN)

        post.delete()
        return Response({"message": "Post successfully removed."}, status=status.HTTP_200_OK)

class ClubAdmissionSettingsView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request, slug):
        try:
            club = Club.objects.get(slug=slug)
        except Club.DoesNotExist:
            return Response({"error": "Club not found"}, status=status.HTTP_404_NOT_FOUND)

        if not is_president_or_admin(request.user, club):
            return Response({"error": "Only the Club President can modify admission rules and dates."}, status=status.HTTP_403_FORBIDDEN)

        if 'admission_procedure' in request.data:
            club.admission_procedure = request.data['admission_procedure']
        if 'recruitment_status' in request.data:
            club.recruitment_status = request.data['recruitment_status']
        if 'registration_start_date' in request.data:
            club.registration_start_date = request.data['registration_start_date'] or None
        if 'registration_end_date' in request.data:
            club.registration_end_date = request.data['registration_end_date'] or None
        if 'registration_link' in request.data:
            club.registration_link = request.data['registration_link']
        if 'recruitment_eligibility' in request.data:
            club.recruitment_eligibility = request.data['recruitment_eligibility']

        club.save()
        return Response({
            "message": f"Admission procedure & dates updated for {club.name}!",
            "club": ClubSerializer(club, context={'request': request}).data
        })

class ClubAnnouncementCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, slug):
        try:
            club = Club.objects.get(slug=slug)
        except Club.DoesNotExist:
            return Response({"error": "Club not found"}, status=status.HTTP_404_NOT_FOUND)

        if not is_president_or_admin(request.user, club):
            return Response({"error": "Only the Club President can publish announcements."}, status=status.HTTP_403_FORBIDDEN)

        title = request.data.get('title', '').strip()
        content = request.data.get('content', '').strip()
        is_pinned = request.data.get('is_pinned', False)

        if not title or not content:
            return Response({"error": "Title and content are required."}, status=status.HTTP_400_BAD_REQUEST)

        ann = Announcement.objects.create(
            club=club,
            title=title,
            content=content,
            is_pinned=is_pinned
        )
        return Response(AnnouncementSerializer(ann).data, status=status.HTTP_201_CREATED)

class AnnouncementListView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        announcements = Announcement.objects.all().order_by('-is_pinned', '-created_at')[:20]
        serializer = AnnouncementSerializer(announcements, many=True)
        return Response(serializer.data)
