import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../models/models.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class LowStockPage extends StatefulWidget {
  const LowStockPage({super.key});

  @override
  State<LowStockPage> createState() => _LowStockPageState();
}

class _LowStockPageState extends State<LowStockPage> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  TextEditingController _ctrl(String id) {
    return _controllers.putIfAbsent(id, () => TextEditingController());
  }

  Future<void> _restock(BuildContext context, Product p) async {
    final amt = int.tryParse(_ctrl(p.id).text) ?? 0;
    if (amt <= 0) return;
    await context.read<AppState>().updateProduct(p.id, {'stock': p.stock + amt});
    _ctrl(p.id).clear();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('📦 ${p.name} restocked by $amt ${p.unit}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      final items = state.lowStockProducts;
      if (items.isEmpty) {
        return const EmptyState(emoji: '✅', title: 'All Good!', subtitle: 'No products below the stock threshold.');
      }
      return Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(children: [
            const Text('Low Stock Items', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const Spacer(),
            StatusBadge('${items.length} items', type: BadgeType.warning),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final p = items[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.isOutOfStock ? AppColors.danger.withOpacity(0.4) : AppColors.warning.withOpacity(0.3)),
                ),
                child: Column(children: [
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 6),
                      Row(children: [
                        StatusBadge(p.category, type: BadgeType.info),
                        const SizedBox(width: 8),
                        StatusBadge(
                          p.isOutOfStock ? 'Out of Stock' : '${p.stock} ${p.unit} left',
                          type: p.isOutOfStock ? BadgeType.danger : BadgeType.warning,
                        ),
                      ]),
                    ])),
                    Text('${p.stock} ${p.unit}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18,
                      color: p.isOutOfStock ? AppColors.danger : AppColors.warning)),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl(p.id),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Add qty',
                          filled: true, fillColor: AppColors.bgInput,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _restock(context, p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                        decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(8)),
                        child: const Text('+ Add', style: TextStyle(color: Color(0xFF0A0A0F), fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ),
                  ]),
                ]),
              );
            },
          ),
        ),
      ]);
    });
  }
}
