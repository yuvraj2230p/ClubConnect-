import jwt
import datetime
from django.conf import settings
from .models import User

# Simulated GL Bajaj SIM Database Records for immediate out-of-the-box demo
DEMO_SIM_RECORDS = {
    "25116CN451": {
        "admission_number": "25116CN451",
        "email": "25116cn451@glbitm.ac.in",
        "full_name": "YUVRAJ",
        "department": "Computer Science & Information Technology (CSIT)",
        "year": "1st Year",
        "semester": "2nd Semester",
        "section": "CSIT-A",
        "roll_number": "25116CN451",
        "role": "student",
        "avatar_url": "http://127.0.0.1:8000/static/images/yuvraj_avatar.jpg",
        "batch": "2025-29",
        "blood_group": "B+",
        "father_name": "Dwarika Prasad",
        "mother_name": "Kamla Devi",
    },
    "GLB22CSE101": {
        "admission_number": "GLB22CSE101",
        "email": "glb22cse101@glbitm.ac.in",
        "full_name": "Yuvraj Sharma",
        "department": "Computer Science & Engineering",
        "year": "3rd Year",
        "semester": "6th Semester",
        "section": "CSE-B",
        "roll_number": "2201920100101",
        "role": "student",
        "avatar_url": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80",
    },
    "GLB21IT045": {
        "admission_number": "GLB21IT045",
        "email": "glb21it045@glbitm.ac.in",
        "full_name": "Ananya Verma",
        "department": "Information Technology",
        "year": "4th Year",
        "semester": "8th Semester",
        "section": "IT-A",
        "roll_number": "2101920130045",
        "role": "club_lead",
        "avatar_url": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80",
    },
    "GLB23AIML022": {
        "admission_number": "GLB23AIML022",
        "email": "glb23aiml022@glbitm.ac.in",
        "full_name": "Rohan Mehta",
        "department": "Artificial Intelligence & Machine Learning",
        "year": "2nd Year",
        "semester": "4th Semester",
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
    def extract_admission_number_from_qr(cls, code_data: str) -> str:
        import json, re
        code_str = code_data.strip()

        # 1. Check if JSON payload inside QR code
        try:
            parsed = json.loads(code_str)
            if isinstance(parsed, dict):
                identifier = (
                    parsed.get('admission_number') or 
                    parsed.get('admission_no') or 
                    parsed.get('admissionNo') or
                    parsed.get('adm_no') or
                    parsed.get('roll_number') or 
                    parsed.get('roll_no') or 
                    parsed.get('rollno') or 
                    parsed.get('rollNumber') or 
                    parsed.get('enrollment_no') or
                    parsed.get('student_id') or
                    parsed.get('adm') or 
                    parsed.get('id')
                )
                if identifier:
                    return str(identifier).strip().upper()
        except Exception:
            pass

        # 2. Check if URL with query param e.g. ?id= or ?adm=
        if 'http://' in code_str or 'https://' in code_str:
            match = re.search(r'[?&](?:id|adm|admission|roll)=([A-Za-z0-9_-]+)', code_str)
            if match:
                return match.group(1).strip().upper()

        # 3. Strip common barcode framing characters e.g. *GLB22CSE101* or GLBITM:GLB22CSE101
        cleaned = re.sub(r'^[*#:]+|[*#:]+$', '', code_str)
        if ':' in cleaned:
            cleaned = cleaned.split(':')[-1]
        if '/' in cleaned:
            cleaned = cleaned.split('/')[-1]

        return cleaned.strip().upper()

    @classmethod
    def verify_with_qr_crosscheck(cls, entered_adm: str, entered_email: str, qr_data: str):
        import re
        entered_adm_clean = entered_adm.strip().upper()
        entered_email_clean = entered_email.strip().lower()

        # Rule 1: Email domain must be glbitm.ac.in
        if not entered_email_clean.endswith('@glbitm.ac.in'):
            return None, "College email must end with official domain @glbitm.ac.in"

        # Rule 2: Email prefix starts with or contains admission number
        email_prefix = entered_email_clean.split('@')[0]
        norm_adm = re.sub(r'[^A-Za-z0-9]', '', entered_adm_clean).lower()
        norm_prefix = re.sub(r'[^A-Za-z0-9]', '', email_prefix).lower()
        if not (norm_prefix.startswith(norm_adm) or norm_adm in norm_prefix or norm_prefix in norm_adm):
            return None, f"College email prefix ({email_prefix}) must match your Admission Number ({entered_adm_clean})."

        # Rule 3: Cross-check QR code admission number with entered admission number
        scanned_adm = cls.extract_admission_number_from_qr(qr_data)
        norm_scanned = re.sub(r'[^A-Za-z0-9]', '', scanned_adm).upper()
        norm_entered = re.sub(r'[^A-Za-z0-9]', '', entered_adm_clean).upper()

        if norm_scanned != norm_entered:
            return None, f"ID Card Verification Failed: Scanned card belongs to ID [{scanned_adm}], but you entered [{entered_adm_clean}]. Please scan your own physical ID card."

        # Rule 4: Retrieve student from SIM with Name, Photo, Semester & Academic details
        user = cls.authenticate_sim(entered_adm_clean, password="id_card_scanned_token")
        if user:
            user.email = entered_email_clean
            user.save()

        return user, None

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
        cleaned = cls.extract_admission_number_from_qr(code_data)
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
                'semester': data.get('semester', '5th Semester'),
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
            user.semester = data.get('semester', user.semester)
            user.section = data.get('section', user.section)
            user.roll_number = data.get('roll_number', user.roll_number)
            if data.get('avatar_url'):
                user.avatar_url = data.get('avatar_url')
            user.is_sim_verified = True
            user.save()

        # If this is Yuvraj / 25116CN451 and card image exists, ensure photo is extracted from physical ID card
        if adm == "25116CN451":
            import os
            from .id_card_photo_service import IDCardPhotoService
            card_img = os.path.join(settings.BASE_DIR, 'static', 'images', 'yuvraj_card_front.jpg')
            if os.path.exists(card_img):
                try:
                    IDCardPhotoService.process_id_card_and_update_profile(
                        image_input=card_img,
                        user=user,
                        fallback_adm=adm
                    )
                    user.refresh_from_db()
                except Exception as e:
                    pass

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
