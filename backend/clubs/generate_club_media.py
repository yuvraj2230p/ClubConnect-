import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

BACKEND_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'static', 'images', 'clubs'))
MOBILE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', 'mobile', 'assets', 'images', 'clubs'))
ARTIFACT_DIR = '/Users/yuvraj/.gemini/antigravity/brain/40528263-f0d6-41f1-9606-7fccec33c630'
CAMPUS_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', 'mobile', 'assets', 'images', 'campus'))

os.makedirs(BACKEND_DIR, exist_ok=True)
os.makedirs(MOBILE_DIR, exist_ok=True)

FONT_BLACK = '/System/Library/Fonts/Supplemental/Arial Black.ttf'
FONT_BOLD = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'
FONT_REGULAR = '/System/Library/Fonts/Supplemental/Arial.ttf'

def get_font(path, size):
    try:
        return ImageFont.truetype(path, size)
    except:
        return ImageFont.load_default()

def save_media(img, filename):
    p1 = os.path.join(BACKEND_DIR, filename)
    p2 = os.path.join(MOBILE_DIR, filename)
    p3 = os.path.join(ARTIFACT_DIR, filename)
    img.save(p1, quality=95)
    img.save(p2, quality=95)
    try:
        img.save(p3, quality=95)
    except:
        pass
    print(f"Generated media: {filename}")

def draw_video_overlay(draw, width, height, duration_text="0:45", views_text="4.2K views"):
    # Semi-transparent dark circular play button in center
    cx, cy = width // 2, height // 2
    r = 38
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(0, 0, 0, 180), outline=(255, 255, 255, 220), width=3)
    # Triangle play icon
    draw.polygon([(cx - 10, cy - 18), (cx - 10, cy + 18), (cx + 18, cy)], fill='#ffffff')

    # Video / Reel tag top-left
    draw.rounded_rectangle([16, 16, 120, 44], radius=14, fill=(0, 0, 0, 200), outline=(255, 255, 255, 120), width=1)
    f_badge = get_font(FONT_BOLD, 12)
    draw.text((68, 30), "▶ REEL", fill='#ffffff', font=f_badge, anchor='mm')

    # Duration pill bottom-right
    draw.rounded_rectangle([width - 80, height - 38, width - 16, height - 16], radius=10, fill=(0, 0, 0, 210))
    f_dur = get_font(FONT_BOLD, 12)
    draw.text((width - 48, height - 27), duration_text, fill='#ffffff', font=f_dur, anchor='mm')

    # Views pill bottom-left
    draw.rounded_rectangle([16, height - 38, 120, height - 16], radius=10, fill=(0, 0, 0, 180))
    draw.text((68, height - 27), f"👁 {views_text}", fill='#f3f4f6', font=f_dur, anchor='mm')

