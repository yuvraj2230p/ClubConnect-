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
    Returns curated photos of GL Bajaj campus
    for the login screen's dynamic sliding carousel.
    """
    permission_classes = [AllowAny]

    def get(self, request):
        slides = [
            {
                "id": 1,
                "title": "G.L. Bajaj Institute of Technology & Management",
                "subtitle": "Gate 1 & Main Academic Campus, Greater Noida",
                "tag": "GL Bajaj Campus",
                "image_url": "assets/images/campus/glb_gate1.webp",
                "badge": "Gate 1",
                "is_asset": True
            },
            {
                "id": 2,
                "title": "Innovation & Green Academic Environment",
                "subtitle": "Home to 30+ Thriving Student Clubs & Societies",
                "tag": "Campus Life",
                "image_url": "assets/images/campus/glb_academic.webp",
                "badge": "Academic Block 1",
                "is_asset": True
            },
            {
                "id": 3,
                "title": "Club Connect: The Student Society Hub",
                "subtitle": "Explore Technical, Cultural, Robotics & Sports Clubs",
                "tag": "Societies & Fests",
                "image_url": "assets/images/campus/glb_panorama.jpg",
                "badge": "Campus Panorama",
                "is_asset": True
            }
        ]
        return Response({"slides": slides})
