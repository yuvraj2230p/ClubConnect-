import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/club_model.dart';
import '../../../providers/clubs_provider.dart';

class ClubPresidentDashboardScreen extends StatefulWidget {
  final ClubModel club;

  const ClubPresidentDashboardScreen({super.key, required this.club});

  @override
  State<ClubPresidentDashboardScreen> createState() => _ClubPresidentDashboardScreenState();
}

class _ClubPresidentDashboardScreenState extends State<ClubPresidentDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  // Controllers for admission settings
  late TextEditingController _procedureController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _linkController;
  late TextEditingController _eligibilityController;
  late String _recruitmentStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _procedureController = TextEditingController(text: widget.club.admissionProcedure);
    _startDateController = TextEditingController(text: widget.club.registrationStartDate);
    _endDateController = TextEditingController(text: widget.club.registrationEndDate);
    _linkController = TextEditingController(text: widget.club.registrationLink);
    _eligibilityController = TextEditingController(text: widget.club.recruitmentEligibility);
    _recruitmentStatus = widget.club.recruitmentStatus;

    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _procedureController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _linkController.dispose();
    _eligibilityController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final provider = context.read<ClubsProvider>();
    final data = await provider.fetchPresidentDashboard(widget.club.slug);
    if (mounted) {
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.club.name} Dashboard',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text(
              'President Admin Control Panel',
              style: TextStyle(color: AppColors.accentGold, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.accentGold,
          labelColor: AppColors.accentGold,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.feed, size: 18), text: 'Posts & Videos'),
            Tab(icon: Icon(Icons.rule, size: 18), text: 'Admission Rules'),
            Tab(icon: Icon(Icons.campaign, size: 18), text: 'Announcements'),
            Tab(icon: Icon(Icons.group, size: 18), text: 'Members Roster'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentIndigo))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPostsTab(),
                _buildAdmissionSettingsTab(),
                _buildAnnouncementsTab(),
                _buildMembersTab(),
              ],
            ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: POSTS & VIDEOS (Instagram Media Feed)
  // -------------------------------------------------------------
  Widget _buildPostsTab() {
    final posts = (_dashboardData?['posts'] as List?) ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Club Feed & Video Reels',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${posts.length} published items from ${widget.club.instagramHandle}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _showCreatePostModal,
              icon: const Icon(Icons.add_photo_alternate, size: 16, color: Colors.black),
              label: const Text('New Post', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (posts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text('No posts published yet. Tap "New Post" to add photos or reels.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13), textAlign: TextAlign.center),
            ),
          )
        else
          ...posts.map((p) => _buildPostItem(p)),
      ],
    );
  }

  Widget _buildPostItem(dynamic p) {
    final isVideo = p['media_type'] == 'video';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Image.network(
                  p['thumbnail_url'] ?? p['media_url'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.surfaceDark,
                    child: Center(child: Icon(isVideo ? Icons.videocam : Icons.image, color: Colors.white30, size: 40)),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      Icon(isVideo ? Icons.play_arrow : Icons.camera_alt, color: isVideo ? Colors.cyanAccent : Colors.pinkAccent, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        isVideo ? 'VIDEO / REEL' : 'PHOTO',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.black54,
                    radius: 14,
                    child: Icon(Icons.delete, color: Colors.redAccent, size: 16),
                  ),
                  onPressed: () => _confirmDeletePost(p['id']),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((p['title'] ?? '').isNotEmpty)
                  Text(
                    p['title'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                const SizedBox(height: 4),
                Text(
                  p['caption'] ?? '',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '❤️ ${p['likes_count'] ?? 0} likes  •  👁️ ${p['views_count'] ?? 0} views',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                    Text(
                      widget.club.instagramHandle,
                      style: const TextStyle(color: Color(0xFFF43F5E), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePostModal() {
    final titleCtrl = TextEditingController();
    final captionCtrl = TextEditingController();
    String mediaType = 'image';
    String mediaUrl = '/static/images/clubs/${widget.club.slug.replaceAll('-', '_')}_post1.jpg';
    final igCtrl = TextEditingController(text: 'https://www.instagram.com/${widget.club.instagramHandle.replaceAll('@', '')}/');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Publish New Club Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Media Type Selector
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('📸 Photo'),
                        selected: mediaType == 'image',
                        selectedColor: AppColors.accentGold,
                        onSelected: (val) {
                          if (val) {
                            setModalState(() {
                              mediaType = 'image';
                              mediaUrl = '/static/images/clubs/${widget.club.slug.replaceAll('-', '_')}_post1.jpg';
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('🎬 Video / Reel'),
                        selected: mediaType == 'video',
                        selectedColor: Colors.cyanAccent,
                        onSelected: (val) {
                          if (val) {
                            setModalState(() {
                              mediaType = 'video';
                              mediaUrl = '/static/images/clubs/${widget.club.slug.replaceAll('-', '_')}_reel1_thumb.jpg';
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Title / Headline', labelStyle: TextStyle(color: AppColors.textMuted)),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: captionCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Post Caption & Hashtags *', labelStyle: TextStyle(color: AppColors.textMuted)),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: igCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Instagram Link', labelStyle: TextStyle(color: AppColors.textMuted)),
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (captionCtrl.text.trim().isEmpty) return;
                        Navigator.pop(ctx);
                        final success = await context.read<ClubsProvider>().createPost(
                          widget.club.slug,
                          {
                            'title': titleCtrl.text.trim(),
                            'caption': captionCtrl.text.trim(),
                            'media_type': mediaType,
                            'media_url': mediaUrl,
                            'thumbnail_url': mediaUrl,
                            'video_url': mediaType == 'video'
                                ? 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4'
                                : '',
                            'instagram_post_url': igCtrl.text.trim(),
                          },
                        );
                        if (success) _loadData();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGold, padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Publish to Club Feed', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeletePost(int postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text('Delete Post?', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this post from your club feed?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirm == true) {
      await context.read<ClubsProvider>().deletePost(widget.club.slug, postId);
      _loadData();
    }
  }

  // -------------------------------------------------------------
  // TAB 2: ADMISSION RULES & REGISTRATION DATES
  // -------------------------------------------------------------
  Widget _buildAdmissionSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Recruitment & Admission Configuration',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Defined directly by the Club President to govern student intake procedures.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 16),

        // Status selector
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Recruitment Status', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Recruiting Open'),
                    selected: _recruitmentStatus == 'open',
                    selectedColor: AppColors.accentCyan,
                    onSelected: (val) {
                      if (val) setState(() => _recruitmentStatus = 'open');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Auditions Ongoing'),
                    selected: _recruitmentStatus == 'auditions',
                    selectedColor: AppColors.accentGold,
                    onSelected: (val) {
                      if (val) setState(() => _recruitmentStatus = 'auditions');
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Closed'),
                    selected: _recruitmentStatus == 'closed',
                    selectedColor: Colors.redAccent,
                    onSelected: (val) {
                      if (val) setState(() => _recruitmentStatus = 'closed');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Dates
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _startDateController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Registration Start (YYYY-MM-DD)',
                  labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: AppColors.surfaceCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _endDateController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Registration End (YYYY-MM-DD)',
                  labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: AppColors.surfaceCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        TextField(
          controller: _eligibilityController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Target Eligibility Criteria',
            labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            filled: true,
            fillColor: AppColors.surfaceCard,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 14),

        TextField(
          controller: _linkController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Registration Portal / Google Form URL',
            labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            filled: true,
            fillColor: AppColors.surfaceCard,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 14),

        TextField(
          controller: _procedureController,
          maxLines: 6,
          style: const TextStyle(color: Colors.white, height: 1.4),
          decoration: InputDecoration(
            labelText: 'Detailed Admission Procedure & Selection Steps *',
            labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            filled: true,
            fillColor: AppColors.surfaceCard,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final success = await context.read<ClubsProvider>().updateAdmissionSettings(
                widget.club.slug,
                {
                  'recruitment_status': _recruitmentStatus,
                  'registration_start_date': _startDateController.text.trim(),
                  'registration_end_date': _endDateController.text.trim(),
                  'registration_link': _linkController.text.trim(),
                  'recruitment_eligibility': _eligibilityController.text.trim(),
                  'admission_procedure': _procedureController.text.trim(),
                },
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '✅ Admission rules & dates updated!' : '❌ Failed to update rules.'),
                    backgroundColor: success ? AppColors.success : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Save & Publish Admission Procedure', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 3: ANNOUNCEMENTS
  // -------------------------------------------------------------
  Widget _buildAnnouncementsTab() {
    final announcements = (_dashboardData?['announcements'] as List?) ?? [];
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    bool isPinned = true;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Club Announcements', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => StatefulBuilder(
                    builder: (context, setDState) => AlertDialog(
                      backgroundColor: AppColors.surfaceCard,
                      title: const Text('Post Club Announcement', style: TextStyle(color: Colors.white)),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: titleCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(labelText: 'Title *', labelStyle: TextStyle(color: AppColors.textMuted)),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: contentCtrl,
                            maxLines: 4,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(labelText: 'Content *', labelStyle: TextStyle(color: AppColors.textMuted)),
                          ),
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            title: const Text('Pin to Top of Dashboard', style: TextStyle(color: Colors.white, fontSize: 12)),
                            value: isPinned,
                            onChanged: (val) => setDState(() => isPinned = val ?? false),
                            activeColor: AppColors.accentGold,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () async {
                            if (titleCtrl.text.isEmpty || contentCtrl.text.isEmpty) return;
                            Navigator.pop(ctx);
                            await context.read<ClubsProvider>().createAnnouncement(
                              widget.club.slug,
                              {'title': titleCtrl.text.trim(), 'content': contentCtrl.text.trim(), 'is_pinned': isPinned},
                            );
                            _loadData();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGold),
                          child: const Text('Post', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add, size: 16, color: Colors.black),
              label: const Text('Create', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGold),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (announcements.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('No announcements posted yet.', style: TextStyle(color: AppColors.textMuted))))
        else
          ...announcements.map((a) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: a['is_pinned'] == true ? AppColors.accentGold.withOpacity(0.5) : AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(a['title'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        if (a['is_pinned'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.accentGold.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                            child: const Text('PINNED', style: TextStyle(color: AppColors.accentGold, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(a['content'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
                  ],
                ),
              )),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 4: MEMBER ROSTER
  // -------------------------------------------------------------
  Widget _buildMembersTab() {
    final members = (_dashboardData?['members'] as List?) ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Enrolled Student Roster', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.accentCyan.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Text('${members.length} Active Students', style: const TextStyle(color: AppColors.accentCyan, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (members.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('No members in this club yet.', style: TextStyle(color: AppColors.textMuted))))
        else
          ...members.map((m) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Text((m['user_name'] ?? 'S')[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(m['user_name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(width: 6),
                              if (m['role'] == 'lead')
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(color: AppColors.accentGold.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                                  child: const Text('PRESIDENT', style: TextStyle(color: AppColors.accentGold, fontSize: 8, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${m['user_admission_number']} • ${m['user_department'] ?? ''}',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('ACTIVE', style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )),
      ],
    );
  }
}
