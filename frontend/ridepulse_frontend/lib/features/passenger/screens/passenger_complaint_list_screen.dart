import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/complaint_models.dart';

class PassengerComplaintListScreen extends ConsumerWidget {
  const PassengerComplaintListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myComplaintsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('My Complaints'),
        leading: IconButton(icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/passenger/home')),
        actions: [IconButton(icon: const Icon(Icons.add),
            onPressed: () => context.go('/passenger/complaints/submit'))],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) => list.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.inbox_outlined, size: 60, color: Colors.grey),
                const SizedBox(height: 12),
                const Text('No complaints yet', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.go('/passenger/complaints/submit'),
                  icon: const Icon(Icons.add), label: const Text('File a Complaint')),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) => _ComplaintTile(c: list[i],
                    onTap: () => context.go('/passenger/complaints/\${list[i].complaintId}')),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/passenger/complaints/submit'),
        icon: const Icon(Icons.add), label: const Text('New Complaint'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
    );
  }
}

class _ComplaintTile extends StatelessWidget {
  final ComplaintSummary c;
  final VoidCallback onTap;
  const _ComplaintTile({required this.c, required this.onTap});

  Color get _statusColor => switch (c.status) {
    'resolved'     => const Color(0xFF10B981),
    'rejected'     => const Color(0xFFEF4444),
    'under_review' => const Color(0xFFF59E0B),
    _              => const Color(0xFF6B7280),
  };

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20)),
              child: Text(c.status.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            const Spacer(),
            Text(c.category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
          const SizedBox(height: 8),
          Text(c.description, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14)),
          if (c.hasFeedback) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.check_circle_outline,
                    color: Color(0xFF10B981), size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text('Authority: \${c.authorityFeedback}',
                    style: const TextStyle(fontSize: 13,
                        color: Color(0xFF065F46)))),
              ]),
            ),
          ],
          const SizedBox(height: 8),
          Text(c.submittedAt,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        ]),
      ),
    ),
  );
}
