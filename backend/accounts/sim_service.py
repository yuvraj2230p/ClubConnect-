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
    def save_avatar_image(cls, adm: str, image_bytes: bytes) -> str:
        """
        Saves student avatar image to both backend static and flutter_web static directories.
        """
        import os
        from django.conf import settings
        from PIL import Image
        import io

        adm_clean = adm.strip().upper()
        avatar_dirs = [
            os.path.join(settings.BASE_DIR, 'static', 'images', 'avatars'),
            os.path.join(settings.BASE_DIR, 'flutter_web', 'static', 'images', 'avatars'),
        ]
        try:
            img = Image.open(io.BytesIO(image_bytes))
            if img.mode != 'RGB':
                img = img.convert('RGB')
            img = img.resize((350, 350), Image.Resampling.LANCZOS)
            for d in avatar_dirs:
                os.makedirs(d, exist_ok=True)
                img.save(os.path.join(d, f"{adm_clean}_avatar.jpg"), format='JPEG', quality=95)
                img.save(os.path.join(d, f"{adm_clean}.jpg"), format='JPEG', quality=95)
            return f"/static/images/avatars/{adm_clean}_avatar.jpg"
        except Exception as e:
            print(f"Error saving avatar image for {adm_clean}: {e}")
            return f"/static/images/avatars/{adm_clean}_avatar.jpg"

    @classmethod
    def ensure_student_avatar(cls, adm: str, full_name: str) -> str:
        """
        Ensures a student avatar file ALWAYS exists on disk.
        If photo is missing, dynamically generates a crisp GL Bajaj branded initials avatar.
        """
        import os
        from django.conf import settings
        from PIL import Image, ImageDraw, ImageFont

        adm_clean = adm.strip().upper()
        avatar_dirs = [
            os.path.join(settings.BASE_DIR, 'static', 'images', 'avatars'),
            os.path.join(settings.BASE_DIR, 'flutter_web', 'static', 'images', 'avatars'),
        ]
        primary_file = os.path.join(avatar_dirs[0], f"{adm_clean}_avatar.jpg")
        if os.path.exists(primary_file) and os.path.getsize(primary_file) > 1000:
            return f"/static/images/avatars/{adm_clean}_avatar.jpg"

        try:
            img = Image.new('RGB', (350, 350), color='#231710') # Warm mocha
            draw = ImageDraw.Draw(img)
            draw.ellipse((15, 15, 335, 335), fill='#B87D4B', outline='#DDB892', width=6)

            parts = full_name.strip().split()
            initials = (parts[0][0] + parts[-1][0]).upper() if len(parts) >= 2 else (parts[0][:2].upper() if parts else 'ST')

            font = None
            for fp in [
                '/System/Library/Fonts/Supplemental/Arial Bold.ttf',
                '/System/Library/Fonts/Helvetica.ttc',
                '/System/Library/Fonts/SFCompact.ttf',
                '/Library/Fonts/Arial.ttf'
            ]:
                if os.path.exists(fp):
                    try:
                        font = ImageFont.truetype(fp, 110)
                        break
                    except Exception:
                        pass
            if not font:
                font = ImageFont.load_default()

            draw.text((175, 160), initials, fill='#FAF6F0', font=font, anchor='mm')

            sub_font = None
            for fp in ['/System/Library/Fonts/Supplemental/Arial.ttf', '/System/Library/Fonts/Helvetica.ttc']:
                if os.path.exists(fp):
                    try:
                        sub_font = ImageFont.truetype(fp, 26)
                        break
                    except Exception:
                        pass
            if sub_font:
                draw.text((175, 255), adm_clean, fill='#FAF6F0', font=sub_font, anchor='mm')

            for d in avatar_dirs:
                os.makedirs(d, exist_ok=True)
                img.save(os.path.join(d, f"{adm_clean}_avatar.jpg"), format='JPEG', quality=95)
                img.save(os.path.join(d, f"{adm_clean}.jpg"), format='JPEG', quality=95)
        except Exception as e:
            print(f"Error generating fallback avatar for {adm_clean}: {e}")

        return f"/static/images/avatars/{adm_clean}_avatar.jpg"

    @classmethod
    def parse_barcode_payload(cls, code_data: str) -> dict:
        """
        Deep barcode inspection: parses JSON, delimiter, key-value, URL, or plain tokens.
        Extracts Admission Number, Full Name, Semester, Department, and embedded Photo!
        """
        import json, re, base64, requests

        res = {}
        code_str = code_data.strip()

        # 1. JSON Payload Check
        if (code_str.startswith('{') and code_str.endswith('}')) or ('{' in code_str and '}' in code_str):
            try:
                json_str = code_str[code_str.find('{'):code_str.rfind('}')+1]
                parsed = json.loads(json_str)
                if isinstance(parsed, dict):
                    for k, v in parsed.items():
                        k_norm = k.lower().replace(' ', '_').replace('-', '_')
                        res[k_norm] = str(v).strip()
            except Exception:
                pass

        # 2. GL Bajaj PI-delimited format (π and &)
        if 'π' in code_str or ('&' in code_str and ('Student' in code_str or 'Admission' in code_str)):
            for item in code_str.split('π'):
                if '&' in item:
                    k, v = item.split('&', 1)
                    res[k.strip().lower().replace(' ', '_')] = v.strip()

        # 3. Key-Value pairs with colons/semicolons/newlines
        if not res and any(sep in code_str for sep in [';', '\n', '|']):
            parts = re.split(r'[;\n|]+', code_str)
            for part in parts:
                if ':' in part:
                    k, v = part.split(':', 1)
                    res[k.strip().lower().replace(' ', '_')] = v.strip()
                elif '=' in part:
                    k, v = part.split('=', 1)
                    res[k.strip().lower().replace(' ', '_')] = v.strip()

        # Extract normalized fields
        adm = (
            res.get('admission_number') or
            res.get('admissionno') or
            res.get('admission_no') or
            res.get('stuadmissionno') or
            res.get('adm_no') or
            res.get('roll_number') or
            res.get('rollno') or
            res.get('roll_no') or
            res.get('student_id') or
            res.get('id')
        )

        # 4. Check if URL param
        if not adm:
            match = re.search(r'[?&](?:id|adm|admission|roll|stuadmissionno)=([A-Za-z0-9_-]+)', code_str, re.IGNORECASE)
            if match:
                adm = match.group(1).strip()

        # 5. Check standard tokens
        if not adm:
            match_token = re.search(r'\b(GLB[0-9A-Za-z]{6,10}|[0-9]{2}[0-9A-Za-z]{6,14})\b', code_str, re.IGNORECASE)
            if match_token:
                adm = match_token.group(1).strip()

        # 6. Fallback clean token
        if not adm:
            cleaned = re.sub(r'^[*#:]+|[*#:]+$', '', code_str)
            if ':' in cleaned:
                cleaned = cleaned.split(':')[-1]
            if '/' in cleaned:
                cleaned = cleaned.split('/')[-1]
            adm = re.sub(r'[^A-Za-z0-9]', '', cleaned)

        adm = adm.upper() if adm else ""

        full_name = res.get('full_name') or res.get('student_name') or res.get('name') or ""
        semester = res.get('semester') or res.get('sem') or ""
        department = res.get('department') or res.get('course_name') or res.get('course') or res.get('branch') or ""
        photo_raw = res.get('photo') or res.get('student_photo') or res.get('avatar') or res.get('image') or ""

        # Process photo if present inside barcode
        avatar_url = None
        if photo_raw and adm:
            try:
                if photo_raw.startswith('http://') or photo_raw.startswith('https://'):
                    resp = requests.get(photo_raw, timeout=5)
                    if resp.status_code == 200 and len(resp.content) > 500:
                        avatar_url = cls.save_avatar_image(adm, resp.content)
                elif 'base64,' in photo_raw or len(photo_raw) > 200:
                    b64 = photo_raw.split('base64,')[-1] if 'base64,' in photo_raw else photo_raw
                    img_bytes = base64.b64decode(b64)
                    if len(img_bytes) > 500:
                        avatar_url = cls.save_avatar_image(adm, img_bytes)
            except Exception as pe:
                print(f"Error parsing embedded barcode photo: {pe}")

        return {
            'admission_number': adm,
            'full_name': full_name.title() if full_name else "",
            'semester': semester,
            'department': department,
            'avatar_url': avatar_url,
            'year': res.get('session') or res.get('year') or "",
            'section': res.get('status') or res.get('section') or "",
        }

    @classmethod
    def extract_admission_number_from_qr(cls, code_data: str) -> str:
        parsed = cls.parse_barcode_payload(code_data)
        return parsed.get('admission_number', '')

    @classmethod
    def verify_with_qr_crosscheck(cls, entered_adm: str, entered_email: str, qr_data: str, card_image=None):
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
        parsed_barcode = cls.parse_barcode_payload(qr_data)
        scanned_adm = parsed_barcode.get('admission_number', '')
        norm_scanned = re.sub(r'[^A-Za-z0-9]', '', scanned_adm).upper()
        norm_entered = re.sub(r'[^A-Za-z0-9]', '', entered_adm_clean).upper()

        if norm_scanned != norm_entered:
            # Tolerant match: check if one contains the other (e.g. GLB25116CN451 vs 25116CN451)
            if not (norm_scanned in norm_entered or norm_entered in norm_scanned):
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
        user = cls.authenticate_id_card_scan(qr_data, card_image=card_image)
        if user:
            user.email = entered_email_clean
            user.save()

        return user, None

    @classmethod
    def authenticate_id_card_scan(cls, code_data: str, card_image=None):
        """
        Extracts Admission Number, Photo, Semester & Name from physical GL Bajaj ID card barcode or QR code.
        If a physical card image is provided, crops student portrait directly from card.
        """
        import os
        from django.conf import settings
        from .id_card_photo_service import IDCardPhotoService

        barcode_details = cls.parse_barcode_payload(code_data)
        adm = barcode_details.get('admission_number') or cls.extract_admission_number_from_qr(code_data)
        if not adm:
            return None

        # 1. Fetch real-time student details from official GL Bajaj portal
        portal_data = cls.fetch_live_glb_portal_student_data(adm)
        sim_data = portal_data or DEMO_SIM_RECORDS.get(adm) or {
            "admission_number": adm,
            "email": f"{adm.lower()}@glbitm.ac.in",
            "full_name": f"Student {adm}",
            "department": "Computer Science & Engineering",
            "year": "2025 Batch",
            "semester": "Sem III",
            "section": "Day Scholar",
            "roll_number": adm,
            "role": "student",
            "is_sim_verified": True
        }

        # Merge barcode details if specific values were provided in the barcode payload
        if barcode_details.get('full_name'):
            sim_data['full_name'] = barcode_details['full_name']
        if barcode_details.get('semester'):
            sim_data['semester'] = barcode_details['semester']
        if barcode_details.get('department'):
            sim_data['department'] = barcode_details['department']
        if barcode_details.get('avatar_url'):
            sim_data['avatar_url'] = barcode_details['avatar_url']

        # 2. If a physical ID card image was supplied, crop student portrait from card
        if card_image:
            try:
                pil_img = IDCardPhotoService.load_image(card_image)
                upright, _, _, _ = IDCardPhotoService.decode_card_barcode_and_orient(pil_img)
                portrait = IDCardPhotoService.crop_student_portrait(upright)
                import io
                buf = io.BytesIO()
                portrait.save(buf, format='JPEG', quality=95)
                sim_data['avatar_url'] = cls.save_avatar_image(adm, buf.getvalue())
            except Exception as ie:
                print(f"Error cropping card portrait: {ie}")

        # Ensure an avatar file always exists on disk (fallback to styled initials avatar)
        if not sim_data.get('avatar_url') or not sim_data['avatar_url'].startswith('/static/'):
            sim_data['avatar_url'] = cls.ensure_student_avatar(adm, sim_data.get('full_name', adm))

        return cls._get_or_create_user_from_sim_data(sim_data)

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
                timeout=6,
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

                    avatar_url = None
                    if student_id:
                        try:
                            photo_url = f"https://glbg.servergi.com:8072/SIMWEBGLB/Services/getImage.ashx?MasterId={student_id}&Category=Student&ImageRefName=Photo"
                            photo_resp = requests.get(photo_url, timeout=6, verify=False)
                            if photo_resp.status_code == 200 and len(photo_resp.content) > 500:
                                avatar_url = cls.save_avatar_image(adm_clean, photo_resp.content)
                        except Exception as photo_err:
                            print(f"Error caching live student photo: {photo_err}")

                    # If student is Day Scholar or photo not found, ensure styled initials avatar exists on disk
                    if not avatar_url:
                        avatar_url = cls.ensure_student_avatar(adm_clean, student_name)

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

            avatar_url = cls.ensure_student_avatar(adm, name)
            record = {
                "admission_number": adm,
                "email": email,
                "full_name": name,
                "department": "Computer Science & Engineering",
                "year": "2025 Batch",
                "semester": "Sem III",
                "section": "Day Scholar",
                "roll_number": adm if adm.isdigit() else "2201920100999",
                "role": "student",
                "avatar_url": avatar_url,
                "is_sim_verified": True
            }

        return cls._get_or_create_user_from_sim_data(record)

    @classmethod
    def _get_or_create_user_from_sim_data(cls, data: dict):
        adm = data['admission_number'].upper()
        email = data['email'].lower()

        # Guarantee avatar exists on disk
        avatar_url = data.get('avatar_url')
        if not avatar_url or not avatar_url.startswith('/static/'):
            avatar_url = cls.ensure_student_avatar(adm, data.get('full_name', adm))

        user, created = User.objects.get_or_create(
            admission_number=adm,
            defaults={
                'email': email,
                'full_name': data.get('full_name', adm),
                'department': data.get('department', 'Engineering'),
                'year': data.get('year', '2025 Batch'),
                'semester': data.get('semester', 'Sem III'),
                'section': data.get('section', 'Day Scholar'),
                'roll_number': data.get('roll_number', adm),
                'role': data.get('role', 'student'),
                'avatar_url': avatar_url,
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
            if avatar_url:
                user.avatar_url = avatar_url
            user.is_sim_verified = True
            user.save()

        # If card image exists for this student on server, auto-crop portrait
        import os
        from django.conf import settings
        from .id_card_photo_service import IDCardPhotoService

        if adm == "25116CN451":
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