# -------------------------------------------------------------
# 1. CODE SPACE CLUB (@codespaceclub)
# -------------------------------------------------------------
def make_codespace_media():
    # Reel 1 (600x600)
    img = Image.new('RGB', (600, 600), '#060a14')
    try:
        camp = Image.open(os.path.join(CAMPUS_DIR, 'glb_academic.webp')).resize((600, 600)).convert('RGB')
        camp = camp.filter(ImageFilter.GaussianBlur(3))
        img = Image.blend(camp, img, 0.65)
    except:
        pass
    draw = ImageDraw.Draw(img)
    # Neon tech grid
    for x in range(0, 600, 40):
        draw.line([(x, 0), (x, 600)], fill=(0, 242, 254, 30), width=1)
    for y in range(0, 600, 40):
        draw.line([(0, y), (600, y)], fill=(0, 242, 254, 30), width=1)
    
    draw.text((300, 110), "HACKCODESPACE '25 RECAP", fill='#00f2fe', font=get_font(FONT_BLACK, 28), anchor='mm')
    draw.text((300, 145), "36 Hours of Non-stop Adrenaline & Code", fill='#e0f2fe', font=get_font(FONT_BOLD, 15), anchor='mm')
    draw.text((300, 480), "Department of CSIT & IT • GLBITM", fill='#38bdf8', font=get_font(FONT_BOLD, 14), anchor='mm')
    draw.text((300, 510), "Watch on @codespaceclub", fill='#f43f5e', font=get_font(FONT_BOLD, 15), anchor='mm')
    draw_video_overlay(draw, 600, 600, duration_text="0:58", views_text="5.4K views")
    save_media(img, "codespace_reel1_thumb.jpg")

    # Post 1: Orientation Bootcamp
    p1 = Image.new('RGB', (600, 600), '#0b132b')
    draw = ImageDraw.Draw(p1)
    draw.rectangle([0, 0, 600, 10], fill='#00f2fe')
    draw.rounded_rectangle([30, 30, 570, 570], radius=20, outline='#38bdf8', width=2)
    draw.text((300, 90), "CODE SPACE CLUB PRESENTS", fill='#38bdf8', font=get_font(FONT_BOLD, 16), anchor='mm')
    draw.text((300, 160), "AAGAZ '25", fill='#ffffff', font=get_font(FONT_BLACK, 46), anchor='mm')
    draw.text((300, 220), "FRESHERS CODING BOOTCAMP", fill='#00f2fe', font=get_font(FONT_BOLD, 22), anchor='mm')
    draw.rounded_rectangle([80, 270, 520, 400], radius=16, fill='#1c2541', outline='#48cae4', width=2)
    draw.text((300, 315), "200+ CSIT Students Trained", fill='#ffffff', font=get_font(FONT_BLACK, 22), anchor='mm')
    draw.text((300, 355), "Git • Web Dev • Open Source • Data Structures", fill='#a5f3fc', font=get_font(FONT_BOLD, 14), anchor='mm')
    draw.text((300, 470), "📍 Central Audi & CS Labs | GLBITM", fill='#cbd5e1', font=get_font(FONT_REGULAR, 16), anchor='mm')
    draw.text((300, 520), "Instagram: @codespaceclub", fill='#f43f5e', font=get_font(FONT_BOLD, 18), anchor='mm')
    save_media(p1, "codespace_post1.jpg")

    # Post 2: Sprint Contest
    p2 = Image.new('RGB', (600, 600), '#0d1b2a')
    draw = ImageDraw.Draw(p2)
    draw.rectangle([0, 0, 600, 10], fill='#fbbf24')
    draw.rounded_rectangle([30, 30, 570, 570], radius=20, outline='#fbbf24', width=2)
    draw.text((300, 90), "WEEKLY ALGORITHMIC DUEL", fill='#fbbf24', font=get_font(FONT_BOLD, 16), anchor='mm')
    draw.text((300, 160), "CODESPRINT 4.0", fill='#ffffff', font=get_font(FONT_BLACK, 44), anchor='mm')
    draw.text((300, 220), "TOPPERS OF THE WEEK", fill='#38bdf8', font=get_font(FONT_BOLD, 22), anchor='mm')
    draw.rounded_rectangle([80, 270, 520, 420], radius=16, fill='#1b263b', outline='#fbbf24', width=2)
    draw.text((300, 315), "🥇 1st: Aryan (CSIT 2nd Yr)", fill='#fbbf24', font=get_font(FONT_BLACK, 20), anchor='mm')
    draw.text((300, 350), "🥈 2nd: Shreya (IT 3rd Yr)", fill='#e2e8f0', font=get_font(FONT_BOLD, 18), anchor='mm')
    draw.text((300, 385), "🥉 3rd: Yuvraj (CSIT 1st Yr)", fill='#38bdf8', font=get_font(FONT_BOLD, 18), anchor='mm')
    draw.text((300, 480), "Join next sprint on CodeChef & LeetCode", fill='#94a3b8', font=get_font(FONT_REGULAR, 15), anchor='mm')
    draw.text((300, 520), "Official Handle: @codespaceclub", fill='#f43f5e', font=get_font(FONT_BOLD, 18), anchor='mm')
    save_media(p2, "codespace_post2.jpg")

