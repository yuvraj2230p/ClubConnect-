import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

# Directories
BACKEND_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'static', 'images', 'clubs'))
MOBILE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', 'mobile', 'assets', 'images', 'clubs'))
CAMPUS_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', 'mobile', 'assets', 'images', 'campus'))

os.makedirs(BACKEND_DIR, exist_ok=True)
os.makedirs(MOBILE_DIR, exist_ok=True)

# Fonts
FONT_BOLD = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'
FONT_BLACK = '/System/Library/Fonts/Supplemental/Arial Black.ttf'
FONT_REGULAR = '/System/Library/Fonts/Supplemental/Arial.ttf'

def get_font(path, size):
    try:
        return ImageFont.truetype(path, size)
    except:
        return ImageFont.load_default()

def save_image(img, filename):
    p1 = os.path.join(BACKEND_DIR, filename)
    p2 = os.path.join(MOBILE_DIR, filename)
    img.save(p1, quality=95)
    img.save(p2, quality=95)
    print(f"Saved: {filename} -> {p1}")

# -------------------------------------------------------------
# 1. CODE SPACE CLUB (@codespaceclub)
# -------------------------------------------------------------
def generate_codespace():
    # Logo (512x512)
    img = Image.new('RGB', (512, 512), '#0a0f1d')
    draw = ImageDraw.Draw(img)
    
    # Gradient rings / glow
    for r in range(230, 160, -8):
        alpha = int(30 * (1 - (r - 160) / 70))
        draw.ellipse([256 - r, 256 - r, 256 + r, 256 + r], outline=(0, 242, 254, alpha), width=3)
    
    # Outer hexagon / circle
    draw.ellipse([256 - 180, 256 - 180, 256 + 180, 256 + 180], outline='#00f2fe', width=6)
    draw.ellipse([256 - 165, 256 - 165, 256 + 165, 256 + 165], outline='#1e293b', width=4)

    # Brackets icon </>
    f_icon = get_font(FONT_BLACK, 110)
    draw.text((256, 175), "</>", fill='#00f2fe', font=f_icon, anchor='mm')

    # Club Title
    f_title = get_font(FONT_BLACK, 38)
    draw.text((256, 270), "CODE SPACE", fill='#ffffff', font=f_title, anchor='mm')
    
    f_sub = get_font(FONT_BOLD, 18)
    draw.text((256, 310), "CSIT & IT DEPT • GLBITM", fill='#38bdf8', font=f_sub, anchor='mm')

    f_ig = get_font(FONT_BOLD, 17)
    draw.text((256, 355), "@codespaceclub", fill='#f43f5e', font=f_ig, anchor='mm')

    save_image(img, "codespace_logo.png")

    # Banner (1200x600)
    banner = Image.new('RGB', (1200, 600), '#060a14')
    # Try load campus academic block as subtle background
    try:
        camp = Image.open(os.path.join(CAMPUS_DIR, 'glb_academic.webp')).resize((1200, 600)).convert('RGB')
        camp = camp.filter(ImageFilter.GaussianBlur(6))
        # Darken
        banner = Image.blend(camp, banner, 0.75)
    except Exception as e:
        pass

    draw = ImageDraw.Draw(banner)
    # Tech grid lines
    for x in range(0, 1200, 60):
        draw.line([(x, 0), (x, 600)], fill=(0, 242, 254, 25), width=1)
    for y in range(0, 600, 60):
        draw.line([(0, y), (1200, y)], fill=(0, 242, 254, 25), width=1)

    # Accent color bar
    draw.rectangle([0, 0, 1200, 8], fill='#00f2fe')

    # Badge Pill
    draw.rounded_rectangle([70, 70, 420, 115], radius=22, fill=(15, 23, 42, 220), outline='#00f2fe', width=2)
    f_pill = get_font(FONT_BOLD, 18)
    draw.text((245, 92), "💻 OFFICIAL TECHNICAL CLUB", fill='#00f2fe', font=f_pill, anchor='mm')

    # Header
    f_main = get_font(FONT_BLACK, 68)
    draw.text((70, 195), "CODE SPACE CLUB", fill='#ffffff', font=f_main)

    f_tag = get_font(FONT_BOLD, 28)
    draw.text((70, 275), "Empowering Developers • Open Source • Hackathons", fill='#38bdf8', font=f_tag)

    f_desc = get_font(FONT_REGULAR, 20)
    draw.text((70, 325), "Department of Computer Science & Information Technology (CSIT) | GLBITM", fill='#94a3b8', font=f_desc)

    # Stats / Highlights box
    draw.rounded_rectangle([70, 385, 1130, 520], radius=18, fill=(10, 15, 30, 230), outline=(56, 189, 248, 120), width=2)
    
    f_h1 = get_font(FONT_BLACK, 28)
    f_h2 = get_font(FONT_REGULAR, 16)
    
    # 3 cols
    cols = [
        ("HackCodeSpace '26", "Flagship 36H Hackathon", 240),
        ("Aagaz Orientation", "Freshers Coding League", 600),
        ("@codespaceclub", "Instagram Official Hub", 960)
    ]
    for title, sub, xpos in cols:
        draw.text((xpos, 430), title, fill='#00f2fe', font=f_h1, anchor='mm')
        draw.text((xpos, 470), sub, fill='#cbd5e1', font=f_h2, anchor='mm')

    save_image(banner, "codespace_banner.jpg")

    # Event Poster (800x800)
    evt = Image.new('RGB', (800, 800), '#080d1a')
    draw = ImageDraw.Draw(evt)
    draw.rectangle([0, 0, 800, 10], fill='#00f2fe')
    draw.rounded_rectangle([40, 40, 760, 760], radius=24, outline='#00f2fe', width=3)
    
    draw.text((400, 110), "GL BAJAJ CSIT PRESENTS", fill='#94a3b8', font=get_font(FONT_BOLD, 20), anchor='mm')
    draw.text((400, 175), "HACK CODE SPACE", fill='#ffffff', font=get_font(FONT_BLACK, 52), anchor='mm')
    draw.text((400, 240), "36-HOUR ANNUAL HACKATHON", fill='#00f2fe', font=get_font(FONT_BOLD, 26), anchor='mm')
    
    draw.rounded_rectangle([150, 310, 650, 440], radius=18, fill='#0f172a', outline='#38bdf8', width=2)
    draw.text((400, 355), "PRIZE POOL: ₹1,00,000", fill='#fbbf24', font=get_font(FONT_BLACK, 34), anchor='mm')
    draw.text((400, 400), "Web3 • AI/ML • Cloud • Open Innovation", fill='#e2e8f0', font=get_font(FONT_BOLD, 18), anchor='mm')

    draw.text((400, 520), "📅 Upcoming Spring Edition  |  📍 GLBITM Audi & Labs", fill='#ffffff', font=get_font(FONT_BOLD, 20), anchor='mm')
    draw.text((400, 570), "Open to all B.Tech / MCA / BCA students", fill='#94a3b8', font=get_font(FONT_REGULAR, 18), anchor='mm')
    draw.text((400, 670), "Follow @codespaceclub for registrations", fill='#f43f5e', font=get_font(FONT_BOLD, 22), anchor='mm')
    
    save_image(evt, "codespace_event.jpg")

