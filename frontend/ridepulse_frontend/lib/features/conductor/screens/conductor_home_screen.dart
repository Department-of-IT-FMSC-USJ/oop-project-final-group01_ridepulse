import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/conductor_models.dart';

class ConductorHomeScreen extends ConsumerWidget {
  const ConductorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth  = ref.watch(authProvider);
    final async = ref.watch(conductorDashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB45309),
        foregroundColor: Colors.white,
        title: const Text('Conductor Panel',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(conductorDashboardProvider)),
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              }),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => _ErrorBody(error: e.toString(),
            onRetry: () => ref.invalidate(conductorDashboardProvider)),
        data: (dashboard) => _DashboardBody(dashboard: dashboard),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final ConductorDashboardModel dashboard;
  const _DashboardBody({required this.dashboard});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Greeting
      Text('Hello, \${dashboard.conductorName}!',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Text('Employee ID: \${dashboard.employeeId}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      const SizedBox(height: 20),

      // Today's duty card
      _TodayDutyCard(dashboard: dashboard),
      const SizedBox(height: 16),

      // Stats row
      Row(children: [
        _StatBox('Duty Days', '\${dashboard.dutyDaysThisMonth}',
            Icons.calendar_today, const Color(0xFF3B82F6)),
        const SizedBox(width: 12),
        _StatBox('Tickets', '\${dashboard.ticketsIssuedThisMonth}',
            Icons.confirmation_number, const Color(0xFF10B981)),
        const SizedBox(width: 12),
        _StatBox('Welfare',
            'LKR \${dashboard.welfareThisMonth.toStringAsFixed(0)}',
            Icons.volunteer_activism, const Color(0xFF8B5CF6)),
      ]),
      const SizedBox(height: 20),

      // Quick action grid
      const Text('Quick Actions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.3,
        children: [
          _ActionCard(
              icon: Icons.play_circle_outline,
              label: 'Start / Stop Trip',
              color: const Color(0xFF10B981),
              onTap: () => context.go('/conductor/trip')),
          _ActionCard(
              icon: Icons.confirmation_number_outlined,
              label: 'Issue Ticket',
              color: const Color(0xFF3B82F6),
              enabled: dashboard.activeTrip?.isInProgress == true,
              onTap: () => context.go('/conductor/ticket/issue')),
          _ActionCard(
              icon: Icons.calendar_month_outlined,
              label: 'My Roster',
              color: const Color(0xFFF59E0B),
              onTap: () => context.go('/conductor/roster')),
          _ActionCard(
              icon: Icons.volunteer_activism_outlined,
              label: 'Welfare',
              color: const Color(0xFF8B5CF6),
              onTap: () => context.go('/conductor/welfare')),
        ],
      ),
    ]),
  );
}

class _TodayDutyCard extends StatelessWidget {
  final ConductorDashboardModel dashboard;
  const _TodayDutyCard({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final roster = dashboard.todayRoster;
    final trip   = dashboard.activeTrip;

    if (roster == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300)),
        child: const Row(children: [
          Icon(Icons.event_busy, color: Colors.grey, size: 28),
          SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("No Duty Today", style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
            Text("No roster assignment for today",
                style: TextStyle(color: Colors.grey, fontSize: 13)),
          ]),
        ]),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: trip?.isInProgress == true
              ? [const Color(0xFF065F46), const Color(0xFF10B981)]
              : [const Color(0xFFB45309), const Color(0xFFF59E0B)]),
          borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.directions_bus, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(roster.busNumber,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20)),
            child: Text(
                trip?.isInProgress == true ? '● LIVE' : roster.status.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 8),
        Text(roster.routeName,
            style: const TextStyle(color: Colors.white,
                fontSize: 17, fontWeight: FontWeight.bold)),
        Text('\${roster.startLocation} → \${roster.endLocation}',
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.access_time, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text('\${roster.shiftStart} – \${roster.shiftEnd}',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          if (trip != null) ...[
            const Spacer(),
            Text('Tickets: \${trip.ticketsIssuedCount}',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ]),
        if (trip?.isInProgress == true) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF065F46)),
                onPressed: () => context.go('/conductor/trip'),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Manage Active Trip')),
          ),
        ],
      ]),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value; final IconData icon; final Color color;
  const _StatBox(this.label, this.value, this.icon, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold,
            fontSize: 14, color: color)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ]),
    ),
  );
}

class _ActionCard extends StatelessWidget {
  final IconData icon; final String label;
  final Color color;   final VoidCallback onTap;
  final bool enabled;
  const _ActionCard({required this.icon, required this.label,
    required this.color, required this.onTap, this.enabled = true});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600,
                  color: color, fontSize: 13)),
        ]),
      ),
    ),
  );
}

class _ErrorBody extends StatelessWidget {
  final String error; final VoidCallback onRetry;
  const _ErrorBody({required this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(padding: const EdgeInsets.all(24), child: Column(
      mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.error_outline, color: Colors.red, size: 48),
      const SizedBox(height: 12),
      Text(error, textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red)),
      const SizedBox(height: 16),
      ElevatedButton.icon(onPressed: onRetry,
          icon: const Icon(Icons.refresh), label: const Text('Retry')),
    ],
    )),
  );
}
