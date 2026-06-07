import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../state/app_state.dart';
import '../../models/models.dart';
import '../../theme.dart';
import '../../widgets/widgets.dart';

class BillingPage extends StatefulWidget {
  const BillingPage({super.key});

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: AppColors.bgSecondary,
        child: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: '🧾 New Bill'),
            Tab(text: '📜 History'),
            Tab(text: '📦 Stock')
          ],
        ),
      ),
      Expanded(
          child: TabBarView(controller: _tabs, children: const [
        _NewBillTab(),
        _BillHistoryTab(),
        _StockManagerTab(),
      ])),
    ]);
  }
}

// ─── NEW BILL TAB ──────────────────────────────────────────────────────────
class _NewBillTab extends StatefulWidget {
  const _NewBillTab();
  @override
  State<_NewBillTab> createState() => _NewBillTabState();
}

class _NewBillTabState extends State<_NewBillTab> {
  final _customerName = TextEditingController();
  final _customerPhone = TextEditingController();
  final _search = TextEditingController();
  final _discount = TextEditingController();
  final _note = TextEditingController();
  List<CartItem> _items = [];
  bool _showSuggestions = false;
  String _discountType = '%';
  String _paymentMode = 'Cash';

  @override
  void dispose() {
    _customerName.dispose();
    _customerPhone.dispose();
    _search.dispose();
    _discount.dispose();
    _note.dispose();
    super.dispose();
  }

  double get _subtotal => _items.fold(0, (s, i) => s + i.product.price * i.qty);
  double get _discountAmt {
    final d = double.tryParse(_discount.text) ?? 0;
    if (d <= 0) return 0;
    return _discountType == '%'
        ? (_subtotal * d / 100).roundToDouble()
        : d.clamp(0, _subtotal);
  }

  double get _total => _subtotal - _discountAmt;

  void _addItem(Product p) {
    setState(() {
      final idx = _items.indexWhere((i) => i.product.id == p.id);
      if (idx >= 0) {
        _items[idx].qty++;
      } else {
        _items.add(CartItem(product: p));
      }
      _search.clear();
      _showSuggestions = false;
    });
  }

