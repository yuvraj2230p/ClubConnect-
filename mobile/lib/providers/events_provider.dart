import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/event_model.dart';

class EventsProvider extends ChangeNotifier {
  List<EventModel> _events = [];
  List<EventTicketModel> _myTickets = [];
  bool _isLoading = false;
  String _selectedCategory = 'all';
  String? _errorMessage;

  List<EventModel> get events => _events;
  List<EventTicketModel> get myTickets => _myTickets;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String? get errorMessage => _errorMessage;

  List<EventModel> get filteredEvents {
    if (_selectedCategory == 'all') {
      return _events;
    }
    return _events.where((e) => e.category == _selectedCategory).toList();
  }

  Future<void> fetchEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiClient.get(ApiConstants.events);
      if (res is List) {
        _events = res.map((json) => EventModel.fromJson(json)).toList();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('HttpException: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyTickets() async {
    try {
      final res = await ApiClient.get(ApiConstants.myTickets);
      if (res is List) {
        _myTickets = res.map((json) => EventTicketModel.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<String?> registerForEvent(String slug) async {
    try {
      final res = await ApiClient.post(ApiConstants.registerEvent(slug), {});
      final index = _events.indexWhere((e) => e.slug == slug);
      if (index != -1) {
        _events[index].isRegistered = true;
        notifyListeners();
      }
      await fetchMyTickets();
      if (res != null && res['registration'] != null) {
        return res['registration']['ticket_code'];
      }
      return res?['ticket_code'] ?? 'CONFIRMED';
    } catch (e) {
      return null;
    }
  }
}
