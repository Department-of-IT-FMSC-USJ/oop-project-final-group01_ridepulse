import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/bus_models.dart';

class RevenueScreen extends ConsumerStatefulWidget {
  const RevenueScreen({super.key});
  @override
  ConsumerState<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends ConsumerState<RevenueScreen> {
  int _month = DateTime.now().month;
  int _year  = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final revenueAsync = ref.watch(monthlyRevenueProvider((month: _month, year: _year)));
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Revenue & Expenses')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFuelDialog(context),
        icon: const Icon(Icons.local_gas_station),
        label: const Text('Enter Fuel'),
        backgroundColor: Colors.orange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          _MonthPicker(month: _month, year: _year,
              onChange: (m, y) => setState(() { _month = m; _year = y; })),
          const SizedBox(height: 16),
          _FormulaCard(),
          const SizedBox(height: 16),
          revenueAsync.when(
            loading: () => const CircularProgressIndicator(),
            error:   (e, _) => Text('Error: $e'),
            data: (list) => list.isEmpty
                ? const Center(child: Text('No revenue data for this period',
                    style: TextStyle(color: Colors.grey)))
                : Column(children: list.map((r) => _RevenueCard(r: r)).toList()),
          ),
        ]),
      ),
    );
  }

  void _showFuelDialog(BuildContext context) {
    final busId = TextEditingController();
    final amount = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Record Fuel Expense'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: busId,
            decoration: const InputDecoration(labelText: 'Bus ID'),
            keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        TextField(controller: amount,
            decoration: const InputDecoration(labelText: 'Amount (LKR)'),
            keyboardType: TextInputType.number),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            await ref.read(apiServiceProvider).recordFuelExpense(
              busId: int.parse(busId.text),
              date: DateTime.now().toIso8601String().split('T')[0],
              amount: double.parse(amount.text));
            if (ctx.mounted) Navigator.pop(ctx);
          },
          child: const Text('Save', style: TextStyle(color: Colors.white))),
      ],
    ));
  }
}

class _MonthPicker extends StatelessWidget {
  final int month, year;
  final void Function(int, int) onChange;
  const _MonthPicker({required this.month, required this.year, required this.onChange});

  static const _months = ['Jan','Feb','Mar','Apr','May','Jun',
                           'Jul','Aug','Sep','Oct','Nov','Dec'];

  @override
  Widget build(BuildContext context) => Row(children: [
    IconButton(
      icon: const Icon(Icons.chevron_left),
      onPressed: () => month > 1
          ? onChange(month - 1, year)
          : onChange(12, year - 1)),
    Expanded(
      child: Center(child: Text('${_months[month - 1]} $year',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
    IconButton(
      icon: const Icon(Icons.chevron_right),
      onPressed: () => month < 12
          ? onChange(month + 1, year)
          : onChange(1, year + 1)),
  ]);
}

class _FormulaCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xFFEFF6FF),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Net Profit Formula',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Gross Revenue (ticket sales)'),
        const Text('  − Fuel Expenses', style: TextStyle(color: Colors.red)),
        const Text('  − Maintenance (fixed)', style: TextStyle(color: Colors.red)),
        const Text('  − Staff Base Salaries', style: TextStyle(color: Colors.red)),
        const Divider(),
        const Text('= Net Profit', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Driver Welfare  = Net × 3%', style: TextStyle(color: Color(0xFF10B981))),
        const Text('Conductor Welfare = Net × 2%', style: TextStyle(color: Color(0xFF10B981))),
      ]),
    ),
  );
}

class _RevenueCard extends StatelessWidget {
  final MonthlyRevenueModel r;
  const _RevenueCard({required this.r});

  Widget _row(String k, String v, {Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(k, style: TextStyle(color: Colors.grey.shade700)),
      Text(v, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
    ]),
  );

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(r.busNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const Divider(height: 20),
        _row('Gross Revenue', 'LKR ${r.grossRevenue.toStringAsFixed(2)}'),
        _row('Fuel Cost',     '- LKR ${r.totalFuelCost.toStringAsFixed(2)}', color: Colors.red),
        _row('Maintenance',   '- LKR ${r.maintenanceCost.toStringAsFixed(2)}', color: Colors.red),
        _row('Staff Salaries','- LKR ${r.totalStaffSalaries.toStringAsFixed(2)}', color: Colors.red),
        const Divider(height: 16),
        _row('Net Profit', 'LKR ${r.netProfit.toStringAsFixed(2)}',
            color: r.netProfit >= 0 ? const Color(0xFF10B981) : Colors.red),
        const SizedBox(height: 8),
        _row('Driver Welfare',    'LKR ${r.driverWelfareAmount.toStringAsFixed(2)}',
            color: const Color(0xFF6366F1)),
        _row('Conductor Welfare', 'LKR ${r.conductorWelfareAmount.toStringAsFixed(2)}',
            color: const Color(0xFF6366F1)),
      ]),
    ),
  );
}
