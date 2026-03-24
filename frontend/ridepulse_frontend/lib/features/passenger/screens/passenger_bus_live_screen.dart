import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/passenger_models.dart';

class PassengerBusLiveScreen extends ConsumerWidget {
  final int busId;
  const PassengerBusLiveScreen({super.key, required this.busId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(busLiveDetailProvider(busId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Bus Tracking'),
        leading: IconButton(icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(busLiveDetailProvider(busId))),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.gps_off, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('Could not load bus location',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(e.toString(),
              style: const TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(busLiveDetailProvider(busId)),
            icon: const Icon(Icons.refresh), label: const Text('Retry')),
        ])),
        data: (bus) => _Body(bus: bus),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final BusLiveDetail bus;
  const _Body({required this.bus});

  Color get _crowdColor => switch (bus.crowdCategory) {
    'low'    => const Color(0xFF10B981),
    'medium' => const Color(0xFFF59E0B),
    'high'   => const Color(0xFFEF4444),
    _        => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final defaultCenter = const LatLng(6.9271, 79.8612);
    final busCenter = bus.hasLocation
        ? LatLng(bus.latitude!, bus.longitude!)
        : defaultCenter;

    return Column(children: [
      // Map — 60% of screen
      Expanded(
        flex: 3,
        child: FlutterMap(
          options: MapOptions(
              initialCenter: busCenter,
              initialZoom: 14),
          children: [
            TileLayer(urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ridepulse.app'),

            // Route polyline if stops available
            if (bus.stops.isNotEmpty)
              PolylineLayer(polylines: [
                Polyline(
                  points: bus.stops
                      .where((s) => s['latitude'] != null)
                      .map((s) => LatLng(
                          (s['latitude'] as num).toDouble(),
                          (s['longitude'] as num).toDouble()))
                      .toList(),
                  color: const Color(0xFF1A56DB).withOpacity(0.5),
                  strokeWidth: 4,
                ),
              ]),

            // Bus marker
            if (bus.hasLocation)
              MarkerLayer(markers: [
                Marker(
                  point: busCenter,
                  width: 70, height: 70,
                  child: _BusMapPin(
                    busNumber: bus.busNumber,
                    crowdColor: _crowdColor)),
              ]),
          ],
        ),
      ),

      // Info panel — 40% of screen
      Expanded(
        flex: 2,
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              // Bus + route header
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A56DB),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text(bus.busNumber,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold))),
                const SizedBox(width: 10),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(bus.routeName,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Route ${bus.routeNumber}',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(bus.lastUpdated,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 11)),
                  if (bus.speedKmh != null)
                    Text('${bus.speedKmh!.toStringAsFixed(0)} km/h',
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 12)),
                ]),
              ]),
              const Divider(height: 20),

              // Crowd section
              Row(children: [
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Current Crowd',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: bus.capacityPercentage / 100,
                      minHeight: 12,
                      backgroundColor: _crowdColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(_crowdColor))),
                  const SizedBox(height: 6),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _crowdColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        bus.crowdCategory == 'low' ? 'Not Crowded'
                        : bus.crowdCategory == 'medium' ? 'Moderate'
                        : bus.crowdCategory == 'high' ? 'Very Crowded'
                        : 'Unknown',
                        style: TextStyle(
                            color: _crowdColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12))),
                    const Spacer(),
                    Text('${bus.passengerCount}/${bus.capacity}',
                        style: TextStyle(
                            color: _crowdColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ]),
                ])),
              ]),

              if (!bus.hasLocation) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8)),
                  child: const Row(children: [
                    Icon(Icons.gps_not_fixed,
                        color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Expanded(child: Text(
                        'GPS location not available for this bus',
                        style: TextStyle(
                            color: Colors.orange, fontSize: 13))),
                  ]),
                ),
              ],

              if (!bus.isOnTrip) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8)),
                  child: const Row(children: [
                    Icon(Icons.info_outline,
                        color: Colors.grey, size: 16),
                    SizedBox(width: 8),
                    Text('This bus is not currently on a trip',
                        style: TextStyle(
                            color: Colors.grey, fontSize: 13)),
                  ]),
                ),
              ],
            ]),
          ),
        ),
      ),
    ]);
  }
}

class _BusMapPin extends StatelessWidget {
  final String busNumber;
  final Color crowdColor;
  const _BusMapPin({required this.busNumber, required this.crowdColor});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min, children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
          color: crowdColor, borderRadius: BorderRadius.circular(6)),
      child: Text(busNumber,
          style: const TextStyle(
              color: Colors.white, fontSize: 10,
              fontWeight: FontWeight.bold))),
    Icon(Icons.directions_bus_rounded, color: crowdColor, size: 32),
  ]);
}
