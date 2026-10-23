import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import 'id_card_scanner_modal.dart';

class SimLoginCard extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const SimLoginCard({super.key, required this.onLoginSuccess});

  @override
  State<SimLoginCard> createState() => _SimLoginCardState();
}

class _SimLoginCardState extends State<SimLoginCard> {
  final _admissionController = TextEditingController(text: '25116CN451');
  final _emailController = TextEditingController(text: '25116cn451@glbitm.ac.in');
  final _passwordController = TextEditingController(text: 'simpass123');
  bool _obscurePassword = true;
  bool _showPasswordLogin = false; // By default prioritize physical ID card scan

  @override
  void initState() {
    super.initState();
    _admissionController.addListener(_onAdmissionChanged);
  }

  @override
  void dispose() {
    _admissionController.removeListener(_onAdmissionChanged);
    _admissionController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onAdmissionChanged() {
    final adm = _admissionController.text.trim().toLowerCase();
    if (adm.isNotEmpty) {
      final currentEmail = _emailController.text.trim().toLowerCase();
      // Auto-suggest college email if empty or matches standard pattern
      if (currentEmail.isEmpty || currentEmail.endsWith('@glbitm.ac.in')) {
        _emailController.text = '$adm@glbitm.ac.in';
      }
    }
  }

  void _fillDemo(String adm, String email, String pass) {
    setState(() {
      _admissionController.text = adm;
      _emailController.text = email;
      _passwordController.text = pass;
    });
  }

  void _openIdScanner() {
    final adm = _admissionController.text.trim();
    final email = _emailController.text.trim();

    if (adm.isEmpty) {
      _showWarning('Please enter your GL Bajaj Admission Number.');
      return;
    }

    if (!email.toLowerCase().endsWith('@glbitm.ac.in')) {
      _showWarning('College email must end with @glbitm.ac.in');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => IdCardScannerModal(
        onLoginSuccess: widget.onLoginSuccess,
        initialAdmissionNumber: adm,
        initialEmail: email,
      ),
    );
  }

  void _handlePasswordLogin() async {
    final adm = _admissionController.text.trim();
    final pass = _passwordController.text;

    if (adm.isEmpty || pass.isEmpty) {
      _showWarning('Please enter your admission number and SIM password.');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithSIM(adm, pass);
    if (success && mounted) {
      widget.onLoginSuccess();
    }
  }

  void _showWarning(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Translucent Frosted Glass Card in Warm Beige & Mocha Brown
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xB8231710), // Warm mocha 72% opacity
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0x55DDB892), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.45),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.beige.withOpacity(0.4), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.caramel.withOpacity(0.25),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/glb_logo.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Student ID Verification',
                          style: TextStyle(
                            color: AppColors.ivory,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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
                              'GLBITM SIM Records Sync',
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
                      '2-STEP AUTH',
                      style: TextStyle(
                        color: AppColors.beige,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Step 1: Admission Number Field
              TextField(
                controller: _admissionController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(color: AppColors.ivory, fontSize: 14, fontFamily: 'Courier', fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'College Admission Number',
                  hintText: 'e.g. GLB22CSE101 or 2201920100101',
                  prefixIcon: const Icon(Icons.fingerprint, size: 20, color: AppColors.caramel),
                  suffixIcon: _admissionController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: AppColors.softBeige),
                          onPressed: () => setState(() => _admissionController.clear()),
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 12),

              // Step 2: College Gmail ID Field (starts with admission number + @glbitm.ac.in)
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.ivory, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Official College Gmail ID',
                  hintText: 'e.g. <admission_no>@glbitm.ac.in',
                  helperText: 'Must start with Admission No. & end with @glbitm.ac.in',
                  helperStyle: TextStyle(color: AppColors.softBeige.withOpacity(0.7), fontSize: 10),
                  prefixIcon: const Icon(Icons.alternate_email, size: 18, color: AppColors.caramel),
                  suffixIcon: const Icon(Icons.verified, size: 16, color: AppColors.accentCyan),
                ),
              ),

              const SizedBox(height: 14),

              // Quick Test Student Records Chips
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚡ Tap to load sample student credentials:',
                    style: TextStyle(color: AppColors.softBeige, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildDemoChip('Yuvraj (25116CN451 • CSIT)', '25116CN451', '25116cn451@glbitm.ac.in'),
                        const SizedBox(width: 8),
                        _buildDemoChip('Ananya (IT • 8th Sem)', 'GLB21IT045', 'glb21it045@glbitm.ac.in'),
                        const SizedBox(width: 8),
                        _buildDemoChip('Rohan (AIML • 4th Sem)', 'GLB23AIML022', 'glb23aiml022@glbitm.ac.in'),
                      ],
                    ),
                  ),
                ],
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

              // Primary Action: Scan Physical ID Card (QR / Barcode)
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
                  onPressed: authProvider.isLoading ? null : _openIdScanner,
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
                            Icon(Icons.qr_code_scanner, size: 22, color: AppColors.espressoDark),
                            SizedBox(width: 10),
                            Text(
                              'Scan ID Card & Auto-Verify',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                                color: AppColors.espressoDark,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Password toggle for students without physical card
              Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _showPasswordLogin = !_showPasswordLogin),
                  icon: Icon(
                    _showPasswordLogin ? Icons.keyboard_arrow_up : Icons.lock_outline,
                    size: 16,
                    color: AppColors.softBeige,
                  ),
                  label: Text(
                    _showPasswordLogin ? 'Hide Password Login' : 'Don\'t have physical card? Use SIM Password',
                    style: TextStyle(
                      color: AppColors.softBeige.withOpacity(0.9),
                      fontSize: 11,
                    ),
                  ),
                ),
              ),

              if (_showPasswordLogin) ...[
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: AppColors.ivory, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'SIM Portal Password',
                    hintText: 'Enter college ERP password',
                    prefixIcon: const Icon(Icons.key, size: 18, color: AppColors.caramel),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 18,
                        color: AppColors.softBeige,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: authProvider.isLoading ? null : _handlePasswordLogin,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0x66DDB892)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.login, size: 16, color: AppColors.beige),
                  label: const Text(
                    'Authenticate with Password',
                    style: TextStyle(color: AppColors.ivory, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // Informational footnote
              Center(
                child: Text(
                  'Name, photo, and semester will automatically sync from college SIM records upon scan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted.withOpacity(0.8),
                    fontSize: 10.5,
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

  Widget _buildDemoChip(String label, String adm, String email) {
    final isSelected = _admissionController.text.trim().toUpperCase() == adm;
    return GestureDetector(
      onTap: () => _fillDemo(adm, email, 'simpass123'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.caramel.withOpacity(0.35) : const Color(0x661F140D),
          borderRadius: BorderRadius.circular(14),
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
