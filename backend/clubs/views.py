from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from .models import Club, ClubMembership, Announcement
from .serializers import ClubSerializer, AnnouncementSerializer

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
        announcements = Announcement.objects.filter(club=club).order_by('-is_pinned', '-created_at')[:5]
        announcement_data = AnnouncementSerializer(announcements, many=True).data

        data = serializer.data
        data['announcements'] = announcement_data
        return Response(data)

class JoinClubView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, slug):
        try:
            club = Club.objects.get(slug=slug)
        except Club.DoesNotExist:
            return Response({"error": "Club not found"}, status=status.HTTP_404_NOT_FOUND)

        membership, created = ClubMembership.objects.get_or_create(
            club=club,
            user=request.user,
            defaults={'role': 'member', 'status': 'active'}
        )

        if not created:
            return Response({"message": "You are already a member of this club."}, status=status.HTTP_200_OK)

        return Response({
            "message": f"Successfully joined {club.name}!",
            "role": membership.role
        }, status=status.HTTP_201_CREATED)

class AnnouncementListView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        announcements = Announcement.objects.all().order_by('-is_pinned', '-created_at')[:15]
        serializer = AnnouncementSerializer(announcements, many=True)
        return Response(serializer.data)
