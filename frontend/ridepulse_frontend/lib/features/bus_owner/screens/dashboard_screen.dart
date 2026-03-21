import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';

class BusOwnerDashboardScreen extends ConsumerWidget {
  const BusOwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busesAsync = ref.watch(busListProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Dashboard', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          busesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:   (e, _) => _ErrorCard(message: e.toString()),
            data: (buses) => Column(children: [
              // Stats row
              Row(children: [
                _StatCard(label: 'Total Buses', value: '${buses.length}',
                    icon: Icons.directions_bus, color: const Color(0xFF3B82F6)),
                const SizedBox(width: 16),
                _StatCard(label: 'Active Buses',
                    value: '${buses.where((b) => b.isActive).length}',
                    icon: Icons.check_circle_outline, color: const Color(0xFF10B981)),
              ]),
              const SizedBox(height: 16),
              // Quick actions
              const Align(alignment: Alignment.centerLeft,
                  child: Text('Quick Actions',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
              const SizedBox(height: 12),
              Row(children: [
                _ActionBtn(label: 'Add Bus', icon: Icons.add,
                    onTap: () => context.go('/bus-owner/buses')),
                const SizedBox(width: 12),
                _ActionBtn(label: 'Register Staff', icon: Icons.person_add,
                    onTap: () => context.go('/bus-owner/staff/register')),
                const SizedBox(width: 12),
                _ActionBtn(label: 'Live Map', icon: Icons.location_on,
                    onTap: () => context.go('/bus-owner/live-map')),
              ]),
              const SizedBox(height: 24),
              // Bus list
              const Align(alignment: Alignment.centerLeft,
                  child: Text('Your Fleet',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
              const SizedBox(height: 12),
              ...buses.map((bus) => _BusSummaryCard(
                busNumber: bus.busNumber,
                route: bus.route?.displayName ?? 'No route',
                driver: bus.assignedDriverName,
                conductor: bus.assignedConductorName,
                isActive: bus.isActive,
              )),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value; final IconData icon; final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2))),
      child: Row(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ]),
      ]),
    ),
  );
}

class _ActionBtn extends StatelessWidget {
  final String label; final IconData icon; final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200)),
        child: Column(children: [
          Icon(icon, color: const Color(0xFF1A56DB), size: 22),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ]),
      ),
    ),
  );
}

class _BusSummaryCard extends StatelessWidget {
  final String busNumber, route, driver, conductor;
  final bool isActive;
  const _BusSummaryCard({required this.busNumber, required this.route,
      required this.driver, required this.conductor, required this.isActive});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: isActive
            ? const Color(0xFF10B981).withOpacity(0.1)
            : Colors.grey.shade100,
        child: Icon(Icons.directions_bus,
            color: isActive ? const Color(0xFF10B981) : Colors.grey),
      ),
      title: Text(busNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(route, overflow: TextOverflow.ellipsis),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(driver, style: const TextStyle(fontSize: 11)),
        Text(conductor, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      ]),
    ),
  );
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
    child: Text('Error: $message', style: const TextStyle(color: Colors.red)),
  );
}
