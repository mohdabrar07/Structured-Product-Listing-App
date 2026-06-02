import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';

// ==========================================================================
// MULTI-USER SEPARATED CART CUBIT
// ==========================================================================
class CartCubit extends HydratedCubit<Map<String, List<dynamic>>> {
  // State: { "user@email.com": [ProductModel, ProductModel] }
  CartCubit() : super({});

  List<ProductModel> getCartForUser(String email) {
    final list = state[email] ?? [];
    return list.map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  void addToCart(String email, ProductModel product) {
    final currentMap = Map<String, List<dynamic>>.from(state);
    final userCart = List<dynamic>.from(currentMap[email] ?? []);
    userCart.add(product.toJson());
    currentMap[email] = userCart;
    emit(currentMap);
  }

  void removeFromCart(String email, ProductModel product) {
    final currentMap = Map<String, List<dynamic>>.from(state);
    final userCart = List<dynamic>.from(currentMap[email] ?? []);
    
    userCart.removeWhere((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)).id == product.id);
    currentMap[email] = userCart;
    emit(currentMap);
  }

  void clearCart(String email) {
    final currentMap = Map<String, List<dynamic>>.from(state);
    currentMap[email] = [];
    emit(currentMap);
  }

  @override
  Map<String, List<dynamic>>? fromJson(Map<String, dynamic> json) {
    try {
      final rawMap = json['user_carts'] as Map<String, dynamic>? ?? {};
      return rawMap.map((key, value) => MapEntry(key, List<dynamic>.from(value)));
    } catch (_) {
      return {};
    }
  }

  @override
  Map<String, dynamic>? toJson(Map<String, List<dynamic>> state) {
    return {'user_carts': state};
  }
}

// ==========================================================================
// DATA ORDER MODEL SCHEMA
// ==========================================================================
class OrderModel {
  final String id;
  final List<ProductModel> items;
  final double total;
  final String address;
  final DateTime date;

  OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.address,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((x) => x.toJson()).toList(),
      'total': total,
      'address': address,
      'date': date.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      items: List<ProductModel>.from((map['items'] as List<dynamic>).map((x) => ProductModel.fromJson(x))),
      total: (map['total'] as num).toDouble(),
      address: map['address'] ?? '',
      date: DateTime.parse(map['date']),
    );
  }
}

// ==========================================================================
// MULTI-USER SEPARATED ORDER HISTORY CUBIT
// ==========================================================================
class OrderCubit extends HydratedCubit<Map<String, List<dynamic>>> {
  // State: { "user@email.com": [OrderModelJson, OrderModelJson] }
  OrderCubit() : super({});

  List<OrderModel> getOrdersForUser(String email) {
    final list = state[email] ?? [];
    return list.map((item) => OrderModel.fromMap(Map<String, dynamic>.from(item))).toList();
  }

  void addOrder(String email, List<ProductModel> items, double total, String address) {
    final currentMap = Map<String, List<dynamic>>.from(state);
    final userOrders = List<dynamic>.from(currentMap[email] ?? []);

    final newOrder = OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      items: List.from(items),
      total: total,
      address: address,
      date: DateTime.now(),
    );

    userOrders.insert(0, newOrder.toMap());
    currentMap[email] = userOrders;
    emit(currentMap);
  }

  @override
  Map<String, List<dynamic>>? fromJson(Map<String, dynamic> json) {
    try {
      final rawMap = json['user_orders'] as Map<String, dynamic>? ?? {};
      return rawMap.map((key, value) => MapEntry(key, List<dynamic>.from(value)));
    } catch (_) {
      return {};
    }
  }

  @override
  Map<String, dynamic>? toJson(Map<String, List<dynamic>> state) {
    return {'user_orders': state};
  }
}