import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/club_model.dart';

class ClubsProvider extends ChangeNotifier {
  List<ClubModel> _clubs = [];
  List<AnnouncementModel> _announcements = [];
  bool _isLoading = false;
  String _selectedCategory = 'all';
  String? _errorMessage;

  List<ClubModel> get clubs => _clubs;
  List<AnnouncementModel> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String? get errorMessage => _errorMessage;

  List<ClubModel> get filteredClubs {
    if (_selectedCategory == 'all') {
      return _clubs;
    }
    return _clubs.where((c) => c.category == _selectedCategory).toList();
  }

  Future<void> fetchClubs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient.get(ApiConstants.clubs);
      if (res is List) {
        _clubs = res.map((json) => ClubModel.fromJson(json)).toList();
      }
      final annRes = await ApiClient.get(ApiConstants.clubAnnouncements);
      if (annRes is List) {
        _announcements = annRes.map((json) => AnnouncementModel.fromJson(json)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('HttpException: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<bool> joinClub(String slug) async {
    try {
      await ApiClient.post(ApiConstants.joinClub(slug), {});
      final index = _clubs.indexWhere((c) => c.slug == slug);
      if (index != -1) {
        _clubs[index].isJoined = true;
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
