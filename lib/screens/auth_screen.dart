import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class AuthScreen extends StatefulWidget {
  final String role; // 'owner' | 'customer'
  const AuthScreen({super.key, required this.role});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose(); _password.dispose(); _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_email.text.isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final state = context.read<AppState>();
    String? err;
    if (isLogin) {
      err = await state.signIn(_email.text.trim(), _password.text, widget.role);
    } else {
      err = await state.signUp(_email.text.trim(), _password.text, widget.role);
    }
    if (mounted) setState(() { _loading = false; _error = err; });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final isOwner = widget.role == 'owner';
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.5, -0.5),
            radius: 1.0,
            colors: [Color(0x1A6C63FF), AppColors.bgPrimary],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back
                GestureDetector(
                  onTap: () => state.setView(AppView.landing),
                  child: Row(children: [
                    const Icon(Icons.arrow_back_ios, color: AppColors.textSecondary, size: 16),
                    const SizedBox(width: 4),
                    const Text('Back', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  ]),
                ),
                const SizedBox(height: 36),

                // Logo
                Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accent2]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text('📦', style: TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 10),
                  RichText(text: const TextSpan(style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800), children: [
                    TextSpan(text: 'Stock', style: TextStyle(color: AppColors.textPrimary)),
                    TextSpan(text: 'ify', style: TextStyle(color: AppColors.accent)),
                  ])),
                ]),
                const SizedBox(height: 28),
                Text(
                  '${isOwner ? '🏪 Owner' : '🛍️ Customer'} ${isLogin ? 'Sign In' : 'Register'}',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  isLogin ? 'Welcome back! Sign in to continue.' : 'Create your account to get started.',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 28),

                // Toggle tabs
                Container(
                  decoration: BoxDecoration(color: AppColors.bgInput, borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.all(4),
                  child: Row(children: [
                    Expanded(child: _Tab('Sign In', isLogin, () => setState(() { isLogin = true; _error = null; }))),
                    Expanded(child: _Tab('Register', !isLogin, () => setState(() { isLogin = false; _error = null; }))),
                  ]),
                ),
                const SizedBox(height: 24),

                // Form
                if (!isLogin) ...[
                  AppTextField(label: 'Full Name', hint: 'Your name', controller: _name),
                  const SizedBox(height: 18),
                ],
                AppTextField(label: 'Email Address', hint: 'you@email.com', controller: _email, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 18),
                AppTextField(label: 'Password', hint: '••••••••', controller: _password, obscureText: true),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                ],
                const SizedBox(height: 24),
                PrimaryButton(
                  label: isLogin ? 'Sign In →' : 'Create Account →',
                  onPressed: _submit,
                  loading: _loading,
                  fullWidth: true,
                ),
                const SizedBox(height: 20),
                const Row(children: [
                  Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: AppColors.border)),
                ]),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Google login disabled — use email & password')),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.bgInput,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('🌐', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 10),
                      Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Tab(this.label, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label, textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: active ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}
