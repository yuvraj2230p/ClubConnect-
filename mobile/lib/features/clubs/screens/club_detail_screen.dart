import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/club_model.dart';
import '../../../providers/clubs_provider.dart';
import 'club_president_dashboard_screen.dart';

class ClubDetailScreen extends StatefulWidget {
  final ClubModel club;

  const ClubDetailScreen({super.key, required this.club});

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  String _selectedMediaFilter = 'all'; // 'all', 'video', 'image'
  late ClubModel _club;

  @override
  void initState() {
    super.initState();
    _club = widget.club;
    _refreshClub();
  }

  Future<void> _refreshClub() async {
    final updated = await context.read<ClubsProvider>().fetchClubDetail(widget.club.slug);
    if (updated != null && mounted) {
      setState(() => _club = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clubsProvider = context.watch<ClubsProvider>();

    String bannerAsset = 'assets/images/campus/glb_academic.webp';
    String logoAsset = 'assets/images/glb_logo.jpg';
    String eventPosterAsset = '';
    String eventTitle = '';
    String eventDate = '';

    if (_club.slug.contains('codespace')) {
      bannerAsset = 'assets/images/clubs/codespace_banner.jpg';
      logoAsset = 'assets/images/clubs/codespace_logo.png';
      eventPosterAsset = 'assets/images/clubs/codespace_event.jpg';
      eventTitle = "HackCodeSpace '26 (36-Hr Annual Hackathon)";
      eventDate = "March 1 - 18 • ₹1 Lakh Prize Pool";
    } else if (_club.slug.contains('shrinik')) {
      bannerAsset = 'assets/images/clubs/shrinik_banner.jpg';
      logoAsset = 'assets/images/clubs/shrinik_logo.png';
      eventPosterAsset = 'assets/images/clubs/shrinik_event.jpg';
      eventTitle = "GLB Talks : 2026 (Speaker Series)";
      eventDate = "March 5 - 22 • Tech Founders & Keynote";
    } else if (_club.slug.contains('navrang')) {
      bannerAsset = 'assets/images/clubs/navrang_banner.jpg';
      logoAsset = 'assets/images/clubs/navrang_logo.png';
      eventPosterAsset = 'assets/images/clubs/navrang_event.jpg';
      eventTitle = "Tandav : Intra-College Dance Championship";
      eventDate = "Feb 28 - March 20 • Central Lawns";
    } else if (_club.slug.contains('vividhata')) {
      bannerAsset = 'assets/images/clubs/vividhata_banner.jpg';
      logoAsset = 'assets/images/clubs/vividhata_logo.png';
      eventPosterAsset = 'assets/images/clubs/vividhata_event.jpg';
      eventTitle = "Next Orbit '26: Innovation & Leadership Summit";
      eventDate = "March 8 - 26 • Design & DAM Expo";
    }

    List<ClubPostModel> activePosts = _club.posts;
    if (activePosts.isEmpty) {
      final matching = clubsProvider.clubs.firstWhere(
        (c) => c.slug == _club.slug,
        orElse: () => _club,
      );
      if (matching.posts.isNotEmpty) {
        activePosts = matching.posts;
      }
    }

    final filteredPosts = activePosts.where((p) {
      if (_selectedMediaFilter == 'all') return true;
      return p.mediaType == _selectedMediaFilter;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          // Sliver App Bar with cover image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.surfaceDark,
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.refresh, color: Colors.white, size: 18),
                ),
                onPressed: _refreshClub,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _club.coverImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(bannerAsset, fit: BoxFit.cover),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.bgDark.withOpacity(0.85),
                          AppColors.bgDark,
                        ],
                        stops: const [0.3, 0.8, 1.0],
                      ),
                    ),
                  ),
                  // Floating Club Logo over the banner
                  Positioned(
                    bottom: 12,
                    left: 20,
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accentGold, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        _club.logoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(logoAsset, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Category Pill & Recruitment Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentIndigo.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accentIndigo.withOpacity(0.4)),
                        ),
                        child: Text(
                          _club.category.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.accentIndigo,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _club.recruitmentStatus == 'open'
                              ? AppColors.accentCyan.withOpacity(0.15)
                              : AppColors.accentGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _club.recruitmentStatus == 'open'
                                ? AppColors.accentCyan.withOpacity(0.4)
                                : AppColors.accentGold.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          _club.recruitmentStatus == 'open' ? 'Recruiting Open' : 'Auditions Ongoing',
                          style: TextStyle(
                            color: _club.recruitmentStatus == 'open' ? AppColors.accentCyan : AppColors.accentGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Club Title & Tagline
                  Text(
                    _club.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _club.tagline,
                    style: const TextStyle(color: AppColors.accentGold, fontSize: 13, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 14),

                  // PRESIDENT ADMIN DASHBOARD BUTTON (Always shown for seamless testing/management)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF2C1E14), Color(0xFF452E1C)]),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.accentGold.withOpacity(0.5)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClubPresidentDashboardScreen(club: _club),
                            ),
                          ).then((_) => _refreshClub());
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGold.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.admin_panel_settings, color: AppColors.accentGold, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'President Admin Dashboard',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Text(
                                      'Manage posts, video reels, announcements & admission rules',
                                      style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, color: AppColors.accentGold, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Instagram Official Badge Card
                  if (_club.instagramHandle.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFD1D1D).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Color(0xFFE1306C), size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Official Instagram Portal',
                                  style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _club.instagramHandle,
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Follow',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 18),

                  // Info Stats Row
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCol(Icons.people_outline, '${_club.membersCount}', 'Members'),
                        Container(width: 1, height: 30, color: AppColors.surfaceBorder),
                        _buildStatCol(Icons.school_outlined, 'GLBITM', 'Campus Body'),
                        Container(width: 1, height: 30, color: AppColors.surfaceBorder),
                        _buildStatCol(Icons.verified_user_outlined, '1 Club/Student', 'Policy Rule'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // =========================================================
                  // ADMISSION PROCEDURE & REGISTRATION DATES (President Defined)
                  // =========================================================
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E140E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accentGold.withOpacity(0.4)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.how_to_reg, color: AppColors.accentGold, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Admission Procedure',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('President Directive', style: TextStyle(color: AppColors.accentGold, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Registration Date Badges
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.date_range, color: AppColors.accentCyan, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Intake Window: ${_club.registrationStartDate.isNotEmpty ? _club.registrationStartDate : "March 1, 2026"} to ${_club.registrationEndDate.isNotEmpty ? _club.registrationEndDate : "March 20, 2026"}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Eligibility
                        Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Eligibility: ${_club.recruitmentEligibility}',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Step-by-Step Selection Process
                        const Text(
                          'Step-by-Step Selection Process:',
                          style: TextStyle(color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _club.admissionProcedure.isNotEmpty
                              ? _club.admissionProcedure
                              : "1. Submit Intake Form with past works\n2. Practical Domain Assessment\n3. Interview with President & Faculty Coordinator\n4. Formal induction into club cohort.",
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // =========================================================
                  // INSTAGRAM PHOTOS & VIDEO REELS FEED
                  // =========================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Instagram Media Feed',
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _club.instagramHandle,
                        style: const TextStyle(color: Color(0xFFF43F5E), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Filter Chips
                  Row(
                    children: [
                      _buildFilterChip('All Feed', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('🎬 Video Reels', 'video'),
                      const SizedBox(width: 8),
                      _buildFilterChip('📸 Photos', 'image'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (filteredPosts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('No media found for this filter.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ),
                    )
                  else
                    SizedBox(
                      height: 250,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: filteredPosts.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final post = filteredPosts[index];
                          return _buildMediaFeedCard(post);
                        },
                      ),
                    ),

                  const SizedBox(height: 24),

                  // =========================================================
                  // ABOUT SOCIETY
                  // =========================================================
                  const Text(
                    'About Society',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _club.description,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                  ),

                  const SizedBox(height: 24),

                  // =========================================================
                  // CLUB PRESIDENT & FACULTY CARDS
                  // =========================================================
                  const Text(
                    'Leadership & Governance',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // President Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.accentGold.withOpacity(0.2),
                          backgroundImage: _club.presidentAvatar.isNotEmpty
                              ? NetworkImage(_club.presidentAvatar)
                              : null,
                          child: _club.presidentAvatar.isEmpty
                              ? const Icon(Icons.person, color: AppColors.accentGold)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _club.presidentName,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentGold.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('PRESIDENT', style: TextStyle(color: AppColors.accentGold, fontSize: 8, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_club.presidentAdmissionNumber} • ${_club.presidentEmail}',
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Faculty Coordinator
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primaryLight,
                          child: Icon(Icons.school, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Faculty In-Charge', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              Text(
                                _club.facultyCoordinator,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =========================================================
                  // SINGLE CLUB POLICY ENFORCEMENT & JOIN ACTION
                  // =========================================================
                  _buildJoinSection(clubsProvider),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedMediaFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.accentGold,
      backgroundColor: AppColors.surfaceCard,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 11,
      ),
      onSelected: (_) => setState(() => _selectedMediaFilter = value),
    );
  }

  String _resolvePostAsset(String url) {
    if (url.contains('codespace_reel1_thumb')) return 'assets/images/clubs/codespace_reel1_thumb.jpg';
    if (url.contains('codespace_post1')) return 'assets/images/clubs/codespace_post1.jpg';
    if (url.contains('codespace_post2')) return 'assets/images/clubs/codespace_post2.jpg';
    if (url.contains('shrinik_reel1_thumb')) return 'assets/images/clubs/shrinik_reel1_thumb.jpg';
    if (url.contains('shrinik_post1')) return 'assets/images/clubs/shrinik_post1.jpg';
    if (url.contains('shrinik_post2')) return 'assets/images/clubs/shrinik_post2.jpg';
    if (url.contains('navrang_reel1_thumb')) return 'assets/images/clubs/navrang_reel1_thumb.jpg';
    if (url.contains('navrang_post1')) return 'assets/images/clubs/navrang_post1.jpg';
    if (url.contains('navrang_post2')) return 'assets/images/clubs/navrang_post2.jpg';
    if (url.contains('vividhata_reel1_thumb')) return 'assets/images/clubs/vividhata_reel1_thumb.jpg';
    if (url.contains('vividhata_post1')) return 'assets/images/clubs/vividhata_post1.jpg';
    if (url.contains('vividhata_post2')) return 'assets/images/clubs/vividhata_post2.jpg';
    return '';
  }

  Widget _buildMediaFeedCard(ClubPostModel post) {
    final isVideo = post.mediaType == 'video';

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 130,
                width: double.infinity,
                child: Builder(
                  builder: (_) {
                    final targetUrl = post.thumbnailUrl.isNotEmpty ? post.thumbnailUrl : post.mediaUrl;
                    final localAsset = _resolvePostAsset(targetUrl);
                    if (localAsset.isNotEmpty) {
                      return Image.asset(localAsset, fit: BoxFit.cover);
                    }
                    return Image.network(
                      targetUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceDark,
                        child: Center(child: Icon(isVideo ? Icons.play_circle : Icons.image, color: Colors.white30, size: 36)),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(isVideo ? Icons.play_arrow : Icons.camera_alt, color: isVideo ? Colors.cyanAccent : Colors.pinkAccent, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        isVideo ? 'REEL' : 'PHOTO',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              if (isVideo)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('▶ Watch', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.title.isNotEmpty)
                  Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                const SizedBox(height: 3),
                Text(
                  post.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, height: 1.3),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('❤️ ${post.likesCount}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                    const Text('Instagram', style: TextStyle(color: Color(0xFFF43F5E), fontSize: 9, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinSection(ClubsProvider clubsProvider) {
    if (_club.isJoined) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified, color: Colors.greenAccent, size: 22),
                SizedBox(width: 8),
                Text('You are an Active Member of this Club', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'As per college policy, a student can only belong to one club. You hold your exclusive membership here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.surfaceCard,
                    title: Text('Leave ${_club.name}?', style: const TextStyle(color: Colors.white)),
                    content: const Text(
                      'Are you sure you want to surrender your membership? You will be free to join another club once you leave.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Leave Club', style: TextStyle(color: Colors.redAccent))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await clubsProvider.leaveClub(_club.slug);
                  _refreshClub();
                }
              },
              icon: const Icon(Icons.exit_to_app, color: Colors.redAccent, size: 16),
              label: const Text('Leave Club (To Switch to Another)', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent)),
            ),
          ],
        ),
      );
    }

    // If user is member of ANOTHER club
    final activeClub = _club.activeMembershipClub;
    if (activeClub != null && activeClub['slug'] != _club.slug) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2B170E),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.amberAccent.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amberAccent, size: 20),
                SizedBox(width: 8),
                Text('Single Club Policy Notice', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "You are already an active member of '${activeClub['name']}'. GLBITM enforces a strict rule: a student can only belong to ONE club at a time.\n\nTo join ${_club.name}, please first leave your current club.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
            ),
          ],
        ),
      );
    }

    // Can Join
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ElevatedButton(
        onPressed: () async {
          final res = await clubsProvider.joinClub(_club.slug);
          if (mounted) {
            if (res.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('🎉 Welcome to ${_club.name}!'), backgroundColor: AppColors.success),
              );
              _refreshClub();
            } else {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surfaceCard,
                  title: const Text('Membership Restriction', style: TextStyle(color: Colors.amberAccent)),
                  content: Text(res.message, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
                  ],
                ),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_add, color: Colors.white),
            SizedBox(width: 8),
            Text('Apply & Join Society', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCol(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accentGold, size: 20),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }
}