# -------------------------------------------------------------
# 2. SHRINIK CLUB (@shrinik_glbajaj)
# -------------------------------------------------------------
def make_shrinik_media():
    # Reel 1 (600x600)
    img = Image.new('RGB', (600, 600), '#180d2b')
    try:
        camp = Image.open(os.path.join(CAMPUS_DIR, 'glb_panorama.jpg')).resize((600, 600)).convert('RGB')
        camp = camp.filter(ImageFilter.GaussianBlur(3))
        img = Image.blend(camp, img, 0.65)
    except:
        pass
    draw = ImageDraw.Draw(img)
    draw.text((300, 110), "GLB TALKS SEASON 2 RECAP", fill='#f59e0b', font=get_font(FONT_BLACK, 28), anchor='mm')
    draw.text((300, 145), "Keynote Insights from Tech Startup Founders", fill='#f3e8ff', font=get_font(FONT_BOLD, 15), anchor='mm')
    draw.text((300, 480), "Dept. of Computer Science & Engineering | GLBITM", fill='#c084fc', font=get_font(FONT_BOLD, 14), anchor='mm')
    draw.text((300, 510), "Follow @shrinik_glbajaj", fill='#ec4899', font=get_font(FONT_BOLD, 15), anchor='mm')
    draw_video_overlay(draw, 600, 600, duration_text="1:12", views_text="7.1K views")
    save_media(img, "shrinik_reel1_thumb.jpg")

    # Post 1: Speed Debugging Duel
    p1 = Image.new('RGB', (600, 600), '#1c1033')
    draw = ImageDraw.Draw(p1)
    draw.rectangle([0, 0, 600, 10], fill='#8b5cf6')
    draw.rounded_rectangle([30, 30, 570, 570], radius=20, outline='#8b5cf6', width=2)
    draw.text((300, 90), "SHRINIK CSE PRESENTS", fill='#c084fc', font=get_font(FONT_BOLD, 16), anchor='mm')
    draw.text((300, 160), "CODE WITH SHRINIK", fill='#ffffff', font=get_font(FONT_BLACK, 42), anchor='mm')
    draw.text((300, 220), "SPEED DEBUGGING ARENA", fill='#f59e0b', font=get_font(FONT_BOLD, 22), anchor='mm')
    draw.rounded_rectangle([80, 270, 520, 400], radius=16, fill='#2e1a52', outline='#a78bfa', width=2)
    draw.text((300, 315), "150+ Contestants Battled Live", fill='#ffffff', font=get_font(FONT_BLACK, 22), anchor='mm')
    draw.text((300, 355), "C++ • Java • Python • Logic Puzzles", fill='#e9d5ff', font=get_font(FONT_BOLD, 15), anchor='mm')
    draw.text((300, 470), "📍 CSE Labs, Academic Block-1 | GLBITM", fill='#cbd5e1', font=get_font(FONT_REGULAR, 16), anchor='mm')
    draw.text((300, 520), "Instagram: @shrinik_glbajaj", fill='#ec4899', font=get_font(FONT_BOLD, 18), anchor='mm')
    save_media(p1, "shrinik_post1.jpg")

    # Post 2: Parichay Induction
    p2 = Image.new('RGB', (600, 600), '#150a26')
    draw = ImageDraw.Draw(p2)
    draw.rectangle([0, 0, 600, 10], fill='#f59e0b')
    draw.rounded_rectangle([30, 30, 570, 570], radius=20, outline='#f59e0b', width=2)
    draw.text((300, 90), "TECHNO-CULTURAL NIGHT", fill='#f59e0b', font=get_font(FONT_BOLD, 16), anchor='mm')
    draw.text((300, 160), "PARICHAY 2025", fill='#ffffff', font=get_font(FONT_BLACK, 44), anchor='mm')
    draw.text((300, 220), "WELCOME NEW CORE SQUAD", fill='#c084fc', font=get_font(FONT_BOLD, 22), anchor='mm')
    draw.rounded_rectangle([80, 270, 520, 400], radius=16, fill='#251242', outline='#f59e0b', width=2)
    draw.text((300, 315), "Tech • Cultural • Media • PR Domains", fill='#f59e0b', font=get_font(FONT_BLACK, 20), anchor='mm')
    draw.text((300, 355), "Fostering Innovation Across All Years", fill='#e2e8f0', font=get_font(FONT_BOLD, 16), anchor='mm')
    draw.text((300, 470), "GL Bajaj Institute of Technology & Management", fill='#94a3b8', font=get_font(FONT_REGULAR, 15), anchor='mm')
    draw.text((300, 520), "Official Instagram: @shrinik_glbajaj", fill='#ec4899', font=get_font(FONT_BOLD, 18), anchor='mm')
    save_media(p2, "shrinik_post2.jpg")

