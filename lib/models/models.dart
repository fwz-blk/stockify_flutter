class Shop {
  final String id;
  final String name;
  final String phone;
  final String ownerId;

  Shop({required this.id, required this.name, required this.phone, required this.ownerId});

  factory Shop.fromMap(Map<String, dynamic> m) => Shop(
        id: m['id'].toString(),
        name: m['name'] ?? '',
        phone: m['phone'] ?? '',
        ownerId: m['owner_id'] ?? '',
      );

  Map<String, dynamic> toMap() => {'name': name, 'phone': phone, 'owner_id': ownerId};
}

class Product {
  final String id;
  final String shopId;
  final String name;
  final String category;
  final double price;
  int stock;
  final String unit;

  Product({
    required this.id,
    required this.shopId,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.unit,
  });

  factory Product.fromMap(Map<String, dynamic> m) => Product(
        id: m['id'].toString(),
        shopId: m['shop_id'].toString(),
        name: m['name'] ?? '',
        category: m['category'] ?? '',
        price: (m['price'] as num).toDouble(),
        stock: (m['stock'] as num).toInt(),
        unit: m['unit'] ?? 'pcs',
      );

  Map<String, dynamic> toMap() => {
        'shop_id': shopId,
        'name': name,
        'category': category,
        'price': price,
        'stock': stock,
        'unit': unit,
      };

  bool get isOutOfStock => stock == 0;
  bool get isLowStock => stock > 0 && stock <= 10;
}

class OrderItem {
  final String productId;
  final String name;
  final int qty;
  final double price;
  final String unit;

  OrderItem({
    required this.productId,
    required this.name,
    required this.qty,
    required this.price,
    required this.unit,
  });

  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(
        productId: m['product_id']?.toString() ?? '',
        name: m['product_name'] ?? '',
        qty: (m['qty'] as num).toInt(),
        price: (m['price'] as num).toDouble(),
        unit: m['unit'] ?? 'pcs',
      );

  double get subtotal => price * qty;
}

class Order {
  final String id;
  final String shopId;
  final String customerName;
  final List<OrderItem> items;
  final double total;
  String status;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.shopId,
    required this.customerName,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromMap(Map<String, dynamic> m, {List<OrderItem> items = const []}) => Order(
        id: m['id'].toString(),
        shopId: m['shop_id'].toString(),
        customerName: m['customer_name'] ?? 'Customer',
        items: items,
        total: (m['total'] as num).toDouble(),
        status: m['status'] ?? 'pending',
        createdAt: m['created_at'] != null
            ? DateTime.parse(m['created_at'])
            : DateTime.now(),
      );

  bool get isPending => status == 'pending';
}

class CartItem {
  final Product product;
  int qty;

  CartItem({required this.product, this.qty = 1});

  double get subtotal => product.price * qty;
}

class Bill {
  final String id;
  final String customerName;
  final String customerPhone;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final String discountType;
  final double discountAmt;
  final double total;
  final String paymentMode;
  final DateTime time;
  final String note;

  Bill({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.discountType,
    required this.discountAmt,
    required this.total,
    required this.paymentMode,
    required this.time,
    required this.note,
  });
}
