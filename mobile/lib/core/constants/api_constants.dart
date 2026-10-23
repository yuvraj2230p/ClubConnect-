import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Base API configuration
  static String get baseUrl {
    // 1. Check if production URL was passed during build via --dart-define=API_BASE_URL=...
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // 2. Default local development URLs
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else if (Platform.isAndroid) {
      // Android emulator loopback alias
      return 'http://10.0.2.2:8000/api';
    } else {
      // iOS Simulator or macOS desktop
      return 'http://127.0.0.1:8000/api';
    }
  }

  // Endpoints
  static const String simLogin = '/auth/sim-login/';
  static const String idCardScan = '/auth/id-card-scan/';
  static const String verifyIdCard = '/auth/verify-id-card/';
  static const String extractIdCardPhoto = '/auth/extract-id-card-photo/';
  static const String currentUser = '/auth/me/';
  static const String showcaseSlides = '/auth/showcase-slides/';
  
  static const String clubs = '/clubs/';
  static const String clubAnnouncements = '/clubs/announcements/';
  static String clubDetail(String slug) => '/clubs/$slug/';
  static String joinClub(String slug) => '/clubs/$slug/join/';
  static String leaveClub(String slug) => '/clubs/$slug/leave/';
  static String presidentDashboard(String slug) => '/clubs/$slug/dashboard/';
  static String clubPosts(String slug) => '/clubs/$slug/posts/';
  static String clubPostDelete(String slug, int id) => '/clubs/$slug/posts/$id/';
  static String clubAnnouncementCreate(String slug) => '/clubs/$slug/announcements/create/';
  static String clubAdmissionSettings(String slug) => '/clubs/$slug/admission-settings/';

  static const String events = '/events/';
  static const String myTickets = '/events/my-tickets/';
  static String eventDetail(String slug) => '/events/$slug/';
  static String registerEvent(String slug) => '/events/$slug/register/';
}
