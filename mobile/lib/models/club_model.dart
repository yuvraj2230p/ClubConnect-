class AnnouncementModel {
  final int id;
  final String clubName;
  final String title;
  final String content;
  final bool isPinned;
  final String createdAt;

  AnnouncementModel({
    required this.id,
    required this.clubName,
    required this.title,
    required this.content,
    required this.isPinned,
    required this.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] ?? 0,
      clubName: json['club_name'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      isPinned: json['is_pinned'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class ClubPostModel {
  final int id;
  final String clubName;
  final String clubSlug;
  final String title;
  final String caption;
  final String mediaType; // 'image' or 'video'
  final String mediaUrl;
  final String videoUrl;
  final String thumbnailUrl;
  final String instagramPostUrl;
  final int likesCount;
  final int viewsCount;
  final String createdAt;

  ClubPostModel({
    required this.id,
    required this.clubName,
    required this.clubSlug,
    required this.title,
    required this.caption,
    required this.mediaType,
    required this.mediaUrl,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.instagramPostUrl,
    required this.likesCount,
    required this.viewsCount,
    required this.createdAt,
  });

  factory ClubPostModel.fromJson(Map<String, dynamic> json) {
    String media = json['media_url'] ?? '';
    if (media.startsWith('/static/')) {
      media = 'http://127.0.0.1:8000$media';
    }
    String thumb = json['thumbnail_url'] ?? '';
    if (thumb.startsWith('/static/')) {
      thumb = 'http://127.0.0.1:8000$thumb';
    }

    return ClubPostModel(
      id: json['id'] ?? 0,
      clubName: json['club_name'] ?? '',
      clubSlug: json['club_slug'] ?? '',
      title: json['title'] ?? '',
      caption: json['caption'] ?? '',
      mediaType: json['media_type'] ?? 'image',
      mediaUrl: media,
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: thumb.isNotEmpty ? thumb : media,
      instagramPostUrl: json['instagram_post_url'] ?? '',
      likesCount: json['likes_count'] ?? 0,
      viewsCount: json['views_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class ClubModel {
  final int id;
  final String name;
  final String slug;
  final String tagline;
  final String description;
  final String category;
  final String logoUrl;
  final String coverImageUrl;
  final String facultyCoordinator;
  final String recruitmentStatus;
  final String instagramHandle;
  final int membersCount;
  bool isJoined;

  // President / Admin
  final String presidentName;
  final String presidentAdmissionNumber;
  final String presidentEmail;
  final String presidentAvatar;
  final bool isPresident;

  // Admission Procedure & Dates
  final String admissionProcedure;
  final String registrationStartDate;
  final String registrationEndDate;
  final String registrationLink;
  final String recruitmentEligibility;

  // Single Club Policy
  final bool canJoin;
  final Map<String, dynamic>? activeMembershipClub;

  // Posts & Videos
  final List<ClubPostModel> posts;

  ClubModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.tagline,
    required this.description,
    required this.category,
    required this.logoUrl,
    required this.coverImageUrl,
    required this.facultyCoordinator,
    required this.recruitmentStatus,
    required this.instagramHandle,
    required this.membersCount,
    required this.isJoined,
    required this.presidentName,
    required this.presidentAdmissionNumber,
    required this.presidentEmail,
    required this.presidentAvatar,
    required this.isPresident,
    required this.admissionProcedure,
    required this.registrationStartDate,
    required this.registrationEndDate,
    required this.registrationLink,
    required this.recruitmentEligibility,
    required this.canJoin,
    this.activeMembershipClub,
    required this.posts,
  });

  factory ClubModel.fromJson(Map<String, dynamic> json) {
    String logo = json['logo_url'] ?? '';
    if (logo.startsWith('/static/')) {
      logo = 'http://127.0.0.1:8000$logo';
    }
    String cover = json['cover_image_url'] ?? '';
    if (cover.startsWith('/static/')) {
      cover = 'http://127.0.0.1:8000$cover';
    }

    final pDetails = json['president_details'] as Map<String, dynamic>?;
    List<ClubPostModel> parsedPosts = [];
    if (json['posts'] is List) {
      parsedPosts = (json['posts'] as List)
          .map((p) => ClubPostModel.fromJson(p))
          .toList();
    }

    return ClubModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      tagline: json['tagline'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'technical',
      logoUrl: logo,
      coverImageUrl: cover,
      facultyCoordinator: json['faculty_coordinator'] ?? '',
      recruitmentStatus: json['recruitment_status'] ?? 'open',
      instagramHandle: json['instagram_handle'] ?? '',
      membersCount: json['members_count'] ?? 0,
      isJoined: json['is_joined'] ?? false,
      presidentName: pDetails?['name'] ?? 'Aditya Verma',
      presidentAdmissionNumber: pDetails?['admission_number'] ?? '',
      presidentEmail: pDetails?['email'] ?? '',
      presidentAvatar: pDetails?['avatar_url'] ?? '',
      isPresident: json['is_president'] ?? false,
      admissionProcedure: json['admission_procedure'] ?? '',
      registrationStartDate: json['registration_start_date'] ?? '',
      registrationEndDate: json['registration_end_date'] ?? '',
      registrationLink: json['registration_link'] ?? '',
      recruitmentEligibility: json['recruitment_eligibility'] ?? 'Open to all GLBITM batches',
      canJoin: json['can_join'] ?? true,
      activeMembershipClub: json['active_membership_club'] as Map<String, dynamic>?,
      posts: parsedPosts,
    );
  }
}
