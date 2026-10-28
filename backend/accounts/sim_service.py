import jwt
import datetime
from django.conf import settings
from .models import User

# Simulated GL Bajaj SIM Database Records for immediate out-of-the-box demo
DEMO_SIM_RECORDS = {
    "25116CN451": {
        "admission_number": "25116CN451",
        "email": "25116cn451@glbitm.ac.in",
        "full_name": "Yuvraj",
        "department": "B.TECH.(CSIT)",
        "year": "2025 Batch",
        "semester": "Sem III",
        "section": "Day Scholar",
        "roll_number": "25116CN451",
        "role": "student",
        "avatar_url": "/static/images/avatars/25116CN451_avatar.jpg",
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
        match = re.search(r'[?&](?:id|adm|admission|roll|student|uid)=([A-Za-z0-9_-]+)', code_str, re.IGNORECASE)
        if match:
            return match.group(1).strip().upper()

        # 3. Check for labeled pattern e.g. "Admission No: 25116CN451" or "Roll: 2201920100101"
        match_label = re.search(r'(?:adm(?:ission)?|roll|enrollment)(?:\s+)?(?:no|num|number)?\s*[:=-]\s*([A-Za-z0-9_-]+)', code_str, re.IGNORECASE)
        if match_label:
            return match_label.group(1).strip().upper()

        # 4. Check for standard college admission/roll number token
        match_token = re.search(r'\b(GLB[0-9A-Za-z]{6,10}|[0-9]{2}[0-9A-Za-z]{6,14})\b', code_str, re.IGNORECASE)
        if match_token:
            return match_token.group(1).strip().upper()

        # 5. Strip common barcode framing characters e.g. *GLB22CSE101* or GLBITM:GLB22CSE101
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
            # Tolerant match: check if one contains the other (e.g. GLB25116CN451 vs 25116CN451)
            if not (norm_scanned in norm_entered or norm_entered in norm_scanned):
                # Check if both reference the same student record (e.g. roll number vs admission number)
                user_check = cls.authenticate_sim(entered_adm_clean, password="id_card_scanned_token")
                matched = False
                if user_check:
                    user_roll = re.sub(r'[^A-Za-z0-9]', '', str(user_check.roll_number or '')).upper()
                    user_adm = re.sub(r'[^A-Za-z0-9]', '', str(user_check.admission_number or '')).upper()
                    if norm_scanned == user_roll or norm_scanned == user_adm:
                        matched = True
                if not matched:
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
    def fetch_live_glb_portal_student_data(cls, identifier: str) -> dict:
        """
        Queries the live official GL Bajaj SIM / Hostel Verification portal:
        URL: https://glbg.servergi.com:8072/SIMWEBGLB/Services/WSDataServices.asmx/GetStudentDetailForVerifyHostel
        Returns real student name, course, semester, session, and downloads real official photo!
        """
        import requests, os, re
        from django.conf import settings

        adm_clean = re.sub(r'[^A-Za-z0-9]', '', identifier).upper()
        if not adm_clean:
            return None

        payload = {
            "param": f'[ {{ "FormName" : "frmVerifyHostal", "StuAdmissionNo" : "{adm_clean}" }} ]'
        }
        headers = {
            "Content-Type": "application/json; charset=utf-8",
            "User-Agent": "Mozilla/5.0 (ClubConnect App)"
        }
        try:
            resp = requests.post(
                "https://glbg.servergi.com:8072/SIMWEBGLB/Services/WSDataServices.asmx/GetStudentDetailForVerifyHostel",
                json=payload,
                headers=headers,
                timeout=5,
                verify=False
            )
            if resp.status_code == 200:
                data = resp.json()
                raw_d = data.get('d', '')
                if raw_d and 'Student_Name' in raw_d:
                    parsed = {}
                    for item in raw_d.split('π'):
                        if '&' in item:
                            k, v = item.split('&', 1)
                            parsed[k.strip()] = v.strip()

                    student_id = parsed.get('Student_Id')
                    student_name = parsed.get('Student_Name', adm_clean).title()
                    course_name = parsed.get('Course_name', 'B.TECH.(CSIT)')
                    sem_str = parsed.get('Semester', 'Sem III')
                    session_str = parsed.get('Session', '2025')
                    status_str = parsed.get('Status', 'Day Scholar')

                    avatar_url = f"/static/images/avatars/{adm_clean}_avatar.jpg"
                    if student_id:
                        try:
                            photo_url = f"https://glbg.servergi.com:8072/SIMWEBGLB/Services/getImage.ashx?MasterId={student_id}&Category=Student&ImageRefName=Photo"
                            photo_resp = requests.get(photo_url, timeout=6, verify=False)
                            if photo_resp.status_code == 200 and len(photo_resp.content) > 500:
                                avatar_dir = os.path.join(settings.BASE_DIR, 'static', 'images', 'avatars')
                                os.makedirs(avatar_dir, exist_ok=True)
                                with open(os.path.join(avatar_dir, f"{adm_clean}_avatar.jpg"), 'wb') as f:
                                    f.write(photo_resp.content)
                                # Also copy to flutter_web so immediately live
                                web_avatar_dir = os.path.join(settings.BASE_DIR, 'flutter_web', 'static', 'images', 'avatars')
                                os.makedirs(web_avatar_dir, exist_ok=True)
                                with open(os.path.join(web_avatar_dir, f"{adm_clean}_avatar.jpg"), 'wb') as f:
                                    f.write(photo_resp.content)
                        except Exception as photo_err:
                            print(f"Error caching live student photo: {photo_err}")

                    return {
                        "admission_number": adm_clean,
                        "email": f"{adm_clean.lower()}@glbitm.ac.in",
                        "full_name": student_name,
                        "department": course_name,
                        "semester": sem_str,
                        "year": f"{session_str} Batch",
                        "section": status_str,
                        "roll_number": adm_clean,
                        "avatar_url": avatar_url,
                        "role": "student",
                        "is_sim_verified": True
                    }
        except Exception as e:
            print(f"GL Bajaj Portal query error: {e}")

        return None

    @classmethod
    def _authenticate_simulated(cls, identifier: str, password: str):
        norm_key = identifier.upper()

        # 1. Attempt to fetch real-time student details & official photo from GL Bajaj portal
        portal_data = cls.fetch_live_glb_portal_student_data(norm_key)
        if portal_data:
            return cls._get_or_create_user_from_sim_data(portal_data)

        # 2. Check against pre-seeded records
        record = None
        for k, v in DEMO_SIM_RECORDS.items():
            if k == norm_key or v['email'].lower() == identifier.lower() or v['roll_number'] == identifier:
                record = v
                break

        # 3. If not in demo list, dynamically synthesize verified college student record
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
                "semester": "5th Semester",
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
