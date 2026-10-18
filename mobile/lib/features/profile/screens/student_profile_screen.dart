import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        title: const Text(
          'Student Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // GL Bajaj Digital Identity Card
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F2B48), Color(0xFF0A182E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // College Card Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.school, color: AppColors.accentGold, size: 24),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'G.L. BAJAJ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                'INSTITUTE OF TECHNOLOGY & MANAGEMENT',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentCyan.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.accentCyan.withOpacity(0.4)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified, color: AppColors.accentCyan, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'SIM VERIFIED',
                              style: TextStyle(color: AppColors.accentCyan, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Avatar & Student Name
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: user?.avatarUrl.isNotEmpty == true ? NetworkImage(user!.avatarUrl) : null,
                    child: user?.avatarUrl.isEmpty == true
                        ? Text(user!.fullName[0], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))
                        : null,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    user?.fullName ?? 'GL Bajaj Student',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: AppColors.surfaceBorder, height: 1),
                  const SizedBox(height: 16),

                  // Academic Details Grid
                  Row(
                    children: [
                      _buildIdDetail('ADMISSION NO.', user?.admissionNumber ?? 'N/A'),
                      _buildIdDetail('ROLL NUMBER', user?.rollNumber ?? 'N/A'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildIdDetail('BRANCH', user?.department ?? 'Engineering'),
                      _buildIdDetail('YEAR & SEC', '${user?.year ?? '3rd'} (${user?.section ?? 'A'})'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Info Tiles
            _buildActionTile(Icons.group_outlined, 'My Joined Clubs', '2 Active Societies', () {}),
            const SizedBox(height: 12),
            _buildActionTile(Icons.security_outlined, 'SIM Authentication Provider', 'GL Bajaj ERP v2.4 (Active)', () {}),
            const SizedBox(height: 12),
            _buildActionTile(Icons.info_outline, 'About Club Connect', 'Version 1.0 • GL Bajaj Edition', () {}),

            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await authProvider.logout();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.logout, color: AppColors.error, size: 18),
                label: const Text('Log Out of SIM Account', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildIdDetail(String title, String val) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(val, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.accentIndigo),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
        onTap: onTap,
      ),
    );
  }
}
