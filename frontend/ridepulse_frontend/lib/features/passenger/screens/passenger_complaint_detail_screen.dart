import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/complaint_models.dart';

class PassengerComplaintDetailScreen extends ConsumerWidget {
  final int complaintId;
  const PassengerComplaintDetailScreen({super.key, required this.complaintId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(FutureProvider.autoDispose((r) =>
        r.read(apiServiceProvider).getComplaintDetail(complaintId)));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Detail'),
        leading: IconButton(icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/passenger/complaints')),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(child: Text('Error: $e')),
        data:    (c) => _Body(c: c),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final ComplaintDetail c;
  const _Body({required this.c});

  Color get _sc => switch (c.status) {
    'resolved'     => const Color(0xFF10B981),
    'rejected'     => const Color(0xFFEF4444),
    'under_review' => const Color(0xFFF59E0B),
    _              => const Color(0xFF6B7280),
  };

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Status badge
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: _sc.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
        child: Text(c.status.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(color: _sc, fontWeight: FontWeight.w700)),
      ),
      const SizedBox(height: 20),

      _section('Complaint Details', [
        _row('Category', c.category.replaceAll('_', ' ')),
        _row('Bus',      c.busNumber),
        _row('Route',    c.routeName),
        _row('Priority', c.priority.toUpperCase()),
        _row('Filed',    c.submittedAt),
        if (c.resolvedAt != null) _row('Resolved', c.resolvedAt!),
      ]),
      const SizedBox(height: 16),

      Card(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Your Description',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(c.description, style: TextStyle(color: Colors.grey.shade700)),
        ]),
      )),

      // Authority feedback section
      if (c.authorityFeedback != null) ...[
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.admin_panel_settings_outlined,
                  color: Color(0xFF10B981), size: 18),
              SizedBox(width: 8),
              Text('Authority Response',
                  style: TextStyle(fontWeight: FontWeight.w700,
                      color: Color(0xFF065F46))),
            ]),
            const SizedBox(height: 10),
            Text(c.authorityFeedback!,
                style: TextStyle(color: Colors.grey.shade800)),
            const SizedBox(height: 6),
            Text('Handled by: ${c.assignedToName}',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ),
      ] else ...[
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
          child: const Row(children: [
            Icon(Icons.hourglass_empty, color: Colors.grey),
            SizedBox(width: 12),
            Text('Awaiting authority response...',
                style: TextStyle(color: Colors.grey)),
          ]),
        ),
      ],
    ]),
  );

  Widget _section(String title, List<Widget> rows) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...rows,
      ]),
    ),
  );

  Widget _row(String k, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      SizedBox(width: 80,
          child: Text(k, style: const TextStyle(color: Colors.grey, fontSize: 13))),
      Expanded(child: Text(v, style: const TextStyle(fontSize: 13))),
    ]),
  );
}
