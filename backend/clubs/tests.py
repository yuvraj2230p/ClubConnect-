from django.test import TestCase
from django.urls import reverse
from rest_framework.test import APIClient
from accounts.models import User
from .models import Club, ClubMembership, Announcement, ClubPost
import datetime

class ClubSystemTests(TestCase):
    def setUp(self):
        self.client = APIClient()

        # Users
        self.student = User.objects.create_user(
            email="yuvraj.csit@glbitm.ac.in",
            admission_number="25116CN451",
            full_name="YUVRAJ",
            department="Computer Science & Information Technology",
            role="student"
        )
        self.president1 = User.objects.create_user(
            email="aditya.csit@glbitm.ac.in",
            admission_number="23116CS001",
            full_name="Aditya Verma",
            department="Computer Science & Information Technology",
            role="club_lead"
        )
        self.president2 = User.objects.create_user(
            email="rohan.cse@glbitm.ac.in",
            admission_number="230192010045",
            full_name="Rohan Malhotra",
            department="Computer Science & Engineering",
            role="club_lead"
        )

        # Clubs
        self.club1 = Club.objects.create(
            name="Code Space Club",
            slug="codespace-club",
            tagline="Empowering Developers",
            category="technical",
            instagram_handle="@codespaceclub",
            president=self.president1,
            lead=self.president1,
            admission_procedure="Step 1: Submit form. Step 2: DSA round.",
            registration_start_date=datetime.date(2026, 3, 1),
            registration_end_date=datetime.date(2026, 3, 18),
        )
        self.club2 = Club.objects.create(
            name="Shrinik Club",
            slug="shrinik-club",
            tagline="Technology Meets Culture",
            category="technical",
            instagram_handle="@shrinik_glbajaj",
            president=self.president2,
            lead=self.president2,
            admission_procedure="Step 1: Domain challenge. Step 2: Interview.",
            registration_start_date=datetime.date(2026, 3, 5),
            registration_end_date=datetime.date(2026, 3, 22),
        )

        # Posts
        ClubPost.objects.create(
            club=self.club1,
            title="HackCodeSpace '25 Recap",
            caption="36 Hours of coding adrenaline",
            media_type="video",
            media_url="/static/images/clubs/codespace_reel1_thumb.jpg",
            video_url="https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
            instagram_post_url="https://instagram.com/reel/123",
            author=self.president1
        )

    def test_single_club_membership_enforcement(self):
        """A student can be a member of ONLY ONE club at a time."""
        self.client.force_authenticate(user=self.student)

        # 1. Join Club 1 -> Success
        resp1 = self.client.post('/api/clubs/codespace-club/join/')
        self.assertEqual(resp1.status_code, 201)

        # Verify active membership
        self.assertEqual(ClubMembership.objects.filter(user=self.student, status='active').count(), 1)

        # 2. Try to join Club 2 while in Club 1 -> Must fail with 400
        resp2 = self.client.post('/api/clubs/shrinik-club/join/')
        self.assertEqual(resp2.status_code, 400)
        self.assertIn("College Policy Violation", resp2.data['error'])
        self.assertEqual(resp2.data['current_club'], 'Code Space Club')

        # Count must still be 1
        self.assertEqual(ClubMembership.objects.filter(user=self.student, status='active').count(), 1)

        # 3. Leave Club 1 -> Success
        leave_resp = self.client.post('/api/clubs/codespace-club/leave/')
        self.assertEqual(leave_resp.status_code, 200)
        self.assertEqual(ClubMembership.objects.filter(user=self.student, status='active').count(), 0)

        # 4. Now Join Club 2 -> Success
        resp3 = self.client.post('/api/clubs/shrinik-club/join/')
        self.assertEqual(resp3.status_code, 201)
        self.assertEqual(ClubMembership.objects.filter(user=self.student, status='active').count(), 1)
        self.assertEqual(ClubMembership.objects.get(user=self.student, status='active').club, self.club2)

    def test_president_dashboard_authorization(self):
        """Only the President of the club can access its admin dashboard."""
        # Authenticate as President 1
        self.client.force_authenticate(user=self.president1)
        resp1 = self.client.get('/api/clubs/codespace-club/dashboard/')
        self.assertEqual(resp1.status_code, 200)
        self.assertIn("analytics", resp1.data)
        self.assertIn("members", resp1.data)
        self.assertIn("posts", resp1.data)

        # President 1 tries to access Club 2's dashboard -> Forbidden 403
        resp2 = self.client.get('/api/clubs/shrinik-club/dashboard/')
        self.assertEqual(resp2.status_code, 403)

        # Normal student tries to access Club 1's dashboard -> Forbidden 403
        self.client.force_authenticate(user=self.student)
        resp3 = self.client.get('/api/clubs/codespace-club/dashboard/')
        self.assertEqual(resp3.status_code, 403)

    def test_president_post_creation(self):
        """President can publish photos and video reels to their club dashboard."""
        self.client.force_authenticate(user=self.president1)
        post_data = {
            "title": "New Dev Workshop",
            "caption": "Join us this Friday for an exclusive Docker & Kubernetes session! #DevOps",
            "media_type": "image",
            "media_url": "/static/images/clubs/codespace_post1.jpg",
            "instagram_post_url": "https://instagram.com/p/test456"
        }
        resp = self.client.post('/api/clubs/codespace-club/posts/', post_data)
        self.assertEqual(resp.status_code, 201)
        self.assertEqual(ClubPost.objects.filter(club=self.club1).count(), 2)

    def test_president_admission_settings_update(self):
        """President can update admission procedure and registration dates."""
        self.client.force_authenticate(user=self.president1)
        update_data = {
            "admission_procedure": "Updated 3-Step Procedure: 1. GitHub 2. LeetCode 3. Offline Interview",
            "registration_end_date": "2026-03-31",
            "recruitment_status": "open"
        }
        resp = self.client.patch('/api/clubs/codespace-club/admission-settings/', update_data)
        self.assertEqual(resp.status_code, 200)
        self.club1.refresh_from_db()
        self.assertIn("Updated 3-Step Procedure", self.club1.admission_procedure)
        self.assertEqual(str(self.club1.registration_end_date), "2026-03-31")

    def test_club_detail_includes_posts_and_admission_info(self):
        """Club Detail API returns posts, videos, president details and admission procedures."""
        resp = self.client.get('/api/clubs/codespace-club/')
        self.assertEqual(resp.status_code, 200)
        self.assertIn("admission_procedure", resp.data)
        self.assertIn("registration_start_date", resp.data)
        self.assertIn("registration_end_date", resp.data)
        self.assertIn("president_details", resp.data)
        self.assertEqual(resp.data['president_details']['name'], "Aditya Verma")
        self.assertEqual(len(resp.data['posts']), 1)
        self.assertEqual(resp.data['posts'][0]['media_type'], "video")
