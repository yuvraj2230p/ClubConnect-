import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/club_model.dart';

class JoinClubResult {
  final bool success;
  final String message;
  final String? currentClub;

  JoinClubResult({
    required this.success,
    required this.message,
    this.currentClub,
  });
}

class ClubsProvider extends ChangeNotifier {
  List<ClubModel> _clubs = [];
  List<AnnouncementModel> _announcements = [];
  bool _isLoading = false;
  String _selectedCategory = 'all';
  String? _errorMessage;

  ClubsProvider() {
    _clubs = _buildFallbackClubs();
    fetchClubs();
  }

  List<ClubModel> get clubs => _clubs;
  List<AnnouncementModel> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String? get errorMessage => _errorMessage;

  List<ClubModel> get filteredClubs {
    if (_selectedCategory == 'all') {
      return _clubs;
    }
    return _clubs.where((c) => c.category == _selectedCategory).toList();
  }

  static List<ClubModel> _buildFallbackClubs() {
    return [
      ClubModel(
        id: 7,
        name: 'Code Space Club',
        slug: 'codespace-club',
        tagline: 'Empowering Developers • Open Source • Hackathons',
        description: 'Code Space Club is the premier technical and software development society of the Department of Computer Science & Information Technology (CSIT) and IT at GL Bajaj Institute of Technology & Management. Founded in 2022, we host flagship hackathons, open-source cohorts, competitive programming masterclasses, and project dev sprints.',
        category: 'technical',
        logoUrl: 'http://127.0.0.1:8000/static/images/clubs/codespace_logo.png',
        coverImageUrl: 'http://127.0.0.1:8000/static/images/clubs/codespace_banner.jpg',
        facultyCoordinator: 'Dr. IT & CSIT Faculty Lead',
        recruitmentStatus: 'open',
        instagramHandle: '@codespaceclub',
        membersCount: 42,
        isJoined: true,
        presidentName: 'Aditya Verma',
        presidentAdmissionNumber: '23116CS001',
        presidentEmail: '23116cs001@glbitm.ac.in',
        presidentAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
        isPresident: false,
        admissionProcedure: '1. Online Application: Fill out the official CSIT Developer Intake form with your GitHub, HackerRank or LeetCode profile before March 18.\n2. Algorithmic Screening Round: Complete 3 problem-solving questions on HackerEarth (60 mins) testing logic, arrays, and basic strings.\n3. Technical & Project Review: In-person walkthrough of your past code repositories, hackathon submissions, or web/app projects with President Aditya Verma & Core Tech Leads.\n4. Final Onboarding: Selected students receive an official welcome packet and are inducted into their chosen domain (Web3, AI/ML, Full-Stack, or CP).',
        registrationStartDate: 'March 1, 2026',
        registrationEndDate: 'March 18, 2026',
        registrationLink: 'https://forms.gle/codespace2026intake',
        recruitmentEligibility: 'B.Tech CSIT, IT, CSE & BCA/MCA 1st & 2nd Year Students',
        canJoin: false,
        activeMembershipClub: {'name': 'Code Space Club', 'slug': 'codespace-club', 'role': 'member'},
        posts: [
          ClubPostModel(
            id: 1,
            clubName: 'Code Space Club',
            clubSlug: 'codespace-club',
            title: "HackCodeSpace '25 Recap Reel 🚀",
            caption: '36 Hours of coding adrenaline, peer-to-peer debugging, and groundbreaking innovation at GL Bajaj! Relive the best moments from our flagship hackathon. #CodeSpaceClub #GLBITM #Hackathon',
            mediaType: 'video',
            mediaUrl: 'http://127.0.0.1:8000/static/images/clubs/codespace_reel1_thumb.jpg',
            videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
            thumbnailUrl: 'http://127.0.0.1:8000/static/images/clubs/codespace_reel1_thumb.jpg',
            instagramPostUrl: 'https://www.instagram.com/reel/C3_codespace_reel/',
            likesCount: 482,
            viewsCount: 5420,
            createdAt: '2026-10-22T22:35:40Z',
          ),
          ClubPostModel(
            id: 2,
            clubName: 'Code Space Club',
            clubSlug: 'codespace-club',
            title: "Aagaz '25 Orientation Bootcamp",
            caption: 'Welcoming 200+ first-year CSIT minds into the world of Git, Open Source, and algorithmic problem solving. The journey has just begun! 💻✨ #Aagaz #CSIT #GLBajaj',
            mediaType: 'image',
            mediaUrl: 'http://127.0.0.1:8000/static/images/clubs/codespace_post1.jpg',
            videoUrl: '',
            thumbnailUrl: 'http://127.0.0.1:8000/static/images/clubs/codespace_post1.jpg',
            instagramPostUrl: 'https://www.instagram.com/p/C2_codespace_aagaz/',
            likesCount: 310,
            viewsCount: 1890,
            createdAt: '2026-10-22T22:35:40Z',
          ),
          ClubPostModel(
            id: 3,
            clubName: 'Code Space Club',
            clubSlug: 'codespace-club',
            title: 'CodeSprint 4.0 Contest Champions 🏆',
            caption: 'Massive shoutout to our weekly sprint toppers who cracked complex dynamic programming challenges in record time. Keep grinding! #CodeChef #LeetCode #CodeSpace',
            mediaType: 'image',
            mediaUrl: 'http://127.0.0.1:8000/static/images/clubs/codespace_post2.jpg',
            videoUrl: '',
            thumbnailUrl: 'http://127.0.0.1:8000/static/images/clubs/codespace_post2.jpg',
            instagramPostUrl: 'https://www.instagram.com/p/C4_codespace_sprint/',
            likesCount: 275,
            viewsCount: 1420,
            createdAt: '2026-10-22T22:35:40Z',
          ),
        ],
      ),
      ClubModel(
        id: 8,
        name: 'Shrinik Club',
        slug: 'shrinik-club',
        tagline: 'Coding Culture • Peer Mentorship • GLB Talks',
        description: 'Shrinik Club is the premier developer community dedicated to competitive programming, machine learning, and developer hackathons across GL Bajaj campus.',
        category: 'technical',
        logoUrl: 'http://127.0.0.1:8000/static/images/clubs/shrinik_logo.png',
        coverImageUrl: 'http://127.0.0.1:8000/static/images/clubs/shrinik_banner.jpg',
        facultyCoordinator: 'Dr. Pushpendra Kumar',
        recruitmentStatus: 'open',
        instagramHandle: '@shrinik_glbajaj',
        membersCount: 38,
        isJoined: false,
        presidentName: 'Rohan Malhotra',
        presidentAdmissionNumber: '230192010045',
        presidentEmail: '230192010045@glbitm.ac.in',
        presidentAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80',
        isPresident: false,
        admissionProcedure: '1. Online Application Form\n2. 45-Min Basic Aptitude & DSA Round\n3. Interview with President Rohan Malhotra\n4. Induction into Core Wing.',
        registrationStartDate: 'March 5, 2026',
        registrationEndDate: 'March 22, 2026',
        registrationLink: 'https://forms.gle/shrinik2026intake',
        recruitmentEligibility: 'Open to all B.Tech Branches (1st, 2nd, 3rd Year)',
        canJoin: false,
        activeMembershipClub: {'name': 'Code Space Club', 'slug': 'codespace-club', 'role': 'member'},
        posts: [
          ClubPostModel(
            id: 4,
            clubName: 'Shrinik Club',
            clubSlug: 'shrinik-club',
            title: 'GLB Talks 2025 Highlights Reel',
            caption: 'Fireside chat with alumni leaders and silicon valley founders. Watch the inspiring moments!',
            mediaType: 'video',
            mediaUrl: 'http://127.0.0.1:8000/static/images/clubs/shrinik_reel1_thumb.jpg',
            videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
            thumbnailUrl: 'http://127.0.0.1:8000/static/images/clubs/shrinik_reel1_thumb.jpg',
            instagramPostUrl: 'https://www.instagram.com/reel/C3_shrinik_talks/',
            likesCount: 512,
            viewsCount: 6150,
            createdAt: '2026-10-22T22:35:40Z',
          ),
          ClubPostModel(
            id: 5,
            clubName: 'Shrinik Club',
            clubSlug: 'shrinik-club',
            title: 'Shrinik Induction Bootcamp',
            caption: 'Hands-on Web Dev and Git workshop for our newly inducted tech cohort.',
            mediaType: 'image',
            mediaUrl: 'http://127.0.0.1:8000/static/images/clubs/shrinik_post1.jpg',
            videoUrl: '',
            thumbnailUrl: 'http://127.0.0.1:8000/static/images/clubs/shrinik_post1.jpg',
            instagramPostUrl: 'https://www.instagram.com/p/C2_shrinik_bootcamp/',
            likesCount: 340,
            viewsCount: 2100,
            createdAt: '2026-10-22T22:35:40Z',
          ),
          ClubPostModel(
            id: 6,
            clubName: 'Shrinik Club',
            clubSlug: 'shrinik-club',
            title: 'System Design & Web Dev Workshop',
            caption: 'Full-stack microservices masterclass at Audi-3.',
            mediaType: 'image',
            mediaUrl: 'http://127.0.0.1:8000/static/images/clubs/shrinik_post2.jpg',
            videoUrl: '',
            thumbnailUrl: 'http://127.0.0.1:8000/static/images/clubs/shrinik_post2.jpg',
            instagramPostUrl: 'https://www.instagram.com/p/C4_shrinik_workshop/',
            likesCount: 290,
            viewsCount: 1650,
            createdAt: '2026-10-22T22:35:40Z',
          ),
        ],
      ),
      ClubModel(
        id: 9,
        name: 'Navrang Cultural Club',
        slug: 'navrang-club',
        tagline: 'Music • Dance • Drama • GL Bajaj Cultural Horizon',
        description: 'Navrang Club is the heart of cultural expression, dramatic arts, dance showcases, and musical vibrancy at GL Bajaj.',
        category: 'cultural',
        logoUrl: 'http://127.0.0.1:8000/static/images/clubs/navrang_logo.png',
        coverImageUrl: 'http://127.0.0.1:8000/static/images/clubs/navrang_banner.jpg',
        facultyCoordinator: 'Prof. Neha Gupta',
        recruitmentStatus: 'open',
        instagramHandle: '@navrang_glbitm',
        membersCount: 65,
        isJoined: false,
        presidentName: 'Simran Kaur',
        presidentAdmissionNumber: '230192010088',
        presidentEmail: '230192010088@glbitm.ac.in',
        presidentAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80',
        isPresident: false,
        admissionProcedure: '1. Register for Live Auditions\n2. 2-Minute Solo Performance in Chosen Wing (Dance, Vocals, Drama)\n3. Group Sync Exercise\n4. Induction Ceremony.',
        registrationStartDate: 'February 28, 2026',
        registrationEndDate: 'March 20, 2026',
        registrationLink: 'https://forms.gle/navrang2026intake',
        recruitmentEligibility: 'Open to all students with passion for performance arts',
        canJoin: false,
        activeMembershipClub: {'name': 'Code Space Club', 'slug': 'codespace-club', 'role': 'member'},
        posts: [
          ClubPostModel(
            id: 7,
            clubName: 'Navrang Cultural Club',
            clubSlug: 'navrang-club',
            title: 'Tandav 2025 Dance Showcase Reel',
            caption: 'Electrifying beats and heart-stopping choreography from intra-college Tandav championship.',
            mediaType: 'video',
            mediaUrl: 'http://127.0.0.1:8000/static/images/clubs/navrang_reel1_thumb.jpg',
            videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
            thumbnailUrl: 'http://127.0.0.1:8000/static/images/clubs/navrang_reel1_thumb.jpg',
            instagramPostUrl: 'https://www.instagram.com/reel/C3_navrang_dance/',
            likesCount: 680,
            viewsCount: 7890,
            createdAt: '2026-10-22T22:35:40Z',
          ),
          ClubPostModel(
            id: 8,
            clubName: 'Navrang Cultural Club',
            clubSlug: 'navrang-club',
            title: 'Nukkad Natak Street Play on Central Lawns',
            caption: 'Social awareness street play by our theatre division at Audi ground.',
            mediaType: 'image',
            mediaUrl: 'http://127.0.0.1:8000/static/images/clubs/navrang_post1.jpg',
            videoUrl: '',
            thumbnailUrl: 'http://127.0.0.1:8000/static/images/clubs/navrang_post1.jpg',
            instagramPostUrl: 'https://www.instagram.com/p/C2_navrang_theatre/',
            likesCount: 410,
            viewsCount: 3400,
            createdAt: '2026-10-22T22:35:40Z',
          ),
          ClubPostModel(
            id: 9,
            clubName: 'Navrang Cultural Club',
            clubSlug: 'navrang-club',
            title: 'Sargam Acoustic Jam Night',
            caption: 'Sunset unplugged jam session with the music wing.',
            mediaType: 'image',
            mediaUrl: 'http://127.0.0.1:8000/static/images/clubs/navrang_post2.jpg',
            videoUrl: '',
            thumbnailUrl: 'http://127.0.0.1:8000/static/images/clubs/navrang_post2.jpg',
            instagramPostUrl: 'https://www.instagram.com/p/C4_navrang_music/',
            likesCount: 360,
            viewsCount: 2800,
            createdAt: '2026-10-22T22:35:40Z',
          ),
        ],
      ),
      ClubModel(
        id: 10,
        name: 'Vividhata Club',
        slug: 'vividhata-club',
        tagline: 'Creative Leadership • Diversity • Student Innovation',
        description: 'Vividhata Club champions cross-disciplinary innovation, student welfare initiatives, social entrepreneurship, and inclusive leadership development across all academic departments at GL Bajaj.',
        category: 'social',
        logoUrl: 'http://127.0.0.1:8000/static/images/clubs/vividhata_logo.png',
        coverImageUrl: 'http://127.0.0.1:8000/static/images/clubs/vividhata_banner.jpg',
        facultyCoordinator: 'Dr. Sanjeev Pippal',
        recruitmentStatus: 'open',
        instagramHandle: '@vividhata.club.glbajaj',
        membersCount: 52,
        isJoined: false,
        presidentName: 'Priya Sharma',
        presidentAdmissionNumber: '230192013012',
        presidentEmail: '230192013012@glbitm.ac.in',
        presidentAvatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&auto=format&fit=crop&q=80',
        isPresident: false,
        admissionProcedure: '1. Portal form on vividhata.club\n2. 24-Hr UI/UX Design Sprint or Essay\n3. Interview with President Priya Sharma & Faculty Lead\n4. Induction into chosen domain.',
        registrationStartDate: 'March 8, 2026',
        registrationEndDate: 'March 26, 2026',
        registrationLink: 'https://forms.gle/vividhata2026intake',
        recruitmentEligibility: 'Open to all departments and degree programs',
        canJoin: false,
        activeMembershipClub: {'name': 'Code Space Club', 'slug': 'codespace-club', 'role': 'member'},
        posts: [
          ClubPostModel(
            id: 10,
            clubName: 'Vividhata Club',
            clubSlug: 'vividhata-club',
            title: 'Next Orbit 26 Leadership Summit Teaser Reel',
            caption: 'Student innovation and leadership summit teaser video. Shape the future!',
            mediaType: 'video',
            mediaUrl: 'http://127.0.0.1:8000/static/images/clubs/vividhata_reel1_thumb.jpg',
            videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
            thumbnailUrl: 'http://127.0.0.1:8000/static/images/clubs/vividhata_reel1_thumb.jpg',
            instagramPostUrl: 'https://www.instagram.com/reel/C3_vividhata_summit/',
            likesCount: 395,
            viewsCount: 4750,
            createdAt: '2026-10-22T22:35:40Z',
          ),
          ClubPostModel(
            id: 11,
            clubName: 'Vividhata Club',
            clubSlug: 'vividhata-club',
            title: 'Design & DAM Masterclass Bootcamp',
            caption: 'Hands-on Figma and brand identity curation workshop with creative leads.',
            mediaType: 'image',
            mediaUrl: 'http://127.0.0.1:8000/static/images/clubs/vividhata_post1.jpg',
            videoUrl: '',
            thumbnailUrl: 'http://127.0.0.1:8000/static/images/clubs/vividhata_post1.jpg',
            instagramPostUrl: 'https://www.instagram.com/p/C2_vividhata_figma/',
            likesCount: 315,
            viewsCount: 2300,
            createdAt: '2026-10-22T22:35:40Z',
          ),
          ClubPostModel(
            id: 12,
            clubName: 'Vividhata Club',
            clubSlug: 'vividhata-club',
            title: 'Canvas of Diversity Art Exhibition',
            caption: 'Cross-branch art, poetry, and photography showcase at Audi-2.',
            mediaType: 'image',
            mediaUrl: 'http://127.0.0.1:8000/static/images/clubs/vividhata_post2.jpg',
            videoUrl: '',
            thumbnailUrl: 'http://127.0.0.1:8000/static/images/clubs/vividhata_post2.jpg',
            instagramPostUrl: 'https://www.instagram.com/p/C4_vividhata_art/',
            likesCount: 280,
            viewsCount: 1920,
            createdAt: '2026-10-22T22:35:40Z',
          ),
        ],
      ),
    ];
  }

