// ============================================================
// features/driver/screens/driver_home_screen.dart
// OOP Abstraction: all data fetched in one dashboard call.
//     Polymorphism: action grid tiles behave differently —
//     active tiles navigate, Coming Soon tiles show a dialog.
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/driver_models.dart';

class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(driverDashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E40AF),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('RidePulse Driver',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(driverDashboardProvider)),
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
        error: (e, _) => _ErrorBody(
            error: e.toString().replaceFirst('Exception: ', ''),
            onRetry: () => ref.invalidate(driverDashboardProvider)),
        data: (dash) => _HomeBody(dash: dash),
      ),
    );
  }
}

// ── Main body ─────────────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  final DriverDashboardModel dash;
  const _HomeBody({required this.dash});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Greeting
      Row(children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF1E40AF).withOpacity(0.15),
          child: Text(
            dash.driverName.isNotEmpty
                ? dash.driverName[0].toUpperCase() : 'D',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E40AF), fontSize: 18)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hello, ${dash.driverName}! 👋',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          Text('ID: ${dash.employeeId}',
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 12)),
        ])),
      ]),
      const SizedBox(height: 18),

      // Today's duty card
      _TodayDutyCard(dash: dash),
      const SizedBox(height: 16),

      // Stats row
      Row(children: [
        _StatBox('Duty Days', '${dash.dutyDaysThisMonth}',
            Icons.calendar_today_outlined, const Color(0xFF3B82F6)),
        const SizedBox(width: 12),
        _StatBox('Welfare',
            'LKR ${dash.welfareThisMonth.toStringAsFixed(0)}',
            Icons.volunteer_activism_outlined, const Color(0xFF10B981)),
        const SizedBox(width: 12),
        _StatBox('Balance',
            'LKR ${dash.totalWelfareBalance.toStringAsFixed(0)}',
            Icons.account_balance_wallet_outlined,
            const Color(0xFF8B5CF6)),
      ]),
      const SizedBox(height: 22),

      // Active features section
      const Text('My Features',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 14, mainAxisSpacing: 14,
        childAspectRatio: 1.2,
        children: [
          // ── Active tiles ──────────────────────────────────
          _ActiveTile(
            icon: Icons.calendar_month_outlined,
            label: 'Duty Roster',
            subtitle: 'View assignments',
            color: const Color(0xFF3B82F6),
            onTap: () => context.go('/driver/roster')),
          _ActiveTile(
            icon: Icons.payments_outlined,
            label: 'My Income',
            subtitle: 'Salary & earnings',
            color: const Color(0xFF10B981),
            onTap: () => context.go('/driver/income')),
          _ActiveTile(
            icon: Icons.volunteer_activism_outlined,
            label: 'Welfare',
            subtitle: 'Monthly balance',
            color: const Color(0xFF8B5CF6),
            onTap: () => context.go('/driver/welfare')),
          _ActiveTile(
            icon: Icons.play_circle_outline,
            label: 'Trip',
            subtitle: 'Start / stop trip',
            color: const Color(0xFF059669),
            onTap: () => context.go('/driver/trip')),
        ],
      ),
      const SizedBox(height: 22),

      // Coming Soon section
      Row(children: [
        const Text('Coming Soon',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20)),
          child: const Text('In Development',
              style: TextStyle(
                  color: Colors.orange,
                  fontSize: 10, fontWeight: FontWeight.w600)),
        ),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _ComingSoonTile(
          icon: Icons.warning_amber_rounded,
          label: 'Emergency Alert',
          subtitle: 'SOS & incidents',
          color: const Color(0xFFEF4444))),
        const SizedBox(width: 14),
        Expanded(child: _ComingSoonTile(
          icon: Icons.badge_outlined,
          label: 'License & Health',
          subtitle: 'Records & renewals',
          color: const Color(0xFFF59E0B))),
      ]),
    ]),
  );
}

// ── Today's Duty Card ─────────────────────────────────────────

class _TodayDutyCard extends StatelessWidget {
  final DriverDashboardModel dash;
  const _TodayDutyCard({required this.dash});

  @override
  Widget build(BuildContext context) {
    final roster = dash.todayRoster;
    final trip   = dash.activeTrip;

    if (roster == null) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200)),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.event_busy,
                color: Colors.grey, size: 26)),
          const SizedBox(width: 14),
          const Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('No Duty Today',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15)),
            SizedBox(height: 2),
            Text('Check back tomorrow',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ]),
      );
    }

    final isActive = trip?.isInProgress == true;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: isActive
              ? [const Color(0xFF065F46), const Color(0xFF059669)]
              : [const Color(0xFF1E3A8A), const Color(0xFF1D4ED8)]),
        borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.directions_bus,
                color: Colors.white, size: 20)),
          const SizedBox(width: 10),
          Text(roster.busNumber,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 13)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (isActive) ...[
                const Icon(Icons.circle,
                    color: Colors.greenAccent, size: 8),
                const SizedBox(width: 4),
              ],
              Text(isActive ? 'DRIVING' : 'TODAY',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Text(roster.routeName,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.location_on_outlined,
              color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text('${roster.startLocation} → ${roster.endLocation}',
              style: const TextStyle(
                  color: Colors.white70, fontSize: 12)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.access_time,
              color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text('${roster.shiftStart} – ${roster.shiftEnd}',
              style: const TextStyle(
                  color: Colors.white70, fontSize: 12)),
          const Spacer(),
          const Icon(Icons.event_seat_outlined,
              color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text('Cap: ${roster.busCapacity}',
              style: const TextStyle(
                  color: Colors.white70, fontSize: 12)),
        ]),
        if (isActive) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF065F46),
                  elevation: 0),
              onPressed: () => context.go('/driver/trip'),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Manage Active Trip')),
          ),
        ],
      ]),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatBox(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13, color: color),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis),
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 9),
            textAlign: TextAlign.center),
      ]),
    ),
  );
}

class _ActiveTile extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ActiveTile({required this.icon, required this.label,
      required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
        Icon(icon, color: color, size: 28),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(
              fontWeight: FontWeight.w700, color: color, fontSize: 13)),
          Text(subtitle, style: TextStyle(
              color: color.withOpacity(0.7), fontSize: 10)),
        ]),
      ]),
    ),
  );
}

class _ComingSoonTile extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final Color color;
  const _ComingSoonTile({required this.icon, required this.label,
      required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => _showComingSoon(context, label),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              style: BorderStyle.solid)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
        Stack(children: [
          Icon(icon, color: Colors.grey.shade400, size: 28),
          Positioned(
            right: 0, top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                  color: Colors.orange, shape: BoxShape.circle),
              child: const Icon(Icons.lock,
                  color: Colors.white, size: 8))),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600, fontSize: 13)),
          Text(subtitle, style: TextStyle(
              color: Colors.grey.shade400, fontSize: 10)),
        ]),
      ]),
    ),
  );

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle),
          child: const Icon(Icons.construction_outlined,
              color: Colors.orange, size: 40)),
        const SizedBox(height: 16),
        Text(feature,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('$feature is currently under development '
            'and will be available in a future update.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey.shade600, fontSize: 13)),
      ]),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it')),
        ),
      ],
    ));
  }
}

class _ErrorBody extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorBody({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.cloud_off_outlined,
            color: Colors.grey, size: 56),
        const SizedBox(height: 14),
        const Text('Could not load dashboard',
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        Text(error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Try Again')),
      ]),
    ),
  );
}
