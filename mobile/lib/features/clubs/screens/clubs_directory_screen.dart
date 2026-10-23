import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/club_model.dart';
import '../../../providers/clubs_provider.dart';
import 'club_detail_screen.dart';

class ClubsDirectoryScreen extends StatelessWidget {
  const ClubsDirectoryScreen({super.key});

  final List<Map<String, String>> _categories = const [
    {'id': 'all', 'label': 'All Clubs'},
    {'id': 'technical', 'label': '💻 Tech & Coding'},
    {'id': 'cultural', 'label': '🎭 Cultural & Arts'},
    {'id': 'social', 'label': '🤝 Social & Leadership'},
  ];

  @override
  Widget build(BuildContext context) {
    final clubsProvider = context.watch<ClubsProvider>();
    final clubs = clubsProvider.filteredClubs;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        title: const Text(
          'GL Bajaj Societies',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => clubsProvider.fetchClubs(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Selector Chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = clubsProvider.selectedCategory == cat['id'];
                return ChoiceChip(
                  label: Text(cat['label']!),
                  selected: isSelected,
                  selectedColor: AppColors.accentIndigo,
                  backgroundColor: AppColors.surfaceCard,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.accentIndigo : AppColors.surfaceBorder,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (_) => clubsProvider.setCategory(cat['id']!),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Clubs List
          Expanded(
            child: clubsProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accentIndigo))
                : clubs.isEmpty
                    ? const Center(
                        child: Text('No clubs found in this category.', style: TextStyle(color: AppColors.textMuted)),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: clubs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final club = clubs[index];
                          return _buildClubCard(context, club);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubCard(BuildContext context, ClubModel club) {
    String bannerAsset = 'assets/images/campus/glb_academic.webp';
    String logoAsset = 'assets/images/glb_logo.jpg';

    if (club.slug.contains('codespace')) {
      bannerAsset = 'assets/images/clubs/codespace_banner.jpg';
      logoAsset = 'assets/images/clubs/codespace_logo.png';
    } else if (club.slug.contains('shrinik')) {
      bannerAsset = 'assets/images/clubs/shrinik_banner.jpg';
      logoAsset = 'assets/images/clubs/shrinik_logo.png';
    } else if (club.slug.contains('navrang')) {
      bannerAsset = 'assets/images/clubs/navrang_banner.jpg';
      logoAsset = 'assets/images/clubs/navrang_logo.png';
    } else if (club.slug.contains('vividhata')) {
      bannerAsset = 'assets/images/clubs/vividhata_banner.jpg';
      logoAsset = 'assets/images/clubs/vividhata_logo.png';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ClubDetailScreen(club: club)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image Stack
            SizedBox(
              height: 130,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    bannerAsset,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.surfaceCard.withOpacity(0.95)],
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        '${club.membersCount} Members',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.bgDark.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accentGold.withOpacity(0.4)),
                      ),
                      child: Text(
                        club.category.toUpperCase(),
                        style: const TextStyle(color: AppColors.accentGold, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Club Details Row with Logo Avatar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Club Logo
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.accentGold, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          logoAsset,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    club.name,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (club.isJoined)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentCyan.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.accentCyan.withOpacity(0.4)),
                                    ),
                                    child: const Text('Joined', style: TextStyle(color: AppColors.accentCyan, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                              ],
                            ),
                            if (club.instagramHandle.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  club.instagramHandle,
                                  style: const TextStyle(
                                    color: Color(0xFFF43F5E),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    club.tagline,
                    style: const TextStyle(color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    club.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
