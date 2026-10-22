import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/showcase_carousel.dart';
import '../widgets/sim_login_card.dart';

class SimLoginScreen extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  const SimLoginScreen({super.key, required this.onLoginSuccess});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section: Sliding Carousel showing GL Bajaj campus & clubs
            Stack(
              children: [
                ShowcaseCarousel(
                  slides: authProvider.slides,
                  height: size.height * 0.44,
                ),

                // Top College Branding Bar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // GL Bajaj Logo Pill in warm Brown & Beige
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.espressoDark.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: AppColors.beige.withOpacity(0.35)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.hub_rounded, color: AppColors.beige, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'CLUB CONNECT',
                                style: TextStyle(
                                  color: AppColors.ivory,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // College Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.espressoDark.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.beige.withOpacity(0.2)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: AppColors.accentCyan, size: 14),
                              SizedBox(width: 5),
                              Text(
                                'GL Bajaj, Gr. Noida',
                                style: TextStyle(
                                  color: AppColors.softBeige,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Section: Translucent SIM Login Form over the background
            Transform.translate(
              offset: const Offset(0, -22),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SimLoginCard(onLoginSuccess: onLoginSuccess)
                        .animate()
                        .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                        .slideY(begin: 0.1, end: 0, duration: 500.ms),

                    const SizedBox(height: 24),

                    // College Accreditation Footer in Warm Beige
                    Column(
                      children: [
                        Text(
                          'G.L. BAJAJ INSTITUTE OF TECHNOLOGY & MANAGEMENT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.softBeige.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Approved by AICTE | Affiliated to Dr. A.P.J. Abdul Kalam Technical University',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textMuted.withOpacity(0.6),
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
