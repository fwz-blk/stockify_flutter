import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../state/app_state.dart';
import '../../models/models.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      final filtered = _filter == 'all'
          ? state.orders
          : state.orders.where((o) => o.status == _filter).toList();

      return Column(children: [
        // Filter tabs
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: ['all', 'pending', 'completed'].map((f) {
              final active = _filter == f;
              return GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppColors.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: active ? AppColors.accent : AppColors.border),
                  ),
                  child: Row(children: [
                    Text(f[0].toUpperCase() + f.substring(1),
                        style: TextStyle(
                            color:
                                active ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    if (f == 'pending' && state.pendingOrders.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                            color: active
                                ? Colors.white.withOpacity(0.3)
                                : AppColors.accent,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('${state.pendingOrders.length}',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: active ? Colors.white : Colors.white)),
                      ),
                    ],
                  ]),
                ),
              );
            }).toList()),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const EmptyState(
                  emoji: '📭',
                  title: 'No orders found',
                  subtitle: 'Orders will appear here when customers place them')
              : RefreshIndicator(
                  onRefresh: () async {
                    if (context.read<AppState>().shop != null) {
                      await context
                          .read<AppState>()
                          .loadOrders(context.read<AppState>().shop!.id);
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _OrderCard(order: filtered[i]),
                  ),
                ),
        ),
      ]);
    });
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('hh:mm a · dd MMM').format(order.createdAt);
    final advance = (order.total * 0.3).round();
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(order.customerName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                    '${order.id.length > 12 ? order.id.substring(0, 12) : order.id}... · $fmt',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontFamily: 'monospace')),
              ])),
          StatusBadge(order.status,
              type: order.isPending ? BadgeType.warning : BadgeType.success),
        ]),
        const SizedBox(height: 14),
        const Divider(color: AppColors.border),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Total · 30% advance',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 4),
                RichText(
                    text: TextSpan(
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800),
                        children: [
                      TextSpan(
                          text: '₹${order.total.round()} · ',
                          style: const TextStyle(color: AppColors.textPrimary)),
                      TextSpan(
                          text: '₹$advance',
                          style: const TextStyle(color: AppColors.success)),
                    ])),
              ])),
          if (order.isPending)
            GestureDetector(
              onTap: () async {
                await context.read<AppState>().completeOrder(order.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order marked complete ✅')));
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(10)),
                child: const Text('✓ Complete',
                    style: TextStyle(
                        color: Color(0xFF0A0A0F),
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
            ),
        ]),
      ]),
    );
  }
}