# -------------------------------------------------------------
# 3. NAVRANG CLUB (@navrang_glbitm)
# -------------------------------------------------------------
def make_navrang_media():
    # Reel 1 (600x600)
    img = Image.new('RGB', (600, 600), '#22060b')
    try:
        camp = Image.open(os.path.join(CAMPUS_DIR, 'glb_gate1.webp')).resize((600, 600)).convert('RGB')
        camp = camp.filter(ImageFilter.GaussianBlur(3))
        img = Image.blend(camp, img, 0.65)
    except:
        pass
    draw = ImageDraw.Draw(img)
    draw.text((300, 110), "CAMPUS FLASHMOB 2026 ⚡", fill='#f59e0b', font=get_font(FONT_BLACK, 28), anchor='mm')
    draw.text((300, 145), "50+ Dancers Igniting the Central Lawns!", fill='#ffe4e6', font=get_font(FONT_BOLD, 15), anchor='mm')
    draw.text((300, 480), "Official Cultural Society of GLBITM", fill='#f87171', font=get_font(FONT_BOLD, 14), anchor='mm')
    draw.text((300, 510), "Reel on @navrang_glbitm", fill='#f43f5e', font=get_font(FONT_BOLD, 15), anchor='mm')
    draw_video_overlay(draw, 600, 600, duration_text="1:30", views_text="12.8K views")
    save_media(img, "navrang_reel1_thumb.jpg")

    # Post 1: Tandav Finals
    p1 = Image.new('RGB', (600, 600), '#1f0408')
    draw = ImageDraw.Draw(p1)
    draw.rectangle([0, 0, 600, 10], fill='#ef4444')
    draw.rounded_rectangle([30, 30, 570, 570], radius=20, outline='#ef4444', width=2)
    draw.text((300, 90), "NAVRANG CULTURAL CLUB PRESENTS", fill='#fca5a5', font=get_font(FONT_BOLD, 16), anchor='mm')
    draw.text((300, 160), "TANDAV NRITYA", fill='#ffffff', font=get_font(FONT_BLACK, 44), anchor='mm')
    draw.text((300, 220), "SOLO & GROUP DANCE FINALS", fill='#fbbf24', font=get_font(FONT_BOLD, 22), anchor='mm')
    draw.rounded_rectangle([80, 270, 520, 400], radius=16, fill='#3b0b12', outline='#f87171', width=2)
    draw.text((300, 315), "Classical • Hip-Hop • Contemporary", fill='#fbbf24', font=get_font(FONT_BLACK, 20), anchor='mm')
    draw.text((300, 355), "Electrifying Stage Battles at Main Audi", fill='#fee2e2', font=get_font(FONT_BOLD, 16), anchor='mm')
    draw.text((300, 470), "Open to all branches | GLBITM Greater Noida", fill='#cbd5e1', font=get_font(FONT_REGULAR, 15), anchor='mm')
    draw.text((300, 520), "Instagram: @navrang_glbitm", fill='#f43f5e', font=get_font(FONT_BOLD, 18), anchor='mm')
    save_media(p1, "navrang_post1.jpg")

    # Post 2: Aawaz Street Play
    p2 = Image.new('RGB', (600, 600), '#1a0307')
    draw = ImageDraw.Draw(p2)
    draw.rectangle([0, 0, 600, 10], fill='#f59e0b')
    draw.rounded_rectangle([30, 30, 570, 570], radius=20, outline='#f59e0b', width=2)
    draw.text((300, 90), "DRAMATICS & THEATRE WING", fill='#f59e0b', font=get_font(FONT_BOLD, 16), anchor='mm')
    draw.text((300, 160), "AAWAZ : NUKKAD NATAK", fill='#ffffff', font=get_font(FONT_BLACK, 38), anchor='mm')
    draw.text((300, 220), "SOCIAL REFORM STREET PLAY", fill='#f87171', font=get_font(FONT_BOLD, 22), anchor='mm')
    draw.rounded_rectangle([80, 270, 520, 400], radius=16, fill='#2e080f', outline='#f59e0b', width=2)
    draw.text((300, 315), "Inter-College Fest Preparations", fill='#ffffff', font=get_font(FONT_BLACK, 22), anchor='mm')
    draw.text((300, 355), "Raw Energy • Voice Projection • Social Change", fill='#fee2e2', font=get_font(FONT_BOLD, 15), anchor='mm')
    draw.text((300, 470), "Auditions ongoing at Central Lawns", fill='#cbd5e1', font=get_font(FONT_REGULAR, 16), anchor='mm')
    draw.text((300, 520), "Follow @navrang_glbitm", fill='#f43f5e', font=get_font(FONT_BOLD, 18), anchor='mm')
    save_media(p2, "navrang_post2.jpg")

