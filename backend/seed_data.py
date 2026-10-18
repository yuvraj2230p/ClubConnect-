import os
import django
import datetime
from django.utils import timezone

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from accounts.models import User
from clubs.models import Club, ClubMembership, Announcement
from events.models import Event

def seed():
    print("🌱 Seeding GL Bajaj Club Connect database...")

    # 1. Create Coordinator & Student demo accounts
    student, _ = User.objects.get_or_create(
        admission_number="GLB22CSE101",
        defaults={
            "email": "yuvraj.cse22@glbitm.ac.in",
            "full_name": "Yuvraj Sharma",
            "department": "Computer Science & Engineering",
            "year": "3rd Year",
            "section": "CSE-B",
            "roll_number": "2201920100101",
            "role": "student",
            "avatar_url": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80",
            "is_sim_verified": True
        }
    )

    lead, _ = User.objects.get_or_create(
        admission_number="GLB21IT045",
        defaults={
            "email": "ananya.it21@glbitm.ac.in",
            "full_name": "Ananya Verma",
            "department": "Information Technology",
            "year": "4th Year",
            "section": "IT-A",
            "roll_number": "2101920130045",
            "role": "club_lead",
            "avatar_url": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80",
            "is_sim_verified": True
        }
    )

    # 2. Clubs
    clubs_data = [
        {
            "name": "Google Developer Student Club (GDSC)",
            "slug": "gdsc-glb",
            "tagline": "Innovate, Code & Solve Real-World Challenges",
            "category": "technical",
            "description": "GDSC GL Bajaj is a vibrant community of passionate student developers focused on Mobile, Web, Cloud & Machine Learning. We host workshops, solution challenges, and hackathons.",
            "logo_url": "https://images.unsplash.com/photo-1531482615713-2afd69097998?w=300&auto=format&fit=crop&q=80",
            "cover_image_url": "https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=1200&auto=format&fit=crop&q=80",
            "faculty_coordinator": "Dr. V. K. Singh",
            "recruitment_status": "open",
            "instagram_handle": "@gdsc_glbajaj",
        },
        {
            "name": "Rotaract Club of GLBITM",
            "slug": "rotaract-glb",
            "tagline": "Fellowship Through Service & Youth Leadership",
            "category": "social",
            "description": "Affiliated with Rotary International, Rotaract Club focuses on community development, social outreach, tree plantation drives, and student leadership seminars.",
            "logo_url": "https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=300&auto=format&fit=crop&q=80",
            "cover_image_url": "https://images.unsplash.com/photo-1544027993-37dbfe43562a?w=1200&auto=format&fit=crop&q=80",
            "faculty_coordinator": "Prof. S. P. Sharma",
            "recruitment_status": "open",
            "instagram_handle": "@rotaract_glbitm",
        },
        {
            "name": "Verve Cultural & Arts Society",
            "slug": "verve-arts",
            "tagline": "The Soul, Rhythm & Spotlight of GL Bajaj",
            "category": "cultural",
            "description": "Verve is the home of dance, music, theater (Nukkad Natak), and fine arts at GL Bajaj. We represent the college at national youth fests including IITs & DTU.",
            "logo_url": "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=300&auto=format&fit=crop&q=80",
            "cover_image_url": "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=1200&auto=format&fit=crop&q=80",
            "faculty_coordinator": "Dr. Manisha Goel",
            "recruitment_status": "auditions",
            "instagram_handle": "@verve_glbajaj",
        },
        {
            "name": "Droid & Robotics Club",
            "slug": "droid-robotics",
            "tagline": "Engineering the Future with Embedded Bots & IoT",
            "category": "robotics",
            "description": "Droid Club trains students in PCB design, microcontrollers, Arduino, ROS, autonomous line followers, and battle bot engineering.",
            "logo_url": "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=300&auto=format&fit=crop&q=80",
            "cover_image_url": "https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=1200&auto=format&fit=crop&q=80",
            "faculty_coordinator": "Prof. R. K. Agrawal",
            "recruitment_status": "open",
            "instagram_handle": "@droid_glbajaj",
        },
        {
            "name": "Techmaniacs Coding Club",
            "slug": "techmaniacs-club",
            "tagline": "Mastering Algorithms & Competitive Programming",
            "category": "technical",
            "description": "The elite competitive programming society of GL Bajaj. We prepare students for ICPC, Google Summer of Code, LeetCode sprints, and top tier placement rounds.",
            "logo_url": "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=300&auto=format&fit=crop&q=80",
            "cover_image_url": "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=1200&auto=format&fit=crop&q=80",
            "faculty_coordinator": "Dr. Neeraj Kumar",
            "recruitment_status": "open",
            "instagram_handle": "@techmaniacs_glb",
        },
        {
            "name": "Pixels Media & Photography",
            "slug": "pixels-photography",
            "tagline": "Capturing Campus Memories Frame by Frame",
            "category": "literary",
            "description": "The official media and photojournalism body covering every college festival, guest lecture, sporting clash, and campus moment.",
            "logo_url": "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=300&auto=format&fit=crop&q=80",
            "cover_image_url": "https://images.unsplash.com/photo-1452587925148-ce544e77e70d?w=1200&auto=format&fit=crop&q=80",
            "faculty_coordinator": "Prof. Amit Saxena",
            "recruitment_status": "open",
            "instagram_handle": "@pixels_glbajaj",
        }
    ]

    created_clubs = {}
    for c_info in clubs_data:
        club, _ = Club.objects.get_or_create(
            slug=c_info['slug'],
            defaults={
                "name": c_info['name'],
                "tagline": c_info['tagline'],
                "category": c_info['category'],
                "description": c_info['description'],
                "logo_url": c_info['logo_url'],
                "cover_image_url": c_info['cover_image_url'],
                "faculty_coordinator": c_info['faculty_coordinator'],
                "recruitment_status": c_info['recruitment_status'],
                "instagram_handle": c_info['instagram_handle'],
                "lead": lead
            }
        )
        created_clubs[c_info['slug']] = club

    # Add student to GDSC & Verve
    ClubMembership.objects.get_or_create(club=created_clubs['gdsc-glb'], user=student, defaults={'role': 'member', 'status': 'active'})
    ClubMembership.objects.get_or_create(club=created_clubs['techmaniacs-club'], user=student, defaults={'role': 'core', 'status': 'active'})

    # 3. Announcements
    Announcement.objects.get_or_create(
        club=created_clubs['gdsc-glb'],
        title="📢 Google Solution Challenge 2026 Kickoff!",
        defaults={
            "content": "All GL Bajaj students are invited to form teams for the Google Solution Challenge 2026. Mentorship sessions start this Friday at Audi-2.",
            "is_pinned": True
        }
    )
    Announcement.objects.get_or_create(
        club=created_clubs['verve-arts'],
        title="🎭 Annual Street Play (Nukkad Natak) Auditions",
        defaults={
            "content": "Auditions for the street play team will be held on the Central Amphitheatre lawns. All years welcome!",
            "is_pinned": True
        }
    )

    # 4. Events
    now = timezone.now()
    events_data = [
        {
            "club": created_clubs['gdsc-glb'],
            "title": "HackGLB 2026: 36-Hour National Hackathon",
            "slug": "hackglb-2026",
            "description": "GL Bajaj's biggest annual tech hackathon! Solve problems in AI, Web3, Smart Cities, and Healthcare. Prizes worth ₹2,50,000 + Internship opportunities with top sponsors.",
            "category": "hackathon",
            "banner_url": "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=1200&auto=format&fit=crop&q=80",
            "venue": "Audi 1 & Central Computing Lab, Academic Block 2",
            "start_time": now + datetime.timedelta(days=7, hours=10),
            "end_time": now + datetime.timedelta(days=9, hours=18),
            "registration_deadline": now + datetime.timedelta(days=5),
            "registration_fee": 0.00,
            "max_seats": 200,
            "tags": "Hackathon,AI,Web3,Cash Prizes"
        },
        {
            "club": created_clubs['verve-arts'],
            "title": "Yuva Utsav: Inter-College Cultural Spotlight",
            "slug": "yuva-utsav-cultural",
            "description": "An electrifying evening of battle of the bands, western group dance, classical solos, and stand-up comedy.",
            "category": "cultural",
            "banner_url": "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=1200&auto=format&fit=crop&q=80",
            "venue": "Main College Auditorium, GL Bajaj",
            "start_time": now + datetime.timedelta(days=12, hours=16),
            "end_time": now + datetime.timedelta(days=12, hours=21),
            "registration_deadline": now + datetime.timedelta(days=10),
            "registration_fee": 0.00,
            "max_seats": 500,
            "tags": "Music,Dance,Celebrity Night"
        },
        {
            "club": created_clubs['droid-robotics'],
            "title": "RoboArena 4.0: Autonomous Line & Obstacle Race",
            "slug": "roboarena-4",
            "description": "Design and pit your custom autonomous microcontroller bots in a race against time through complex mazes and ramps.",
            "category": "competition",
            "banner_url": "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=1200&auto=format&fit=crop&q=80",
            "venue": "Robotics Lab, Mechanical Block Ground Floor",
            "start_time": now + datetime.timedelta(days=15, hours=11),
            "end_time": now + datetime.timedelta(days=15, hours=17),
            "registration_deadline": now + datetime.timedelta(days=13),
            "registration_fee": 0.00,
            "max_seats": 80,
            "tags": "Robotics,Arduino,Sensors"
        },
        {
            "club": created_clubs['techmaniacs-club'],
            "title": "CodeClash: Algorithmic Sprint on LeetCode & Codeforces",
            "slug": "codeclash-sprint",
            "description": "A 2-hour high-octane competitive programming contest. Test your speed on Dynamic Programming, Graphs, and Greedy heuristics.",
            "category": "hackathon",
            "banner_url": "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=1200&auto=format&fit=crop&q=80",
            "venue": "Online / Computer Lab 3",
            "start_time": now + datetime.timedelta(days=3, hours=19),
            "end_time": now + datetime.timedelta(days=3, hours=21),
            "registration_deadline": now + datetime.timedelta(days=3, hours=18),
            "registration_fee": 0.00,
            "max_seats": 300,
            "tags": "DSA,ICPC,CP,Prizes"
        }
    ]

    for e_info in events_data:
        Event.objects.get_or_create(
            slug=e_info['slug'],
            defaults=e_info
        )

    print("✅ Seed complete! Pre-loaded GL Bajaj clubs, events, announcements & SIM accounts.")

if __name__ == '__main__':
    seed()
