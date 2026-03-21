import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/complaint_models.dart';

final _busOwnerComplaintsProvider = FutureProvider.autoDispose
    .family<List<ComplaintSummary>, String>((ref, status) async {
  return ref.read(apiServiceProvider).getBusOwnerComplaints(status: status);
});

class BusOwnerComplaintsScreen extends ConsumerStatefulWidget {
  const BusOwnerComplaintsScreen({super.key});
  @override
  ConsumerState<BusOwnerComplaintsScreen> createState() => _State();
}

class _State extends ConsumerState<BusOwnerComplaintsScreen> {
  String _status = 'all';
  final _statuses = ['all', 'submitted', 'under_review', 'resolved', 'rejected'];

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_busOwnerComplaintsProvider(_status));
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Complaints About Your Buses')),
      body: Column(children: [
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: _statuses.map((s) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(s.replaceAll('_', ' ')),
              selected: _status == s,
              onSelected: (_) => setState(() => _status = s),
              selectedColor: const Color(0xFF1A56DB).withOpacity(0.15)),
          )).toList()),
        ),
        Expanded(child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:   (e, _) => Center(child: Text('Error: $e')),
          data: (list) => list.isEmpty
              ? const Center(child: Text('No complaints found', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _ComplaintCard(c: list[i])),
        )),
      ]),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  final ComplaintSummary c;
  const _ComplaintCard({required this.c});

  Color get _sc => switch (c.status) {
    'resolved'     => const Color(0xFF10B981),
    'rejected'     => const Color(0xFFEF4444),
    'under_review' => const Color(0xFFF59E0B),
    _              => const Color(0xFF6B7280),
  };

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(c.passengerName,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _sc.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(c.status.replaceAll('_', ' '),
                style: TextStyle(color: _sc, fontSize: 11, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 4),
        Text('Bus: ${c.busNumber} • ${c.category.replaceAll("_", " ")}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        const SizedBox(height: 8),
        Text(c.description, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        Text(c.submittedAt, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
      ]),
    ),
  );
}
