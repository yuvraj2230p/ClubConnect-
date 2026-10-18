from rest_framework import serializers
from .models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            'id', 'admission_number', 'email', 'full_name',
            'department', 'year', 'section', 'roll_number',
            'role', 'avatar_url', 'is_sim_verified', 'sim_last_synced'
        ]

class SIMLoginSerializer(serializers.Serializer):
    identifier = serializers.CharField(
        help_text="College Email (e.g. yuvraj.cse22@glbitm.ac.in) or Admission/Roll Number"
    )
    password = serializers.CharField(
        write_only=True,
        style={'input_type': 'password'},
        help_text="College SIM Portal Password"
    )