# -------------------------------------------------------------
# 2. SHRINIK CLUB (@shrinik_glbajaj)
# -------------------------------------------------------------
def generate_shrinik():
    # Logo (512x512)
    img = Image.new('RGB', (512, 512), '#140c24')
    draw = ImageDraw.Draw(img)
    
    # Glow rings
    draw.ellipse([256 - 190, 256 - 190, 256 + 190, 256 + 190], outline='#8b5cf6', width=6)
    draw.ellipse([256 - 170, 256 - 170, 256 + 170, 256 + 170], outline='#f59e0b', width=3)

    # Stylized S icon with tech gear / culture flame
    draw.ellipse([256 - 70, 200 - 70, 256 + 70, 200 + 70], outline='#a78bfa', width=14)
    draw.text((256, 195), "S", fill='#f59e0b', font=get_font(FONT_BLACK, 110), anchor='mm')

    # Club Title
    f_title = get_font(FONT_BLACK, 40)
    draw.text((256, 295), "SHRINIK", fill='#ffffff', font=f_title, anchor='mm')

    f_sub = get_font(FONT_BOLD, 17)
    draw.text((256, 335), "TECHNO-CULTURAL • CSE DEPT", fill='#a78bfa', font=f_sub, anchor='mm')

    f_est = get_font(FONT_BOLD, 15)
    draw.text((256, 368), "GLBITM • EST. NOV 2021", fill='#f59e0b', font=f_est, anchor='mm')

    f_ig = get_font(FONT_BOLD, 17)
    draw.text((256, 410), "@shrinik_glbajaj", fill='#ec4899', font=f_ig, anchor='mm')

    save_image(img, "shrinik_logo.png")

    # Banner (1200x600)
    banner = Image.new('RGB', (1200, 600), '#120a1f')
    try:
        camp = Image.open(os.path.join(CAMPUS_DIR, 'glb_panorama.jpg')).resize((1200, 600)).convert('RGB')
        camp = camp.filter(ImageFilter.GaussianBlur(5))
        banner = Image.blend(camp, banner, 0.72)
    except:
        pass

    draw = ImageDraw.Draw(banner)
    draw.rectangle([0, 0, 1200, 8], fill='#8b5cf6')

    # Pill
    draw.rounded_rectangle([70, 70, 480, 115], radius=22, fill=(30, 18, 55, 230), outline='#8b5cf6', width=2)
    draw.text((275, 92), "🚀 TECHNO-CULTURAL SOCIETY", fill='#f59e0b', font=get_font(FONT_BOLD, 18), anchor='mm')

    # Title
    draw.text((70, 195), "SHRINIK CLUB", fill='#ffffff', font=get_font(FONT_BLACK, 68))
    draw.text((70, 275), "Where Technology Meets Culture & Innovation", fill='#c084fc', font=get_font(FONT_BOLD, 28))
    draw.text((70, 325), "Department of Computer Science & Engineering | GL Bajaj Institute of Technology & Management", fill='#cbd5e1', font=get_font(FONT_REGULAR, 20))

    # Highlights box
    draw.rounded_rectangle([70, 385, 1130, 520], radius=18, fill=(24, 12, 45, 230), outline=(139, 92, 246, 130), width=2)
    cols = [
        ("GLB Talks Series", "Keynotes with Top Founders", 240),
        ("Code with Shrinik", "Hackathons & Coding Duels", 600),
        ("@shrinik_glbajaj", "Official Instagram Portal", 960)
    ]
    for title, sub, xpos in cols:
        draw.text((xpos, 430), title, fill='#f59e0b', font=get_font(FONT_BLACK, 28), anchor='mm')
        draw.text((xpos, 470), sub, fill='#e2e8f0', font=get_font(FONT_REGULAR, 16), anchor='mm')

    save_image(banner, "shrinik_banner.jpg")

    # Event Poster
    evt = Image.new('RGB', (800, 800), '#11071f')
    draw = ImageDraw.Draw(evt)
    draw.rectangle([0, 0, 800, 10], fill='#8b5cf6')
    draw.rounded_rectangle([40, 40, 760, 760], radius=24, outline='#8b5cf6', width=3)
    
    draw.text((400, 110), "SHRINIK CSE PRESENTS", fill='#c084fc', font=get_font(FONT_BOLD, 20), anchor='mm')
    draw.text((400, 175), "GLB TALKS : 2026", fill='#ffffff', font=get_font(FONT_BLACK, 54), anchor='mm')
    draw.text((400, 240), "LEADERSHIP & TECH ENTREPRENEURSHIP", fill='#f59e0b', font=get_font(FONT_BOLD, 24), anchor='mm')
    
    draw.rounded_rectangle([120, 305, 680, 440], radius=18, fill='#1e1136', outline='#a78bfa', width=2)
    draw.text((400, 350), "SPECIAL GUEST SPEAKER SERIES", fill='#a78bfa', font=get_font(FONT_BOLD, 22), anchor='mm')
    draw.text((400, 395), "Industry Pioneers & Startup Founders", fill='#ffffff', font=get_font(FONT_BLACK, 26), anchor='mm')

    draw.text((400, 520), "📍 Main Auditorium, GLBITM  |  📅 Registration Open", fill='#ffffff', font=get_font(FONT_BOLD, 20), anchor='mm')
    draw.text((400, 570), "Interactive Q&A • Certificate of Attendance", fill='#cbd5e1', font=get_font(FONT_REGULAR, 18), anchor='mm')
    draw.text((400, 670), "Updates & RSVP on @shrinik_glbajaj", fill='#ec4899', font=get_font(FONT_BOLD, 22), anchor='mm')
    
    save_image(evt, "shrinik_event.jpg")