  Future<void> fetchClubs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient.get(ApiConstants.clubs);
      if (res is List) {
        _clubs = res.map((json) => ClubModel.fromJson(json)).toList();
      }
      final annRes = await ApiClient.get(ApiConstants.clubAnnouncements);
      if (annRes is List) {
        _announcements = annRes.map((json) => AnnouncementModel.fromJson(json)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('HttpException: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<ClubModel?> fetchClubDetail(String slug) async {
    try {
      final res = await ApiClient.get(ApiConstants.clubDetail(slug));
      if (res is Map<String, dynamic>) {
        final updatedClub = ClubModel.fromJson(res);
        final index = _clubs.indexWhere((c) => c.slug == slug);
        if (index != -1) {
          _clubs[index] = updatedClub;
          notifyListeners();
        }
        return updatedClub;
      }
    } catch (_) {}
    return null;
  }

  Future<JoinClubResult> joinClub(String slug) async {
    try {
      final res = await ApiClient.post(ApiConstants.joinClub(slug), {});
      if (res is Map<String, dynamic>) {
        // Update local state: member of this club, and not of others
        for (var c in _clubs) {
          if (c.slug == slug) {
            c.isJoined = true;
          } else {
            c.isJoined = false;
          }
        }
        notifyListeners();
        return JoinClubResult(
          success: true,
          message: res['message'] ?? 'Successfully joined club!',
        );
      }
      return JoinClubResult(success: true, message: 'Joined club successfully!');
    } catch (e) {
      final errMsg = e.toString().replaceFirst('HttpException: ', '');
      String? currentClubName;
      if (errMsg.contains("active member of '")) {
        final start = errMsg.indexOf("active member of '") + 18;
        final end = errMsg.indexOf("'", start);
        if (end != -1) {
          currentClubName = errMsg.substring(start, end);
        }
      }
      return JoinClubResult(
        success: false,
        message: errMsg,
        currentClub: currentClubName,
      );
    }
  }

  Future<bool> leaveClub(String slug) async {
    try {
      await ApiClient.post(ApiConstants.leaveClub(slug), {});
      final index = _clubs.indexWhere((c) => c.slug == slug);
      if (index != -1) {
        _clubs[index].isJoined = false;
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // President / Admin Operations
  Future<Map<String, dynamic>?> fetchPresidentDashboard(String slug) async {
    try {
      final res = await ApiClient.get(ApiConstants.presidentDashboard(slug));
      if (res is Map<String, dynamic>) {
        return res;
      }
    } catch (_) {}
    return null;
  }

  Future<bool> createPost(String slug, Map<String, dynamic> data) async {
    try {
      await ApiClient.post(ApiConstants.clubPosts(slug), data);
      await fetchClubDetail(slug);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deletePost(String slug, int postId) async {
    try {
      await ApiClient.delete(ApiConstants.clubPostDelete(slug, postId));
      await fetchClubDetail(slug);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createAnnouncement(String slug, Map<String, dynamic> data) async {
    try {
      await ApiClient.post(ApiConstants.clubAnnouncementCreate(slug), data);
      await fetchClubs();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateAdmissionSettings(String slug, Map<String, dynamic> data) async {
    try {
      await ApiClient.patch(ApiConstants.clubAdmissionSettings(slug), data);
      await fetchClubDetail(slug);
      return true;
    } catch (_) {
      return false;
    }
  }
}
