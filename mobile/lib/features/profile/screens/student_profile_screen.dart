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
            // GL Bajaj Digital Identity Card in Rich Leather-Brown & Gold/Beige
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF382317), Color(0xFF1E130D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.beige.withOpacity(0.35), width: 1.5),
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
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/glb_logo.jpg',
                              width: 34,
                              height: 34,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Column(
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

                  // Avatar & Student Name with Camera Badge
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: AppColors.caramel,
                        backgroundImage: const AssetImage('assets/images/yuvraj_avatar.jpg'),
                        foregroundImage: (user?.avatarUrl.isNotEmpty == true && user!.avatarUrl.startsWith('http'))
                            ? NetworkImage(user!.avatarUrl)
                            : null,
                        onBackgroundImageError: (exception, stackTrace) {},
                        onForegroundImageError: (exception, stackTrace) {},
                      ),
                      GestureDetector(
                        onTap: () => _showIdCardPhotoExtractionSheet(context),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: AppColors.caramel,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: AppColors.espressoDark, size: 14),
                        ),
                      ),
                    ],
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

                  const SizedBox(height: 16),
                  const Divider(color: AppColors.surfaceBorder, height: 1),
                  const SizedBox(height: 14),

                  // Scan Real ID Card to Extract Photo
                  InkWell(
                    onTap: () => _showIdCardPhotoExtractionSheet(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.caramel.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.caramel.withOpacity(0.35)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.caramel.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.face_retouching_natural, color: AppColors.caramel, size: 18),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Extract Photo from Real ID Card',
                                  style: TextStyle(color: AppColors.ivory, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Decodes barcode & crops student portrait',
                                  style: TextStyle(color: AppColors.softBeige, fontSize: 10.5),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.caramel, size: 18),
                        ],
                      ),
                    ),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          leading: Icon(icon, color: AppColors.caramel),
          title: Text(title, style: const TextStyle(color: AppColors.ivory, fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: const TextStyle(color: AppColors.softBeige, fontSize: 12)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showIdCardPhotoExtractionSheet(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    bool isProcessing = false;
    String? statusMsg;
    String? extractedAvatarUrl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(
                top: BorderSide(color: AppColors.caramel, width: 2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.caramel.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.badge, color: AppColors.caramel, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'College ID Card Photo Scanner',
                            style: TextStyle(
                              color: AppColors.ivory,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'GL Bajaj Institute of Technology & Management',
                            style: TextStyle(color: AppColors.softBeige, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Card Preview Frame
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.caramel.withOpacity(0.4)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/yuvraj_card_front.jpg',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.credit_card, color: AppColors.caramel, size: 48),
                        ),
                      ),
                      // Face bounding crop highlight
                      Positioned(
                        top: 25,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.greenAccent, width: 2),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.greenAccent.withOpacity(0.15),
                          ),
                          child: const Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Text('PORTRAIT', style: TextStyle(color: Colors.greenAccent, fontSize: 7, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                      // Barcode bounding highlight
                      Positioned(
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.caramel, width: 1),
                          ),
                          child: const Text(
                            'BARCODE: 25116CN451 (Code 128)',
                            style: TextStyle(color: AppColors.beige, fontSize: 9, fontFamily: 'Courier', fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                if (statusMsg != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0x334E9F3D),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.greenAccent, width: 1),
                    ),
                    child: Row(
                      children: [
                        if (extractedAvatarUrl != null)
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage('http://127.0.0.1:8000$extractedAvatarUrl'),
                            backgroundColor: AppColors.caramel,
                          )
                        else
                          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            statusMsg!,
                            style: const TextStyle(color: AppColors.ivory, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Action Buttons
                ElevatedButton.icon(
                  onPressed: isProcessing
                      ? null
                      : () async {
                          setModalState(() {
                            isProcessing = true;
                            statusMsg = 'Scanning barcode and cropping student portrait...';
                          });

                          final res = await authProvider.extractPhotoFromIdCard(
                            sampleCard: true,
                            admissionNumber: user?.admissionNumber,
                          );

                          if (res != null) {
                            setModalState(() {
                              isProcessing = false;
                              extractedAvatarUrl = res['avatar_url'];
                              statusMsg = '✓ Extracted photo & Code 128 (${res['admission_number']})! Profile updated in database.';
                            });
                          } else {
                            setModalState(() {
                              isProcessing = false;
                              statusMsg = 'Failed: ${authProvider.errorMessage ?? "Could not crop photo"}';
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.caramel,
                    foregroundColor: AppColors.espressoDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: isProcessing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.espressoDark),
                        )
                      : const Icon(Icons.auto_fix_high, size: 20),
                  label: Text(
                    isProcessing ? 'Processing ID Card...' : 'Scan ID Card & Update Photo Now',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}
