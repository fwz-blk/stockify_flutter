import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../models/models.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String _search = '';

  void _showAddDialog(BuildContext context) {
    final name = TextEditingController();
    final category = TextEditingController();
    final price = TextEditingController();
    final stock = TextEditingController();
    String unit = 'pcs';
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            const Text('Add New Product', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            AppTextField(label: 'Product Name *', hint: 'e.g. Sunflower Oil', controller: name),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: AppTextField(label: 'Category *', hint: 'e.g. Oils', controller: category)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Unit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: AppColors.bgInput, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                  child: DropdownButton<String>(
                    value: unit,
                    underline: const SizedBox(),
                    dropdownColor: AppColors.bgCard,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    items: ['pcs', 'kg', 'L', 'g', 'ml', 'pack'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (v) => setS(() => unit = v!),
                  ),
                ),
              ]),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: AppTextField(label: 'Price (₹) *', hint: '0.00', controller: price, keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: AppTextField(label: 'Initial Stock', hint: '0', controller: stock, keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Add Product',
              fullWidth: true,
              loading: loading,
              onPressed: () async {
                if (name.text.isEmpty || category.text.isEmpty || price.text.isEmpty) return;
                setS(() => loading = true);
                final state = context.read<AppState>();
                await state.addProduct({
                  'shop_id': state.shop!.id,
                  'name': name.text.trim(),
                  'category': category.text.trim(),
                  'price': double.tryParse(price.text) ?? 0,
                  'stock': int.tryParse(stock.text) ?? 0,
                  'unit': unit,
                });
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 24),
          ])),
        );
      }),
    );
  }

  void _showEditDialog(BuildContext context, Product p) {
    final price = TextEditingController(text: '${p.price}');
    final stock = TextEditingController(text: '${p.stock}');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Edit ${p.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: AppTextField(label: 'Price (₹)', controller: price, keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: AppTextField(label: 'Stock', controller: stock, keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 24),
          PrimaryButton(
            label: '✓ Save Changes',
            fullWidth: true,
            onPressed: () async {
              await context.read<AppState>().updateProduct(p.id, {
                'price': double.tryParse(price.text) ?? p.price,
                'stock': int.tryParse(stock.text) ?? p.stock,
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      final filtered = state.products.where((p) =>
        p.name.toLowerCase().contains(_search.toLowerCase()) ||
        p.category.toLowerCase().contains(_search.toLowerCase()),
      ).toList();

      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddDialog(context),
          backgroundColor: AppColors.accent,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
        body: Column(children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.bgInput,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
              ? const EmptyState(emoji: '📦', title: 'No products found', subtitle: 'Add your first product using the button below')
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final p = filtered[i];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: p.isLowStock || p.isOutOfStock ? AppColors.danger.withOpacity(0.3) : AppColors.border),
                      ),
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 4),
                          Row(children: [
                            StatusBadge(p.category, type: BadgeType.info),
                            const SizedBox(width: 8),
                            StatusBadge(
                              p.isOutOfStock ? 'Out of Stock' : '${p.stock} ${p.unit}',
                              type: p.isOutOfStock ? BadgeType.danger : p.isLowStock ? BadgeType.warning : BadgeType.success,
                            ),
                          ]),
                        ])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text('₹${p.price}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.accent)),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _showEditDialog(context, p),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: AppColors.bgInput, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.borderLight)),
                              child: const Text('✏️ Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ]),
                      ]),
                    );
                  },
                ),
          ),
        ]),
      );
    });
  }
}
