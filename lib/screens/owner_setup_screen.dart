import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class OwnerSetupScreen extends StatefulWidget {
  const OwnerSetupScreen({super.key});

  @override
  State<OwnerSetupScreen> createState() => _OwnerSetupScreenState();
}

class _OwnerSetupScreenState extends State<OwnerSetupScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose(); _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) { setState(() => _error = 'Shop name is required'); return; }
    if (_phone.text.length < 10) { setState(() => _error = 'Enter a valid 10-digit phone number'); return; }
    setState(() { _loading = true; _error = null; });
    final err = await context.read<AppState>().setupShop(_name.text.trim(), _phone.text.trim());
    if (mounted) setState(() { _loading = false; _error = err; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(children: [
                const Text('🏪', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 16),
                const Text('Set Up Your Shop', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                const Text(
                  'This is required before you can start managing inventory and accepting orders.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: 32),
                AppTextField(label: 'Shop Name *', hint: 'e.g. Krishna General Store', controller: _name),
                const SizedBox(height: 18),
                AppTextField(
                  label: 'Phone Number *',
                  hint: '10-digit mobile number',
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                ],
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Done — Generate QR Code ✨',
                  onPressed: _submit,
                  loading: _loading,
                  fullWidth: true,
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
