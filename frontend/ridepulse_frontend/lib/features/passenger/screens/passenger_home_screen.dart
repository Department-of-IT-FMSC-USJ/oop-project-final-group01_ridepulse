import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';

class PassengerHomeScreen extends ConsumerWidget {
  const PassengerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('RidePulse',
            style: TextStyle(fontWeight: FontWeight.bold,
                color: Color(0xFF1A56DB))),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Greeting
          Text('Hello, \${auth.fullName?.split(" ").first ?? "Passenger"}! 👋',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Where are you going today?',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 20),

          // Search bar — taps into search screen
          GestureDetector(
            onTap: () => context.go('/passenger/search'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(children: [
                const Icon(Icons.search,
                    color: Color(0xFF1A56DB), size: 22),
                const SizedBox(width: 12),
                Text('Search bus route or destination…',
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 15)),
              ]),
            ),
          ),
          const SizedBox(height: 24),

          // Feature grid
          const Text('What do you need?',
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14, mainAxisSpacing: 14,
            childAspectRatio: 1.15,
            children: [
              _FeatureCard(
                icon: Icons.search,
                label: 'Search Routes',
                subtitle: 'Find your bus',
                color: const Color(0xFF1A56DB),
                onTap: () => context.go('/passenger/search')),
              _FeatureCard(
                icon: Icons.location_on_outlined,
                label: 'Live Tracking',
                subtitle: 'Track bus location',
                color: const Color(0xFF10B981),
                onTap: () => context.go('/passenger/search')),
              _FeatureCard(
                icon: Icons.people_outline,
                label: 'Crowd Level',
                subtitle: 'See how crowded',
                color: const Color(0xFFF59E0B),
                onTap: () => context.go('/passenger/search')),
              _FeatureCard(
                icon: Icons.auto_graph,
                label: 'Crowd Forecast',
                subtitle: 'AI prediction',
                color: const Color(0xFF8B5CF6),
                onTap: () => context.go('/passenger/search')),
              _FeatureCard(
                icon: Icons.report_problem_outlined,
                label: 'My Complaints',
                subtitle: 'View & track',
                color: const Color(0xFFEF4444),
                onTap: () => context.go('/passenger/complaints')),
              _FeatureCard(
                icon: Icons.confirmation_number_outlined,
                label: 'Tickets',
                subtitle: 'Coming soon',
                color: Colors.grey,
                onTap: () => _showComingSoon(context, 'Ticket Booking')),
            ],
          ),
        ]),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text(
            '$feature will be available in the next update.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Got it')),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _FeatureCard({required this.icon, required this.label,
      required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
        Icon(icon, color: color, size: 28),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color, fontSize: 13)),
          Text(subtitle, style: TextStyle(
              color: color.withOpacity(0.7), fontSize: 11)),
        ]),
      ]),
    ),
  );
}
