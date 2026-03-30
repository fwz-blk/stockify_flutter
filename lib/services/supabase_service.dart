import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

const supabaseUrl = 'https://lztofouholixewypgeii.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx6dG9mb3Vob2xpeGV3eXBnZWlpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI0MjcxNTIsImV4cCI6MjA4ODAwMzE1Mn0.Ur8Lp1ppAPDCfvhrPRR8tdo0BsBUHXvZbvDE16Y3xoA';

class SupabaseService {
  static final _client = Supabase.instance.client;

  // ─── Auth ───────────────────────────────────────────────
  static Future<AuthResponse> signUp(String email, String password) =>
      _client.auth.signUp(email: email, password: password);

  static Future<AuthResponse> signIn(String email, String password) =>
      _client.auth.signInWithPassword(email: email, password: password);

  static Future<void> signOut() => _client.auth.signOut();

  static User? get currentUser => _client.auth.currentUser;
  static Session? get currentSession => _client.auth.currentSession;

  // ─── Shops ──────────────────────────────────────────────
  static Future<Shop?> createShop(String ownerId, String name, String phone) async {
    final res = await _client
        .from('shops')
        .insert({'owner_id': ownerId, 'name': name, 'phone': phone})
        .select()
        .single();
    return Shop.fromMap(res);
  }

  static Future<Shop?> getShopByOwner(String ownerId) async {
    final res = await _client
        .from('shops')
        .select()
        .eq('owner_id', ownerId)
        .maybeSingle();
    return res != null ? Shop.fromMap(res) : null;
  }

  static Future<Shop?> getShopById(String shopId) async {
    final res = await _client
        .from('shops')
        .select()
        .eq('id', shopId)
        .maybeSingle();
    return res != null ? Shop.fromMap(res) : null;
  }

  // ─── Products ───────────────────────────────────────────
  static Future<List<Product>> getProducts(String shopId) async {
    final res = await _client
        .from('products')
        .select()
        .eq('shop_id', shopId)
        .order('name');
    return (res as List).map((m) => Product.fromMap(m)).toList();
  }

  static Future<Product?> addProduct(Map<String, dynamic> data) async {
    final res = await _client.from('products').insert(data).select().single();
    return Product.fromMap(res);
  }

  static Future<void> updateProduct(String id, Map<String, dynamic> changes) async {
    await _client.from('products').update(changes).eq('id', id);
  }

  // ─── Orders ─────────────────────────────────────────────
  static Future<List<Order>> getOrders(String shopId) async {
    final res = await _client
        .from('orders')
        .select()
        .eq('shop_id', shopId)
        .order('created_at', ascending: false);
    return (res as List).map((m) => Order.fromMap(m)).toList();
  }

  static Future<Order?> placeOrder({
    required String shopId,
    required String customerName,
    required double total,
    required List<CartItem> cartItems,
  }) async {
    // 1. Insert order
    final orderRes = await _client.from('orders').insert({
      'shop_id': shopId,
      'customer_name': customerName,
      'total': total,
      'status': 'pending',
    }).select().single();

    final orderId = orderRes['id'].toString();

    // 2. Insert items
    final itemsPayload = cartItems.map((c) => {
          'order_id': orderId,
          'product_name': c.product.name,
          'qty': c.qty,
          'price': c.product.price,
        }).toList();
    await _client.from('order_items').insert(itemsPayload);

    // 3. Update stock
    for (final item in cartItems) {
      final newStock = (item.product.stock - item.qty).clamp(0, 999999);
      await _client.from('products').update({'stock': newStock}).eq('id', item.product.id);
    }

    return Order.fromMap(orderRes, items: cartItems.map((c) => OrderItem(
      productId: c.product.id,
      name: c.product.name,
      qty: c.qty,
      price: c.product.price,
      unit: c.product.unit,
    )).toList());
  }

  static Future<void> completeOrder(String orderId) async {
    await _client.from('orders').update({'status': 'completed'}).eq('id', orderId);
  }
}
