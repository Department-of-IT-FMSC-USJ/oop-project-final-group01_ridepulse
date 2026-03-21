import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/bus_models.dart';

class BusManagementScreen extends ConsumerWidget {
  const BusManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busesAsync = ref.watch(busListProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Bus Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBusDialog(context, ref),
        icon: const Icon(Icons.add), label: const Text('Add Bus'),
        backgroundColor: const Color(0xFF1A56DB),
      ),
      body: busesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(child: Text('Error: $e')),
        data: (buses) => buses.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.directions_bus_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 12),
                const Text('No buses yet', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddBusDialog(context, ref),
                  icon: const Icon(Icons.add), label: const Text('Add Your First Bus')),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: buses.length,
                itemBuilder: (_, i) => _BusCard(
                  bus: buses[i],
                  onDelete: () => _confirmDelete(context, ref, buses[i]),
                  onChangeRoute: () => _showChangeRouteDialog(context, ref, buses[i]),
                ),
              ),
      ),
    );
  }

  void _showAddBusDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, barrierDismissible: false,
        builder: (_) => _AddBusDialog(onSaved: () => ref.invalidate(busListProvider)));
  }

  void _showChangeRouteDialog(BuildContext context, WidgetRef ref, BusModel bus) {
    showDialog(context: context,
        builder: (_) => _ChangeRouteDialog(
            bus: bus, onSaved: () => ref.invalidate(busListProvider)));
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, BusModel bus) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Deactivate Bus'),
      content: Text('Deactivate bus ${bus.busNumber}?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            Navigator.pop(ctx);
            await ref.read(apiServiceProvider).deleteBus(bus.busId);
            ref.invalidate(busListProvider);
          },
          child: const Text('Deactivate', style: TextStyle(color: Colors.white))),
      ],
    ));
  }
}

class _BusCard extends StatelessWidget {
  final BusModel bus;
  final VoidCallback onDelete, onChangeRoute;
  const _BusCard({required this.bus, required this.onDelete, required this.onChangeRoute});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0xFF1A56DB),
                borderRadius: BorderRadius.circular(6)),
            child: Text(bus.busNumber,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          const SizedBox(width: 10),
          Text(bus.registrationNumber, style: TextStyle(color: Colors.grey.shade600)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (bus.isActive ? const Color(0xFF10B981) : Colors.grey).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20)),
            child: Text(bus.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                    color: bus.isActive ? const Color(0xFF10B981) : Colors.grey,
                    fontSize: 12, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          const Icon(Icons.route, size: 15, color: Color(0xFF3B82F6)),
          const SizedBox(width: 6),
          Expanded(child: Text(bus.route?.displayName ?? 'No route assigned',
              style: const TextStyle(fontWeight: FontWeight.w500))),
          TextButton(onPressed: onChangeRoute, child: const Text('Change')),
        ]),
        const Divider(height: 20),
        Row(children: [
          const Icon(Icons.drive_eta, size: 15, color: Colors.grey),
          const SizedBox(width: 4),
          Text(bus.assignedDriverName, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 16),
          const Icon(Icons.person, size: 15, color: Colors.grey),
          const SizedBox(width: 4),
          Text(bus.assignedConductorName, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          const Icon(Icons.event_seat, size: 15, color: Colors.grey),
          const SizedBox(width: 4),
          Text('${bus.capacity} seats', style: const TextStyle(fontSize: 13)),
        ]),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
            label: const Text('Deactivate', style: TextStyle(color: Colors.red, fontSize: 13))),
        ),
      ]),
    ),
  );
}

class _AddBusDialog extends ConsumerStatefulWidget {
  final VoidCallback onSaved;
  const _AddBusDialog({required this.onSaved});
  @override
  ConsumerState<_AddBusDialog> createState() => _AddBusDialogState();
}

class _AddBusDialogState extends ConsumerState<_AddBusDialog> {
  final _form   = GlobalKey<FormState>();
  final _num    = TextEditingController();
  final _reg    = TextEditingController();
  final _cap    = TextEditingController();
  final _model  = TextEditingController();
  RouteModel? _route;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final routesAsync = ref.watch(routeDropdownProvider);
    return AlertDialog(
      title: const Text('Add New Bus'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _form,
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            _f(_num, 'Bus Number', 'e.g. NB-1234'),
            const SizedBox(height: 12),
            _f(_reg, 'Registration Number', 'e.g. CAB-1234'),
            const SizedBox(height: 12),
            _f(_cap, 'Capacity', 'e.g. 52', keyboard: TextInputType.number),
            const SizedBox(height: 12),
            _f(_model, 'Model (optional)', 'e.g. Ashok Leyland', required: false),
            const SizedBox(height: 12),
            routesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error:   (e, _) => Text('Error: $e'),
              data: (routes) => DropdownButtonFormField<RouteModel>(
                value: _route,
                isExpanded: true,
                decoration: const InputDecoration(
                    labelText: 'Select Route *', prefixIcon: Icon(Icons.route, size: 20)),
                items: routes.map((r) => DropdownMenuItem(
                    value: r,
                    child: Text(r.displayName, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (r) => setState(() => _route = r),
                validator: (_) => _route == null ? 'Please select a route' : null,
              ),
            ),
          ])),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Add Bus', style: TextStyle(color: Colors.white))),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(apiServiceProvider).addBus(
        busNumber: _num.text, registrationNumber: _reg.text,
        routeId: _route!.routeId, capacity: int.parse(_cap.text),
        model: _model.text.isEmpty ? null : _model.text);
      if (mounted) { Navigator.pop(context); widget.onSaved(); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally { setState(() => _loading = false); }
  }

  Widget _f(TextEditingController c, String label, String hint,
      {TextInputType keyboard = TextInputType.text, bool required = true}) =>
    TextFormField(
      controller: c, keyboardType: keyboard,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: required ? (v) => (v == null || v.isEmpty) ? '$label required' : null : null);
}

class _ChangeRouteDialog extends ConsumerStatefulWidget {
  final BusModel bus;
  final VoidCallback onSaved;
  const _ChangeRouteDialog({required this.bus, required this.onSaved});
  @override
  ConsumerState<_ChangeRouteDialog> createState() => _ChangeRouteDialogState();
}

class _ChangeRouteDialogState extends ConsumerState<_ChangeRouteDialog> {
  RouteModel? _route;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final routesAsync = ref.watch(routeDropdownProvider);
    return AlertDialog(
      title: Text('Change Route — ${widget.bus.busNumber}'),
      content: routesAsync.when(
        loading: () => const LinearProgressIndicator(),
        error:   (e, _) => Text('Error: $e'),
        data: (routes) => DropdownButtonFormField<RouteModel>(
          value: _route,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Select new route'),
          items: routes.map((r) => DropdownMenuItem(
              value: r,
              child: Text(r.displayName, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: (r) => setState(() => _route = r),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: (_route == null || _loading) ? null : () async {
            setState(() => _loading = true);
            await ref.read(apiServiceProvider).updateBusRoute(widget.bus.busId, _route!.routeId);
            if (mounted) { Navigator.pop(context); widget.onSaved(); }
          },
          child: const Text('Update', style: TextStyle(color: Colors.white))),
      ],
    );
  }
}
