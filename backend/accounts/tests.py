from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status
from accounts.models import User

class SIMAuthTests(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_sim_login_with_admission_number(self):
        response = self.client.post(reverse('sim_login'), {
            'identifier': 'GLB22CSE101',
            'password': 'anypassword'
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('token', response.data)
        self.assertIn('user', response.data)
        self.assertEqual(response.data['user']['admission_number'], 'GLB22CSE101')
        self.assertEqual(response.data['user']['department'], 'Computer Science & Engineering')
        self.assertTrue(response.data['user']['is_sim_verified'])

    def test_sim_login_with_college_email(self):
        response = self.client.post(reverse('sim_login'), {
            'identifier': 'yuvraj.cse22@glbitm.ac.in',
            'password': 'anypassword'
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('token', response.data)
        self.assertEqual(response.data['user']['email'], 'yuvraj.cse22@glbitm.ac.in')

    def test_showcase_slides_endpoint(self):
        response = self.client.get(reverse('showcase_slides'))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('slides', response.data)
        self.assertGreater(len(response.data['slides']), 0)

    def test_id_card_barcode_login(self):
        # Physical ID card barcode scan
        response = self.client.post(reverse('id_card_scan'), {
            'code_data': '*GLB22CSE101*'
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('token', response.data)
        self.assertEqual(response.data['user']['admission_number'], 'GLB22CSE101')
        self.assertEqual(response.data['auth_method'], 'id_card_scan')

    def test_id_card_qr_code_login(self):
        # Physical ID card QR code JSON scan
        qr_payload = '{"admission_number": "GLB21IT045", "name": "Ananya Verma"}'
        response = self.client.post(reverse('id_card_scan'), {
            'code_data': qr_payload
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('token', response.data)
        self.assertEqual(response.data['user']['admission_number'], 'GLB21IT045')

    def test_verify_student_with_qr_crosscheck_success(self):
        response = self.client.post(reverse('verify_id_card'), {
            'admission_number': 'GLB22CSE101',
            'college_email': 'glb22cse101@glbitm.ac.in',
            'qr_code_data': '*GLB22CSE101*'
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('verified_details', response.data)
        self.assertEqual(response.data['verified_details']['full_name'], 'Yuvraj Sharma')
        self.assertEqual(response.data['verified_details']['semester'], '6th Semester')
        self.assertEqual(response.data['verified_details']['department'], 'Computer Science & Engineering')
        self.assertTrue(response.data['verified_details']['photo_url'].startswith('https://'))

    def test_verify_student_with_qr_crosscheck_mismatch(self):
        response = self.client.post(reverse('verify_id_card'), {
            'admission_number': 'GLB22CSE101',
            'college_email': 'glb22cse101@glbitm.ac.in',
            'qr_code_data': '*GLB21IT045*' # Different student card
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('ID Card Verification Failed', response.data['error'])

    def test_verify_real_student_id_card_qr(self):
        # Real physical GL Bajaj ID card QR URL payload
        real_qr = 'https://glbg.servergi.com:8072/SIMWEBGLB/hostel/vh?id=25116CN451'
        response = self.client.post(reverse('verify_id_card'), {
            'admission_number': '25116CN451',
            'college_email': '25116cn451@glbitm.ac.in',
            'qr_code_data': real_qr
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('verified_details', response.data)
        self.assertEqual(response.data['verified_details']['full_name'], 'YUVRAJ')
        self.assertEqual(response.data['verified_details']['admission_number'], '25116CN451')
        self.assertEqual(response.data['verified_details']['department'], 'Computer Science & Information Technology (CSIT)')
        self.assertEqual(response.data['verified_details']['semester'], '2nd Semester')

    def test_verify_real_student_id_card_barcode(self):
        # Real physical GL Bajaj ID card 1D Barcode (Code 128)
        response = self.client.post(reverse('verify_id_card'), {
            'admission_number': '25116CN451',
            'college_email': '25116cn451@glbitm.ac.in',
            'qr_code_data': '25116CN451'
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['verified_details']['admission_number'], '25116CN451')

    def test_extract_id_card_photo_endpoint_sample(self):
        response = self.client.post(reverse('extract_id_card_photo'), {
            'sample_card': 'yuvraj_front'
        }, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['barcode_detected'])
        self.assertEqual(response.data['admission_number'], '25116CN451')
        self.assertIn('/static/images/avatars/', response.data['avatar_url'])
        self.assertEqual(response.data['full_name'], 'YUVRAJ')

    def test_extract_id_card_photo_endpoint_file_upload(self):
        import os
        from django.conf import settings
        card_path = os.path.join(settings.BASE_DIR, 'static', 'images', 'yuvraj_card_front.jpg')
        if os.path.exists(card_path):
            with open(card_path, 'rb') as f:
                response = self.client.post(reverse('extract_id_card_photo'), {
                    'card_image': f
                }, format='multipart')
            self.assertEqual(response.status_code, status.HTTP_200_OK)
            self.assertEqual(response.data['admission_number'], '25116CN451')
            self.assertTrue(response.data['avatar_url'].endswith('.jpg'))
            self.assertEqual(response.data['verified_details']['full_name'], 'YUVRAJ')
