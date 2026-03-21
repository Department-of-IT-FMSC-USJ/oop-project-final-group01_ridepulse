import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/bus_models.dart';

class StaffListScreen extends ConsumerStatefulWidget {
  const StaffListScreen({super.key});
  @override
  ConsumerState<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends ConsumerState<StaffListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() { super.initState(); _tab = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    appBar: AppBar(
      title: const Text('Staff Management'),
      actions: [IconButton(
        icon: const Icon(Icons.person_add),
        onPressed: () => context.go('/bus-owner/staff/register'))],
      bottom: TabBar(
        controller: _tab,
        labelColor: const Color(0xFF1A56DB),
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(icon: Icon(Icons.drive_eta, size: 18), text: 'Drivers'),
          Tab(icon: Icon(Icons.person_outline, size: 18), text: 'Conductors'),
        ]),
    ),
    body: TabBarView(
      controller: _tab,
      // OOP Polymorphism: same widget renders both staff types
      children: [
        _StaffTab(staffType: 'driver'),
        _StaffTab(staffType: 'conductor'),
      ]),
  );
}

class _StaffTab extends ConsumerWidget {
  final String staffType;
  const _StaffTab({required this.staffType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(staffListProvider(staffType));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:   (e, _) => Center(child: Text('Error: $e')),
      data: (list) => list.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.people_outline, size: 60, color: Colors.grey),
              const SizedBox(height: 12),
              Text('No ${staffType}s yet', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.go('/bus-owner/staff/register'),
                icon: const Icon(Icons.person_add), label: const Text('Register Staff')),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (_, i) => _StaffCard(
                staff: list[i],
                onToggle: (val) async {
                  await ref.read(apiServiceProvider).toggleStaffStatus(list[i].staffId, val);
                  ref.invalidate(staffListProvider(staffType));
                },
                onTap: () => context.go('/bus-owner/staff/${list[i].staffId}'),
              ),
            ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  final StaffModel staff;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;
  const _StaffCard({required this.staff, required this.onToggle, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: staff.isActive
            ? const Color(0xFF3B82F6).withOpacity(0.1)
            : Colors.grey.shade100,
        child: Text(staff.fullName[0].toUpperCase(),
            style: TextStyle(
                color: staff.isActive ? const Color(0xFF3B82F6) : Colors.grey,
                fontWeight: FontWeight.bold)),
      ),
      title: Text(staff.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Bus: ${staff.assignedBusNumber}'),
        Text('LKR ${staff.baseSalary.toStringAsFixed(0)}/month',
            style: TextStyle(color: Colors.grey.shade600)),
      ]),
      trailing: Switch(
        value: staff.isActive, onChanged: onToggle,
        activeColor: const Color(0xFF10B981)),
    ),
  );
}
