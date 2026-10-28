import os
import pptx
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.enum.shapes import MSO_SHAPE

def create_presentation():
    prs = pptx.Presentation()
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)
    blank_layout = prs.slide_layouts[6]

    # Colors matching the PDF
    C_NAVY = RGBColor(11, 27, 61)       # #0B1B3D
    C_DARK_BLUE = RGBColor(15, 32, 66)   # #0F2042
    C_BG_LIGHT = RGBColor(248, 250, 252) # #F8FAFC
    C_WHITE = RGBColor(255, 255, 255)
    C_CARD_BORDER = RGBColor(226, 232, 240)
    C_TEXT_MAIN = RGBColor(30, 41, 59)
    C_TEXT_MUTED = RGBColor(100, 116, 139)
    C_ACCENT_BLUE = RGBColor(29, 78, 216)
    C_CYAN_BG = RGBColor(224, 242, 254)
    C_CYAN_TXT = RGBColor(3, 105, 161)
    C_GREEN_BG = RGBColor(240, 253, 244)
    C_GREEN_TXT = RGBColor(21, 128, 61)

    def set_slide_background(slide, color):
        bg = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, prs.slide_width, prs.slide_height)
        bg.fill.solid()
        bg.fill.fore_color.rgb = color
        bg.line.fill.background()
        return bg

    def add_header(slide, title_text, bloom="Bloom: Understand & Apply", slide_num=2):
        # Background
        set_slide_background(slide, C_BG_LIGHT)

        # BCC351 pill badge
        badge = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.55), Inches(0.4), Inches(1.1), Inches(0.35))
        badge.fill.solid()
        badge.fill.fore_color.rgb = C_NAVY
        badge.line.fill.background()
        tf = badge.text_frame
        tf.word_wrap = False
        p = tf.paragraphs[0]
        p.text = "BCC351"
        p.alignment = PP_ALIGN.CENTER
        p.font.size = Pt(11)
        p.font.bold = True
        p.font.color.rgb = C_WHITE

        # Title Text
        tx = slide.shapes.add_textbox(Inches(1.75), Inches(0.32), Inches(8.5), Inches(0.55))
        tf = tx.text_frame
        tf.word_wrap = True
        p = tf.paragraphs[0]
        p.text = title_text
        p.font.size = Pt(22)
        p.font.bold = True
        p.font.color.rgb = C_DARK_BLUE

        # Bloom badge (top right)
        bloom_box = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(10.8), Inches(0.4), Inches(2.0), Inches(0.35))
        bloom_box.fill.solid()
        bloom_box.fill.fore_color.rgb = C_CYAN_BG
        bloom_box.line.color.rgb = RGBColor(186, 230, 253)
        bloom_box.line.width = Pt(1)
        tf = bloom_box.text_frame
        p = tf.paragraphs[0]
        p.text = bloom
        p.alignment = PP_ALIGN.CENTER
        p.font.size = Pt(10)
        p.font.bold = True
        p.font.color.rgb = C_CYAN_TXT

        # Footer
        footer_tx = slide.shapes.add_textbox(Inches(0.55), Inches(7.05), Inches(6.0), Inches(0.3))
        p = footer_tx.text_frame.paragraphs[0]
        p.text = "Ms. Nidhi | Department of Computer Science & IT"
        p.font.size = Pt(9.5)
        p.font.color.rgb = C_TEXT_MUTED

        page_tx = slide.shapes.add_textbox(Inches(11.0), Inches(7.05), Inches(1.8), Inches(0.3))
        p = page_tx.text_frame.paragraphs[0]
        p.text = f"Slide {slide_num} of 15"
        p.alignment = PP_ALIGN.RIGHT
        p.font.size = Pt(9.5)
        p.font.color.rgb = C_TEXT_MUTED

    def add_card(slide, left, top, width, height, title, items, subtitle=None, bg_color=C_WHITE, border_color=C_CARD_BORDER):
        card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, top, width, height)
        card.fill.solid()
        card.fill.fore_color.rgb = bg_color
        card.line.color.rgb = border_color
        card.line.width = Pt(1.2)

        tx = slide.shapes.add_textbox(left + Inches(0.18), top + Inches(0.15), width - Inches(0.36), height - Inches(0.3))
        tf = tx.text_frame
        tf.word_wrap = True

        p = tf.paragraphs[0]
        p.text = title
        p.font.size = Pt(14)
        p.font.bold = True
        p.font.color.rgb = C_DARK_BLUE

        if subtitle:
            p_sub = tf.add_paragraph()
            p_sub.text = subtitle
            p_sub.font.size = Pt(10.5)
            p_sub.font.color.rgb = C_TEXT_MUTED
            p_sub.space_after = Pt(8)

        for item in items:
            p_item = tf.add_paragraph()
            p_item.text = f"•  {item}"
            p_item.font.size = Pt(11.5)
            p_item.font.color.rgb = C_TEXT_MAIN
            p_item.space_after = Pt(4)

        return card

    def add_speaker_note(slide, note_text):
        # Callout box at bottom
        box = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.55), Inches(6.35), Inches(12.23), Inches(0.6))
        box.fill.solid()
        box.fill.fore_color.rgb = C_WHITE
        box.line.color.rgb = RGBColor(203, 213, 225)
        box.line.width = Pt(1)

        # Small blue bar
        bar = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0.68), Inches(6.47), Inches(0.12), Inches(0.36))
        bar.fill.solid()
        bar.fill.fore_color.rgb = C_ACCENT_BLUE
        bar.line.fill.background()

        tx = slide.shapes.add_textbox(Inches(0.9), Inches(6.38), Inches(11.7), Inches(0.55))
        tf = tx.text_frame
        tf.word_wrap = True
        p = tf.paragraphs[0]
        p.text = f"Speaker Note: {note_text}"
        p.font.size = Pt(10.5)
        p.font.color.rgb = C_TEXT_MAIN

        # Also add to native PowerPoint speaker notes
        notes_slide = slide.notes_slide
        tf_notes = notes_slide.notes_text_frame
        tf_notes.text = note_text

    # ==========================================
    # SLIDE 1: Title Slide (Dark Blue)
    # ==========================================
    s1 = prs.slides.add_slide(blank_layout)
    set_slide_background(s1, RGBColor(13, 27, 50)) # Deep Navy

    # Top Tag
    t_tag = s1.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(0.7), Inches(3.2), Inches(0.4))
    t_tag.fill.solid()
    t_tag.fill.fore_color.rgb = RGBColor(22, 42, 75)
    t_tag.line.color.rgb = RGBColor(38, 70, 115)
    p = t_tag.text_frame.paragraphs[0]
    p.text = "AKTU Curriculum | Session 2026–27"
    p.font.size = Pt(10.5)
    p.font.color.rgb = RGBColor(147, 197, 253)

    # Main Project Title
    tx = s1.shapes.add_textbox(Inches(0.8), Inches(1.4), Inches(11.5), Inches(1.5))
    tf = tx.text_frame
    p = tf.paragraphs[0]
    p.text = "BCC351 – Mini Project"
    p.font.size = Pt(40)
    p.font.bold = True
    p.font.color.rgb = C_WHITE

    p2 = tf.add_paragraph()
    p2.text = "Club Connect: Smart Campus Student Society & Event Platform"
    p2.font.size = Pt(22)
    p2.font.bold = True
    p2.font.color.rgb = RGBColor(224, 231, 255)

    p3 = tf.add_paragraph()
    p3.text = "Instant Physical ID Card Barcode Scan, Live SIM Portal Sync & 24/7 Cloud Architecture"
    p3.font.size = Pt(13)
    p3.font.color.rgb = RGBColor(148, 163, 184)

    # Bottom 3 Meta Columns
    def add_meta_col(left, label, value1, value2=None):
        tx = s1.shapes.add_textbox(left, Inches(5.6), Inches(3.6), Inches(1.2))
        tf = tx.text_frame
        p = tf.paragraphs[0]
        p.text = label.upper()
        p.font.size = Pt(9.5)
        p.font.bold = True
        p.font.color.rgb = RGBColor(148, 163, 184)
        
        p_val = tf.add_paragraph()
        p_val.text = value1
        p_val.font.size = Pt(13.5)
        p_val.font.bold = True
        p_val.font.color.rgb = C_WHITE

        if value2:
            p_val2 = tf.add_paragraph()
            p_val2.text = value2
            p_val2.font.size = Pt(11)
            p_val2.font.color.rgb = RGBColor(203, 213, 225)

    add_meta_col(Inches(0.8), "Course Code & Branch", "BCC351 | B.Tech CSE / IT", "Session: 2026–27")
    add_meta_col(Inches(4.8), "Faculty Coordinator", "Ms. Nidhi", "Assistant Professor, CS/IT")
    add_meta_col(Inches(8.8), "Project Lead & College", "Yuvraj & Team", "G.L. Bajaj Institute of Tech. & Mgmt.")

    # ==========================================
    # SLIDE 2: Objectives & Outcomes
    # ==========================================
    s2 = prs.slides.add_slide(blank_layout)
    add_header(s2, "Project Objectives & Learning Outcomes", "Bloom: Understand & Apply", 2)
    add_card(s2, Inches(0.55), Inches(1.05), Inches(5.9), Inches(5.0),
             "Course Learning Outcomes (COs)",
             [
                 "CO1: Identify real-world student and club communication bottlenecks on campus.",
                 "CO2: Apply modern Agile Software Development Life Cycle (SDLC) methodologies.",
                 "CO3: Design responsive, intuitive user interfaces and normalized database schemas.",
                 "CO4: Implement full-stack solution using Flutter, Python Django & C++ Barcode libraries.",
                 "CO5: Deploy on cloud servers for 24/7 public access and present technical demonstration."
             ],
             "Alignment with AICTE / AKTU Outcome-Based Education (OBE)")

    add_card(s2, Inches(6.88), Inches(1.05), Inches(5.9), Inches(5.0),
             "Key Project Objectives",
             [
                 "Single Hub for All Clubs: Centralize technical, cultural, and sports societies in one place.",
                 "Instant Barcode Login: Enable instant sign-in by scanning the student ID card barcode (Code 128).",
                 "Zero Manual Typing: Auto-sync official Student Name, Semester & Department from college records.",
                 "Frictionless Event Ticketing: Allow 1-tap fest registrations with digital pass generation.",
                 "Club President Control: Provide dedicated dashboards for notices, member approvals, and posts."
             ],
             "Solving daily campus society coordination challenges")
    add_speaker_note(s2, "Introduce Club Connect as an engineering response to scattered WhatsApp groups and manual Google forms, connecting directly to AKTU's BCC351 learning outcomes.")

    # ==========================================
    # SLIDE 3: What is Club Connect? (Comparison)
    # ==========================================
    s3 = prs.slides.add_slide(blank_layout)
    add_header(s3, "What is Club Connect? (Real-World Scope)", "Bloom: Analyze", 3)
    w_col = Inches(3.85)
    add_card(s3, Inches(0.55), Inches(1.05), w_col, Inches(5.0),
             "Theory Assignments",
             [
                 "Focus: Textbook problem solving and algorithm analysis.",
                 "Scope: Isolated classroom homework problems.",
                 "Outcome: Static written reports or solution sheets.",
                 "Limitation: No real user interaction or hardware integration."
             ],
             "Traditional Academic Study")
    add_card(s3, Inches(4.74), Inches(1.05), w_col, Inches(5.0),
             "Lab Experiments",
             [
                 "Focus: Verification of pre-written lab routines.",
                 "Scope: 2-hour lab exercises on local machines.",
                 "Outcome: Executing fixed programs with mock inputs.",
                 "Limitation: Does not prepare for production deployments."
             ],
             "Standard Laboratory Work")
    add_card(s3, Inches(8.93), Inches(1.05), w_col, Inches(5.0),
             "Club Connect (BCC351)",
             [
                 "Focus: Production-grade, end-to-end full stack development.",
                 "Scope: Multi-module system serving 5000+ campus students.",
                 "Features: Physical ID card barcode scanning + live portal sync.",
                 "Outcome: 24/7 live hosted web application and verified code."
             ],
             "Industry-Ready Practical Engineering",
             bg_color=RGBColor(240, 249, 255), border_color=RGBColor(147, 197, 253))
    add_speaker_note(s3, "Contrast standard classroom lab assignments with Club Connect. Club Connect is a complete, deployable multi-module system solving a real campus need.")

    # ==========================================
    # SLIDE 4: Why Do We Need Club Connect?
    # ==========================================
    s4 = prs.slides.add_slide(blank_layout)
    add_header(s4, "Why Do We Need Club Connect?", "Bloom: Evaluate", 4)
    w_grid = Inches(2.88)
    h_grid = Inches(3.6)
    add_card(s4, Inches(0.55), Inches(1.05), w_grid, h_grid,
             "Campus Chaos",
             [
                 "30+ student societies operate through chaotic WhatsApp groups.",
                 "Important hackathons and cultural event announcements get buried.",
                 "Students miss crucial registration deadlines."
             ], "Current Pain Point")
    add_card(s4, Inches(3.67), Inches(1.05), w_grid, h_grid,
             "Fake Registrations",
             [
                 "Google Forms allow anyone to enter incorrect roll numbers.",
                 "Organizers spend hours manually verifying students at the door.",
                 "No official validation against college records."
             ], "Verification Problem")
    add_card(s4, Inches(6.79), Inches(1.05), w_grid, h_grid,
             "Smart ID Solution",
             [
                 "Point phone camera at ID card barcode to log in instantly.",
                 "Auto-fetches real student name, semester, and branch.",
                 "Ensures 100% verified campus identity."
             ], "Our Technology Fix")
    add_card(s4, Inches(9.91), Inches(1.05), w_grid, h_grid,
             "Centralized Hub",
             [
                 "Explore societies: CodeSpace, Navrang, Shrinik, Vividhata.",
                 "Enforces fair 1-club membership policy automatically.",
                 "Club leaders manage registrations and post updates easily."
             ], "Organized Campus Life")

    # Recruiter callout banner
    banner = s4.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.55), Inches(4.85), Inches(12.23), Inches(1.2))
    banner.fill.solid()
    banner.fill.fore_color.rgb = RGBColor(238, 242, 255)
    banner.line.color.rgb = RGBColor(199, 210, 254)
    tx_b = s4.shapes.add_textbox(Inches(0.8), Inches(4.9), Inches(11.7), Inches(1.1))
    p = tx_b.text_frame.paragraphs[0]
    p.text = "💡 Recruiter & Industry Insight"
    p.font.size = Pt(12)
    p.font.bold = True
    p.font.color.rgb = C_ACCENT_BLUE
    p_sub = tx_b.text_frame.add_paragraph()
    p_sub.text = '"Over 85% of technical recruiters prioritize verifiable projects with live deployed URLs, hardware integration (camera/barcode), and clean version control over textbook GPAs alone."'
    p_sub.font.size = Pt(11)
    p_sub.font.color.rgb = C_DARK_BLUE

    add_speaker_note(s4, "Explain the campus problem: clubs currently use unverified Google Forms and WhatsApp. Club Connect replaces this with instant ID card verification and one official hub.")

    # ==========================================
    # SLIDE 5: Project Development Life Cycle (SDLC)
    # ==========================================
    s5 = prs.slides.add_slide(blank_layout)
    add_header(s5, "Project Development Life Cycle (SDLC)", "Bloom: Understand", 5)
    
    stages = [
        ("1", "Problem Identification", "Identified club coordination & form issues on campus."),
        ("2", "Literature Survey", "Analyzed existing portals; found zero barcode login systems."),
        ("3", "Requirement Analysis", "Defined student, club lead, and event ticket requirements."),
        ("4", "System Design", "Created system architecture, DFDs, and database schemas."),
        ("5", "Development", "Built Flutter Web frontend, Django API & ZXing scanner."),
        ("6", "Testing & Debug", "Tested with physical ID cards, wide barcodes, and lighting."),
        ("7", "Documentation", "Prepared complete BCC351 SRS and project reports."),
        ("8", "Final Viva & Demo", "Live 24/7 cloud deployment on Render for public evaluation.")
    ]
    w_box = Inches(2.88)
    h_box = Inches(2.25)
    for i, (num, title, desc) in enumerate(stages):
        r = i // 4
        c = i % 4
        left = Inches(0.55) + c * Inches(3.12)
        top = Inches(1.1) + r * Inches(2.45)
        add_card(s5, left, top, w_box, h_box, f"Phase {num}: {title}", [desc], subtitle=f"Stage {num}")

    add_speaker_note(s5, "Walk through the 8-stage engineering process. Highlight that we followed structured software engineering principles rather than jumping straight into coding.")

    # ==========================================
    # SLIDE 6: Team Formation & Responsibilities
    # ==========================================
    s6 = prs.slides.add_slide(blank_layout)
    add_header(s6, "Team Formation & Responsibilities", "Bloom: Apply", 6)
    w_team = Inches(5.9)
    add_card(s6, Inches(0.55), Inches(1.05), w_team, Inches(5.0),
             "Team Leader (TL) Responsibilities",
             [
                 "Acts as primary point of contact with Faculty Coordinator Ms. Nidhi.",
                 "Architected full stack system and database schema design.",
                 "Integrated C++ ZXing barcode decoding with Python Django server.",
                 "Maintains GitHub Organization, code merges, and Docker configurations.",
                 "Set up permanent 24/7 cloud deployment on Render."
             ],
             "Yuvraj — Architecture & Backend Lead")

    add_card(s6, Inches(6.88), Inches(1.05), w_team, Inches(5.0),
             "Team Members' Responsibilities",
             [
                 "Frontend & UI/UX Specialist: Built responsive Flutter web interface, warm college color palette, and campus carousel.",
                 "SIM Data & Integration Engineer: Mapped GL Bajaj ASMX portal fields to auto-sync Name, Semester, and Branch.",
                 "Testing & QA Lead: Validated camera barcode autofocus and linear Code 128 angle tolerance across devices.",
                 "Documentation Specialist: Prepared project report conforming to official AKTU guidelines."
             ],
             "Collaborative Module Ownership")
    add_speaker_note(s6, "Emphasize clear task distribution across frontend, backend, barcode integration, testing, and documentation conforming to BCC351 rubrics.")

    # ==========================================
    # SLIDE 7: Project Selection & Feasibility
    # ==========================================
    s7 = prs.slides.add_slide(blank_layout)
    add_header(s7, "Project Feasibility & Selection Criteria", "Bloom: Evaluate", 7)
    w_feas = Inches(3.85)
    add_card(s7, Inches(0.55), Inches(1.05), w_feas, Inches(5.0),
             "1. Problem Relevance",
             [
                 "Solves a real daily problem for thousands of students on our campus.",
                 "Eliminates manual verification queues at fest entrances.",
                 "Provides official digital identity for all student societies.",
                 "Not a generic clone project—tailored specifically to GL Bajaj."
             ],
             "Practical Campus Value")

    add_card(s7, Inches(4.74), Inches(1.05), w_feas, Inches(5.0),
             "2. Scope & Timeframe",
             [
                 "Executed within the 12-week semester deadline.",
                 "Agile sprint delivery ensured core barcode login worked early.",
                 "Incremental addition of club profiles and event ticketing.",
                 "Feasible, realistic milestones with zero scope creep."
             ],
             "Semester Deliverables")

    add_card(s7, Inches(8.93), Inches(1.05), w_feas, Inches(5.0),
             "3. Technical Feasibility",
             [
                 "Zero paid APIs: Uses free-tier cloud hosting on Render.",
                 "Uses standard browser camera APIs (works on any smartphone).",
                 "Efficient SQLite database handles campus traffic smoothly.",
                 "No costly hardware: Works with existing printed college ID cards."
             ],
             "100% Free & Sustainable")
    add_speaker_note(s7, "Explain why Club Connect is technically and practically feasible: it requires zero expensive hardware, uses free cloud hosting, and works with our existing college ID cards.")

    # ==========================================
    # SLIDE 8: Technology Stack (Simple & Clean)
    # ==========================================
    s8 = prs.slides.add_slide(blank_layout)
    add_header(s8, "Technology Stack Overview", "Bloom: Explore", 8)
    w_t = Inches(2.88)
    h_t = Inches(5.0)
    add_card(s8, Inches(0.55), Inches(1.05), w_t, h_t,
             "Frontend (Client)",
             [
                 "Flutter Web & Dart: High-performance single-page web app.",
                 "Html5-QRCode: High-speed browser camera scanner library.",
                 "Warm College Theme: Frosted mocha & beige palette with responsive mobile layouts.",
                 "Dynamic Carousel: Showcases campus blocks and events."
             ], "What Students See")

    add_card(s8, Inches(3.67), Inches(1.05), w_t, h_t,
             "Backend (Server)",
             [
                 "Python & Django: Secure, scalable REST API server.",
                 "C++ ZXing Engine: Industry-standard linear Code 128 barcode reader.",
                 "Pillow (PIL): Image processing to crop student portrait photos from physical cards.",
                 "JWT Auth: Fast, tamper-proof student session tokens."
             ], "Behind the Scenes")

    add_card(s8, Inches(6.79), Inches(1.05), w_t, h_t,
             "Database & Data",
             [
                 "SQLite / Relational DB: Stores clubs, announcements, events, and tickets.",
                 "GL Bajaj Portal Sync: Live connector verifying student admission numbers.",
                 "Dynamic Avatar System: Creates custom college-branded avatars for day scholars."
             ], "Records & Storage")

    add_card(s8, Inches(9.91), Inches(1.05), w_t, h_t,
             "Cloud & Tools",
             [
                 "Render.com: 24/7 cloud container hosting (Singapore region).",
                 "Docker: Packages app with Python and C++ libraries for reliable deployment.",
                 "Git & GitHub: Full version control with atomic commits.",
                 "Vercel: Fast edge proxy for static frontend delivery."
             ], "Production Deployment")
    add_speaker_note(s8, "Present the tech stack simply: Flutter for the web app, Python Django for the server, ZXing for barcode reading, and Render Docker for 24/7 cloud access.")

    # ==========================================
    # SLIDE 9: System Architecture & Data Flow
    # ==========================================
    s9 = prs.slides.add_slide(blank_layout)
    add_header(s9, "System Architecture & Data Flow", "Bloom: Analyze", 9)
    w_flow = Inches(2.88)
    h_flow = Inches(4.9)
    add_card(s9, Inches(0.55), Inches(1.05), w_flow, h_flow,
             "Step 1: Camera Input",
             [
                 "Student opens the scanner on smartphone or PC.",
                 "Points camera at physical ID card barcode.",
                 "Live viewfinder captures high-resolution video frames (24 FPS).",
                 "Supports both camera scan & card photo upload."
             ], "Input Layer")

    add_card(s9, Inches(3.67), Inches(1.05), w_flow, h_flow,
             "Step 2: Barcode Decoding",
             [
                 "C++ ZXing library analyzes linear Code 128 barcode.",
                 "Auto-orients card across all 4 rotations (0°, 90°, 180°, 270°).",
                 "Extracts clean student admission number (e.g. 25116CN197).",
                 "Instant feedback beep confirms detection."
             ], "Processing Layer")

    add_card(s9, Inches(6.79), Inches(1.05), w_flow, h_flow,
             "Step 3: Portal Verification",
             [
                 "Backend queries college verification service.",
                 "Validates active student enrollment status.",
                 "Auto-retrieves official Name (Yash Kumar), Semester (Sem III), and Branch (B.Tech CSIT).",
                 "Issues secure 30-day login token."
             ], "Verification Layer")

    add_card(s9, Inches(9.91), Inches(1.05), w_flow, h_flow,
             "Step 4: Active Dashboard",
             [
                 "Loads personalized student profile card.",
                 "Shows enrolled clubs and upcoming events.",
                 "Generates digital fest entry passes with QR codes.",
                 "Gives club presidents administrative controls."
             ], "Presentation Layer")
    add_speaker_note(s9, "Walk through the 4-step pipeline: Student holds card $\rightarrow$ Barcode decoded $\rightarrow$ College database verifies Name and Semester $\rightarrow$ Student accesses their society dashboard.")

    # ==========================================
    # SLIDE 10: Software Development Process (Agile)
    # ==========================================
    s10 = prs.slides.add_slide(blank_layout)
    add_header(s10, "Software Development Process (Agile Scrum)", "Bloom: Apply", 10)
    w_ag = Inches(5.9)
    add_card(s10, Inches(0.55), Inches(1.05), w_ag, Inches(5.0),
             "Agile Scrum Framework (Recommended & Adopted)",
             [
                 "Sprint 1 (Weeks 1–3): Problem discovery, UI wireframes, warm college theme design.",
                 "Sprint 2 (Weeks 4–7): Django REST APIs, database schema, Code 128 barcode scanner integration.",
                 "Sprint 3 (Weeks 8–10): Real college portal data sync, semester and branch auto-fill, day scholar avatars.",
                 "Sprint 4 (Weeks 11–12): Dockerization, Render 24/7 deployment, and external viva presentation rehearsal.",
                 "Benefit: Working software ready at every stage—zero last-minute compilation panics."
             ],
             "Why Agile worked best for Club Connect")

    add_card(s10, Inches(6.88), Inches(1.05), w_ag, Inches(5.0),
             "Waterfall Lifecycle Approach (Why Avoided)",
             [
                 "Rigid sequential stages: Coding cannot begin until documentation is 100% frozen.",
                 "High Risk: System integration happens only at the very end.",
                 "Zero Flexibility: Changes to barcode angles or college portal response formats cause delays.",
                 "Late Testing: Bugs discovered just days before viva lead to broken demonstrations.",
                 "Conclusion: Agile provided continuous testing and guaranteed a working live demo."
             ],
             "Comparison with traditional sequential model")
    add_speaker_note(s10, "Explain why we adopted Agile Scrum instead of Waterfall. Sprints allowed us to test barcode scanning and portal sync continuously, ensuring our demo worked flawlessly.")

    # ==========================================
    # SLIDE 11: Core Modules & Features
    # ==========================================
    s11 = prs.slides.add_slide(blank_layout)
    add_header(s11, "Core Functional Modules", "Bloom: Understand", 11)
    w_m = Inches(2.88)
    h_m = Inches(5.0)
    add_card(s11, Inches(0.55), Inches(1.05), w_m, h_m,
             "1. Smart Auth Module",
             [
                 "Hardware-free ID card scanner (reads Code 128 & QR).",
                 "Auto-syncs verified student name, semester, and department.",
                 "Personalized student avatar generation with college styling.",
                 "Eliminates password fatigue and manual signup forms."
             ], "Module 1: Authentication")

    add_card(s11, Inches(3.67), Inches(1.05), w_m, h_m,
             "2. Society Hub Module",
             [
                 "Explore verified clubs: CodeSpace, Navrang, Shrinik, Vividhata.",
                 "Detailed club bios, banners, and lead info.",
                 "Fair One-Club Policy: Prevents chaotic multiple club registrations.",
                 "View club announcement feeds in real time."
             ], "Module 2: Club Directory")

    add_card(s11, Inches(6.79), Inches(1.05), w_m, h_m,
             "3. Events & Ticketing",
             [
                 "Campus hackathons, coding contests, and fests showcase.",
                 "One-tap event registration.",
                 "Generates digital entry tickets with unique QR badges.",
                 "Organizers scan student QR tickets at the door."
             ], "Module 3: Campus Events")

    add_card(s11, Inches(9.91), Inches(1.05), w_m, h_m,
             "4. President Dashboard",
             [
                 "Dedicated panel for verified club presidents.",
                 "Publish official club updates and announcements.",
                 "Review and approve student membership requests.",
                 "Set recruitment deadlines and upload fest media."
             ], "Module 4: Administration")
    add_speaker_note(s11, "Highlight the 4 pillars of the app: Smart Barcode Login, Club Directory, Event Ticketing, and the President Management Dashboard.")

    # ==========================================
    # SLIDE 12: Good Project vs Poor Project Matrix
    # ==========================================
    s12 = prs.slides.add_slide(blank_layout)
    add_header(s12, "Evaluation Matrix: Good vs. Poor Project", "Bloom: Evaluate", 12)
    w_eval = Inches(5.9)
    add_card(s12, Inches(0.55), Inches(1.05), w_eval, Inches(5.0),
             "Club Connect (Grade A / A+ Standard)",
             [
                 "Problem Definition: Specific, solves real campus club fragmentation.",
                 "Live Cloud Deployment: Hosted 24/7 on Render cloud with permanent HTTPS URL.",
                 "Innovative Hardware Feature: Decodes physical student ID card barcodes seamlessly.",
                 "Real College Integration: Auto-retrieves live student records without dummy data.",
                 "Git Transparency: Daily commit history on GitHub with structured pull requests.",
                 "Responsive UX: Professional frosted glass design with dynamic carousel."
             ],
             "Why Club Connect meets high evaluation criteria",
             bg_color=C_GREEN_BG, border_color=RGBColor(134, 239, 172))

    add_card(s12, Inches(6.88), Inches(1.05), w_eval, Inches(5.0),
             "Typical Poor Project (Grade C / D Pitfalls)",
             [
                 "Problem Definition: Vague, generic clone (e.g. copied basic e-commerce or calculator).",
                 "Deployment: Runs only on localhost; crashes when external examiner tests it.",
                 "Authentication: Hardcoded mock passwords with zero real verification.",
                 "Code Quality: Monolithic spaghetti code copied from internet tutorials.",
                 "Version Control: Single .zip file uploaded a night before final submission.",
                 "User Interface: Unaligned buttons, unhandled error popups, poor usability."
             ],
             "Common mistakes highlighted in BCC351 guidelines",
             bg_color=RGBColor(254, 242, 242), border_color=RGBColor(254, 202, 202))
    add_speaker_note(s12, "Show that Club Connect avoids every single common project trap: it is not a generic clone, it has continuous Git commits, and it is live 24/7 on the cloud.")

    # ==========================================
    # SLIDE 13: Live Testing & Verification Results
    # ==========================================
    s13 = prs.slides.add_slide(blank_layout)
    add_header(s13, "Live Testing & Output Verification", "Bloom: Analyze", 13)
    w_res = Inches(3.85)
    add_card(s13, Inches(0.55), Inches(1.05), w_res, Inches(5.0),
             "Real Student Test",
             [
                 "Tested Barcode: 25116CN197",
                 "Verified Name: Yash Kumar",
                 "Verified Semester: Sem III",
                 "Department: B.TECH.(CSIT)",
                 "Session / Status: 2025 Batch • Day Scholar",
                 "Avatar: Generated customized college badge avatar.",
                 "Verification Speed: Under 0.8 seconds."
             ], "Official Portal Sync")

    add_card(s13, Inches(4.74), Inches(1.05), w_res, Inches(5.0),
             "Multi-Device Camera Test",
             [
                 "Smartphone Cameras: Tested on Android & iOS Chrome browsers.",
                 "Desktop Webcams: Tested on Mac and Windows laptops.",
                 "Lighting Test: Accurately decodes in low light and tilted angles.",
                 "Wide Aperture: 98% scan box easily captures wide linear Code 128 barcodes.",
                 "Fallback: Supports uploading ID card photo directly."
             ], "Hardware Compatibility")

    add_card(s13, Inches(8.93), Inches(1.05), w_res, Inches(5.0),
             "Cloud Endpoint Health",
             [
                 "Web UI Root (/): 200 OK (Fast loading)",
                 "Campus Carousel (/api/auth/slides): 200 OK",
                 "Barcode Scan (/api/auth/id-card-scan): 200 OK",
                 "Clubs Directory (/api/clubs): 200 OK",
                 "Events API (/api/events): 200 OK",
                 "Static Avatars (/static/images): 200 OK",
                 "Uptime: 24/7 live availability on Render cloud."
             ], "Production Performance",
             bg_color=RGBColor(240, 253, 244), border_color=RGBColor(134, 239, 172))
    add_speaker_note(s13, "Present the verification results: we tested real student ID cards like Yash Kumar, achieving instant portal synchronization and 100% healthy HTTP 200 responses on Render cloud.")

    # ==========================================
    # SLIDE 14: Future Scope & Enhancements
    # ==========================================
    s14 = prs.slides.add_slide(blank_layout)
    add_header(s14, "Future Scope & Enhancements", "Bloom: Create", 14)
    w_fut = Inches(3.85)
    add_card(s14, Inches(0.55), Inches(1.05), w_fut, Inches(5.0),
             "1. QR Door Attendance",
             [
                 "Club leaders can scan students' digital event QR tickets at the hall entrance.",
                 "Real-time attendance tracker shows exact headcounts.",
                 "Completely eliminates paper attendance sheets at fests."
             ], "Phase 2 Feature")

    add_card(s14, Inches(4.74), Inches(1.05), w_fut, Inches(5.0),
             "2. Automated Certificates",
             [
                 "Students who attend workshops automatically receive verified PDF certificates.",
                 "Certificates feature cryptographic QR codes for tamper verification.",
                 "Students can directly share certificates on LinkedIn."
             ], "Phase 2 Feature")

    add_card(s14, Inches(8.93), Inches(1.05), w_fut, Inches(5.0),
             "3. Push Notifications",
             [
                 "Real-time alerts whenever a joined club posts a meeting notice.",
                 "Reminders 1 hour before registered hackathons begin.",
                 "Cross-platform notification support on Android and Web."
             ], "Phase 2 Feature")
    add_speaker_note(s14, "Discuss future enhancements: QR attendance scanning at workshop doors, automatic PDF participation certificates, and push notifications for event updates.")

    # ==========================================
    # SLIDE 15: Conclusion & Q&A (Dark Blue)
    # ==========================================
    s15 = prs.slides.add_slide(blank_layout)
    set_slide_background(s15, RGBColor(13, 27, 50)) # Deep Navy

    tx_c = s15.shapes.add_textbox(Inches(0.8), Inches(1.0), Inches(11.5), Inches(2.2))
    tf_c = tx_c.text_frame
    p = tf_c.paragraphs[0]
    p.text = "Build, Innovate & Excel!"
    p.font.size = Pt(40)
    p.font.bold = True
    p.font.color.rgb = C_WHITE

    p2 = tf_c.add_paragraph()
    p2.text = '"Club Connect bridges campus life with modern software engineering—turning existing physical ID cards into smart digital keys."'
    p2.font.size = Pt(16)
    p2.font.color.rgb = RGBColor(224, 231, 255)
    p2.space_before = Pt(10)

    # Info Cards
    def add_end_card(left, title, lines):
        c = s15.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, Inches(3.6), Inches(3.8), Inches(2.6))
        c.fill.solid()
        c.fill.fore_color.rgb = RGBColor(22, 42, 75)
        c.line.color.rgb = RGBColor(38, 70, 115)
        tx = s15.shapes.add_textbox(left + Inches(0.2), Inches(3.75), Inches(3.4), Inches(2.3))
        tf = tx.text_frame
        p = tf.paragraphs[0]
        p.text = title
        p.font.size = Pt(14)
        p.font.bold = True
        p.font.color.rgb = RGBColor(147, 197, 253)
        for line in lines:
            p_l = tf.add_paragraph()
            p_l.text = line
            p_l.font.size = Pt(11)
            p_l.font.color.rgb = C_WHITE
            p_l.space_before = Pt(4)

    add_end_card(Inches(0.8), "Live Project Access", [
        "🌐 Live URL: clubconnect-3gl1.onrender.com",
        "📱 Accessible on any phone or PC",
        "☁️ 24/7 Cloud Uptime on Render",
        "⚡ HTTPS Encrypted & Verified"
    ])

    add_end_card(Inches(4.75), "Source Code & Docs", [
        "📁 GitHub: yuvraj2230p/ClubConnect-",
        "🌿 Branch: main (Production ready)",
        "📄 Complete BCC351 SRS Documentation",
        "👥 Team: Yuvraj & Team Members"
    ])

    add_end_card(Inches(8.7), "Department Coordination", [
        "👩‍🏫 Faculty Coordinator: Ms. Nidhi",
        "🏫 Department: Computer Science & IT",
        "🎓 GL Bajaj Institute of Tech. & Mgmt.",
        "❓ Floor Open for Questions & Feedback"
    ])

    add_speaker_note(s15, "Conclude by thanking Ms. Nidhi and the faculty evaluators. Invite questions and transition smoothly into the live demonstration on Render.")

    # Save presentation
    output_path = "/Users/yuvraj/Club Connect/Club_Connect_Mini_Project_BCC351.pptx"
    prs.save(output_path)
    print(f"Presentation successfully generated at: {output_path}")

create_presentation()
