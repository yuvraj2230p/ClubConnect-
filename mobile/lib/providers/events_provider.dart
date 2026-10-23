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

  EventsProvider() {
    _events = _buildFallbackEvents();
    fetchEvents();
    fetchMyTickets();
  }

  static List<EventModel> _buildFallbackEvents() {
    final now = DateTime.now();
    return [
      EventModel(
        id: 1,
        title: "HackCodeSpace '26",
        slug: 'hackcodespace-26',
        description: '36-Hour flagship software hackathon with domains in Web3, AI/ML, and Open Innovation.',
        category: 'hackathon',
        bannerUrl: 'http://127.0.0.1:8000/static/images/clubs/codespace_event.jpg',
        venue: 'Main Audi & CSIT Lab Block',
        startTime: now.add(const Duration(days: 10)),
        endTime: now.add(const Duration(days: 12)),
        registrationDeadline: now.add(const Duration(days: 8)),
        registrationFee: 0.0,
        isRegistrationOpen: true,
        maxSeats: 200,
        tags: 'coding,hackathon,tech',
        clubName: 'Code Space Club',
        clubLogo: 'http://127.0.0.1:8000/static/images/clubs/codespace_logo.png',
        registrationsCount: 142,
        isRegistered: false,
      ),
      EventModel(
        id: 2,
        title: 'GLB Talks : 2026',
        slug: 'glb-talks-2026',
        description: 'Distinguished speaker series featuring tech entrepreneurs, authors, and industry pioneers.',
        category: 'workshop',
        bannerUrl: 'http://127.0.0.1:8000/static/images/clubs/shrinik_event.jpg',
        venue: 'Auditorium 1',
        startTime: now.add(const Duration(days: 15)),
        endTime: now.add(const Duration(days: 15, hours: 4)),
        registrationDeadline: now.add(const Duration(days: 14)),
        registrationFee: 0.0,
        isRegistrationOpen: true,
        maxSeats: 350,
        tags: 'keynote,speaker,talks',
        clubName: 'Shrinik Club',
        clubLogo: 'http://127.0.0.1:8000/static/images/clubs/shrinik_logo.png',
        registrationsCount: 290,
        isRegistered: false,
      ),
      EventModel(
        id: 3,
        title: "Tandav '26",
        slug: 'tandav-26',
        description: 'Intra-college dance and musical extravaganza showcasing classical, hip-hop, and fusion.',
        category: 'cultural',
        bannerUrl: 'http://127.0.0.1:8000/static/images/clubs/navrang_event.jpg',
        venue: 'Central Lawns Amphitheatre',
        startTime: now.add(const Duration(days: 18)),
        endTime: now.add(const Duration(days: 18, hours: 6)),
        registrationDeadline: now.add(const Duration(days: 16)),
        registrationFee: 0.0,
        isRegistrationOpen: true,
        maxSeats: 500,
        tags: 'dance,music,cultural',
        clubName: 'Navrang Cultural Club',
        clubLogo: 'http://127.0.0.1:8000/static/images/clubs/navrang_logo.png',
        registrationsCount: 420,
        isRegistered: false,
      ),
      EventModel(
        id: 4,
        title: "Next Orbit '26",
        slug: 'next-orbit-26',
        description: 'Annual summit on student entrepreneurship, cross-branch diversity, and creative leadership.',
        category: 'conference',
        bannerUrl: 'http://127.0.0.1:8000/static/images/clubs/vividhata_event.jpg',
        venue: 'Auditorium 2',
        startTime: now.add(const Duration(days: 22)),
        endTime: now.add(const Duration(days: 23)),
        registrationDeadline: now.add(const Duration(days: 20)),
        registrationFee: 0.0,
        isRegistrationOpen: true,
        maxSeats: 300,
        tags: 'leadership,design,innovation',
        clubName: 'Vividhata Club',
        clubLogo: 'http://127.0.0.1:8000/static/images/clubs/vividhata_logo.png',
        registrationsCount: 210,
        isRegistered: false,
      ),
    ];
  }

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
