import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';
import '../models/showcase_slide.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  List<ShowcaseSlide> _slides = [];
  bool _isSlidesLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ShowcaseSlide> get slides => _slides;
  bool get isSlidesLoading => _isSlidesLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    loadShowcaseSlides();
    checkAuthStatus();
  }

  // Authentic GL Bajaj campus photos provided for the login slideshow
  final List<ShowcaseSlide> _fallbackSlides = [
    ShowcaseSlide(
      id: 1,
      title: "G.L. Bajaj Institute of Technology & Management",
      subtitle: "Gate 1 & Main Academic Blocks, Greater Noida",
      tag: "GL Bajaj Campus",
      imageUrl: "assets/images/campus/glb_gate1.webp",
      badge: "Gate 1",
      isAsset: true,
    ),
    ShowcaseSlide(
      id: 2,
      title: "Innovation & Green Academic Environment",
      subtitle: "Home to 30+ Thriving Student Clubs & Societies",
      tag: "Campus Life",
      imageUrl: "assets/images/campus/glb_academic.webp",
      badge: "Academic Block 1",
      isAsset: true,
    ),
    ShowcaseSlide(
      id: 3,
      title: "Club Connect: The Student Society Hub",
      subtitle: "Explore Technical, Cultural, Robotics & Sports Clubs",
      tag: "Societies & Fests",
      imageUrl: "assets/images/campus/glb_panorama.jpg",
      badge: "Campus Panorama",
      isAsset: true,
    ),
  ];

  Future<void> loadShowcaseSlides() async {
    _isSlidesLoading = true;
    _slides = _fallbackSlides; // Instant display
    notifyListeners();

    try {
      final res = await ApiClient.get(ApiConstants.showcaseSlides);
      if (res != null && res['slides'] != null) {
        final List list = res['slides'];
        _slides = list.map((item) => ShowcaseSlide.fromJson(item)).toList();
      }
    } catch (_) {
      // Retain fallback slides if network is slow/offline
    } finally {
      _isSlidesLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithSIM(String identifier, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.post(ApiConstants.simLogin, {
        'identifier': identifier,
        'password': password,
      });

      if (response != null && response['token'] != null) {
        final token = response['token'];
        await ApiClient.saveToken(token);
        _currentUser = UserModel.fromJson(response['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = "Authentication response invalid.";
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('HttpException: ', '');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> loginWithIdCardScan(String codeData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.post(ApiConstants.idCardScan, {
        'code_data': codeData,
      });

      if (response != null && response['token'] != null) {
        final token = response['token'];
        await ApiClient.saveToken(token);
        _currentUser = UserModel.fromJson(response['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = "College ID card verification failed.";
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('HttpException: ', '');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> verifyAndLoginWithIdCard({
    required String admissionNumber,
    required String collegeEmail,
    required String qrCodeData,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.post(ApiConstants.verifyIdCard, {
        'admission_number': admissionNumber,
        'college_email': collegeEmail,
        'qr_code_data': qrCodeData,
      });

      if (response != null && response['token'] != null) {
        final token = response['token'];
        await ApiClient.saveToken(token);
        _currentUser = UserModel.fromJson(response['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = "ID Card Verification failed.";
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('HttpException: ', '');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Extracts student portrait photo and barcode directly from the physical ID card,
  /// attaches the photo to user's profile and updates the database avatar.
  Future<Map<String, dynamic>?> extractPhotoFromIdCard({
    String? base64Image,
    bool sampleCard = false,
    String? admissionNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> body = {};
      if (sampleCard) {
        body['sample_card'] = 'yuvraj_front';
      }
      if (base64Image != null) {
        body['card_image_base64'] = base64Image;
      }
      if (admissionNumber != null) {
        body['admission_number'] = admissionNumber;
      }

      final response = await ApiClient.post(ApiConstants.extractIdCardPhoto, body);
      if (response != null && response['status'] == 'success') {
        if (response['token'] != null) {
          await ApiClient.saveToken(response['token']);
        }
        if (response['user'] != null) {
          _currentUser = UserModel.fromJson(response['user']);
        } else if (_currentUser != null && response['avatar_url'] != null) {
          _currentUser = _currentUser!.copyWith(
            avatarUrl: ApiConstants.resolveUrl(response['avatar_url']),
          );
        }
        _isLoading = false;
        notifyListeners();
        return response;
      }
      _errorMessage = response?['error'] ?? "Failed to extract photo from ID card.";
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('HttpException: ', '');
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<void> checkAuthStatus() async {
    try {
      final token = await ApiClient.getToken();
      if (token != null) {
        final response = await ApiClient.get(ApiConstants.currentUser);
        if (response != null) {
          _currentUser = UserModel.fromJson(response);
          notifyListeners();
        }
      }
    } catch (_) {
      await ApiClient.clearToken();
      _currentUser = null;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await ApiClient.clearToken();
    _currentUser = null;
    notifyListeners();
  }
}
