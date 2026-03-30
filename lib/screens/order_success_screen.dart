import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      final order = state.lastOrder;
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(children: [
                  const SizedBox(height: 40),
                  const Text('🎉', style: TextStyle(fontSize: 72)),
                  const SizedBox(height: 16),
                  const Text('Order Placed!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Text(
                    'Your order has been placed at ${state.shop?.name}. The owner will prepare it shortly.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.6),
                  ),
                  const SizedBox(height: 28),

                  if (order != null) AppCard(child: Column(children: [
                    ...order.items.map((it) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(children: [
                        Expanded(child: Text('${it.name} ×${it.qty}', style: const TextStyle(fontSize: 14))),
                        Text('₹${it.subtotal.round()}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ]),
                    )),
                    const Divider(color: AppColors.border),
                    Row(children: [
                      const Expanded(child: Text('Total', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                      Text('₹${order.total.round()}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.accent)),
                    ]),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        '30% advance: ₹${(order.total * 0.3).round()} — pay at pickup',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.success, fontSize: 13),
                      ),
                    ),
                  ])),
                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.accent.withOpacity(0.3))),
                    child: const Text('📲 You\'ll be notified when your order is ready for pickup!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.accent, fontSize: 14)),
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: 'Continue Shopping',
                    fullWidth: true,
                    onPressed: () => state.setView(AppView.customerShop),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => state.setView(AppView.landing),
                    child: Container(
                      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                      child: const Center(child: Text('Back to Home', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600))),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
    });
  }
}
