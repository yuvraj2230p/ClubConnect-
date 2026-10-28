import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import 'web_cam_bridge.dart';

class IdCardScannerModal extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final String initialAdmissionNumber;
  final String initialEmail;

  const IdCardScannerModal({
    super.key,
    required this.onLoginSuccess,
    this.initialAdmissionNumber = '',
    this.initialEmail = '',
  });

  @override
  State<IdCardScannerModal> createState() => _IdCardScannerModalState();
}

class _IdCardScannerModalState extends State<IdCardScannerModal> with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  late TextEditingController _customCodeController;
  bool _isQrMode = false; // Default to Code 128 Barcode on ID Card Front
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Initial code matching the entered admission number
    _customCodeController = TextEditingController(
      text: widget.initialAdmissionNumber.isNotEmpty
          ? (_isQrMode
              ? 'https://glbg.servergi.com:8072/SIMWEBGLB/hostel/vh?id=${widget.initialAdmissionNumber}'
              : widget.initialAdmissionNumber)
          : '',
    );

    // Listen to real camera scan events from the browser
    listenForCardScan((scannedCode) {
      if (mounted) {
        setState(() {
          _customCodeController.text = scannedCode;
        });
        _scanCode(scannedCode);
      }
    });

    // Auto-launch camera scanner on modal open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        startRealWebcamScan();
      }
    });
  }

  @override
  void dispose() {
    stopListeningForCardScan();
    stopRealWebcamScan();
    _laserController.dispose();
    _customCodeController.dispose();
    super.dispose();
  }

  void _onToggleMode(bool qr) {
    setState(() {
      _isQrMode = qr;
      final adm = widget.initialAdmissionNumber.trim();
      if (adm.isNotEmpty) {
        if (_isQrMode) {
          _customCodeController.text = 'https://glbg.servergi.com:8072/SIMWEBGLB/hostel/vh?id=$adm';
        } else {
          _customCodeController.text = adm;
        }
      }
    });
  }

  void _scanCode(String code) async {
    final cleanCode = code.trim();
    if (cleanCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please align your ID card in front of camera or enter the scanned code.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final adm = widget.initialAdmissionNumber.trim();
    final email = widget.initialEmail.trim();

    bool success;
    if (adm.isNotEmpty && email.isNotEmpty) {
      // 2-Step Anti-Spoofing Cross-Check
      success = await authProvider.verifyAndLoginWithIdCard(
        admissionNumber: adm,
        collegeEmail: email,
        qrCodeData: cleanCode,
      );
    } else {
      // Direct Barcode/QR Scan
      success = await authProvider.loginWithIdCardScan(cleanCode);
    }

    if (success && mounted) {
      setState(() => _isVerified = true);
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) {
        Navigator.pop(context); // Close modal
        widget.onLoginSuccess();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final verifiedUser = authProvider.currentUser;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xF71C130D), // 97% opacity warm dark mocha
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: const Color(0x66DDB892), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.65),
              blurRadius: 32,
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
                margin: const EdgeInsets.only(bottom: 14),
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
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.beige.withOpacity(0.4), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.caramel.withOpacity(0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/glb_logo.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'College ID Card Scanner',
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
                                'Mobile & Desktop Camera Active',
                                style: TextStyle(
                                  color: AppColors.softBeige,
                                  fontSize: 11,
                                ),
                              ),
                            ],
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

              const SizedBox(height: 12),

              // Cross-Check Context Banner
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.caramel.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.beige.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_outlined, color: AppColors.beige, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ANTI-SPOOFING CROSS-CHECK',
                            style: TextStyle(
                              color: AppColors.beige,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Entered ID: ${widget.initialAdmissionNumber} • ${widget.initialEmail}',
                            style: const TextStyle(
                              color: AppColors.ivory,
                              fontSize: 11,
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Real Webcam Launch Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.caramel.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => startRealWebcamScan(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.videocam, color: AppColors.espressoDark, size: 20),
                  label: const Text(
                    'Scan With Real Webcam (Live)',
                    style: TextStyle(
                      color: AppColors.espressoDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Barcode / QR Code Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0x66140D08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x33DDB892)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onToggleMode(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !_isQrMode ? AppColors.caramel : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
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
                                'Barcode (Front)',
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
                        onTap: () => _onToggleMode(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _isQrMode ? AppColors.caramel : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
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
                                'QR Code (Back)',
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

              const SizedBox(height: 14),

              // Animated Laser Viewfinder with GL Bajaj Physical ID Card
              if (!_isVerified) ...[
                Container(
                  height: 190,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.caramel, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Real Physical College ID Card Image
                        Image.asset(
                          !_isQrMode
                              ? 'assets/images/yuvraj_card_front.jpg'
                              : 'assets/images/yuvraj_card_back.jpg',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.credit_card, size: 64, color: AppColors.caramel),
                          ),
                        ),

                        // Front Card: Green Portrait Crop Frame & Yellow Barcode Frame
                        if (!_isQrMode) ...[
                          Positioned(
                            top: 20,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.greenAccent, width: 2.2),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.greenAccent.withOpacity(0.18),
                              ),
                              child: const Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: EdgeInsets.all(3.0),
                                  child: Text(
                                    'PORTRAIT',
                                    style: TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.amberAccent, width: 1.2),
                              ),
                              child: Text(
                                widget.initialAdmissionNumber.isNotEmpty
                                    ? 'BARCODE: ${widget.initialAdmissionNumber}'
                                    : 'ALIGN ID CARD BARCODE',
                                style: const TextStyle(
                                  color: Colors.amberAccent,
                                  fontSize: 9.5,
                                  fontFamily: 'Courier',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          Positioned(
                            bottom: 12,
                            left: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.greenAccent, width: 1.2),
                              ),
                              child: Text(
                                widget.initialAdmissionNumber.isNotEmpty
                                    ? 'QR: ${widget.initialAdmissionNumber}'
                                    : 'ALIGN ID CARD QR CODE',
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 9.5,
                                  fontFamily: 'Courier',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],

                        // Animated Laser Beam
                        AnimatedBuilder(
                          animation: _laserController,
                          builder: (context, child) {
                            return Positioned(
                              top: 14 + (_laserController.value * 155),
                              left: 10,
                              right: 10,
                              child: Container(
                                height: 2.5,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.redAccent.withOpacity(0.9),
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
                          top: 8,
                          left: 8,
                          child: Container(width: 16, height: 16, decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.beige, width: 3), left: BorderSide(color: AppColors.beige, width: 3)))),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(width: 16, height: 16, decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.beige, width: 3), right: BorderSide(color: AppColors.beige, width: 3)))),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(width: 16, height: 16, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.beige, width: 3), left: BorderSide(color: AppColors.beige, width: 3)))),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(width: 16, height: 16, decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.beige, width: 3), right: BorderSide(color: AppColors.beige, width: 3)))),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Success Verification Confirmation Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0x334E9F3D),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.greenAccent, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.caramel,
                        foregroundImage: (verifiedUser?.avatarUrl.isNotEmpty == true)
                            ? NetworkImage(ApiConstants.resolveUrl(verifiedUser!.avatarUrl))
                            : null,
                        onForegroundImageError: (e, s) {},
                        child: Text(
                          (verifiedUser?.fullName.isNotEmpty == true) ? verifiedUser!.fullName[0].toUpperCase() : 'S',
                          style: const TextStyle(color: AppColors.espressoDark, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  verifiedUser?.fullName ?? 'Verified Student',
                                  style: const TextStyle(
                                    color: AppColors.ivory,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${verifiedUser?.semester.isNotEmpty == true ? verifiedUser!.semester : "Sem III"} • ${verifiedUser?.department ?? "B.TECH.(CSIT)"}',
                              style: const TextStyle(color: AppColors.beige, fontSize: 11),
                            ),
                            Text(
                              verifiedUser?.admissionNumber ?? widget.initialAdmissionNumber,
                              style: const TextStyle(
                                color: AppColors.softBeige,
                                fontSize: 10,
                                fontFamily: 'Courier',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Code Payload Box
              TextField(
                controller: _customCodeController,
                style: const TextStyle(color: AppColors.ivory, fontSize: 12, fontFamily: 'Courier'),
                decoration: InputDecoration(
                  labelText: _isQrMode ? 'Scanned QR Payload' : 'Scanned Barcode Text',
                  hintText: 'e.g. *GLB22CSE101*',
                  prefixIcon: Icon(_isQrMode ? Icons.qr_code : Icons.barcode_reader, color: AppColors.caramel, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),

              if (authProvider.errorMessage != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(color: AppColors.error, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Confirm Scan & Cross-Check Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: authProvider.isLoading || _isVerified
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
                      : const Icon(Icons.verified, size: 18, color: AppColors.espressoDark),
                  label: Text(
                    authProvider.isLoading
                        ? 'Cross-Checking Card & SIM DB...'
                        : (_isVerified ? '✓ Identity Verified!' : 'Verify ID Card & Sign In'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
