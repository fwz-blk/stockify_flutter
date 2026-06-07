import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../state/app_state.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      final totalValue =
          state.products.fold(0.0, (s, p) => s + p.price * p.stock);
      return RefreshIndicator(
        onRefresh: () async {
          if (state.shop != null) {
            await state.loadProducts(state.shop!.id);
            await state.loadOrders(state.shop!.id);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Good day! 👋',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('${state.shop?.name ?? ''} — Store overview',
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),

            // Stats grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                StatCard(
                    emoji: '📦',
                    value: '${state.products.length}',
                    label: 'Total Products',
                    iconBg: AppColors.accent.withOpacity(0.15)),
                StatCard(
                    emoji: '📋',
                    value: '${state.pendingOrders.length}',
                    label: 'Pending Orders',
                    iconBg: AppColors.accent2.withOpacity(0.15)),
                StatCard(
                    emoji: '⚠️',
                    value: '${state.lowStockProducts.length}',
                    label: 'Low Stock Items',
                    iconBg: AppColors.warning.withOpacity(0.15)),
                StatCard(
                    emoji: '💰',
                    value:
                        '₹${NumberFormat('#,##,###').format(totalValue.round())}',
                    label: 'Inventory Value',
                    iconBg: AppColors.success.withOpacity(0.15)),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Orders
            AppCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('📋 Recent Orders',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 16),
                  if (state.orders.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No orders yet',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 14)),
                    )
                  else
                    ...state.orders.take(4).map((o) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(o.customerName,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600)),
                                  Text(
                                      'Order #${o.id.length > 8 ? o.id.substring(0, 8) : o.id}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMuted)),
                                ])),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('₹${o.total.round()}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  StatusBadge(o.status,
                                      type: o.isPending
                                          ? BadgeType.warning
                                          : BadgeType.success),
                                ]),
                          ]),
                        )),
                ])),
            const SizedBox(height: 16),

            // Low Stock
            AppCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('⚠️ Low Stock Alerts',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 16),
                  if (state.lowStockProducts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('✅ All products well stocked!',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 14)),
                    )
                  else
                    ...state.lowStockProducts.take(5).map((p) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(children: [
                            Expanded(
                                child: Text(p.name,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600))),
                            StatusBadge(
                              p.isOutOfStock
                                  ? 'Out of Stock'
                                  : '${p.stock} ${p.unit} left',
                              type: p.isOutOfStock
                                  ? BadgeType.danger
                                  : BadgeType.warning,
                            ),
                          ]),
                        )),
                ])),
          ]),
        ),
      );
    });
  }
}
