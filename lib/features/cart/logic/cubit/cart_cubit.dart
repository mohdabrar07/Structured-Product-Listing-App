import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';

// ==========================================================================
// 1. PERSISTENT CART CUBIT IMPLEMENTATION
// ==========================================================================
class CartCubit extends HydratedCubit<List<ProductModel>> {
  CartCubit() : super([]);

  void addToCart(ProductModel product) {
    emit([...state, product]);
  }

  void removeFromCart(ProductModel product) {
    final updated = List<ProductModel>.from(state)..remove(product);
    emit(updated);
  }

  void clearCart() {
    emit([]);
  }

  // Deserializes data from disk storage when application boots up
  @override
  List<ProductModel>? fromJson(Map<String, dynamic> json) {
    try {
      // 💡 Added print log to see when browser reads cart data
      print("📦 HYDRATED_BLOC (CART): Reading Cart Data from Browser Database...");
      final itemsList = json['cart_items'] as List<dynamic>;
      return itemsList.map((item) => ProductModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      print("⚠️ HYDRATED_BLOC (CART): Read Error: $e");
      return [];
    }
  }

  // Serializes changes into memory every single time a state mutation emits
  @override
  Map<String, dynamic>? toJson(List<ProductModel> state) {
    // 💡 Added print log to see when browser saves cart data
    print("💾 HYDRATED_BLOC (CART): Writing Cart Data directly to Browser Storage!");
    return {
      'cart_items': state.map((item) => item.toJson()).toList(),
    };
  }
}

// ==========================================================================
// 2. DATA SCHEMA DEFINITION
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
// 3. PERSISTENT ORDER HISTORY CUBIT IMPLEMENTATION
// ==========================================================================
class OrderCubit extends HydratedCubit<List<OrderModel>> {
  OrderCubit() : super([]);

  void addOrder(List<ProductModel> items, double total, String address) {
    final newOrder = OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      items: List.from(items),
      total: total,
      address: address,
      date: DateTime.now(),
    );
    emit([newOrder, ...state]);
  }

  @override
  List<OrderModel>? fromJson(Map<String, dynamic> json) {
    try {
      // 💡 Added print log to see when browser reads order history
      print("📦 HYDRATED_BLOC (ORDERS): Reading Order History from Browser Database...");
      final orderHistory = json['orders'] as List<dynamic>;
      return orderHistory.map((item) => OrderModel.fromMap(item as Map<String, dynamic>)).toList();
    } catch (e) {
      print("⚠️ HYDRATED_BLOC (ORDERS): Read Error: $e");
      return [];
    }
  }

  @override
  Map<String, dynamic>? toJson(List<OrderModel> state) {
    // 💡 Added print log to see when browser saves order history
    print("💾 HYDRATED_BLOC (ORDERS): Writing Order History directly to Browser Storage!");
    return {
      'orders': state.map((item) => item.toMap()).toList(),
    };
  }
}