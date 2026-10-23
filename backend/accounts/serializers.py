from rest_framework import serializers
from .models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            'id', 'admission_number', 'email', 'full_name',
            'department', 'year', 'semester', 'section', 'roll_number',
            'role', 'avatar_url', 'is_sim_verified', 'sim_last_synced'
        ]

class IDCardCrossCheckSerializer(serializers.Serializer):
    admission_number = serializers.CharField(
        help_text="Student College Admission Number (e.g. GLB22CSE101 or 2201920100101)"
    )
    college_email = serializers.EmailField(
        help_text="Official College Gmail ID ending in @glbitm.ac.in"
    )
    qr_code_data = serializers.CharField(
        help_text="Decoded Barcode or QR Code string from the physical ID card"
    )

class SIMLoginSerializer(serializers.Serializer):
    identifier = serializers.CharField(
        help_text="College Email (e.g. yuvraj.cse22@glbitm.ac.in) or Admission/Roll Number"
    )
    password = serializers.CharField(
        write_only=True,
        style={'input_type': 'password'},
        help_text="College SIM Portal Password"
    )
