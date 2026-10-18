from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from .serializers import UserSerializer, SIMLoginSerializer
from .sim_service import SIMAuthService

class SIMLoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = SIMLoginSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        identifier = serializer.validated_data['identifier']
        password = serializer.validated_data['password']

        user = SIMAuthService.authenticate_sim(identifier, password)
        if not user:
            return Response(
                {"error": "Invalid SIM credentials or student not found in GL Bajaj database."},
                status=status.HTTP_401_UNAUTHORIZED
            )

        token = SIMAuthService.generate_jwt_for_user(user)
        return Response({
            "message": "Welcome to Club Connect! SIM Authentication successful.",
            "token": token,
            "user": UserSerializer(user).data
        }, status=status.HTTP_200_OK)

class CurrentUserView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)

class ShowcaseSlidesView(APIView):
    """
    Returns curated high-resolution photos of GL Bajaj campus & active student clubs
    for the login screen's dynamic sliding carousel.
    """
    permission_classes = [AllowAny]

    def get(self, request):
        slides = [
            {
                "id": 1,
                "title": "GL Bajaj Institute of Technology & Management",
                "subtitle": "Home to 30+ Thriving Student Clubs & Societies",
                "tag": "Campus Life",
                "image_url": "https://images.unsplash.com/photo-1562774053-701939374585?w=1200&auto=format&fit=crop&q=80",
                "badge": "GL Bajaj Greater Noida"
            },
            {
                "id": 2,
                "title": "Google Developer Student Club (GDSC)",
                "subtitle": "Hackathons, Cloud Jams & Open-Source Projects",
                "tag": "Tech Club",
                "image_url": "https://images.unsplash.com/photo-1531482615713-2afd69097998?w=1200&auto=format&fit=crop&q=80",
                "badge": "Active Community"
            },
            {
                "id": 3,
                "title": "Verve Cultural Club & Street Plays",
                "subtitle": "Expressing Creativity through Dance, Drama & Music",
                "tag": "Cultural Fest",
                "image_url": "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=1200&auto=format&fit=crop&q=80",
                "badge": "Annual Fest"
            },
            {
                "id": 4,
                "title": "Rotaract Club of GLBITM",
                "subtitle": "Youth Leadership, Social Impact & Community Drives",
                "tag": "Social Welfare",
                "image_url": "https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=1200&auto=format&fit=crop&q=80",
                "badge": "Leadership"
            },
            {
                "id": 5,
                "title": "Droid & Robotics Club",
                "subtitle": "Autonomous Bots, Drone Arenas & AI Hardware",
                "tag": "Robotics",
                "image_url": "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=1200&auto=format&fit=crop&q=80",
                "badge": "Innovation Lab"
            }
        ]
        return Response({"slides": slides})
