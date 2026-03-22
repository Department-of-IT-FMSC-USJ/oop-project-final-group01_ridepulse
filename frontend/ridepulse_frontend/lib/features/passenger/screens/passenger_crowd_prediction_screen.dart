import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/passenger_models.dart';

class PassengerCrowdPredictionScreen extends ConsumerStatefulWidget {
  final int routeId;
  const PassengerCrowdPredictionScreen({super.key, required this.routeId});
  @override
  ConsumerState<PassengerCrowdPredictionScreen> createState() =>
      _State();
}

class _State extends ConsumerState<PassengerCrowdPredictionScreen> {
  DateTime _selectedDate = DateTime.now();

  String get _dateStr =>
      '\${_selectedDate.year}-'
      '\${_selectedDate.month.toString().padLeft(2, "0")}-'
      '\${_selectedDate.day.toString().padLeft(2, "0")}';

  @override
  Widget build(BuildContext context) {
    final predAsync = ref.watch(crowdPredictionProvider(
        (routeId: widget.routeId, date: _dateStr)));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Crowd Forecast'),
        leading: IconButton(icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Column(children: [
        // Date selector
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(() =>
                  _selectedDate = _selectedDate.subtract(
                      const Duration(days: 1)))),
            Expanded(child: Center(child: Text(
              _selectedDate.day == DateTime.now().day
                  ? 'Today — $_dateStr' : _dateStr,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15)))),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(() =>
                  _selectedDate = _selectedDate.add(
                      const Duration(days: 1)))),
          ]),
        ),
        const Divider(height: 1),

        Expanded(child: predAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:   (e, _) => Center(child: Text('Error: $e')),
          data: (schedule) => schedule.hasData
              ? _PredictionChart(schedule: schedule)
              : _ComingSoon(routeName: schedule.routeName),
        )),
      ]),
    );
  }
}

// ── "Coming Soon" placeholder when LSTM not yet trained ──────
class _ComingSoon extends StatelessWidget {
  final String routeName;
  const _ComingSoon({required this.routeName});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, children: [
        // Animated icon
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withOpacity(0.1),
            shape: BoxShape.circle),
          child: const Icon(Icons.auto_graph,
              size: 50, color: Color(0xFF8B5CF6))),
        const SizedBox(height: 24),
        const Text('Crowd Prediction',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Coming Soon for $routeName',
            style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.2))),
          child: Column(children: const [
            Text('What this will show:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 10),
            _FeatureItem('AI-powered crowd predictions by time slot'),
            _FeatureItem('Best time to board for low crowds'),
            _FeatureItem('Historical crowd patterns'),
            _FeatureItem('Confidence score per prediction'),
          ]),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.schedule, color: Colors.orange, size: 16),
            SizedBox(width: 6),
            Text('LSTM model training in progress',
                style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                    fontSize: 13)),
          ]),
        ),
      ]),
    ),
  );
}

class _FeatureItem extends StatelessWidget {
  final String text;
  const _FeatureItem(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      const Icon(Icons.check_circle_outline,
          size: 16, color: Color(0xFF8B5CF6)),
      const SizedBox(width: 8),
      Expanded(child: Text(text,
          style: const TextStyle(fontSize: 13))),
    ]),
  );
}

// ── Real prediction chart when LSTM data exists ───────────────
class _PredictionChart extends StatelessWidget {
  final RoutePredictionSchedule schedule;
  const _PredictionChart({required this.schedule});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      // Info banner
      Card(
        color: const Color(0xFFEFF6FF),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            const Icon(Icons.auto_graph,
                color: Color(0xFF8B5CF6), size: 20),
            const SizedBox(width: 10),
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(schedule.routeName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('AI crowd predictions for \${schedule.date}',
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12)),
            ])),
          ]),
        ),
      ),
      const SizedBox(height: 12),

      // Time slots
      ...schedule.slots.map((slot) => _SlotRow(slot: slot)),
    ],
  );
}

class _SlotRow extends StatelessWidget {
  final CrowdPredictionSlot slot;
  const _SlotRow({required this.slot});

  Color get _color => switch (slot.predictedCategory) {
    'low'    => const Color(0xFF10B981),
    'medium' => const Color(0xFFF59E0B),
    'high'   => const Color(0xFFEF4444),
    _        => Colors.grey,
  };

  String get _label => switch (slot.predictedCategory) {
    'low'    => 'Low crowd',
    'medium' => 'Moderate',
    'high'   => 'Very crowded',
    _        => 'Unknown',
  };

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12),
      child: Row(children: [
        SizedBox(width: 50,
            child: Text(slot.timeSlot,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13))),
        const SizedBox(width: 12),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: slot.predictedPercentage / 100,
              minHeight: 10,
              backgroundColor: _color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(_color))),
          const SizedBox(height: 4),
          Row(children: [
            Text(_label,
                style: TextStyle(
                    color: _color, fontSize: 12,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            Text('\${slot.predictedPercentage.toStringAsFixed(0)}%',
                style: TextStyle(
                    color: _color, fontWeight: FontWeight.bold)),
          ]),
        ])),
        if (slot.confidenceScore != null) ...[
          const SizedBox(width: 12),
          Text('\${(slot.confidenceScore! * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                  color: Colors.grey, fontSize: 11)),
        ],
      ]),
    ),
  );
}
