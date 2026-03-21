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
            style: TextStyle(fontWeight: FontWeight.bold)),
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
          Text('Hello, ${auth.fullName ?? "Passenger"}!',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          Text('What do you need today?',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.2,
            children: [
              _HomeCard(
                  icon: Icons.report_problem_outlined,
                  label: 'My Complaints',
                  color: const Color(0xFFEF4444),
                  onTap: () => context.go('/passenger/complaints')),
              _HomeCard(
                  icon: Icons.add_circle_outline,
                  label: 'File Complaint',
                  color: const Color(0xFF3B82F6),
                  onTap: () =>
                      context.go('/passenger/complaints/submit')),
              _HomeCard(
                  icon: Icons.map_outlined,
                  label: 'Track Bus',
                  color: const Color(0xFF10B981),
                  onTap: () {}),
              _HomeCard(
                  icon: Icons.confirmation_number_outlined,
                  label: 'My Tickets',
                  color: const Color(0xFFF59E0B),
                  onTap: () {}),
            ],
          ),
        ]),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _HomeCard(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.2))),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 10),
                Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                        fontSize: 13)),
              ]),
        ),
      );
}
