import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'owner/dashboard_page.dart';
import 'owner/products_page.dart';
import 'owner/orders_page.dart';
import 'owner/low_stock_page.dart';
import 'owner/billing_page.dart';
import 'owner/qr_code_page.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      final titles = {
        OwnerPage.dashboard: 'Dashboard',
        OwnerPage.products: 'Products',
        OwnerPage.orders: 'Customer Orders',
        OwnerPage.lowStock: 'Low Stock',
        OwnerPage.billing: 'Billing & Stock',
        OwnerPage.qrCode: 'QR Code',
      };
      final pages = {
        OwnerPage.dashboard: const DashboardPage(),
        OwnerPage.products: const ProductsPage(),
        OwnerPage.orders: const OrdersPage(),
        OwnerPage.lowStock: const LowStockPage(),
        OwnerPage.billing: const BillingPage(),
        OwnerPage.qrCode: const QrCodePage(),
      };
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        appBar: AppBar(
          backgroundColor: AppColors.bgSecondary,
          title: Text(titles[state.ownerPage] ?? 'Dashboard',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text('Live', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
            ),
          ],
        ),
        drawer: _OwnerDrawer(),
        body: pages[state.ownerPage] ?? const DashboardPage(),
      );
    });
  }
}

class _OwnerDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      final navItems = [
        _NavItem(OwnerPage.dashboard, '📊', 'Dashboard'),
        _NavItem(OwnerPage.products, '📦', 'Products'),
        _NavItem(OwnerPage.orders, '📋', 'Orders', badge: state.pendingOrders.length),
        _NavItem(OwnerPage.lowStock, '⚠️', 'Low Stock', badge: state.lowStockProducts.length, badgeDanger: true),
        _NavItem(OwnerPage.billing, '🧾', 'Billing & Stock'),
        _NavItem(OwnerPage.qrCode, '📷', 'QR Code'),
      ];
      return Drawer(
        backgroundColor: AppColors.bgSecondary,
        child: Column(children: [
          DrawerHeader(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accent2]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: Text('📦', style: TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 10),
              RichText(text: const TextSpan(style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800), children: [
                TextSpan(text: 'Stock', style: TextStyle(color: AppColors.textPrimary)),
                TextSpan(text: 'ify', style: TextStyle(color: AppColors.accent)),
              ])),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Align(alignment: Alignment.centerLeft, child: Text('MANAGEMENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.5))),
          ),
          ...navItems.map((item) => _DrawerNavItem(item: item, state: state)),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Align(alignment: Alignment.centerLeft, child: Text('ACCOUNT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.5))),
          ),
          ListTile(
            leading: const Text('🚪', style: TextStyle(fontSize: 18)),
            title: const Text('Sign Out', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
            onTap: () { Navigator.pop(context); state.logout(); },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.accent, AppColors.accent2]),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text(
                    (state.shop?.name ?? 'O')[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  )),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(state.shop?.name ?? 'Shop', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                  const Text('Owner', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ])),
              ]),
            ),
          ),
        ]),
      );
    });
  }
}

class _NavItem { final OwnerPage page; final String icon; final String label; final int badge; final bool badgeDanger;
  _NavItem(this.page, this.icon, this.label, {this.badge = 0, this.badgeDanger = false}); }

class _DrawerNavItem extends StatelessWidget {
  final _NavItem item;
  final AppState state;
  const _DrawerNavItem({required this.item, required this.state});

  @override
  Widget build(BuildContext context) {
    final active = state.ownerPage == item.page;
    return GestureDetector(
      onTap: () { Navigator.pop(context); state.setOwnerPage(item.page); },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? AppColors.accent.withOpacity(0.3) : Colors.transparent),
        ),
        child: Row(children: [
          Text(item.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(item.label, style: TextStyle(color: active ? AppColors.accent : AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500))),
          if (item.badge > 0) Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: item.badgeDanger ? AppColors.danger : AppColors.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${item.badge}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ]),
      ),
    );
  }
}
