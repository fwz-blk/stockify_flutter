import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class CustomerShopScreen extends StatefulWidget {
  const CustomerShopScreen({super.key});

  @override
  State<CustomerShopScreen> createState() => _CustomerShopScreenState();
}

class _CustomerShopScreenState extends State<CustomerShopScreen> {
  String _search = '';
  String _category = 'All';
  bool _cartOpen = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      final categories = ['All', ...state.products.map((p) => p.category).toSet()];
      final filtered = state.products.where((p) {
        final matchCat = _category == 'All' || p.category == _category;
        final matchSearch = _search.isEmpty || p.name.toLowerCase().contains(_search.toLowerCase());
        return matchCat && matchSearch;
      }).toList();

      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Stack(children: [
          Column(children: [
            // Header
            Container(
              color: AppColors.bgSecondary,
              padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
              child: Column(children: [
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(state.shop?.name ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const Text('📍 Kirana Shop', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ])),
                  GestureDetector(
                    onTap: () => setState(() => _cartOpen = true),
                    child: Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(24)),
                      child: Stack(children: [
                        const Center(child: Text('🛒', style: TextStyle(fontSize: 22))),
                        if (state.cartCount > 0) Positioned(
                          top: 2, right: 2,
                          child: Container(
                            width: 18, height: 18,
                            decoration: const BoxDecoration(color: AppColors.accent2, shape: BoxShape.circle),
                            child: Center(child: Text('${state.cartCount}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white))),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) => setState(() => _search = v),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                    filled: true, fillColor: AppColors.bgInput,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                  ),
                ),
              ]),
            ),

            // Category filter
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: categories.length,
                itemBuilder: (_, i) {
                  final c = categories[i];
                  final active = _category == c;
                  return GestureDetector(
                    onTap: () => setState(() => _category = c),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: active ? AppColors.accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: active ? AppColors.accent : AppColors.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(c, style: TextStyle(color: active ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  );
                },
              ),
            ),

            // Products grid
            Expanded(
              child: filtered.isEmpty
                ? const EmptyState(emoji: '🔍', title: 'No products', subtitle: 'Try a different category or search term')
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _ProductCard(product: filtered[i]),
                  ),
            ),
          ]),

          // Cart drawer overlay
          if (_cartOpen) GestureDetector(
            onTap: () => setState(() => _cartOpen = false),
            child: Container(color: Colors.black54),
          ),

          // Cart panel
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            right: _cartOpen ? 0 : -MediaQuery.of(context).size.width,
            top: 0, bottom: 0,
            width: MediaQuery.of(context).size.width * 0.85,
            child: _CartPanel(onClose: () => setState(() => _cartOpen = false)),
          ),
        ]),
      );
    });
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final qty = state.cart.firstWhere((c) => c.product.id == product.id, orElse: () => CartItem(product: product, qty: 0)).qty;
    final stockPct = (product.stock / 60).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(product.category, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ])),
          StatusBadge(
            product.isOutOfStock ? 'Out' : product.isLowStock ? 'Low' : 'In',
            type: product.isOutOfStock ? BadgeType.danger : product.isLowStock ? BadgeType.warning : BadgeType.success,
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const Text('Stock: ', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          Text('${product.stock} ${product.unit}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: stockPct,
            backgroundColor: AppColors.bgInput,
            color: product.isOutOfStock ? AppColors.danger : product.isLowStock ? AppColors.warning : AppColors.success,
            minHeight: 4,
          ),
        ),
        const Spacer(),
        Text('₹${product.price}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.accent)),
        Text('/${product.unit}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        if (product.isOutOfStock)
          const Center(child: Text('Unavailable', style: TextStyle(fontSize: 12, color: AppColors.textMuted)))
        else if (qty == 0)
          GestureDetector(
            onTap: () => context.read<AppState>().addToCart(product),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8)),
              child: const Center(child: Text('+ Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))),
            ),
          )
        else
          QtyControl(
            qty: qty,
            onInc: () => context.read<AppState>().updateCartQty(product.id, qty + 1),
            onDec: () => context.read<AppState>().updateCartQty(product.id, qty - 1),
          ),
      ]),
    );
  }
}

class _CartPanel extends StatelessWidget {
  final VoidCallback onClose;
  const _CartPanel({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      return Container(
        color: AppColors.bgSecondary,
        child: Column(children: [
          const SizedBox(height: 52),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(children: [
              const Text('🛒 Your Cart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              GestureDetector(
                onTap: onClose,
                child: Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.bgInput, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary)),
              ),
            ]),
          ),
          const Divider(color: AppColors.border, height: 1),
          Expanded(
            child: state.cart.isEmpty
              ? const EmptyState(emoji: '🛒', title: 'Cart is empty', subtitle: 'Add products to get started')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.cart.length,
                  itemBuilder: (_, i) {
                    final item = state.cart[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 8),
                        Row(children: [
                          QtyControl(
                            qty: item.qty,
                            onInc: () => state.updateCartQty(item.product.id, item.qty + 1),
                            onDec: () => state.updateCartQty(item.product.id, item.qty - 1),
                          ),
                          const Spacer(),
                          Text('₹${item.subtotal.round()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.accent)),
                        ]),
                      ]),
                    );
                  },
                ),
          ),
          if (state.cart.isNotEmpty) Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
            child: Column(children: [
              Row(children: [
                const Text('Total', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                const Spacer(),
                Text('₹${state.cartTotal.round()}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 8),
              Container(
                width: double.infinity, padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.success.withOpacity(0.2))),
                child: Text('30% advance: ₹${(state.cartTotal * 0.3).round()}', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Place Order 🎉',
                fullWidth: true,
                onPressed: () async {
                  onClose();
                  final ok = await state.placeOrder();
                  if (!ok && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Failed to place order')));
                  }
                },
              ),
            ]),
          ),
          const SizedBox(height: 8),
        ]),
      );
    });
  }
}