# -------------------------------------------------------------
# 3. NAVRANG CLUB (@navrang_glbitm)
# -------------------------------------------------------------
def generate_navrang():
    # Logo (512x512)
    img = Image.new('RGB', (512, 512), '#200508')
    draw = ImageDraw.Draw(img)
    
    # Outer colored rings
    colors = ['#ef4444', '#f59e0b', '#ec4899', '#8b5cf6']
    for idx, c in enumerate(colors):
        r = 190 - (idx * 6)
        draw.ellipse([256 - r, 256 - r, 256 + r, 256 + r], outline=c, width=3)

    # Dramatic Mask / Natraj Icon
    draw.text((256, 185), "🎭", fill='#f59e0b', font=get_font(FONT_BLACK, 88), anchor='mm')

    # Club Title
    f_title = get_font(FONT_BLACK, 40)
    draw.text((256, 280), "NAVRANG", fill='#ffffff', font=f_title, anchor='mm')

    f_sub = get_font(FONT_BOLD, 17)
    draw.text((256, 320), "OFFICIAL CULTURAL SOCIETY", fill='#fca5a5', font=f_sub, anchor='mm')

    f_types = get_font(FONT_BOLD, 15)
    draw.text((256, 355), "DANCE • DRAMA • MUSIC • ARTS", fill='#fbbf24', font=f_types, anchor='mm')

    f_ig = get_font(FONT_BOLD, 17)
    draw.text((256, 400), "@navrang_glbitm", fill='#f43f5e', font=f_ig, anchor='mm')

    save_image(img, "navrang_logo.png")

    # Banner (1200x600)
    banner = Image.new('RGB', (1200, 600), '#1a0407')
    try:
        camp = Image.open(os.path.join(CAMPUS_DIR, 'glb_gate1.webp')).resize((1200, 600)).convert('RGB')
        camp = camp.filter(ImageFilter.GaussianBlur(5))
        banner = Image.blend(camp, banner, 0.72)
    except:
        pass

    draw = ImageDraw.Draw(banner)
    draw.rectangle([0, 0, 1200, 8], fill='#ef4444')

    # Pill
    draw.rounded_rectangle([70, 70, 480, 115], radius=22, fill=(45, 10, 15, 230), outline='#ef4444', width=2)
    draw.text((275, 92), "🎭 GLBITM OFFICIAL CULTURAL CLUB", fill='#fbbf24', font=get_font(FONT_BOLD, 17), anchor='mm')

    # Title
    draw.text((70, 195), "NAVRANG CULTURAL CLUB", fill='#ffffff', font=get_font(FONT_BLACK, 64))
    draw.text((70, 275), "Colors of Expression, Rhythm & Dramatic Soul", fill='#fca5a5', font=get_font(FONT_BOLD, 28))
    draw.text((70, 325), "Dance • Dramatics • Vocals & Rap • Fine Arts • Photography | GLBITM", fill='#e2e8f0', font=get_font(FONT_REGULAR, 20))

    # Highlights box
    draw.rounded_rectangle([70, 385, 1130, 520], radius=18, fill=(35, 8, 12, 230), outline=(239, 68, 68, 130), width=2)
    cols = [
        ("Tandav Mahotsav", "Annual Dance Championship", 240),
        ("GLBians' Got Talent", "Grand Stage Talent Hunt", 600),
        ("@navrang_glbitm", "Auditions & Event Updates", 960)
    ]
    for title, sub, xpos in cols:
        draw.text((xpos, 430), title, fill='#fbbf24', font=get_font(FONT_BLACK, 28), anchor='mm')
        draw.text((xpos, 470), sub, fill='#fee2e2', font=get_font(FONT_REGULAR, 16), anchor='mm')

    save_image(banner, "navrang_banner.jpg")

    # Event Poster
    evt = Image.new('RGB', (800, 800), '#1c0307')
    draw = ImageDraw.Draw(evt)
    draw.rectangle([0, 0, 800, 10], fill='#ef4444')
    draw.rounded_rectangle([40, 40, 760, 760], radius=24, outline='#ef4444', width=3)
    
    draw.text((400, 110), "NAVRANG CULTURAL SOCIETY PRESENTS", fill='#fca5a5', font=get_font(FONT_BOLD, 19), anchor='mm')
    draw.text((400, 175), "TANDAV : NRITYA FEST", fill='#ffffff', font=get_font(FONT_BLACK, 52), anchor='mm')
    draw.text((400, 240), "INTRA-COLLEGE DANCE & PERFORMANCE BATTLE", fill='#fbbf24', font=get_font(FONT_BOLD, 22), anchor='mm')
    
    draw.rounded_rectangle([130, 305, 670, 440], radius=18, fill='#2e080d', outline='#f87171', width=2)
    draw.text((400, 350), "SOLO • DUET • CREW SHOWCASE", fill='#fbbf24', font=get_font(FONT_BLACK, 26), anchor='mm')
    draw.text((400, 395), "Classical, Hip-Hop, Contemporary & Folk", fill='#ffffff', font=get_font(FONT_BOLD, 20), anchor='mm')

    draw.text((400, 520), "📍 Central Amphitheatre / Audi  |  🎟️ Free Student Passes", fill='#ffffff', font=get_font(FONT_BOLD, 20), anchor='mm')
    draw.text((400, 570), "Cash Prizes, Trophies & College Level Recognition", fill='#e2e8f0', font=get_font(FONT_REGULAR, 18), anchor='mm')
    draw.text((400, 670), "Register via Bio Link on @navrang_glbitm", fill='#f43f5e', font=get_font(FONT_BOLD, 22), anchor='mm')
    
    save_image(evt, "navrang_event.jpg")

