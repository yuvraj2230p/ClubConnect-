import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';

class SimLoginCard extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const SimLoginCard({super.key, required this.onLoginSuccess});

  @override
  State<SimLoginCard> createState() => _SimLoginCardState();
}

class _SimLoginCardState extends State<SimLoginCard> {
  final _identifierController = TextEditingController(text: 'GLB22CSE101');
  final _passwordController = TextEditingController(text: 'simpass123');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your college email or admission number.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithSIM(identifier, password);
    if (success && mounted) {
      widget.onLoginSuccess();
    }
  }

  void _fillDemo(String id, String pass) {
    setState(() {
      _identifierController.text = id;
      _passwordController.text = pass;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Translucent Frosted Glass Card showing the college photo subtly beneath
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xB8231710), // Warm brown 72% opacity
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0x55DDB892), width: 1.2), // Warm beige translucent border
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SIM Status Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.caramel.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.beige.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.account_balance, color: AppColors.beige, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GL Bajaj SIM Login',
                          style: TextStyle(
                            color: AppColors.ivory,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.accentCyan,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Direct College DB Sync',
                              style: TextStyle(
                                color: AppColors.softBeige,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.caramel.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.beige.withOpacity(0.4)),
                    ),
                    child: const Text(
                      'SIM ERP',
                      style: TextStyle(
                        color: AppColors.beige,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Identifier Field
              TextField(
                controller: _identifierController,
                style: const TextStyle(color: AppColors.ivory, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'College Email / Admission No.',
                  hintText: 'e.g. GLB22CSE101 or name@glbitm.ac.in',
                  prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: AppColors.caramel),
                  suffixIcon: _identifierController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: AppColors.softBeige),
                          onPressed: () => setState(() => _identifierController.clear()),
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 14),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: AppColors.ivory, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'SIM Portal Password',
                  hintText: 'Enter college portal password',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.caramel),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.softBeige,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              if (authProvider.errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(color: AppColors.error, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // Fast Test Credentials Selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚡ Tap to test pre-verified student records:',
                    style: TextStyle(color: AppColors.softBeige, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildDemoChip('Yuvraj (CSE)', 'GLB22CSE101'),
                        const SizedBox(width: 8),
                        _buildDemoChip('Ananya (Lead)', 'GLB21IT045'),
                        const SizedBox(width: 8),
                        _buildDemoChip('Rohan (AI/ML)', 'GLB23AIML022'),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Submit Button in Warm Caramel & Beige
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.caramel.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.espressoDark),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login, size: 20, color: AppColors.espressoDark),
                            SizedBox(width: 10),
                            Text(
                              'Authenticate with SIM',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                                color: AppColors.espressoDark,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 14),

              // Note
              const Center(
                child: Text(
                  'No account creation needed. Your profile is automatically verified from GL Bajaj student records.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoChip(String label, String id) {
    final isSelected = _identifierController.text == id;
    return GestureDetector(
      onTap: () => _fillDemo(id, 'simpass123'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.caramel.withOpacity(0.35) : const Color(0x661F140D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.beige : const Color(0x33DDB892),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.ivory : AppColors.softBeige,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
