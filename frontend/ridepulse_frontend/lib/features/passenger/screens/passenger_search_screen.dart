import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/passenger_models.dart';

class PassengerSearchScreen extends ConsumerStatefulWidget {
  const PassengerSearchScreen({super.key});
  @override
  ConsumerState<PassengerSearchScreen> createState() =>
      _PassengerSearchScreenState();
}

class _PassengerSearchScreenState
    extends ConsumerState<PassengerSearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final routesAsync = _query.isEmpty
        ? ref.watch(allRoutesProvider)
        : ref.watch(routeSearchProvider(_query));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Search Routes'),
        leading: IconButton(icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/passenger/home')),
      ),
      body: Column(children: [
        // Search bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: TextField(
            controller: _ctrl,
            autofocus: true,
            onChanged: (v) => setState(() => _query = v.trim()),
            decoration: InputDecoration(
              hintText: 'Route number, name or location…',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF1A56DB)),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _ctrl.clear();
                        setState(() => _query = '');
                      })
                  : null,
              filled: true, fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const Divider(height: 1),

        // Results
        Expanded(child: routesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:   (e, _) => Center(child: Text('Error: $e')),
          data: (routes) => routes.isEmpty
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.search_off, size: 60, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(_query.isEmpty
                      ? 'No routes available'
                      : 'No routes found for "$_query"',
                      style: const TextStyle(color: Colors.grey)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: routes.length,
                  itemBuilder: (_, i) => _RouteCard(
                    route: routes[i],
                    onTap: () => context.go(
                        '/passenger/routes/${routes[i].routeId}'),
                  ),
                ),
        )),
      ]),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final RouteSearchResult route;
  final VoidCallback onTap;
  const _RouteCard({required this.route, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          // Route number badge
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF1A56DB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(route.routeNumber,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A56DB),
                    fontSize: 13))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(route.routeName,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 4),
            Text('${route.startLocation} → ${route.endLocation}',
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 6),
            Row(children: [
              if (route.totalDistanceKm != null) ...[
                const Icon(Icons.straighten,
                    size: 13, color: Colors.grey),
                const SizedBox(width: 3),
                Text(route.displayDistance,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12)),
                const SizedBox(width: 12),
              ],
              const Icon(Icons.payments_outlined,
                  size: 13, color: Colors.grey),
              const SizedBox(width: 3),
              Text('LKR ${route.baseFare.toStringAsFixed(0)}',
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12)),
            ]),
          ])),
          // Active buses badge
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: route.hasBuses
                    ? const Color(0xFF10B981).withOpacity(0.12)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                Icon(Icons.directions_bus,
                    size: 12,
                    color: route.hasBuses
                        ? const Color(0xFF10B981)
                        : Colors.grey),
                const SizedBox(width: 4),
                Text('${route.activeBusCount}',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: route.hasBuses
                            ? const Color(0xFF10B981)
                            : Colors.grey)),
              ]),
            ),
            const SizedBox(height: 2),
            Text('active', style: TextStyle(
                fontSize: 10, color: Colors.grey.shade500)),
          ]),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ]),
      ),
    ),
  );
}
