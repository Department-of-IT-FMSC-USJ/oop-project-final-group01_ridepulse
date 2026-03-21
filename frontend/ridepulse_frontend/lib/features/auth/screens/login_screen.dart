// ============================================================
// features/auth/screens/login_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form    = GlobalKey<FormState>();
  final _email   = TextEditingController();
  final _pass    = TextEditingController();
  bool  _obscure = true;

  @override
  void dispose() {
    _email.dispose(); _pass.dispose(); super.dispose();
  }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    await ref.read(authProvider.notifier)
        .login(_email.text.trim(), _pass.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth  = ref.watch(authProvider);
    final isWeb = MediaQuery.of(context).size.width > 700;

    // Redirect after login
    ref.listen(authProvider, (_, next) {
      if (next.isLoggedIn) {
        final dest = switch (next.role) {
          'bus_owner'  => '/bus-owner/dashboard',
          'driver'     => '/driver/home',
          'conductor'  => '/conductor/home',
          'passenger'  => '/passenger/home',
          'authority'  => '/authority/dashboard',
          _            => '/login',
        };
        context.go(dest);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: isWeb ? 0 : 24, vertical: 32),
          child: Container(
            width: isWeb ? 420 : double.infinity,
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06),
                    blurRadius: 20, offset: const Offset(0, 8))
              ],
            ),
            child: Form(
              key: _form,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A56DB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.directions_bus_rounded,
                      color: Color(0xFF1A56DB), size: 36),
                ),
                const SizedBox(height: 16),
                const Text('RidePulse',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A56DB))),
                const SizedBox(height: 4),
                Text('Sign in to your account',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 14)),
                const SizedBox(height: 32),

                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined, size: 20)),
                  validator: (v) =>
                      (v == null || !v.contains('@'))
                          ? 'Enter a valid email'
                          : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pass,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Enter password' : null,
                ),

                if (auth.error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(auth.error!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13))),
                    ]),
                  ),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _login,
                    child: auth.isLoading
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Sign In',
                            style: TextStyle(fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text("Don't have an account?",
                    style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _Chip('Passenger', Icons.person,
                        Colors.green, () => context.go('/register/passenger')),
                    _Chip('Bus Owner', Icons.business,
                        Colors.orange, () => context.go('/register/bus-owner')),
                    _Chip('Authority', Icons.admin_panel_settings,
                        Colors.purple, () => context.go('/register/authority')),
                  ],
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String    label;
  final IconData  icon;
  final Color     color;
  final VoidCallback onTap;
  const _Chip(this.label, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(20),
        color: color.withOpacity(0.07),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
    ),
  );
}
