import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  final _shopId = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() { _shopId.dispose(); super.dispose(); }

  Future<void> _enterShop() async {
    if (_shopId.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a Shop ID');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final state = context.read<AppState>();
    await state.loadShopById(_shopId.text.trim());
    if (mounted && state.view != AppView.customerShop) {
      setState(() { _loading = false; _error = 'Shop not found'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.3, -0.3),
            radius: 1.0,
            colors: [Color(0x1A6C63FF), AppColors.bgPrimary],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          constraints: const BoxConstraints(maxWidth: 400),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => state.setView(AppView.landing),
                                child: const Row(children: [
                                  Icon(Icons.arrow_back_ios, color: AppColors.textSecondary, size: 16),
                                  SizedBox(width: 4),
                                  Text('Back', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                                ]),
                              ),
                              const SizedBox(height: 16),
                              const Text('🏪 Enter Shop ID', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 8),
                              const Text('Enter the Shop ID provided by the store owner.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
                              const SizedBox(height: 24),
                              AppTextField(label: 'Shop ID', hint: 'Paste the shop ID here', controller: _shopId),
                              if (_error != null) ...[
                                const SizedBox(height: 10),
                                Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                              ],
                              const SizedBox(height: 12),
                              PrimaryButton(
                                label: 'Enter Shop →',
                                onPressed: _enterShop,
                                loading: _loading,
                                fullWidth: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}