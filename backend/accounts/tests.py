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
