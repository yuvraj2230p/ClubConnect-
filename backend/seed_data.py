import os
import django
import datetime
from django.utils import timezone

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from accounts.models import User
from clubs.models import Club, ClubMembership, Announcement, ClubPost
from events.models import Event

def seed():
    print("🌱 Seeding GL Bajaj Club Connect: 4 Real Clubs, Dedicated Presidents, Admission Rules & Instagram Media...")

    # 1. Primary Student: YUVRAJ (Real student from physical ID card)
    yuvraj, _ = User.objects.get_or_create(
        admission_number="25116CN451",
        defaults={
            "email": "25116cn451@glbitm.ac.in",
            "full_name": "YUVRAJ",
            "department": "Computer Science & Information Technology",
            "year": "1st Year",
            "section": "CSIT-A",
            "roll_number": "25116CN451",
            "role": "student",
            "avatar_url": "/static/images/yuvraj_avatar.jpg",
            "is_sim_verified": True
        }
    )

    # 2. Four Club Presidents with their official accounts
    presidents_info = {
        'codespace': {
            'adm': '23116CS001',
            'email': '23116cs001@glbitm.ac.in',
            'name': 'Aditya Verma',
            'dept': 'Computer Science & Information Technology',
            'year': '3rd Year',
            'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
        },
        'shrinik': {
            'adm': '230192010045',
            'email': '230192010045@glbitm.ac.in',
            'name': 'Rohan Malhotra',
            'dept': 'Computer Science & Engineering',
            'year': '3rd Year',
            'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80',
        },
        'navrang': {
            'adm': '230192010088',
            'email': '230192010088@glbitm.ac.in',
            'name': 'Simran Kaur',
            'dept': 'Electronics & Communication',
            'year': '3rd Year',
            'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80',
        },
        'vividhata': {
            'adm': '230192013012',
            'email': '230192013012@glbitm.ac.in',
            'name': 'Priya Sharma',
            'dept': 'Information Technology',
            'year': '4th Year',
            'avatar': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&auto=format&fit=crop&q=80',
        }
    }

    presidents = {}
    for key, p in presidents_info.items():
        pres_user, _ = User.objects.get_or_create(
            admission_number=p['adm'],
            defaults={
                'email': p['email'],
                'full_name': p['name'],
                'department': p['dept'],
                'year': p['year'],
                'role': 'club_lead',
                'avatar_url': p['avatar'],
                'is_sim_verified': True
            }
        )
        presidents[key] = pres_user
        print(f"  [President] {p['name']} ({p['adm']}) for {key.upper()}")

    # 3. Four Real Clubs with President & Admission Procedures
    clubs_data = [
        {
            "name": "Code Space Club",
            "slug": "codespace-club",
            "tagline": "Empowering Developers • Open Source • Hackathons",
            "category": "technical",
            "description": "Code Space Club is the premier technical and software development society of the Department of Computer Science & Information Technology (CSIT) and IT at GL Bajaj Institute of Technology & Management. Founded in 2022, we host flagship hackathons, open-source cohorts, competitive programming masterclasses, and project dev sprints.",
            "logo_url": "/static/images/clubs/codespace_logo.png",
            "cover_image_url": "/static/images/clubs/codespace_banner.jpg",
            "president": presidents['codespace'],
            "faculty_coordinator": "Dr. IT & CSIT Faculty Lead",
            "recruitment_status": "open",
            "instagram_handle": "@codespaceclub",
            "registration_start_date": datetime.date(2026, 3, 1),
            "registration_end_date": datetime.date(2026, 3, 18),
            "registration_link": "https://forms.gle/codespace2026intake",
            "recruitment_eligibility": "B.Tech CSIT, IT, CSE & BCA/MCA 1st & 2nd Year Students",
            "admission_procedure": (
                "1. Online Application: Fill out the official CSIT Developer Intake form with your GitHub, HackerRank or LeetCode profile before March 18.\n"
                "2. Algorithmic Screening Round: Complete 3 problem-solving questions on HackerEarth (60 mins) testing logic, arrays, and basic strings.\n"
                "3. Technical & Project Review: In-person walkthrough of your past code repositories, hackathon submissions, or web/app projects with President Aditya Verma & Core Tech Leads.\n"
                "4. Final Onboarding: Selected students receive an official welcome packet and are inducted into their chosen domain (Web3, AI/ML, Full-Stack, or CP)."
            ),
        },
        {
            "name": "Shrinik Club",
            "slug": "shrinik-club",
            "tagline": "Where Technology Meets Culture & Innovation",
            "category": "technical",
            "description": "Shrinik is the leading techno-cultural society operating under the Department of Computer Science and Engineering at GLBITM, Greater Noida. Established on Nov 22, 2021, Shrinik bridges coding battles with creative expression, organizing the acclaimed 'GLB Talks' speaker series, Code with Shrinik hackathons, and technical fests.",
            "logo_url": "/static/images/clubs/shrinik_logo.png",
            "cover_image_url": "/static/images/clubs/shrinik_banner.jpg",
            "president": presidents['shrinik'],
            "faculty_coordinator": "Prof. CSE Coordinator",
            "recruitment_status": "open",
            "instagram_handle": "@shrinik_glbajaj",
            "registration_start_date": datetime.date(2026, 3, 5),
            "registration_end_date": datetime.date(2026, 3, 22),
            "registration_link": "https://forms.gle/shrinik2026induction",
            "recruitment_eligibility": "Open to all engineering branches (CSE, CSIT, IT, AI-ML)",
            "admission_procedure": (
                "1. Induction Form: Submit your application form selecting your preferred wing: Technical, Cultural/Events, or PR & Content.\n"
                "2. Domain Task Challenge: Submit a mini-project (for Tech applicants), a creative pitch or performance video (for Cultural), or a reel/poster draft (for PR/Media).\n"
                "3. Panel Interview: Face-to-face interaction with President Rohan Malhotra and faculty advisors evaluating team chemistry and enthusiasm.\n"
                "4. Induction Ceremony: Formal badge presentation at the annual Parichay Gala."
            ),
        },
        {
            "name": "Navrang Cultural Club",
            "slug": "navrang-club",
            "tagline": "Colors of Expression, Rhythm & Dramatic Soul",
            "category": "cultural",
            "description": "NAVRANG is the official cultural society and artistic heart of GL Bajaj Institute of Technology and Management. Bringing together dance (classical & street), dramatics, vocals, rap, fine arts, and stagecraft, Navrang powers the landmark flashmobs, annual festivals, and talent championships like Tandav and GLBIAN's Got Talent.",
            "logo_url": "/static/images/clubs/navrang_logo.png",
            "cover_image_url": "/static/images/clubs/navrang_banner.jpg",
            "president": presidents['navrang'],
            "faculty_coordinator": "Dr. Cultural Affairs Coordinator",
            "recruitment_status": "auditions",
            "instagram_handle": "@navrang_glbitm",
            "registration_start_date": datetime.date(2026, 2, 28),
            "registration_end_date": datetime.date(2026, 3, 20),
            "registration_link": "https://forms.gle/navrang2026auditions",
            "recruitment_eligibility": "Passionate dancers, actors, vocalists, rappers, musicians & fine artists from all years",
            "admission_procedure": (
                "1. Slot Registration: Reserve your audition time slot online or at the Navrang desk in the Central Lawns.\n"
                "2. Stage-1 Open Auditions: Perform a 2-minute solo piece in front of our domain mentors (Solo Dance, Monologue, Song, or Art Portfolio showcase).\n"
                "3. Stage-2 Ensemble Workshop: Callbacks attend a collaborative 45-minute choreography or street-play workshop to evaluate stage confidence.\n"
                "4. Final Troupe Selection: Final roster declared by President Simran Kaur and Cultural Dean."
            ),
        },
        {
            "name": "Vividhata Club",
            "slug": "vividhata-club",
            "tagline": "Celebrating Diversity, Creativity & Next-Gen Leadership",
            "category": "social",
            "description": "Vividhata Club is an interdisciplinary innovation, creative arts, and student leadership community at GL Bajaj (vividhata.club). Spearheaded by faculty heads Dr. Sanjeev Pippal, Ms. Manisha Bhati, and Ms. Bhumika Nirmohi, Vividhata promotes diversity, collaborative student projects, digital asset management (DAM), and community outreach.",
            "logo_url": "/static/images/clubs/vividhata_logo.png",
            "cover_image_url": "/static/images/clubs/vividhata_banner.jpg",
            "president": presidents['vividhata'],
            "faculty_coordinator": "Dr. Sanjeev Pippal (HOD)",
            "recruitment_status": "open",
            "instagram_handle": "@vividhata.club.glbajaj",
            "registration_start_date": datetime.date(2026, 3, 8),
            "registration_end_date": datetime.date(2026, 3, 26),
            "registration_link": "https://vividhata.club/join",
            "recruitment_eligibility": "All GLBITM undergraduate & postgraduate students passionate about design, media & leadership",
            "admission_procedure": (
                "1. Portal Application: Register on vividhata.club and upload your work portfolio or a 200-word statement on student diversity.\n"
                "2. 24-Hour Creative Case Study: Tackle a real-world prompt in UI/UX design, visual storytelling, photography, or social initiative planning.\n"
                "3. Leadership Interaction: Panel discussion with President Priya Sharma and HOD Dr. Sanjeev Pippal regarding your vision.\n"
                "4. Core Appointment: Official induction into the council during the Next Orbit '26 Summit."
            ),
        },
    ]

    created_clubs = {}
    for c_info in clubs_data:
        club, created = Club.objects.update_or_create(
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
                "president": c_info['president'],
                "lead": c_info['president'],
                "registration_start_date": c_info['registration_start_date'],
                "registration_end_date": c_info['registration_end_date'],
                "registration_link": c_info['registration_link'],
                "recruitment_eligibility": c_info['recruitment_eligibility'],
                "admission_procedure": c_info['admission_procedure'],
            }
        )
        created_clubs[c_info['slug']] = club
        # Also ensure the president is an active member with role='lead'
        ClubMembership.objects.filter(club=club, user=c_info['president']).delete()
        ClubMembership.objects.create(
            club=club,
            user=c_info['president'],
            role='lead',
            status='active'
        )
        action = "Created" if created else "Updated"
        print(f"  [{action}] {club.name} (President: {c_info['president'].full_name})")

    # 4. Strict One-Club Rule for Yuvraj
    # Clear any secondary club memberships so Yuvraj belongs exclusively to Code Space Club
    ClubMembership.objects.filter(user=yuvraj).delete()
    ClubMembership.objects.create(
        club=created_clubs['codespace-club'],
        user=yuvraj,
        role='member',
        status='active'
    )
    print(f"  [Single Membership Enforced] YUVRAJ is exclusively registered in Code Space Club ({created_clubs['codespace-club'].name}).")

    # 5. Instagram Photos & Video Reels Feed for all 4 Clubs
    ClubPost.objects.all().delete()
    posts_data = [
        # Code Space Club Posts
        {
            "club": created_clubs['codespace-club'],
            "title": "HackCodeSpace '25 Recap Reel 🚀",
            "caption": "36 Hours of coding adrenaline, peer-to-peer debugging, and groundbreaking innovation at GL Bajaj! Relive the best moments from our flagship hackathon. #CodeSpaceClub #GLBITM #Hackathon",
            "media_type": "video",
            "media_url": "/static/images/clubs/codespace_reel1_thumb.jpg",
            "thumbnail_url": "/static/images/clubs/codespace_reel1_thumb.jpg",
            "video_url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
            "instagram_post_url": "https://www.instagram.com/reel/C3_codespace_reel/",
            "author": presidents['codespace'],
            "likes_count": 482,
            "views_count": 5420,
        },
        {
            "club": created_clubs['codespace-club'],
            "title": "Aagaz '25 Orientation Bootcamp",
            "caption": "Welcoming 200+ first-year CSIT minds into the world of Git, Open Source, and algorithmic problem solving. The journey has just begun! 💻✨ #Aagaz #CSIT #GLBajaj",
            "media_type": "image",
            "media_url": "/static/images/clubs/codespace_post1.jpg",
            "thumbnail_url": "/static/images/clubs/codespace_post1.jpg",
            "instagram_post_url": "https://www.instagram.com/p/C2_codespace_aagaz/",
            "author": presidents['codespace'],
            "likes_count": 310,
            "views_count": 1890,
        },
        {
            "club": created_clubs['codespace-club'],
            "title": "CodeSprint 4.0 Contest Champions 🏆",
            "caption": "Massive shoutout to our weekly sprint toppers who cracked complex dynamic programming challenges in record time. Keep grinding! #CodeChef #LeetCode #CodeSpace",
            "media_type": "image",
            "media_url": "/static/images/clubs/codespace_post2.jpg",
            "thumbnail_url": "/static/images/clubs/codespace_post2.jpg",
            "instagram_post_url": "https://www.instagram.com/p/C4_codespace_sprint/",
            "author": presidents['codespace'],
            "likes_count": 275,
            "views_count": 1420,
        },

        # Shrinik Club Posts
        {
            "club": created_clubs['shrinik-club'],
            "title": "GLB Talks Season 2 Recap Video 🎙️",
            "caption": "Unfiltered leadership insights, startup playbooks, and tech career advice from Coding Ninjas founder Ankush Singla and industry pioneers! #ShrinikClub #GLBTalks #GLBajaj",
            "media_type": "video",
            "media_url": "/static/images/clubs/shrinik_reel1_thumb.jpg",
            "thumbnail_url": "/static/images/clubs/shrinik_reel1_thumb.jpg",
            "video_url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
            "instagram_post_url": "https://www.instagram.com/reel/C3_shrinik_glbtalks/",
            "author": presidents['shrinik'],
            "likes_count": 625,
            "views_count": 7140,
        },
        {
            "club": created_clubs['shrinik-club'],
            "title": "Code with Shrinik: Speed Debugging Duel",
            "caption": "High-octane bug hunting and algorithmic duels at CSE Department Labs. Over 150 participants pushed their logic to the absolute limit! #CodeWithShrinik #CSE",
            "media_type": "image",
            "media_url": "/static/images/clubs/shrinik_post1.jpg",
            "thumbnail_url": "/static/images/clubs/shrinik_post1.jpg",
            "instagram_post_url": "https://www.instagram.com/p/C2_shrinik_duel/",
            "author": presidents['shrinik'],
            "likes_count": 420,
            "views_count": 2450,
        },
        {
            "club": created_clubs['shrinik-club'],
            "title": "Parichay Techno-Cultural Induction Night",
            "caption": "A celebration of engineering brilliance blended with creative artistic expression. Welcome to our newly inducted core crew! #Parichay #GLBITM",
            "media_type": "image",
            "media_url": "/static/images/clubs/shrinik_post2.jpg",
            "thumbnail_url": "/static/images/clubs/shrinik_post2.jpg",
            "instagram_post_url": "https://www.instagram.com/p/C4_shrinik_parichay/",
            "author": presidents['shrinik'],
            "likes_count": 395,
            "views_count": 2180,
        },

        # Navrang Cultural Club Posts
        {
            "club": created_clubs['navrang-club'],
            "title": "Campus Flashmob 2026 at Central Lawns ⚡",
            "caption": "When the music drops and the entire GL Bajaj campus gathers! 50+ dancers electrifying the central amphitheatre with non-stop beats! 💃🕺 #Navrang #GLBajaj #Flashmob",
            "media_type": "video",
            "media_url": "/static/images/clubs/navrang_reel1_thumb.jpg",
            "thumbnail_url": "/static/images/clubs/navrang_reel1_thumb.jpg",
            "video_url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
            "instagram_post_url": "https://www.instagram.com/reel/C3_navrang_flashmob/",
            "author": presidents['navrang'],
            "likes_count": 1240,
            "views_count": 12890,
        },
        {
            "club": created_clubs['navrang-club'],
            "title": "Tandav Nritya Mahotsav Solo Finals",
            "caption": "Pure grace, fierce classical rhythm, and breathtaking expressions on the Main Audi stage. Kudos to all classical and semi-classical performers! #Tandav #Navrang",
            "media_type": "image",
            "media_url": "/static/images/clubs/navrang_post1.jpg",
            "thumbnail_url": "/static/images/clubs/navrang_post1.jpg",
            "instagram_post_url": "https://www.instagram.com/p/C2_navrang_tandav/",
            "author": presidents['navrang'],
            "likes_count": 780,
            "views_count": 4650,
        },
        {
            "club": created_clubs['navrang-club'],
            "title": "Aawaz Street Play (Nukkad Natak) Showcase",
            "caption": "Powerful dialogue, hard-hitting social awareness, and raw theatrical soul. Navrang dramatic troupe preparing for state youth fest. #Aawaz #NukkadNatak",
            "media_type": "image",
            "media_url": "/static/images/clubs/navrang_post2.jpg",
            "thumbnail_url": "/static/images/clubs/navrang_post2.jpg",
            "instagram_post_url": "https://www.instagram.com/p/C4_navrang_nukkad/",
            "author": presidents['navrang'],
            "likes_count": 615,
            "views_count": 3810,
        },

        # Vividhata Club Posts
        {
            "club": created_clubs['vividhata-club'],
            "title": "Next Orbit '26 Summit Teaser Reel 🌟",
            "caption": "Where student leadership, creative arts, and multidisciplinary design converge into impactful solutions. See what's coming next on vividhata.club! #Vividhata #NextOrbit",
            "media_type": "video",
            "media_url": "/static/images/clubs/vividhata_reel1_thumb.jpg",
            "thumbnail_url": "/static/images/clubs/vividhata_reel1_thumb.jpg",
            "video_url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4",
            "instagram_post_url": "https://www.instagram.com/reel/C3_vividhata_orbit/",
            "author": presidents['vividhata'],
            "likes_count": 345,
            "views_count": 3920,
        },
        {
            "club": created_clubs['vividhata-club'],
            "title": "DAM & UI/UX Design Sprint Masterclass",
            "caption": "Hands-on masterclass in Figma, brand identity design, and digital content curation with our creative leads. #UIUX #DesignSprint #GLBITM",
            "media_type": "image",
            "media_url": "/static/images/clubs/vividhata_post1.jpg",
            "thumbnail_url": "/static/images/clubs/vividhata_post1.jpg",
            "instagram_post_url": "https://www.instagram.com/p/C2_vividhata_dam/",
            "author": presidents['vividhata'],
            "likes_count": 290,
            "views_count": 1650,
        },
        {
            "club": created_clubs['vividhata-club'],
            "title": "Canvas of Diversity: Campus Art Exhibit",
            "caption": "Every engineering branch has creative voices. Proud to showcase student paintings, photography, and creative writing at Audi-2. #DiversityInTech #Vividhata",
            "media_type": "image",
            "media_url": "/static/images/clubs/vividhata_post2.jpg",
            "thumbnail_url": "/static/images/clubs/vividhata_post2.jpg",
            "instagram_post_url": "https://www.instagram.com/p/C4_vividhata_art/",
            "author": presidents['vividhata'],
            "likes_count": 320,
            "views_count": 1940,
        },
    ]

    for p_info in posts_data:
        ClubPost.objects.create(**p_info)
    print(f"  [Media Feed] Created {len(posts_data)} real Instagram posts & video reels across all 4 clubs.")

    # 6. Real Club Announcements
    announcements_data = [
        {
            "club": created_clubs['codespace-club'],
            "title": "💻 HackCodeSpace '26 Registrations Open!",
            "content": "Official announcement from President Aditya Verma: Registrations are officially open until March 18. Follow the 4-step procedure in the club portal to secure your slot.",
            "is_pinned": True
        },
        {
            "club": created_clubs['shrinik-club'],
            "title": "🎙️ GLB Talks Season 3 with Tech Founders",
            "content": "President Rohan Malhotra announces GLB Talks 2026. Join us at the Main Audi. Pre-registration is mandatory for audience passes.",
            "is_pinned": True
        },
        {
            "club": created_clubs['navrang-club'],
            "title": "🎭 Tandav Dance & Street Play Auditions",
            "content": "President Simran Kaur announces that live open auditions for the Tandav dance crew and Nukkad Natak troupe are ongoing at Central Lawns until March 20.",
            "is_pinned": True
        },
        {
            "club": created_clubs['vividhata-club'],
            "title": "🌟 Next Orbit '26 Summit & Core Recruitment",
            "content": "President Priya Sharma invites all creative and engineering students to apply for design, tech, and DAM leads on vividhata.club before March 26.",
            "is_pinned": True
        },
    ]

    for ann in announcements_data:
        Announcement.objects.update_or_create(
            club=ann['club'],
            title=ann['title'],
            defaults={
                "content": ann['content'],
                "is_pinned": ann['is_pinned']
            }
        )

    # 7. Real Club Events
    now = timezone.now()
    events_data = [
        {
            "club": created_clubs['codespace-club'],
            "title": "HackCodeSpace '26: 36-Hour Hackathon",
            "slug": "hackcodespace-2026",
            "description": "The flagship annual hackathon organized by Code Space Club (@codespaceclub). Build real-world solutions across AI/ML, Full-Stack Web, Open Source, and Mobile Dev. ₹1,00,000 in cash prizes + internship opportunities.",
            "category": "hackathon",
            "banner_url": "/static/images/clubs/codespace_event.jpg",
            "venue": "Central Computing Labs, Academic Block 2, GL Bajaj",
            "start_time": now + datetime.timedelta(days=6, hours=10),
            "end_time": now + datetime.timedelta(days=8, hours=18),
            "registration_deadline": now + datetime.timedelta(days=4),
            "registration_fee": 0.00,
            "max_seats": 250,
            "tags": "Hackathon,OpenSource,Coding,Prizes"
        },
        {
            "club": created_clubs['shrinik-club'],
            "title": "GLB Talks: Tech Visionaries & Startup Summit",
            "slug": "glb-talks-2026",
            "description": "Shrinik Club (@shrinik_glbajaj) hosts prominent tech leaders and founders for an insightful keynote on software engineering, product innovation, and career roadmaps.",
            "category": "seminar",
            "banner_url": "/static/images/clubs/shrinik_event.jpg",
            "venue": "Main Auditorium, Academic Block 1, GLBITM",
            "start_time": now + datetime.timedelta(days=10, hours=14),
            "end_time": now + datetime.timedelta(days=10, hours=17),
            "registration_deadline": now + datetime.timedelta(days=8),
            "registration_fee": 0.00,
            "max_seats": 500,
            "tags": "Keynote,Startups,Networking,CSE"
        },
        {
            "club": created_clubs['navrang-club'],
            "title": "Tandav : Intra-College Dance & Rhythm Fest",
            "slug": "tandav-dance-fest-2026",
            "description": "Navrang Cultural Club (@navrang_glbitm) brings the highest-energy stage battle of the year. Solo, duet, and crew categories in classical, contemporary, and hip-hop dance styles.",
            "category": "cultural",
            "banner_url": "/static/images/clubs/navrang_event.jpg",
            "venue": "Open Air Amphitheatre & Main Audi, GLBITM",
            "start_time": now + datetime.timedelta(days=14, hours=16),
            "end_time": now + datetime.timedelta(days=14, hours=21),
            "registration_deadline": now + datetime.timedelta(days=11),
            "registration_fee": 0.00,
            "max_seats": 600,
            "tags": "Dance,Music,Stage,Cultural"
        },
        {
            "club": created_clubs['vividhata-club'],
            "title": "Next Orbit '26: Innovation & Leadership Summit",
            "slug": "next-orbit-2026",
            "description": "Vividhata Club (@vividhata.club.glbajaj) presents Next Orbit '26. Experience cross-disciplinary project showcases, UI/UX sprints, digital asset exhibitions, and student leadership panels.",
            "category": "workshop",
            "banner_url": "/static/images/clubs/vividhata_event.jpg",
            "venue": "Seminar Hall 2, Academic Block 1, GLBITM",
            "start_time": now + datetime.timedelta(days=18, hours=11),
            "end_time": now + datetime.timedelta(days=18, hours=16),
            "registration_deadline": now + datetime.timedelta(days=15),
            "registration_fee": 0.00,
            "max_seats": 200,
            "tags": "Leadership,Design,Innovation,DAM"
        },
    ]

    for e_info in events_data:
        Event.objects.update_or_create(
            slug=e_info['slug'],
            defaults=e_info
        )

    print("✅ Seed complete! All 4 clubs configured with Presidents, strict single-membership rule, admission procedures & Instagram media.")

if __name__ == '__main__':
    seed()
