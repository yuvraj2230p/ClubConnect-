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

  // Fallback high-res slides for immediate instant rendering
  final List<ShowcaseSlide> _fallbackSlides = [
    ShowcaseSlide(
      id: 1,
      title: "GL Bajaj Institute of Technology & Management",
      subtitle: "Home to 30+ Thriving Student Clubs & Societies",
      tag: "Campus Highlights",
      imageUrl: "https://images.unsplash.com/photo-1562774053-701939374585?w=1200&auto=format&fit=crop&q=80",
      badge: "GL Bajaj Greater Noida",
    ),
    ShowcaseSlide(
      id: 2,
      title: "Google Developer Student Club (GDSC)",
      subtitle: "Hackathons, Cloud Jams & Open-Source Projects",
      tag: "Tech Innovation",
      imageUrl: "https://images.unsplash.com/photo-1531482615713-2afd69097998?w=1200&auto=format&fit=crop&q=80",
      badge: "Active Community",
    ),
    ShowcaseSlide(
      id: 3,
      title: "Verve Cultural Club & Street Plays",
      subtitle: "Expressing Creativity through Dance, Drama & Music",
      tag: "Cultural Fest",
      imageUrl: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=1200&auto=format&fit=crop&q=80",
      badge: "Annual Youth Fest",
    ),
    ShowcaseSlide(
      id: 4,
      title: "Rotaract Club of GLBITM",
      subtitle: "Youth Leadership, Social Impact & Community Drives",
      tag: "Social Welfare",
      imageUrl: "https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=1200&auto=format&fit=crop&q=80",
      badge: "Leadership & Impact",
    ),
    ShowcaseSlide(
      id: 5,
      title: "Droid & Robotics Society",
      subtitle: "Autonomous Bots, Drone Arenas & AI Hardware",
      tag: "Robotics Arena",
      imageUrl: "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=1200&auto=format&fit=crop&q=80",
      badge: "Innovation Hub",
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
