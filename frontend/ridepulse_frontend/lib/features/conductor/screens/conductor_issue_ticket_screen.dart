// ============================================================
// features/conductor/screens/conductor_issue_ticket_screen.dart
// Issue ticket with stop dropdowns and QR preview
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/conductor_models.dart';

class ConductorIssueTicketScreen extends ConsumerStatefulWidget {
  const ConductorIssueTicketScreen({super.key});
  @override
  ConsumerState<ConductorIssueTicketScreen> createState() =>
      _ConductorIssueTicketScreenState();
}

class _ConductorIssueTicketScreenState
    extends ConsumerState<ConductorIssueTicketScreen> {
  StopModel? _boarding;
  StopModel? _alighting;
  String     _paymentMethod = 'cash';
  bool       _loading       = false;
  String?    _error;
  TicketModel? _issuedTicket;

  @override
  Widget build(BuildContext context) {
    final dashAsync  = ref.watch(conductorDashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('Issue Ticket'),
        leading: IconButton(icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/conductor/trip')),
      ),
      body: dashAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(child: Text('Error: $e')),
        data: (dash) {
          final trip   = dash.activeTrip;
          final roster = dash.todayRoster;

          if (trip == null || !trip.isInProgress) {
            return const Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.block, size: 60, color: Colors.grey),
              SizedBox(height: 12),
              Text('No active trip. Start a trip first.',
                  style: TextStyle(color: Colors.grey)),
            ]));
          }

          // If ticket was just issued — show QR result
          if (_issuedTicket != null) {
            return _TicketIssued(
                ticket: _issuedTicket!,
                onIssueAnother: () => setState(() => _issuedTicket = null));
          }

          final stopsAsync = ref.watch(routeStopsProvider(roster!.routeId));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              // Trip info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: const Color(0xFF065F46).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.3))),
                child: Row(children: [
                  const Icon(Icons.directions_bus,
                      color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(trip.busNumber,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(trip.routeName,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                  ])),
                  Text('Tickets: \${trip.ticketsIssuedCount}',
                      style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w600)),
                ]),
              ),
              const SizedBox(height: 20),

              // Stop dropdowns
              stopsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error:   (e, _) => Text('Error loading stops: $e'),
                data: (stops) => Column(children: [
                  DropdownButtonFormField<StopModel>(
                    value: _boarding,
                    isExpanded: true,
                    decoration: const InputDecoration(
                        labelText: 'Boarding Stop *',
                        prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                        border: OutlineInputBorder()),
                    items: stops.map((s) => DropdownMenuItem(
                        value: s, child: Text(s.stopName))).toList(),
                    onChanged: (s) => setState(() => _boarding = s),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<StopModel>(
                    value: _alighting,
                    isExpanded: true,
                    decoration: const InputDecoration(
                        labelText: 'Alighting Stop *',
                        prefixIcon: Icon(Icons.location_off_outlined, size: 20),
                        border: OutlineInputBorder()),
                    items: stops.map((s) => DropdownMenuItem(
                        value: s, child: Text(s.stopName))).toList(),
                    onChanged: (s) => setState(() => _alighting = s),
                  ),
                ]),
              ),
              const SizedBox(height: 14),

              // Payment method
              Row(children: [
                const Text('Payment: ',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                ChoiceChip(
                    label: const Text('Cash'),
                    selected: _paymentMethod == 'cash',
                    onSelected: (_) =>
                        setState(() => _paymentMethod = 'cash'),
                    selectedColor: const Color(0xFF10B981).withOpacity(0.15)),
                const SizedBox(width: 8),
                ChoiceChip(
                    label: const Text('Digital'),
                    selected: _paymentMethod == 'digital',
                    onSelected: (_) =>
                        setState(() => _paymentMethod = 'digital'),
                    selectedColor: const Color(0xFF3B82F6).withOpacity(0.15)),
              ]),
              const SizedBox(height: 8),

              if (_error != null)
                Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red))),
              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton.icon(
                  onPressed: (_boarding == null || _alighting == null || _loading)
                      ? null
                      : () => _issue(trip, roster!),
                  icon: _loading
                      ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.confirmation_number_outlined),
                  label: const Text('Issue Ticket', style: TextStyle(fontSize: 16)),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }

  Future<void> _issue(TripModel trip, RosterModel roster) async {
    if (_boarding!.stopId == _alighting!.stopId) {
      setState(() => _error = 'Boarding and alighting stop cannot be the same');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final ticket = await ref.read(apiServiceProvider).issueTicket(
        tripId:         trip.tripId,
        routeId:        roster.routeId,
        boardingStopId:  _boarding!.stopId,
        alightingStopId: _alighting!.stopId,
        paymentMethod:   _paymentMethod,
      );
      ref.invalidate(conductorDashboardProvider);
      ref.invalidate(tripTicketsProvider(trip.tripId));
      setState(() { _issuedTicket = ticket; _boarding = null; _alighting = null; });
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally { setState(() => _loading = false); }
  }
}

class _TicketIssued extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onIssueAnother;
  const _TicketIssued({required this.ticket, required this.onIssueAnother});

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 56),
        const SizedBox(height: 10),
        const Text('Ticket Issued!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        // QR code
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16, offset: const Offset(0, 4))]),
          child: Column(children: [
            QrImageView(data: ticket.qrCode, size: 180),
            const SizedBox(height: 12),
            Text(ticket.ticketNumber,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    fontSize: 14)),
            const SizedBox(height: 10),
            _row('From',    ticket.boardingStop),
            _row('To',      ticket.alightingStop),
            _row('Fare',    'LKR \${ticket.fareAmount.toStringAsFixed(2)}'),
            _row('Payment', ticket.paymentMethod.toUpperCase()),
            _row('Status',  ticket.ticketStatus.toUpperCase()),
          ]),
        ),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(
              child: OutlinedButton.icon(
                  onPressed: () => context.go('/conductor/trip'),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Back to Trip'))),
          const SizedBox(width: 12),
          Expanded(
              child: ElevatedButton.icon(
                  onPressed: onIssueAnother,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Issue Another'))),
        ]),
      ]),
    ),
  );

  Widget _row(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(k, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      Text(v, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
    ]),
  );
}