  void _generateBill(BuildContext context) async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Add at least one product')));
      return;
    }
    final state = context.read<AppState>();
    final bill = Bill(
      id: 'BILL${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      customerName:
          _customerName.text.isEmpty ? 'Walk-in Customer' : _customerName.text,
      customerPhone: _customerPhone.text,
      items: List.from(_items),
      subtotal: _subtotal,
      discount: double.tryParse(_discount.text) ?? 0,
      discountType: _discountType,
      discountAmt: _discountAmt,
      total: _total,
      paymentMode: _paymentMode,
      time: DateTime.now(),
      note: _note.text,
    );
    // Deduct stock
    for (final item in _items) {
      await state.updateProduct(item.product.id,
          {'stock': (item.product.stock - item.qty).clamp(0, 999999)});
    }
    state.addBill(bill);
    _showReceipt(context, bill, state);
  }

  void _showReceipt(BuildContext context, Bill bill, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _BillReceiptSheet(
          bill: bill,
          shopName: state.shop?.name ?? '',
          shopPhone: state.shop?.phone ?? ''),
    );
    setState(() {
      _items = [];
      _customerName.clear();
      _customerPhone.clear();
      _discount.clear();
      _note.clear();
      _paymentMode = 'Cash';
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final suggestions = _search.text.length > 1
        ? state.products
            .where((p) =>
                p.name.toLowerCase().contains(_search.text.toLowerCase()) &&
                p.stock > 0)
            .take(8)
            .toList()
        : <Product>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Customer
        AppCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('👤 Customer Details (Optional)',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
                child: AppTextField(
                    label: 'Name',
                    hint: 'e.g. Ramesh',
                    controller: _customerName)),
            const SizedBox(width: 12),
            Expanded(
                child: AppTextField(
                    label: 'Phone',
                    hint: '10 digits',
                    controller: _customerPhone,
                    keyboardType: TextInputType.phone)),
          ]),
        ])),
        const SizedBox(height: 14),

        // Product search
        AppCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('🔍 Add Products',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5)),
          const SizedBox(height: 14),
          TextField(
            controller: _search,
            style: const TextStyle(color: AppColors.textPrimary),
            onChanged: (v) => setState(() => _showSuggestions = v.length > 1),
            decoration: InputDecoration(
              hintText: 'Search product...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.bgInput,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border)),
            ),
          ),
          if (_showSuggestions && suggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...suggestions.map((p) => GestureDetector(
                  onTap: () => _addItem(p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: AppColors.border))),
                    child: Row(children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(p.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            Text('${p.category} · ${p.stock} ${p.unit}',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textMuted)),
                          ])),
                      Text('₹${p.price}/${p.unit}',
                          style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700)),
                    ]),
                  ),
                )),
          ],
        ])),
        const SizedBox(height: 14),

        // Items list
        if (_items.isEmpty)
          const AppCard(
              child: Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(
                child: Column(children: [
              Text('🛒', style: TextStyle(fontSize: 48)),
              SizedBox(height: 8),
              Text('Bill is empty',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600)),
            ])),
          ))
        else
          AppCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Bill Items',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 12),
                ..._items.asMap().entries.map((e) {
                  final item = e.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(item.product.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            Text('₹${item.product.price}/${item.product.unit}',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textMuted)),
                          ])),
                      QtyControl(
                        qty: item.qty,
                        onInc: () => setState(() => item.qty++),
                        onDec: () => setState(() {
                          if (item.qty > 1) {
                            item.qty--;
                          } else {
                            _items.removeAt(e.key);
                          }
                        }),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                          width: 60,
                          child: Text(
                              '₹${(item.product.price * item.qty).round()}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accent))),
                    ]),
                  );
                }),
              ])),
        const SizedBox(height: 14),

        // Bill summary
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0x1A6C63FF), Color(0x12FF6584)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accent.withOpacity(0.25)),
          ),
          child: Column(children: [
            Row(children: [
              const Expanded(
                  child: Text('Subtotal',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14))),
              Text('₹${_subtotal.round()}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 12),
            // Discount
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _discount,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Discount',
                    filled: true,
                    fillColor: AppColors.bgInput,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(
                    () => _discountType = _discountType == '%' ? '₹' : '%'),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                      color: AppColors.bgInput,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderLight)),
                  child: Text(_discountType,
                      style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
                ),
              ),
            ]),
            if (_discountAmt > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('✅ Saving ₹${_discountAmt.round()}',
                        style: const TextStyle(
                            color: AppColors.success, fontSize: 12))),
              ),
            const Divider(color: AppColors.border, height: 24),
            Row(children: [
              const Text('Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text('₹${_total.round()}',
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.accent)),
            ]),
            const SizedBox(height: 16),

            // Payment mode
            const Align(
                alignment: Alignment.centerLeft,
                child: Text('Payment Mode',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary))),
            const SizedBox(height: 8),
            Wrap(
                spacing: 8,
                children: ['Cash', 'UPI', 'Card', 'Credit'].map((m) {
                  final active = _paymentMode == m;
                  return GestureDetector(
                    onTap: () => setState(() => _paymentMode = m),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.accent.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color:
                                active ? AppColors.accent : AppColors.border),
                      ),
                      child: Text(m,
                          style: TextStyle(
                              color: active
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ),
                  );
                }).toList()),
            const SizedBox(height: 16),

            // Note
            TextField(
              controller: _note,
              style:
                  const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: '📝 Note / Remark (Optional)',
                filled: true,
                fillColor: AppColors.bgInput,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.border)),
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: '🧾 Generate Bill & Deduct Stock',
              onPressed: _items.isEmpty ? null : () => _generateBill(context),
              fullWidth: true,
            ),
          ]),
        ),
        const SizedBox(height: 40),
      ]),
    );
  }
}

