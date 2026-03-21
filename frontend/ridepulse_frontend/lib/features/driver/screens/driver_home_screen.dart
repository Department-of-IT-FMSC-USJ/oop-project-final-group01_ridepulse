import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';

class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E40AF),
        foregroundColor: Colors.white,
        title: const Text('Driver Panel', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () async {
          await ref.read(authProvider.notifier).logout();
          if (context.mounted) context.go('/login');
        })],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Welcome, \${auth.fullName ?? "Driver"}!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Driver ID: \${auth.staffId ?? "N/A"}',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          // Today's duty card
          _DutyCard(),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.2,
            children: [
              _Card(icon: Icons.map_outlined, label: 'My Route',
                  color: const Color(0xFF3B82F6), onTap: () {}),
              _Card(icon: Icons.warning_amber_outlined, label: 'Emergency Alert',
                  color: const Color(0xFFEF4444), onTap: () {}),
              _Card(icon: Icons.calendar_today_outlined, label: 'Duty Roster',
                  color: const Color(0xFF10B981), onTap: () {}),
              _Card(icon: Icons.volunteer_activism_outlined, label: 'My Welfare',
                  color: const Color(0xFFF59E0B), onTap: () {}),
            ],
          ),
        ]),
      ),
    );
  }
}

class _DutyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)]),
      borderRadius: BorderRadius.circular(14)),
    child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Today's Duty", style: TextStyle(color: Colors.white70, fontSize: 13)),
      SizedBox(height: 6),
      Text('No duty scheduled', style: TextStyle(color: Colors.white,
          fontSize: 18, fontWeight: FontWeight.bold)),
      SizedBox(height: 4),
      Text('Check with your bus owner for assignments',
          style: TextStyle(color: Colors.white70, fontSize: 12)),
    ]),
  );
}

class _Card extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _Card({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 10),
        Text(label, textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 13)),
      ]),
    ),
  );
}
