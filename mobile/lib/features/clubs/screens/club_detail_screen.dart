import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/club_model.dart';
import '../../../providers/clubs_provider.dart';

class ClubDetailScreen extends StatelessWidget {
  final ClubModel club;

  const ClubDetailScreen({super.key, required this.club});

  @override
  Widget build(BuildContext context) {
    final clubsProvider = context.watch<ClubsProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          // Sliver App Bar with cover image
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.surfaceDark,
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    club.coverImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceDark),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.bgDark.withOpacity(0.9),
                          AppColors.bgDark,
                        ],
                        stops: const [0.3, 0.8, 1.0],
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
                  // Club Title & Category Pill
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accentIndigo.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.accentIndigo.withOpacity(0.4)),
                              ),
                              child: Text(
                                club.category.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.accentIndigo,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              club.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: club.recruitmentStatus == 'open'
                              ? AppColors.accentCyan.withOpacity(0.15)
                              : AppColors.accentGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          club.recruitmentStatus == 'open' ? 'Recruiting' : 'Auditions',
                          style: TextStyle(
                            color: club.recruitmentStatus == 'open' ? AppColors.accentCyan : AppColors.accentGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  Text(
                    club.tagline,
                    style: const TextStyle(color: AppColors.accentGold, fontSize: 13, fontWeight: FontWeight.w500),
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
                        _buildStatCol(Icons.people_outline, '${club.membersCount}', 'Members'),
                        Container(width: 1, height: 30, color: AppColors.surfaceBorder),
                        _buildStatCol(Icons.school_outlined, 'GL Bajaj', 'Campus Body'),
                        Container(width: 1, height: 30, color: AppColors.surfaceBorder),
                        _buildStatCol(Icons.verified_user_outlined, club.facultyCoordinator.split(' ').first, 'Coordinator'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // About Section
                  const Text(
                    'About Society',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    club.description,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
                  ),

                  const SizedBox(height: 24),

                  // Coordinator Details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.primaryLight,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Faculty In-Charge', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              Text(
                                club.facultyCoordinator,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        if (club.instagramHandle.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.pink.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              club.instagramHandle,
                              style: const TextStyle(color: Colors.pinkAccent, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Join Club CTA
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: club.isJoined ? null : AppColors.primaryGradient,
                      color: club.isJoined ? AppColors.surfaceCard : null,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ElevatedButton(
                      onPressed: club.isJoined
                          ? null
                          : () async {
                              final success = await clubsProvider.joinClub(club.slug);
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('🎉 Welcome to ${club.name}!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(club.isJoined ? Icons.check_circle : Icons.group_add, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            club.isJoined ? 'Joined as Member' : 'Join Society / Club',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
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