// ─── BILL HISTORY TAB ──────────────────────────────────────────────────────
class _BillHistoryTab extends StatelessWidget {
  const _BillHistoryTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bills = state.billHistory;
    if (bills.isEmpty) {
      return const EmptyState(
          emoji: '📜',
          title: 'No bills yet',
          subtitle: 'Generate your first bill to see it here');
    }
    final totalRevenue = bills.fold(0.0, (s, b) => s + b.total);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
            StatCard(
                emoji: '🧾',
                value: '${bills.length}',
                label: 'Total Bills',
                iconBg: AppColors.accent.withOpacity(0.15)),
            StatCard(
                emoji: '💰',
                value: '₹${totalRevenue.round()}',
                label: 'Total Revenue',
                iconBg: AppColors.success.withOpacity(0.15)),
          ],
        ),
        const SizedBox(height: 16),
        ...bills.map((b) => _BillCard(bill: b)),
      ],
    );
  }
}

class _BillCard extends StatelessWidget {
  final Bill bill;
  const _BillCard({required this.bill});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM, hh:mm a').format(bill.time);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(bill.customerName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 4),
                Text('${bill.id} · $fmt',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('₹${bill.total.round()}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.accent)),
            if (bill.discountAmt > 0)
              Text('Saved ₹${bill.discountAmt.round()}',
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.success)),
          ]),
        ]),
        const SizedBox(height: 12),
        Wrap(
            spacing: 6,
            runSpacing: 6,
            children: bill.items
                .map((it) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppColors.bgInput,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border)),
                      child: Text('${it.product.name} ×${it.qty}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ))
                .toList()),
        if (bill.note.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('📝 ${bill.note}',
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic)),
          ),
      ]),
    );
  }
}

// ─── STOCK MANAGER TAB ─────────────────────────────────────────────────────
class _StockManagerTab extends StatefulWidget {
  const _StockManagerTab();
  @override
  State<_StockManagerTab> createState() => _StockManagerTabState();
}

class _StockManagerTabState extends State<_StockManagerTab> {
  String _search = '';
  final Map<String, TextEditingController> _ctrls = {};
  final Map<String, String> _modes = {};

