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
  });

  factory ClubModel.fromJson(Map<String, dynamic> json) {
    return ClubModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      tagline: json['tagline'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'technical',
      logoUrl: json['logo_url'] ?? '',
      coverImageUrl: json['cover_image_url'] ?? '',
      facultyCoordinator: json['faculty_coordinator'] ?? '',
      recruitmentStatus: json['recruitment_status'] ?? 'open',
      instagramHandle: json['instagram_handle'] ?? '',
      membersCount: json['members_count'] ?? 0,
      isJoined: json['is_joined'] ?? false,
    );
  }
}
