// ============================================================
// features/authority/screens/authority_prediction_screen.dart
// Authority can trigger LSTM prediction generation manually
// and see prediction status across all routes.
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';

class AuthorityPredictionScreen extends ConsumerStatefulWidget {
  const AuthorityPredictionScreen({super.key});
  @override
  ConsumerState<AuthorityPredictionScreen> createState() =>
      _AuthorityPredictionScreenState();
}

class _AuthorityPredictionScreenState
    extends ConsumerState<AuthorityPredictionScreen> {
  bool   _generating   = false;
  String? _lastMessage;
  String  _weather     = 'clear';
  double  _rain        = 0.0;
  String  _traffic     = 'medium';

  static const _weathers = ['clear', 'cloudy', 'rainy', 'stormy'];
  static const _traffics  = ['low', 'medium', 'high'];

  Future<void> _generateToday() async {
    setState(() { _generating = true; _lastMessage = null; });
    try {
      await ref.read(apiServiceProvider).generateTodayPredictions(
        weather:      _weather,
        rain:         _rain,
        trafficLevel: _traffic,
      );
      setState(() =>
          _lastMessage = 'Prediction generation started for today. '
              'Results will appear in 1–2 minutes.');
    } catch (e) {
      setState(() =>
          _lastMessage = 'Error: ${e.toString().replaceFirst("Exception: ", "")}');
    } finally {
      setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    appBar: AppBar(
      title: const Text('Crowd Prediction Management'),
      leading: IconButton(icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/authority/dashboard')),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Model info card
        Card(
          color: const Color(0xFFEFF6FF),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.memory, color: Color(0xFF1A56DB), size: 20),
                SizedBox(width: 8),
                Text('LSTM Model Status',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 12),
              _infoRow('Model',       'lstm_crowd_model.h5'),
              _infoRow('Version',     'lstm_v1.0'),
              _infoRow('Accuracy',    '66.58%'),
              _infoRow('MAE',         '4.02 passengers'),
              _infoRow('Schedule',    'Auto-generates daily at 00:30'),
              _infoRow('Slots/route', '36 (every 30 min, 05:00–22:30)'),
            ]),
          ),
        ),
        const SizedBox(height: 20),

        // Manual generation card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Manual Generation',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text('Override auto-schedule with current conditions',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 16),

              // Weather selector
              const Text('Weather Condition',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _weathers.map((w) => ChoiceChip(
                  label: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_weatherIcon(w), size: 14),
                    const SizedBox(width: 4),
                    Text(w),
                  ]),
                  selected: _weather == w,
                  onSelected: (_) => setState(() => _weather = w),
                  selectedColor: const Color(0xFF1A56DB).withOpacity(0.15),
                )).toList(),
              ),
              const SizedBox(height: 14),

              // Rain slider
              Row(children: [
                const Text('Rain intensity:',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                Expanded(child: Slider(
                  value: _rain,
                  min: 0.0, max: 1.0, divisions: 10,
                  label: _rain.toStringAsFixed(1),
                  onChanged: (v) => setState(() => _rain = v),
                )),
                SizedBox(width: 32,
                    child: Text(_rain.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w600))),
              ]),
              const SizedBox(height: 8),

              // Traffic selector
              const Text('Traffic Level',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: _traffics.map((t) => ButtonSegment(
                    value: t,
                    label: Text(t[0].toUpperCase() + t.substring(1)))).toList(),
                selected: {_traffic},
                onSelectionChanged: (s) => setState(() => _traffic = s.first),
              ),

              const SizedBox(height: 20),

              // Status message
              if (_lastMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: _lastMessage!.startsWith('Error')
                        ? Colors.red.shade50
                        : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    Icon(
                      _lastMessage!.startsWith('Error')
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      size: 16,
                      color: _lastMessage!.startsWith('Error')
                          ? Colors.red : const Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_lastMessage!,
                        style: TextStyle(
                            color: _lastMessage!.startsWith('Error')
                                ? Colors.red : const Color(0xFF065F46),
                            fontSize: 13))),
                  ]),
                ),

              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton.icon(
                  onPressed: _generating ? null : _generateToday,
                  icon: _generating
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.auto_graph),
                  label: Text(_generating
                      ? 'Generating predictions…'
                      : 'Generate Today\'s Predictions',
                      style: const TextStyle(fontSize: 15)),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 20),

        // Integration info
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Integration Architecture',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _archStep('1', 'Spring Boot collects route data + DB lag features'),
              _archStep('2', 'Calls Python FastAPI on :8000/predict/batch'),
              _archStep('3', 'LSTM runs 36 predictions per route'),
              _archStep('4', 'Results stored in crowd_predictions table'),
              _archStep('5', 'Passenger app reads predictions by route + time'),
            ]),
          ),
        ),
      ]),
    ),
  );

  IconData _weatherIcon(String w) => switch (w) {
    'clear'  => Icons.wb_sunny_outlined,
    'cloudy' => Icons.cloud_outlined,
    'rainy'  => Icons.water_drop_outlined,
    'stormy' => Icons.thunderstorm_outlined,
    _        => Icons.wb_sunny_outlined,
  };

  Widget _infoRow(String k, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(children: [
      SizedBox(width: 110, child: Text(k,
          style: const TextStyle(color: Colors.grey, fontSize: 13))),
      Text(v, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
    ]),
  );

  Widget _archStep(String num, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      CircleAvatar(radius: 12, backgroundColor: const Color(0xFF1A56DB),
          child: Text(num, style: const TextStyle(
              color: Colors.white, fontSize: 11,
              fontWeight: FontWeight.bold))),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
    ]),
  );
}
