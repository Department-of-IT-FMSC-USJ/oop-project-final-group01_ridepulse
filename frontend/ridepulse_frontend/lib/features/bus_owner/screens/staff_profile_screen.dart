import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/bus_models.dart';

class StaffProfileScreen extends ConsumerStatefulWidget {
  final int staffId;
  const StaffProfileScreen({super.key, required this.staffId});
  @override
  ConsumerState<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends ConsumerState<StaffProfileScreen> {
  late Future<List<StaffModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(apiServiceProvider).getStaff();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    appBar: AppBar(
      title: const Text('Staff Profile'),
      leading: IconButton(icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/bus-owner/staff')),
    ),
    body: FutureBuilder<List<StaffModel>>(
      future: _future,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        final staff = snap.data?.firstWhere((s) => s.staffId == widget.staffId,
            orElse: () => throw Exception('Not found'));
        if (staff == null) return const Center(child: Text('Staff not found'));
        return _Body(staff: staff);
      },
    ),
  );
}

class _Body extends ConsumerStatefulWidget {
  final StaffModel staff;
  const _Body({required this.staff});
  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  final _salary = TextEditingController();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _salary.text = widget.staff.baseSalary.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.staff;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        // Avatar + name
        CircleAvatar(radius: 36, backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
            child: Text(s.fullName[0].toUpperCase(),
                style: const TextStyle(fontSize: 28, color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.bold))),
        const SizedBox(height: 12),
        Text(s.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(s.staffType.toUpperCase(),
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 24),
        // Info card
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            _row('Phone',       s.phone),
            _row('Employee ID', s.employeeId),
            _row('Bus',         s.assignedBusNumber),
            _row('Duty days',   '${s.dutyDaysThisMonth} this month'),
            if (s.licenseNumber != null) _row('License', s.licenseNumber!),
          ]),
        )),
        const SizedBox(height: 16),
        // Welfare card
        Card(
          color: const Color(0xFF10B981).withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Welfare Balance', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('This month'),
                Text('LKR ${s.welfareBalanceThisMonth.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981))),
              ]),
              const Divider(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total accumulated'),
                Text('LKR ${s.cumulativeWelfareBalance.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold,
                        color: Color(0xFF065F46))),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        // Salary edit
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Base Salary (LKR)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextField(
                controller: _salary, enabled: _editing,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(prefixText: 'LKR '))),
              const SizedBox(width: 12),
              _editing
                  ? ElevatedButton(
                      onPressed: () async {
                        await ref.read(apiServiceProvider).updateSalary(
                            s.staffId, double.parse(_salary.text));
                        setState(() => _editing = false);
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Salary updated'),
                                backgroundColor: Colors.green));
                      },
                      child: const Text('Save', style: TextStyle(color: Colors.white)))
                  : OutlinedButton(
                      onPressed: () => setState(() => _editing = true),
                      child: const Text('Edit')),
            ]),
          ]),
        )),
      ]),
    );
  }

  Widget _row(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      SizedBox(width: 100, child: Text(k, style: const TextStyle(color: Colors.grey))),
      Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w500))),
    ]),
  );
}