# -------------------------------------------------------------
# 4. VIVIDHATA CLUB (@vividhata.club.glbajaj)
# -------------------------------------------------------------
def make_vividhata_media():
    # Reel 1 (600x600)
    img = Image.new('RGB', (600, 600), '#021812')
    try:
        camp = Image.open(os.path.join(CAMPUS_DIR, 'glb_academic.webp')).resize((600, 600)).convert('RGB')
        camp = camp.filter(ImageFilter.GaussianBlur(3))
        img = Image.blend(camp, img, 0.65)
    except:
        pass
    draw = ImageDraw.Draw(img)
    draw.text((300, 110), "NEXT ORBIT '26 TEASER REEL 🌟", fill='#10b981', font=get_font(FONT_BLACK, 26), anchor='mm')
    draw.text((300, 145), "Student Innovation, Leadership & Art Summit", fill='#d1fae5', font=get_font(FONT_BOLD, 15), anchor='mm')
    draw.text((300, 480), "GL Bajaj Interdisciplinary Society • vividhata.club", fill='#34d399', font=get_font(FONT_BOLD, 14), anchor='mm')
    draw.text((300, 510), "Instagram: @vividhata.club.glbajaj", fill='#fb7185', font=get_font(FONT_BOLD, 15), anchor='mm')
    draw_video_overlay(draw, 600, 600, duration_text="0:52", views_text="3.9K views")
    save_media(img, "vividhata_reel1_thumb.jpg")

    # Post 1: DAM & UI/UX Workshop
    p1 = Image.new('RGB', (600, 600), '#032018')
    draw = ImageDraw.Draw(p1)
    draw.rectangle([0, 0, 600, 10], fill='#10b981')
    draw.rounded_rectangle([30, 30, 570, 570], radius=20, outline='#10b981', width=2)
    draw.text((300, 90), "VIVIDHATA DIGITAL ASSETS WING", fill='#6ee7b7', font=get_font(FONT_BOLD, 15), anchor='mm')
    draw.text((300, 160), "DAM & UI/UX MASTERCLASS", fill='#ffffff', font=get_font(FONT_BLACK, 38), anchor='mm')
    draw.text((300, 220), "DESIGN SPRINT 2026", fill='#f97316', font=get_font(FONT_BOLD, 22), anchor='mm')
    draw.rounded_rectangle([80, 270, 520, 400], radius=16, fill='#063529', outline='#34d399', width=2)
    draw.text((300, 315), "Figma • Brand Identity • Asset Curation", fill='#ffffff', font=get_font(FONT_BLACK, 20), anchor='mm')
    draw.text((300, 355), "Mentored by Industry Creative Leads", fill='#a7f3d0', font=get_font(FONT_BOLD, 16), anchor='mm')
    draw.text((300, 470), "📍 Audi-2, Block 1 | HOD Dr. Sanjeev Pippal", fill='#cbd5e1', font=get_font(FONT_REGULAR, 15), anchor='mm')
    draw.text((300, 520), "Portal: vividhata.club", fill='#f97316', font=get_font(FONT_BOLD, 18), anchor='mm')
    save_media(p1, "vividhata_post1.jpg")

    # Post 2: Art & Diversity
    p2 = Image.new('RGB', (600, 600), '#021a14')
    draw = ImageDraw.Draw(p2)
    draw.rectangle([0, 0, 600, 10], fill='#f97316')
    draw.rounded_rectangle([30, 30, 570, 570], radius=20, outline='#f97316', width=2)
    draw.text((300, 90), "CELEBRATING CAMPUS VOICES", fill='#f97316', font=get_font(FONT_BOLD, 16), anchor='mm')
    draw.text((300, 160), "CANVAS OF DIVERSITY", fill='#ffffff', font=get_font(FONT_BLACK, 40), anchor='mm')
    draw.text((300, 220), "ANNUAL ART & ESSAY EXHIBIT", fill='#10b981', font=get_font(FONT_BOLD, 22), anchor='mm')
    draw.rounded_rectangle([80, 270, 520, 400], radius=16, fill='#072e23', outline='#f97316', width=2)
    draw.text((300, 315), "Painting • Poetry • Photojournalism", fill='#f97316', font=get_font(FONT_BLACK, 22), anchor='mm')
    draw.text((300, 355), "Uniting Engineers Through Creativity", fill='#d1fae5', font=get_font(FONT_BOLD, 16), anchor='mm')
    draw.text((300, 470), "GL Bajaj Institute of Technology & Management", fill='#cbd5e1', font=get_font(FONT_REGULAR, 15), anchor='mm')
    draw.text((300, 520), "Instagram: @vividhata.club.glbajaj", fill='#fb7185', font=get_font(FONT_BOLD, 18), anchor='mm')
    save_media(p2, "vividhata_post2.jpg")

if __name__ == '__main__':
    print("Generating photos & video/reel assets from Instagram for all 4 clubs...")
    make_codespace_media()
    make_shrinik_media()
    make_navrang_media()
    make_vividhata_media()
    print("All media assets generated successfully!")
