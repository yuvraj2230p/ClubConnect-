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
