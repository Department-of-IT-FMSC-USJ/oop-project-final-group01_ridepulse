import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../features/auth/screens/register_screen.dart';

class RegisterStaffScreen extends StatelessWidget {
  const RegisterStaffScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Register Staff'),
      leading: IconButton(icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/bus-owner/staff'))),
    body: const Center(
        child: SizedBox(width: 560,
            child: RegisterScreen(type: 'staff'))),
  );
}
