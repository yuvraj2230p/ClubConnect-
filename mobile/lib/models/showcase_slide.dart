class ShowcaseSlide {
  final int id;
  final String title;
  final String subtitle;
  final String tag;
  final String imageUrl;
  final String badge;

  ShowcaseSlide({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.imageUrl,
    required this.badge,
  });

  factory ShowcaseSlide.fromJson(Map<String, dynamic> json) {
    return ShowcaseSlide(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      tag: json['tag'] ?? 'GL Bajaj',
      imageUrl: json['image_url'] ?? '',
      badge: json['badge'] ?? '',
    );
  }
}
