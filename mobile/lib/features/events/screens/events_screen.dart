import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/event_model.dart';
import '../../../providers/events_provider.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsProvider = context.watch<EventsProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        title: const Text(
          'Campus Events & Fests',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentGold,
          labelColor: AppColors.accentGold,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            const Tab(text: 'Upcoming Events'),
            Tab(text: 'My Event Passes (${eventsProvider.myTickets.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Upcoming Events
          eventsProvider.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.accentIndigo))
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: eventsProvider.events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final event = eventsProvider.events[index];
                    return _buildEventCard(context, event, eventsProvider);
                  },
                ),

          // My Registered Tickets
          eventsProvider.myTickets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.confirmation_number_outlined, size: 60, color: AppColors.textMuted.withOpacity(0.5)),
                      const SizedBox(height: 14),
                      const Text(
                        'No event passes yet.',
                        style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Register for an event to get your verified college digital ticket.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: eventsProvider.myTickets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final ticket = eventsProvider.myTickets[index];
                    return _buildTicketCard(ticket);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event, EventsProvider provider) {
    String bannerAsset = 'assets/images/campus/glb_academic.webp';
    if (event.slug.contains('codespace')) {
      bannerAsset = 'assets/images/clubs/codespace_event.jpg';
    } else if (event.slug.contains('shrinik') || event.slug.contains('glb-talks')) {
      bannerAsset = 'assets/images/clubs/shrinik_event.jpg';
    } else if (event.slug.contains('navrang') || event.slug.contains('tandav')) {
      bannerAsset = 'assets/images/clubs/navrang_event.jpg';
    } else if (event.slug.contains('vividhata') || event.slug.contains('next-orbit')) {
      bannerAsset = 'assets/images/clubs/vividhata_event.jpg';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 140,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  event.bannerUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(bannerAsset, fit: BoxFit.cover),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppColors.surfaceCard],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentIndigo,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      event.category.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      event.registrationFee == 0 ? 'FREE ENTRY' : '₹${event.registrationFee}',
                      style: const TextStyle(color: AppColors.accentGold, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Organized by ${event.clubName}',
                  style: const TextStyle(color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Text(
                  event.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.venue,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: event.isRegistered
                        ? null
                        : () async {
                            final ticketCode = await provider.registerForEvent(event.slug);
                            if (ticketCode != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('🎟️ Registered! Ticket Code: $ticketCode'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              _tabController.animateTo(1);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: event.isRegistered ? AppColors.surfaceBorder : AppColors.accentIndigo,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      event.isRegistered ? '✓ Registered' : 'Register for Event',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(EventTicketModel ticket) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentGold.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGold.withOpacity(0.1),
            blurRadius: 15,
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.confirmation_number, color: AppColors.accentGold, size: 14),
                    SizedBox(width: 6),
                    Text('COLLEGE EVENT PASS', style: TextStyle(color: AppColors.accentGold, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('CONFIRMED', style: TextStyle(color: AppColors.accentCyan, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            ticket.eventTitle,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            ticket.eventVenue,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PASS CODE', style: TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 0.5)),
                    Text(
                      ticket.ticketCode,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1),
                    ),
                  ],
                ),
                const Icon(Icons.qr_code_2, size: 36, color: Colors.white70),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