  TextEditingController _ctrl(String id) =>
      _ctrls.putIfAbsent(id, () => TextEditingController());
  String _mode(String id) => _modes[id] ?? 'add';

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final filtered = state.products
        .where((p) =>
            _search.isEmpty ||
            p.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();
    final totalValue =
        state.products.fold(0.0, (s, p) => s + p.price * p.stock);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Overview card
        AppCard(
            child: Column(children: [
          const Align(
              alignment: Alignment.centerLeft,
              child: Text('📊 Inventory Overview',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
          const SizedBox(height: 14),
          ...[
            ('Total Products', '${state.products.length}', null),
            (
              'In Stock',
              '${state.products.where((p) => p.stock > 10).length}',
              AppColors.success
            ),
            (
              'Low Stock (≤10)',
              '${state.products.where((p) => p.stock > 0 && p.stock <= 10).length}',
              AppColors.warning
            ),
            (
              'Out of Stock',
              '${state.products.where((p) => p.stock == 0).length}',
              AppColors.danger
            ),
            ('Total Value', '₹${totalValue.round()}', AppColors.accent),
          ].map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  Expanded(
                      child: Text(s.$1,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 14))),
                  Text(s.$2,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: s.$3 ?? AppColors.textPrimary,
                          fontSize: 14)),
                ]),
              )),
        ])),
        const SizedBox(height: 14),

        // Search
        TextField(
          onChanged: (v) => setState(() => _search = v),
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search products...',
            prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.bgInput,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border)),
          ),
        ),
        const SizedBox(height: 14),

        ...filtered.map((p) {
          final mode = _mode(p.id);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border)),
            child: Column(children: [
              Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(p.name,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Row(children: [
                        StatusBadge(p.category, type: BadgeType.info),
                        const SizedBox(width: 6),
                        StatusBadge(
                          p.isOutOfStock
                              ? 'Out'
                              : p.isLowStock
                                  ? 'Low'
                                  : 'OK',
                          type: p.isOutOfStock
                              ? BadgeType.danger
                              : p.isLowStock
                                  ? BadgeType.warning
                                  : BadgeType.success,
                        ),
                      ]),
                    ])),
                Text('${p.stock} ${p.unit}',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: p.isOutOfStock
                            ? AppColors.danger
                            : p.isLowStock
                                ? AppColors.warning
                                : AppColors.success)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                // Mode toggle
                Container(
                  decoration: BoxDecoration(
                      color: AppColors.bgInput,
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: ['add', 'set'].map((m) {
                        final active = mode == m;
                        return GestureDetector(
                          onTap: () => setState(() => _modes[p.id] = m),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: active
                                    ? AppColors.accent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6)),
                            child: Text(m == 'add' ? '+Add' : '=Set',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: active
                                        ? Colors.white
                                        : AppColors.textSecondary)),
                          ),
                        );
                      }).toList()),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _ctrl(p.id),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: mode == 'add' ? '+qty' : 'qty',
                      filled: true,
                      fillColor: AppColors.bgInput,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.border)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    final val = int.tryParse(_ctrl(p.id).text) ?? 0;
                    if (val <= 0) return;
                    final newStock =
                        mode == 'add' ? p.stock + val : val.clamp(0, 999999);
                    await context
                        .read<AppState>()
                        .updateProduct(p.id, {'stock': newStock});
                    setState(() => _ctrl(p.id).clear());
                    if (context.mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('✅ ${p.name} stock updated')));
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Text('✓',
                        style: TextStyle(
                            color: Color(0xFF0A0A0F),
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ]),
            ]),
          );
        }),
        const SizedBox(height: 40),
      ]),
    );
  }
}

// ─── BILL RECEIPT SHEET ────────────────────────────────────────────────────
class _BillReceiptSheet extends StatelessWidget {
  final Bill bill;
  final String shopName;
  final String shopPhone;
  const _BillReceiptSheet(
      {required this.bill, required this.shopName, required this.shopPhone});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy, hh:mm a').format(bill.time);
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        const Text('🧾 Bill Receipt',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        Text(shopName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        if (shopPhone.isNotEmpty)
          Text('📞 $shopPhone',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
        Text(fmt,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        Text(bill.id,
            style: const TextStyle(
                color: AppColors.accent,
                fontSize: 13,
                fontFamily: 'monospace')),
        const SizedBox(height: 16),
        const Divider(color: AppColors.border),
        ...bill.items.map((it) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                Expanded(
                    child: Text(it.product.name,
                        style: const TextStyle(fontWeight: FontWeight.w600))),
                Text('×${it.qty}',
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(width: 16),
                Text('₹${(it.product.price * it.qty).round()}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ]),
            )),
        const Divider(color: AppColors.border),
        if (bill.discountAmt > 0)
          Row(children: [
            const Expanded(
                child: Text('Discount',
                    style: TextStyle(color: AppColors.success))),
            Text('-₹${bill.discountAmt.round()}',
                style: const TextStyle(
                    color: AppColors.success, fontWeight: FontWeight.w600)),
          ]),
        const SizedBox(height: 4),
        Row(children: [
          const Expanded(
              child: Text('Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
          Text('₹${bill.total.round()}',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accent)),
        ]),
        const SizedBox(height: 8),
        Text('Payment: ${bill.paymentMode}',
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 12),
        Text('Thank you for shopping at $shopName! 🙏',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 20),
        PrimaryButton(
            label: '✓ Done',
            fullWidth: true,
            onPressed: () => Navigator.pop(context)),
        const SizedBox(height: 8),
      ]),
    );
  }
}
