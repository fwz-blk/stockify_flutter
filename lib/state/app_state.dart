import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

enum AppView {
  landing, ownerAuth, customerAuth, ownerSetup,
  ownerDash, customerDashboard, customerShop, orderSuccess
}

enum OwnerPage { dashboard, products, orders, lowStock, billing, qrCode }

class AppState extends ChangeNotifier {
  AppView view = AppView.landing;
  OwnerPage ownerPage = OwnerPage.dashboard;
  bool isCheckingSession = true;
  String? userRole;

  Shop? shop;
  List<Product> products = [];
  List<Order> orders = [];
  List<CartItem> cart = [];
  Order? lastOrder;
  List<Bill> billHistory = [];

  // ─── Init ───────────────────────────────────────────────
  Future<void> init() async {
    final session = SupabaseService.currentSession;
    if (session != null) {
      final prefs = await SharedPreferences.getInstance();
      userRole = prefs.getString('userRole');
      final uid = session.user.id;
      if (userRole == 'owner') {
        await loadShop(uid);
      } else if (userRole == 'customer') {
        view = AppView.customerDashboard;
      }
    }
    isCheckingSession = false;
    notifyListeners();
  }

  Future<void> loadShop(String ownerId) async {
    final s = await SupabaseService.getShopByOwner(ownerId);
    if (s != null) {
      shop = s;
      await loadProducts(s.id);
      await loadOrders(s.id);
      view = AppView.ownerDash;
    } else {
      view = AppView.ownerSetup;
    }
    notifyListeners();
  }

  Future<void> loadShopById(String shopId) async {
    final s = await SupabaseService.getShopById(shopId);
    if (s != null) {
      shop = s;
      await loadProducts(s.id);
      view = AppView.customerShop;
      notifyListeners();
    }
  }

  Future<void> loadProducts(String shopId) async {
    products = await SupabaseService.getProducts(shopId);
    notifyListeners();
  }

  Future<void> loadOrders(String shopId) async {
    orders = await SupabaseService.getOrders(shopId);
    notifyListeners();
  }

  // ─── Auth ───────────────────────────────────────────────
  Future<String?> signIn(String email, String password, String role) async {
    try {
      final res = await SupabaseService.signIn(email, password);
      if (res.user == null) return 'Sign in failed';
      userRole = role;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userRole', role);
      if (role == 'owner') {
        await loadShop(res.user!.id);
      } else {
        view = AppView.customerDashboard;
        notifyListeners();
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signUp(String email, String password, String role) async {
    try {
      final res = await SupabaseService.signUp(email, password);
      if (res.user == null) return 'Sign up failed';
      userRole = role;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userRole', role);
      if (role == 'owner') {
        view = AppView.ownerSetup;
      } else {
        view = AppView.customerDashboard;
      }
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await SupabaseService.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userRole');
    shop = null;
    products = [];
    orders = [];
    cart = [];
    userRole = null;
    view = AppView.landing;
    notifyListeners();
  }

  // ─── Shop Setup ─────────────────────────────────────────
  Future<String?> setupShop(String name, String phone) async {
    try {
      final uid = SupabaseService.currentUser!.id;
      final s = await SupabaseService.createShop(uid, name, phone);
      if (s == null) return 'Failed to create shop';
      shop = s;
      await loadProducts(s.id);
      await loadOrders(s.id);
      view = AppView.ownerDash;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ─── Products ───────────────────────────────────────────
  Future<void> addProduct(Map<String, dynamic> data) async {
    final p = await SupabaseService.addProduct(data);
    if (p != null) {
      products.insert(0, p);
      notifyListeners();
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> changes) async {
    await SupabaseService.updateProduct(id, changes);
    await loadProducts(shop!.id);
  }

  // ─── Cart ───────────────────────────────────────────────
  void addToCart(Product p) {
    final idx = cart.indexWhere((c) => c.product.id == p.id);
    if (idx >= 0) {
      cart[idx].qty++;
    } else {
      cart.add(CartItem(product: p));
    }
    notifyListeners();
  }

  void removeFromCart(String pid) {
    cart.removeWhere((c) => c.product.id == pid);
    notifyListeners();
  }

  void updateCartQty(String pid, int qty) {
    if (qty < 1) return removeFromCart(pid);
    final idx = cart.indexWhere((c) => c.product.id == pid);
    if (idx >= 0) cart[idx].qty = qty;
    notifyListeners();
  }

  void clearCart() {
    cart = [];
    notifyListeners();
  }

  double get cartTotal => cart.fold(0, (s, c) => s + c.subtotal);
  int get cartCount => cart.fold(0, (s, c) => s + c.qty);

  // ─── Orders ─────────────────────────────────────────────
  Future<bool> placeOrder() async {
    if (cart.isEmpty || shop == null) return false;
    final user = SupabaseService.currentUser;
    final o = await SupabaseService.placeOrder(
      shopId: shop!.id,
      customerName: user?.email?.split('@').first ?? 'Customer',
      total: cartTotal,
      cartItems: cart,
    );
    if (o != null) {
      lastOrder = o;
      orders.insert(0, o);
      cart = [];
      view = AppView.orderSuccess;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> completeOrder(String orderId) async {
    await SupabaseService.completeOrder(orderId);
    await loadOrders(shop!.id);
  }

  // ─── Computed ───────────────────────────────────────────
  List<Product> get lowStockProducts => products.where((p) => p.stock <= 10).toList();
  List<Order> get pendingOrders => orders.where((o) => o.isPending).toList();

  void setView(AppView v) { view = v; notifyListeners(); }
  void setOwnerPage(OwnerPage p) { ownerPage = p; notifyListeners(); }

  // ─── Billing ────────────────────────────────────────────
  void addBill(Bill b) {
    billHistory.insert(0, b);
    notifyListeners();
  }
}
