import jwt
import datetime
from django.conf import settings
from .models import User

# Simulated GL Bajaj SIM Database Records for immediate out-of-the-box demo
DEMO_SIM_RECORDS = {
    "GLB22CSE101": {
        "admission_number": "GLB22CSE101",
        "email": "yuvraj.cse22@glbitm.ac.in",
        "full_name": "Yuvraj Sharma",
        "department": "Computer Science & Engineering",
        "year": "3rd Year",
        "section": "CSE-B",
        "roll_number": "2201920100101",
        "role": "student",
        "avatar_url": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80",
    },
    "GLB21IT045": {
        "admission_number": "GLB21IT045",
        "email": "ananya.it21@glbitm.ac.in",
        "full_name": "Ananya Verma",
        "department": "Information Technology",
        "year": "4th Year",
        "section": "IT-A",
        "roll_number": "2101920130045",
        "role": "club_lead",
        "avatar_url": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80",
    },
    "GLB23AIML022": {
        "admission_number": "GLB23AIML022",
        "email": "rohan.aiml23@glbitm.ac.in",
        "full_name": "Rohan Mehta",
        "department": "Artificial Intelligence & Machine Learning",
        "year": "2nd Year",
        "section": "AIML-1",
        "roll_number": "2301920150022",
        "role": "student",
        "avatar_url": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80",
    }
}

class SIMAuthService:
    """
    Extensible SIM (Student Information Management) Authentication Service for GL Bajaj.
    Supports:
    1. Direct live API connector to college ERP / SIM portal (when college API endpoint is provided)
    2. Intelligent SIM Simulation mode (validates any college roll number / college email,
       auto-provisions user profile from credentials)
    """

    @classmethod
    def authenticate_sim(cls, identifier: str, password: str):
        """
        identifier: College Email (e.g. user@glbitm.ac.in) OR Admission Number / Roll Number
        password: SIM Portal password
        """
        identifier_clean = identifier.strip()
        
        # 1. Check if live SIM ERP API is configured
        sim_api_url = getattr(settings, 'GL_BAJAJ_SIM_API_URL', None)
        if sim_api_url:
            return cls._authenticate_live_sim_api(identifier_clean, password, sim_api_url)

        # 2. Simulated SIM authentication:
        return cls._authenticate_simulated(identifier_clean, password)

    @classmethod
    def authenticate_id_card_scan(cls, code_data: str):
        """
        Extracts Admission Number or Roll Number from physical GL Bajaj ID card barcode or QR code.
        Format samples supported:
        - Plain Admission No: "GLB22CSE101"
        - University Roll No: "2201920100101"
        - Prefixed barcode: "GLBITM:GLB22CSE101" or "ID:GLB21IT045"
        - QR Code JSON: {"admission_number": "GLB22CSE101", ...}
        - QR URL: "https://glbitm.ac.in/student/verify?id=GLB22CSE101"
        """
        import json, re
        code_str = code_data.strip()

        # 1. Check if JSON payload inside QR code
        try:
            parsed = json.loads(code_str)
            if isinstance(parsed, dict):
                identifier = parsed.get('admission_number') or parsed.get('roll_number') or parsed.get('email')
                if identifier:
                    return cls.authenticate_sim(str(identifier), password="id_card_scanned_token")
        except Exception:
            pass

        # 2. Check if URL with query param e.g. ?id= or ?adm=
        if 'http://' in code_str or 'https://' in code_str:
            match = re.search(r'[?&](?:id|adm|admission|roll)=([A-Za-z0-9_-]+)', code_str)
            if match:
                identifier = match.group(1)
                return cls.authenticate_sim(identifier, password="id_card_scanned_token")

        # 3. Strip common barcode framing characters e.g. *GLB22CSE101* or GLBITM:GLB22CSE101
        cleaned = re.sub(r'^[*#:]+|[*#:]+$', '', code_str)
        if ':' in cleaned:
            cleaned = cleaned.split(':')[-1]
        if '/' in cleaned:
            cleaned = cleaned.split('/')[-1]

        return cls.authenticate_sim(cleaned, password="id_card_scanned_token")

    @classmethod
    def _authenticate_live_sim_api(cls, identifier: str, password: str, api_url: str):
        import requests
        try:
            resp = requests.post(
                f"{api_url}/api/student/verify",
                json={"identifier": identifier, "password": password},
                timeout=5
            )
            if resp.status_code == 200:
                data = resp.json()
                return cls._get_or_create_user_from_sim_data(data)
        except Exception as e:
            print(f"Live SIM API Error: {e}")
        return None

    @classmethod
    def _authenticate_simulated(cls, identifier: str, password: str):
        # Check against pre-seeded records first
        norm_key = identifier.upper()
        record = None

        for k, v in DEMO_SIM_RECORDS.items():
            if k == norm_key or v['email'].lower() == identifier.lower() or v['roll_number'] == identifier:
                record = v
                break

        # If not in demo list, dynamically synthesize verified college student record
        # from the college email or admission number format!
        if not record:
            if '@' in identifier:
                email = identifier.lower()
                username_part = email.split('@')[0]
                adm = f"GLB{username_part[:8].upper()}"
                name = username_part.replace('.', ' ').title()
            else:
                adm = identifier.upper()
                name = f"Student {adm}"
                email = f"{adm.lower()}@glbitm.ac.in"

            record = {
                "admission_number": adm,
                "email": email,
                "full_name": name,
                "department": "Computer Science & Engineering",
                "year": "3rd Year",
                "section": "A",
                "roll_number": adm if adm.isdigit() else "2201920100999",
                "role": "student",
                "avatar_url": "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&auto=format&fit=crop&q=80",
            }

        return cls._get_or_create_user_from_sim_data(record)

    @classmethod
    def _get_or_create_user_from_sim_data(cls, data: dict):
        adm = data['admission_number'].upper()
        email = data['email'].lower()

        user, created = User.objects.get_or_create(
            admission_number=adm,
            defaults={
                'email': email,
                'full_name': data.get('full_name', adm),
                'department': data.get('department', 'Engineering'),
                'year': data.get('year', '1st Year'),
                'section': data.get('section', 'A'),
                'roll_number': data.get('roll_number', adm),
                'role': data.get('role', 'student'),
                'avatar_url': data.get('avatar_url', ''),
                'is_sim_verified': True,
            }
        )

        if not created:
            # Refresh user attributes from SIM
            user.full_name = data.get('full_name', user.full_name)
            user.department = data.get('department', user.department)
            user.year = data.get('year', user.year)
            user.is_sim_verified = True
            user.save()

        return user

    @classmethod
    def generate_jwt_for_user(cls, user: User) -> str:
        payload = {
            'user_id': user.id,
            'admission_number': user.admission_number,
            'email': user.email,
            'role': user.role,
            'exp': datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(days=30),
            'iat': datetime.datetime.now(datetime.timezone.utc)
        }
        return jwt.encode(payload, settings.SECRET_KEY, algorithm='HS256')
