class EventModel {
  final int id;
  final String title;
  final String slug;
  final String description;
  final String category;
  final String bannerUrl;
  final String venue;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime registrationDeadline;
  final double registrationFee;
  final bool isRegistrationOpen;
  final int maxSeats;
  final String tags;
  final String clubName;
  final String clubLogo;
  final int registrationsCount;
  bool isRegistered;

  EventModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.category,
    required this.bannerUrl,
    required this.venue,
    required this.startTime,
    required this.endTime,
    required this.registrationDeadline,
    required this.registrationFee,
    required this.isRegistrationOpen,
    required this.maxSeats,
    required this.tags,
    required this.clubName,
    required this.clubLogo,
    required this.registrationsCount,
    required this.isRegistered,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    String banner = json['banner_url'] ?? '';
    if (banner.startsWith('/static/')) {
      banner = 'http://127.0.0.1:8000$banner';
    }
    String logo = json['club_logo'] ?? '';
    if (logo.startsWith('/static/')) {
      logo = 'http://127.0.0.1:8000$logo';
    }

    return EventModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'hackathon',
      bannerUrl: banner,
      venue: json['venue'] ?? 'GL Bajaj Campus',
      startTime: DateTime.tryParse(json['start_time'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['end_time'] ?? '') ?? DateTime.now(),
      registrationDeadline: DateTime.tryParse(json['registration_deadline'] ?? '') ?? DateTime.now(),
      registrationFee: double.tryParse(json['registration_fee'].toString()) ?? 0.0,
      isRegistrationOpen: json['is_registration_open'] ?? true,
      maxSeats: json['max_seats'] ?? 100,
      tags: json['tags'] ?? '',
      clubName: json['club_name'] ?? '',
      clubLogo: logo,
      registrationsCount: json['registrations_count'] ?? 0,
      isRegistered: json['is_registered'] ?? false,
    );
  }
}

class EventTicketModel {
  final String id;
  final String eventTitle;
  final String eventBanner;
  final String eventVenue;
  final DateTime eventStartTime;
  final String ticketCode;
  final String status;

  EventTicketModel({
    required this.id,
    required this.eventTitle,
    required this.eventBanner,
    required this.eventVenue,
    required this.eventStartTime,
    required this.ticketCode,
    required this.status,
  });

  factory EventTicketModel.fromJson(Map<String, dynamic> json) {
    return EventTicketModel(
      id: json['id']?.toString() ?? '',
      eventTitle: json['event_title'] ?? '',
      eventBanner: json['event_banner'] ?? '',
      eventVenue: json['event_venue'] ?? 'Main Audi, GL Bajaj',
      eventStartTime: DateTime.tryParse(json['event_start_time'] ?? '') ?? DateTime.now(),
      ticketCode: json['ticket_code'] ?? '',
      status: json['status'] ?? 'confirmed',
    );
  }
}
