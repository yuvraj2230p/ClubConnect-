from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from .serializers import UserSerializer, SIMLoginSerializer, IDCardCrossCheckSerializer
from .sim_service import SIMAuthService
from .id_card_photo_service import IDCardPhotoService
import os
from django.conf import settings

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

class IDCardScanLoginView(APIView):
    """
    Authenticates students by scanning the barcode or QR code on their physical college ID card.
    Extracts Admission Number or Roll Number and auto-verifies with the SIM database.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        code_data = request.data.get('code_data', '').strip()

        # Check if an image was uploaded instead of direct text
        if not code_data:
            card_img = request.FILES.get('card_image') or request.data.get('card_image')
            if card_img:
                try:
                    pil_img = IDCardPhotoService.load_image(card_img)
                    _, decoded_code, _, _ = IDCardPhotoService.decode_card_barcode_and_orient(pil_img)
                    if decoded_code:
                        code_data = decoded_code.strip()
                except Exception as e:
                    pass

        if not code_data:
            return Response({"error": "No barcode or QR code detected from scan. Please hold your ID card clearly in good lighting."}, status=status.HTTP_400_BAD_REQUEST)

        user = SIMAuthService.authenticate_id_card_scan(code_data)
        if not user:
            return Response(
                {"error": "ID card could not be matched with college records."},
                status=status.HTTP_401_UNAUTHORIZED
            )

        token = SIMAuthService.generate_jwt_for_user(user)
        return Response({
            "message": f"Welcome {user.full_name}! College ID Card verified successfully.",
            "token": token,
            "user": UserSerializer(user).data,
            "auth_method": "id_card_scan"
        }, status=status.HTTP_200_OK)

class VerifyStudentIDCardView(APIView):
    """
    2-Step ID Card Cross-Check:
    1. Validates entered Admission Number & College Email (<adm>@glbitm.ac.in).
    2. Decodes QR code and cross-checks that the scanned card matches the entered Admission Number.
    3. Auto-retrieves Full Name, Photo, Semester & Branch from SIM records!
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = IDCardCrossCheckSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        adm = serializer.validated_data['admission_number']
        email = serializer.validated_data['college_email']
        qr_data = serializer.validated_data['qr_code_data']

        user, error = SIMAuthService.verify_with_qr_crosscheck(adm, email, qr_data)
        if error:
            return Response({"error": error}, status=status.HTTP_400_BAD_REQUEST)

        token = SIMAuthService.generate_jwt_for_user(user)
        return Response({
            "message": f"Verification successful! Welcome {user.full_name}.",
            "token": token,
            "user": UserSerializer(user).data,
            "verified_details": {
                "full_name": user.full_name,
                "photo_url": user.avatar_url,
                "semester": user.semester,
                "year": user.year,
                "department": user.department,
                "admission_number": user.admission_number,
                "email": user.email,
            }
        }, status=status.HTTP_200_OK)

class ExtractIDCardPhotoView(APIView):
    """
    Physical College ID Card Scanner & Photo Extractor:
    1. Reads barcode / QR code to identify student (e.g. 25116CN451).
    2. Auto-corrects rotation if card is tilted or upside-down.
    3. Crops the student's portrait photo directly from the card.
    4. Attaches photo to student's profile & database avatar_url.
    5. Returns updated student profile and image URL.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        card_image = request.FILES.get('card_image')
        card_base64 = request.data.get('card_image_base64')
        sample_card = request.data.get('sample_card')
        fallback_adm = request.data.get('admission_number')

        image_input = None
        if card_image:
            image_input = card_image
        elif card_base64:
            image_input = card_base64
        elif sample_card or not request.data:
            # Use real physical card image stored on server
            default_path = os.path.join(settings.BASE_DIR, 'static', 'images', 'yuvraj_card_front.jpg')
            if os.path.exists(default_path):
                image_input = default_path
            else:
                return Response({"error": "No ID card image provided."}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response({"error": "No ID card image provided. Upload 'card_image' file or 'card_image_base64'."}, status=status.HTTP_400_BAD_REQUEST)

        user = request.user if request.user.is_authenticated else None
        try:
            result = IDCardPhotoService.process_id_card_and_update_profile(
                image_input=image_input,
                user=user,
                fallback_adm=fallback_adm
            )
            # If user was not logged in, generate token if matched user found
            if not user and result.get('user_id'):
                from .models import User
                matched_user = User.objects.filter(id=result['user_id']).first()
                if matched_user:
                    result['token'] = SIMAuthService.generate_jwt_for_user(matched_user)
                    result['user'] = UserSerializer(matched_user).data

            return Response(result, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"error": f"Failed to process ID card: {str(e)}"}, status=status.HTTP_400_BAD_REQUEST)

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
