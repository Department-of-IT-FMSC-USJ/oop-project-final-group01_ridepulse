// ============================================================
// features/auth/screens/register_screen.dart
// OOP Polymorphism: type param drives which fields + endpoint
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String type; // passenger | bus_owner | authority | staff
  const RegisterScreen({super.key, required this.type});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form        = GlobalKey<FormState>();
  final _name        = TextEditingController();
  final _email       = TextEditingController();
  final _phone       = TextEditingController();
  final _pass        = TextEditingController();
  final _bizName     = TextEditingController();
  final _nic         = TextEditingController();
  final _address     = TextEditingController();
  final _designation = TextEditingController();
  final _empId       = TextEditingController();
  final _license     = TextEditingController();
  final _salary      = TextEditingController();
  String _staffType  = 'driver';
  bool   _loading    = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name,_email,_phone,_pass,_bizName,_nic,
        _address,_designation,_empId,_license,_salary]) c.dispose();
    super.dispose();
  }

  String get _title => switch (widget.type) {
    'passenger'  => 'Create Passenger Account',
    'bus_owner'  => 'Register as Bus Owner',
    'authority'  => 'Authority Registration',
    'staff'      => 'Register Staff Member',
    _            => 'Register',
  };

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final svc = ref.read(authServiceProvider);
      switch (widget.type) {
        case 'passenger':
          final r = await svc.registerPassenger(
            fullName: _name.text, email: _email.text,
            phone: _phone.text,   password: _pass.text);
          await svc.saveSession(r);
        case 'bus_owner':
          final r = await svc.registerBusOwner(
            fullName: _name.text, email: _email.text,
            phone: _phone.text,   password: _pass.text,
            businessName: _bizName.text, nicNumber: _nic.text,
            address: _address.text);
          await svc.saveSession(r);
        case 'authority':
          final r = await svc.registerAuthority(
            fullName: _name.text, email: _email.text,
            phone: _phone.text,   password: _pass.text,
            designation: _designation.text);
          await svc.saveSession(r);
        case 'staff':
          await svc.registerStaff(
            fullName: _name.text, email: _email.text,
            phone: _phone.text,   password: _pass.text,
            staffType: _staffType, employeeId: _empId.text,
            licenseNumber: _license.text.isEmpty ? null : _license.text,
            baseSalary: double.tryParse(_salary.text));
          if (mounted) context.go('/bus-owner/staff');
          return;
      }
      if (mounted) {
        await ref.read(authProvider.notifier)
            .login(_email.text, _pass.text);
      }
    } catch (e) {
      setState(() => _error =
          e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 700;
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: isWeb ? 0 : 20, vertical: 32),
          child: Container(
            width: isWeb ? 500 : double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Form(
              key: _form,
              child: Column(children: [
                Row(children: [
                  TextButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Back'),
                  ),
                ]),
                Text(_title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),

                // Common fields
                _f(_name,  'Full Name',    Icons.person_outline),
                const SizedBox(height: 14),
                _f(_email, 'Email',        Icons.email_outlined,
                    keyboard: TextInputType.emailAddress),
                const SizedBox(height: 14),
                _f(_phone, 'Phone Number', Icons.phone_outlined,
                    keyboard: TextInputType.phone),
                const SizedBox(height: 14),
                _f(_pass,  'Password',     Icons.lock_outline,
                    obscure: true, min: 8),
                const SizedBox(height: 14),

                // Bus owner extras
                if (widget.type == 'bus_owner') ...[
                  _f(_bizName, 'Business Name', Icons.business),
                  const SizedBox(height: 14),
                  _f(_nic, 'NIC Number', Icons.badge_outlined),
                  const SizedBox(height: 14),
                  _f(_address, 'Address', Icons.location_on_outlined,
                      required: false, maxLines: 2),
                  const SizedBox(height: 14),
                ],

                // Authority extras
                if (widget.type == 'authority') ...[
                  _f(_designation, 'Designation / Title',
                      Icons.work_outline),
                  const SizedBox(height: 14),
                ],

                // Staff extras — Polymorphism: fields change by staffType
                if (widget.type == 'staff') ...[
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(children: [
                      RadioListTile<String>(
                        value: 'driver', groupValue: _staffType,
                        title: const Text('Driver'),
                        onChanged: (v) =>
                            setState(() => _staffType = v!),
                      ),
                      RadioListTile<String>(
                        value: 'conductor', groupValue: _staffType,
                        title: const Text('Conductor'),
                        onChanged: (v) =>
                            setState(() => _staffType = v!),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  _f(_empId, 'Employee ID', Icons.badge),
                  const SizedBox(height: 14),
                  if (_staffType == 'driver') ...[
                    _f(_license, 'License Number', Icons.credit_card,
                        required: false),
                    const SizedBox(height: 14),
                  ],
                  _f(_salary, 'Base Salary (LKR)', Icons.attach_money,
                      keyboard: TextInputType.number, required: false),
                  const SizedBox(height: 14),
                ],

                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 13))),
                    ]),
                  ),

                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(widget.type == 'staff'
                            ? 'Register Staff' : 'Create Account'),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _f(TextEditingController c, String label, IconData icon,
      {TextInputType keyboard = TextInputType.text,
      bool obscure = false, bool required = true,
      int maxLines = 1, int min = 1}) =>
    TextFormField(
      controller: c, keyboardType: keyboard,
      obscureText: obscure, maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
      validator: required
          ? (v) {
              if (v == null || v.trim().isEmpty) return '$label required';
              if (min > 1 && v.length < min)
                return '$label min $min characters';
              return null;
            }
          : null,
    );
}
