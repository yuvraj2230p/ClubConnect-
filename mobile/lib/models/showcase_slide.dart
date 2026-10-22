class ShowcaseSlide {
  final int id;
  final String title;
  final String subtitle;
  final String tag;
  final String imageUrl;
  final String badge;
  final bool isAsset;

  ShowcaseSlide({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.imageUrl,
    required this.badge,
    this.isAsset = false,
  });

  factory ShowcaseSlide.fromJson(Map<String, dynamic> json) {
    final url = json['image_url']?.toString() ?? '';
    final assetFlag = json['is_asset'] == true || url.startsWith('assets/');
    return ShowcaseSlide(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      tag: json['tag'] ?? 'GL Bajaj',
      imageUrl: url,
      badge: json['badge'] ?? '',
      isAsset: assetFlag,
    );
  }
}
