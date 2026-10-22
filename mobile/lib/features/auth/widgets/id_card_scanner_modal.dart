import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';

class IdCardScannerModal extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const IdCardScannerModal({super.key, required this.onLoginSuccess});

  @override
  State<IdCardScannerModal> createState() => _IdCardScannerModalState();
}

class _IdCardScannerModalState extends State<IdCardScannerModal> with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  final TextEditingController _customCodeController = TextEditingController(text: '*GLB22CSE101*');
  bool _isQrMode = false;
  String _activePreset = 'Yuvraj (CSE)';

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _laserController.dispose();
    _customCodeController.dispose();
    super.dispose();
  }

  void _scanCode(String code) async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithIdCardScan(code);
    if (success && mounted) {
      Navigator.pop(context); // Close modal
      widget.onLoginSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xF21C130D), // 95% opacity warm dark mocha
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: const Color(0x66DDB892), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.beige.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.caramel.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.beige.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.qr_code_scanner, color: AppColors.beige, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'College ID Card Scanner',
                            style: TextStyle(
                              color: AppColors.ivory,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Scan Barcode or QR Code to Auto-Login',
                            style: TextStyle(
                              color: AppColors.softBeige,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.softBeige, size: 20),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Barcode / QR Code Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0x66140D08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x33DDB892)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isQrMode = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !_isQrMode ? AppColors.caramel : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.line_weight_sharp,
                                size: 16,
                                color: !_isQrMode ? AppColors.espressoDark : AppColors.softBeige,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Barcode (Back)',
                                style: TextStyle(
                                  color: !_isQrMode ? AppColors.espressoDark : AppColors.softBeige,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isQrMode = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _isQrMode ? AppColors.caramel : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_2,
                                size: 16,
                                color: _isQrMode ? AppColors.espressoDark : AppColors.softBeige,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'QR Code (Front)',
                                style: TextStyle(
                                  color: _isQrMode ? AppColors.espressoDark : AppColors.softBeige,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Animated Laser Viewfinder matching GL Bajaj ID Card Frame
              Container(
                height: 170,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.beige.withOpacity(0.6), width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // ID Card Simulated Guide
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!_isQrMode) ...[
                                // Barcode Graphic
                                Icon(Icons.line_weight, size: 70, color: AppColors.beige.withOpacity(0.35)),
                                const SizedBox(height: 6),
                                Text(
                                  _customCodeController.text,
                                  style: TextStyle(
                                    color: AppColors.beige.withOpacity(0.7),
                                    fontFamily: 'Courier',
                                    fontSize: 13,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ] else ...[
                                // QR Code Graphic
                                Icon(Icons.qr_code_2, size: 80, color: AppColors.beige.withOpacity(0.4)),
                                const SizedBox(height: 4),
                                Text(
                                  'GL Bajaj Student QR',
                                  style: TextStyle(
                                    color: AppColors.beige.withOpacity(0.7),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Animated Laser Beam
                      AnimatedBuilder(
                        animation: _laserController,
                        builder: (context, child) {
                          return Positioned(
                            top: 20 + (_laserController.value * 120),
                            left: 20,
                            right: 20,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.accentCyan,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentCyan.withOpacity(0.8),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Corner Brackets
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(width: 16, height: 16, decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.beige, width: 3), left: BorderSide(color: AppColors.beige, width: 3)))),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(width: 16, height: 16, decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.beige, width: 3), right: BorderSide(color: AppColors.beige, width: 3)))),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(width: 16, height: 16, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.beige, width: 3), left: BorderSide(color: AppColors.beige, width: 3)))),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(width: 16, height: 16, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.beige, width: 3), right: BorderSide(color: AppColors.beige, width: 3)))),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick Test ID Card Presets
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '⚡ Tap to simulate scanning physical GL Bajaj cards:',
                  style: TextStyle(color: AppColors.softBeige.withOpacity(0.9), fontSize: 11),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  _buildPresetChip('Yuvraj (CSE)', '*GLB22CSE101*'),
                  const SizedBox(width: 8),
                  _buildPresetChip('Ananya (IT)', '*GLB21IT045*'),
                  const SizedBox(width: 8),
                  _buildPresetChip('Rohan (AIML)', '*GLB23AIML022*'),
                ],
              ),

              const SizedBox(height: 14),

              // Code input (can type, paste, or scan)
              TextField(
                controller: _customCodeController,
                style: const TextStyle(color: AppColors.ivory, fontSize: 13, fontFamily: 'Courier'),
                decoration: InputDecoration(
                  labelText: _isQrMode ? 'Scanned QR Payload' : 'Scanned Barcode Text',
                  hintText: 'e.g. *GLB22CSE101*',
                  prefixIcon: Icon(_isQrMode ? Icons.qr_code : Icons.barcode_reader, color: AppColors.caramel, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),

              if (authProvider.errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  authProvider.errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 11),
                ),
              ],

              const SizedBox(height: 16),

              // Confirm Scan & Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: authProvider.isLoading
                      ? null
                      : () => _scanCode(_customCodeController.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.caramel,
                    foregroundColor: AppColors.espressoDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: authProvider.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.espressoDark),
                        )
                      : const Icon(Icons.flash_on, size: 18, color: AppColors.espressoDark),
                  label: Text(
                    authProvider.isLoading ? 'Verifying with College DB...' : 'Scan & Log In Instantly',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, String code) {
    final isSelected = _activePreset == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activePreset = label;
            _customCodeController.text = code;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.caramel.withOpacity(0.3) : const Color(0x661F140D),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.beige : const Color(0x33DDB892),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.ivory : AppColors.softBeige,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
