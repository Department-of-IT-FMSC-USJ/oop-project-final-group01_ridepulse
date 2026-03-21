import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

class WelfareScreen extends ConsumerStatefulWidget {
  const WelfareScreen({super.key});
  @override
  ConsumerState<WelfareScreen> createState() => _WelfareScreenState();
}

class _WelfareScreenState extends ConsumerState<WelfareScreen> {
  int _month = DateTime.now().month;
  int _year  = DateTime.now().year;

  static const _months = ['Jan','Feb','Mar','Apr','May','Jun',
                           'Jul','Aug','Sep','Oct','Nov','Dec'];

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(welfareProvider((month: _month, year: _year)));
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Staff Welfare')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          // Month picker
          Row(children: [
            IconButton(icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() =>
                    _month > 1 ? _month-- : (_month = 12, _year--))),
            Expanded(child: Center(child: Text('${_months[_month - 1]} $_year',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
            IconButton(icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() =>
                    _month < 12 ? _month++ : (_month = 1, _year++))),
          ]),
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFFF0FDF4),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Row(children: [
                Icon(Icons.info_outline, color: Color(0xFF10B981), size: 18),
                SizedBox(width: 10),
                Expanded(child: Text(
                  'Welfare is auto-calculated on the 1st of each month. '
                  'Drivers receive 3%, Conductors 2% of net profit.',
                  style: TextStyle(fontSize: 13))),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          async.when(
            loading: () => const CircularProgressIndicator(),
            error:   (e, _) => Text('Error: $e'),
            data: (list) => list.isEmpty
                ? const Center(child: Text('No welfare data for this period',
                    style: TextStyle(color: Colors.grey)))
                : Column(children: list.map((s) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: s.staffType == 'driver'
                            ? const Color(0xFF3B82F6).withOpacity(0.1)
                            : const Color(0xFF8B5CF6).withOpacity(0.1),
                        child: Icon(
                            s.staffType == 'driver' ? Icons.drive_eta : Icons.person,
                            color: s.staffType == 'driver'
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFF8B5CF6))),
                      title: Text(s.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${s.staffType.toUpperCase()} • Rate: '
                          '${s.staffType == "driver" ? "3%" : "2%"}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('LKR ${s.welfareBalanceThisMonth.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981))),
                          Text('Total: LKR ${s.cumulativeWelfareBalance.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ]),
                    ))).toList()),
          ),
        ]),
      ),
    );
  }
}
