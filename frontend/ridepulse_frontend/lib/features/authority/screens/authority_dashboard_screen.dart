import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/complaint_models.dart';

class AuthorityDashboardScreen extends ConsumerWidget {
  const AuthorityDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(complaintStatsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Authority Dashboard',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          statsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:   (e, _) => Text('Error: $e'),
            data: (stats) => Column(children: [
              // Status stats
              Row(children: [
                _StatTile('Total', stats.totalComplaints.toString(), Colors.grey),
                const SizedBox(width: 12),
                _StatTile('Submitted', stats.submitted.toString(), const Color(0xFF6B7280)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                _StatTile('Under Review', stats.underReview.toString(), const Color(0xFFF59E0B)),
                const SizedBox(width: 12),
                _StatTile('Resolved', stats.resolved.toString(), const Color(0xFF10B981)),
                const SizedBox(width: 12),
                _StatTile('Rejected', stats.rejected.toString(), const Color(0xFFEF4444)),
              ]),
              const SizedBox(height: 24),
              // Category breakdown
              Card(child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('By Category', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _CatBar('Safety',          stats.safetyCount,         stats.totalComplaints, const Color(0xFFEF4444)),
                  _CatBar('Driver Behavior', stats.driverBehaviorCount, stats.totalComplaints, const Color(0xFFF59E0B)),
                  _CatBar('Delay',           stats.delayCount,          stats.totalComplaints, const Color(0xFF3B82F6)),
                  _CatBar('Crowding',        stats.crowdingCount,       stats.totalComplaints, const Color(0xFF8B5CF6)),
                  _CatBar('Cleanliness',     stats.cleanlinessCount,    stats.totalComplaints, const Color(0xFF10B981)),
                  _CatBar('Other',           stats.otherCount,          stats.totalComplaints, Colors.grey),
                ]),
              )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/authority/complaints'),
                  icon: const Icon(Icons.list_alt),
                  label: const Text('View All Complaints')),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value; final Color color;
  const _StatTile(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ]),
    ),
  );
}

class _CatBar extends StatelessWidget {
  final String label; final int count, total; final Color color;
  const _CatBar(this.label, this.count, this.total, this.color);
  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 13))),
        Expanded(child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct, minHeight: 10,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(color)))),
        const SizedBox(width: 10),
        SizedBox(width: 30, child: Text('$count',
            style: TextStyle(color: color, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}
