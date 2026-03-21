import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/api_service.dart';

/// 🔹 Model for complaint category (clean & scalable)
class ComplaintCategory {
  final String id;
  final String label;
  final IconData icon;

  const ComplaintCategory({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class PassengerComplaintSubmitScreen extends ConsumerStatefulWidget {
  const PassengerComplaintSubmitScreen({super.key});

  @override
  ConsumerState<PassengerComplaintSubmitScreen> createState() => _State();
}

class _State extends ConsumerState<PassengerComplaintSubmitScreen> {
  final _form = GlobalKey<FormState>();
  final _desc = TextEditingController();

  String _cat = 'delay';
  bool _loading = false;
  String? _error;

  /// 🔹 Clean category list (no tuples anymore)
  static const List<ComplaintCategory> _categories = [
    ComplaintCategory(id: 'crowding', label: 'Overcrowding', icon: Icons.people),
    ComplaintCategory(id: 'driver_behavior', label: 'Driver Behavior', icon: Icons.person_off),
    ComplaintCategory(id: 'delay', label: 'Bus Delay', icon: Icons.access_time),
    ComplaintCategory(id: 'cleanliness', label: 'Cleanliness', icon: Icons.cleaning_services),
    ComplaintCategory(id: 'safety', label: 'Safety Issue', icon: Icons.warning),
    ComplaintCategory(id: 'other', label: 'Other', icon: Icons.more_horiz),
  ];

  @override
  void dispose() {
    _desc.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(apiServiceProvider).submitComplaint(
            category: _cat,
            description: _desc.text.trim(),
          );

      ref.invalidate(myComplaintsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complaint submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        context.go('/passenger/complaints');
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('File a Complaint'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/passenger/complaints'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Category Title
              const Text(
                'Select Category',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 12),

              /// 🔹 Category Grid
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
                children: _categories.map((cat) {
                  final selected = _cat == cat.id;

                  return GestureDetector(
                    onTap: () => setState(() => _cat = cat.id),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF3B82F6) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF3B82F6)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            cat.icon,
                            color: selected
                                ? Colors.white
                                : Colors.grey.shade600,
                            size: 24,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              /// 🔹 Description Title
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 8),

              /// 🔹 Description Field
              TextFormField(
                controller: _desc,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Describe the issue in detail...',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().length < 10)
                        ? 'Please write at least 10 characters'
                        : null,
              ),

              /// 🔹 Error Message
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              /// 🔹 Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Complaint',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}