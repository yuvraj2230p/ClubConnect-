from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from .models import Event, EventRegistration
from .serializers import EventSerializer, EventRegistrationSerializer

class EventListView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        category = request.query_params.get('category')
        club_id = request.query_params.get('club')
        
        events = Event.objects.all().order_by('start_time')
        if category:
            events = events.filter(category=category)
        if club_id:
            events = events.filter(club_id=club_id)

        serializer = EventSerializer(events, many=True, context={'request': request})
        return Response(serializer.data)

class EventDetailView(APIView):
    permission_classes = [AllowAny]

    def get(self, request, slug):
        try:
            event = Event.objects.get(slug=slug)
        except Event.DoesNotExist:
            return Response({"error": "Event not found"}, status=status.HTTP_404_NOT_FOUND)

        serializer = EventSerializer(event, context={'request': request})
        return Response(serializer.data)

class RegisterEventView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, slug):
        try:
            event = Event.objects.get(slug=slug)
        except Event.DoesNotExist:
            return Response({"error": "Event not found"}, status=status.HTTP_404_NOT_FOUND)

        if not event.is_registration_open:
            return Response({"error": "Registrations for this event are closed."}, status=status.HTTP_400_BAD_REQUEST)

        current_count = event.registrations.count()
        if current_count >= event.max_seats:
            return Response({"error": "Event seats are fully booked."}, status=status.HTTP_400_BAD_REQUEST)

        registration, created = EventRegistration.objects.get_or_create(
            event=event,
            user=request.user,
            defaults={'status': 'confirmed'}
        )

        if not created:
            return Response({
                "message": "You are already registered for this event.",
                "ticket_code": registration.ticket_code
            }, status=status.HTTP_200_OK)

        serializer = EventRegistrationSerializer(registration)
        return Response({
            "message": f"Successfully registered for {event.title}!",
            "registration": serializer.data
        }, status=status.HTTP_201_CREATED)

class MyRegistrationsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        registrations = EventRegistration.objects.filter(user=request.user).order_by('-registered_at')
        serializer = EventRegistrationSerializer(registrations, many=True)
        return Response(serializer.data)