# -------------------------------------------------------------
# 4. VIVIDHATA CLUB (@vividhata.club.glbajaj)
# -------------------------------------------------------------
def generate_vividhata():
    # Logo (512x512)
    img = Image.new('RGB', (512, 512), '#031c15')
    draw = ImageDraw.Draw(img)
    
    # Prismatic rings
    draw.ellipse([256 - 190, 256 - 190, 256 + 190, 256 + 190], outline='#10b981', width=6)
    draw.ellipse([256 - 170, 256 - 170, 256 + 170, 256 + 170], outline='#f97316', width=3)

    # Stylized V emblem
    draw.text((256, 185), "V", fill='#10b981', font=get_font(FONT_BLACK, 115), anchor='mm')

    # Club Title
    f_title = get_font(FONT_BLACK, 40)
    draw.text((256, 285), "VIVIDHATA", fill='#ffffff', font=f_title, anchor='mm')

    f_sub = get_font(FONT_BOLD, 17)
    draw.text((256, 325), "INNOVATION • DIVERSITY • IMPACT", fill='#6ee7b7', font=f_sub, anchor='mm')

    f_web = get_font(FONT_BOLD, 15)
    draw.text((256, 360), "GL BAJAJ • vividhata.club", fill='#f97316', font=f_web, anchor='mm')

    f_ig = get_font(FONT_BOLD, 17)
    draw.text((256, 405), "@vividhata.club.glbajaj", fill='#fb7185', font=f_ig, anchor='mm')

    save_image(img, "vividhata_logo.png")

    # Banner (1200x600)
    banner = Image.new('RGB', (1200, 600), '#021711')
    try:
        camp = Image.open(os.path.join(CAMPUS_DIR, 'glb_academic.webp')).resize((1200, 600)).convert('RGB')
        camp = camp.filter(ImageFilter.GaussianBlur(5))
        banner = Image.blend(camp, banner, 0.72)
    except:
        pass

    draw = ImageDraw.Draw(banner)
    draw.rectangle([0, 0, 1200, 8], fill='#10b981')

    # Pill
    draw.rounded_rectangle([70, 70, 500, 115], radius=22, fill=(6, 40, 30, 230), outline='#10b981', width=2)
    draw.text((285, 92), "🌟 DIVERSITY & INNOVATION SOCIETY", fill='#f97316', font=get_font(FONT_BOLD, 17), anchor='mm')

    # Title
    draw.text((70, 195), "VIVIDHATA CLUB", fill='#ffffff', font=get_font(FONT_BLACK, 66))
    draw.text((70, 275), "Celebrating Diversity, Creativity & Next-Gen Leadership", fill='#6ee7b7', font=get_font(FONT_BOLD, 28))
    draw.text((70, 325), "Interdisciplinary Tech-Art, Social Welfare & Leadership Summit | GLBITM", fill='#cbd5e1', font=get_font(FONT_REGULAR, 20))

    # Highlights box
    draw.rounded_rectangle([70, 385, 1130, 520], radius=18, fill=(4, 30, 22, 230), outline=(16, 185, 129, 130), width=2)
    cols = [
        ("Next Orbit '26", "Flagship Orientation & Summit", 240),
        ("Creative DAM Sprint", "Design, Media & Photography", 600),
        ("@vividhata.club.glbajaj", "Official Web & Instagram Hub", 960)
    ]
    for title, sub, xpos in cols:
        draw.text((xpos, 430), title, fill='#10b981', font=get_font(FONT_BLACK, 28), anchor='mm')
        draw.text((xpos, 470), sub, fill='#e2e8f0', font=get_font(FONT_REGULAR, 16), anchor='mm')

    save_image(banner, "vividhata_banner.jpg")

    # Event Poster
    evt = Image.new('RGB', (800, 800), '#021510')
    draw = ImageDraw.Draw(evt)
    draw.rectangle([0, 0, 800, 10], fill='#10b981')
    draw.rounded_rectangle([40, 40, 760, 760], radius=24, outline='#10b981', width=3)
    
    draw.text((400, 110), "VIVIDHATA COMMUNITY PRESENTS", fill='#6ee7b7', font=get_font(FONT_BOLD, 20), anchor='mm')
    draw.text((400, 175), "NEXT ORBIT '26", fill='#ffffff', font=get_font(FONT_BLACK, 54), anchor='mm')
    draw.text((400, 240), "INNOVATION, LEADERSHIP & CREATIVITY SUMMIT", fill='#f97316', font=get_font(FONT_BOLD, 22), anchor='mm')
    
    draw.rounded_rectangle([130, 305, 670, 440], radius=18, fill='#062d22', outline='#34d399', width=2)
    draw.text((400, 350), "STUDENT LEADERSHIP & PROJECT EXPO", fill='#10b981', font=get_font(FONT_BLACK, 26), anchor='mm')
    draw.text((400, 395), "Design • Social Impact • Media • Innovation", fill='#ffffff', font=get_font(FONT_BOLD, 20), anchor='mm')

    draw.text((400, 520), "📍 Audi-2, Academic Block-1  |  🌐 vividhata.club", fill='#ffffff', font=get_font(FONT_BOLD, 20), anchor='mm')
    draw.text((400, 570), "Join the Next Wave of Creative GLB Leaders", fill='#cbd5e1', font=get_font(FONT_REGULAR, 18), anchor='mm')
    draw.text((400, 670), "Connect: @vividhata.club.glbajaj", fill='#fb7185', font=get_font(FONT_BOLD, 22), anchor='mm')
    
    save_image(evt, "vividhata_event.jpg")

if __name__ == '__main__':
    print("Generating assets for all 4 real GL Bajaj clubs...")
    generate_codespace()
    generate_shrinik()
    generate_navrang()
    generate_vividhata()
    print("All assets successfully generated!")
