import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/bus_models.dart';

class LiveMapScreen extends ConsumerWidget {
  const LiveMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(busLocationsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Live Bus Locations'),
        actions: [IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(busLocationsProvider))],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(child: Text('Error: $e')),
        data: (locations) => Row(children: [
          // Map
          Expanded(
            flex: 3,
            child: FlutterMap(
              options: const MapOptions(
                  initialCenter: LatLng(6.9271, 79.8612),
                  initialZoom: 12),
              children: [
                TileLayer(urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                MarkerLayer(markers: locations.map((loc) => Marker(
                  point: LatLng(loc.latitude, loc.longitude),
                  child: _BusPin(loc: loc),
                  width: 60, height: 60,
                )).toList()),
              ],
            ),
          ),
          // Bus list panel
          SizedBox(
            width: 240,
            child: Container(
              color: Colors.white,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Buses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                const Divider(height: 1),
                Expanded(child: ListView.builder(
                  itemCount: locations.length,
                  itemBuilder: (_, i) {
                    final loc = locations[i];
                    return ListTile(
                      dense: true,
                      leading: _CrowdDot(loc.crowdCategory),
                      title: Text(loc.busNumber,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                          '${loc.speedKmh?.toStringAsFixed(0) ?? "0"} km/h · ${loc.recordedAt}',
                          style: const TextStyle(fontSize: 11)),
                    );
                  }),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _BusPin extends StatelessWidget {
  final BusLocationModel loc;
  const _BusPin({required this.loc});

  Color get _color => switch (loc.crowdCategory) {
    'low'    => const Color(0xFF10B981),
    'medium' => const Color(0xFFF59E0B),
    'high'   => const Color(0xFFEF4444),
    _        => const Color(0xFF6B7280),
  };

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(4)),
      child: Text(loc.busNumber,
          style: const TextStyle(color: Colors.white, fontSize: 9,
              fontWeight: FontWeight.bold))),
    Icon(Icons.directions_bus_rounded, color: _color, size: 24),
  ]);
}

class _CrowdDot extends StatelessWidget {
  final String category;
  const _CrowdDot(this.category);

  Color get _color => switch (category) {
    'low'    => const Color(0xFF10B981),
    'medium' => const Color(0xFFF59E0B),
    'high'   => const Color(0xFFEF4444),
    _        => Colors.grey,
  };

  @override
  Widget build(BuildContext context) =>
      CircleAvatar(radius: 8, backgroundColor: _color);
}
