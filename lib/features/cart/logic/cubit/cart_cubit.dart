import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:structured_product_listing_app/features/cart/logic/cubit/cart_state.dart';
import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';

class CartCubit extends HydratedCubit<Map<String, List<dynamic>>> {
  CartCubit() : super({});

  // =========================
  // GET USER CART
  // =========================
  List<CartItem> getCartForUser(String email) {
    final list = state[email] ?? [];

    return list.map((item) {
      try {
        return CartItem.fromJson(
          Map<String, dynamic>.from(item),
        );
      } catch (e) {
        return CartItem(
          product: ProductModel(),
          quantity: 1,
        );
      }
    }).toList();
  }

  // =================================
  // ADD TO CART (Acts as INCREMENT)
  // =================================
  void addToCart(String email, ProductModel product) {
    final currentMap = Map<String, List<dynamic>>.from(state);
    final userCart = List<dynamic>.from(currentMap[email] ?? []);

    final cartItems = userCart.map((item) {
      try {
        return CartItem.fromJson(Map<String, dynamic>.from(item));
      } catch (e) {
        return CartItem(product: ProductModel(), quantity: 1);
      }
    }).toList();

    final existingIndex = cartItems.indexWhere(
      (item) => item.product.id.toString() == product.id.toString(),
    );

    if (existingIndex >= 0) {
      final existingItem = cartItems[existingIndex];
      cartItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      );
    } else {
      cartItems.add(
        CartItem(product: product, quantity: 1),
      );
    }

    currentMap[email] = cartItems.map((e) => e.toJson()).toList();
    emit(currentMap);
  }

  // ======================================
  // REMOVE FROM CART (Acts as DECREMENT)
  // ======================================
  void removeFromCart(String email, ProductModel product) {
    final currentMap = Map<String, List<dynamic>>.from(state);
    final userCart = List<dynamic>.from(currentMap[email] ?? []);

    final cartItems = userCart.map((item) {
      try {
        return CartItem.fromJson(Map<String, dynamic>.from(item));
      } catch (e) {
        return CartItem(product: ProductModel(), quantity: 1);
      }
    }).toList();

    final existingIndex = cartItems.indexWhere(
      (item) => item.product.id.toString() == product.id.toString(),
    );

    if (existingIndex >= 0) {
      final existingItem = cartItems[existingIndex];

      if (existingItem.quantity > 1) {
        cartItems[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity - 1,
        );
      } else {
        cartItems.removeAt(existingIndex);
      }
    }

    currentMap[email] = cartItems.map((e) => e.toJson()).toList();
    emit(currentMap);
  }

  // =========================
  // CLEAR CART
  // =========================
  void clearCart(String email) {
    final currentMap = Map<String, List<dynamic>>.from(state);
    currentMap[email] = [];
    emit(currentMap);
  }

  // =========================
  // HYDRATED STORAGE
  // =========================
  @override
  Map<String, List<dynamic>>? fromJson(Map<String, dynamic> json) {
    try {
      final rawMap = json['user_carts'] as Map<String, dynamic>?;
      if (rawMap == null) return {};

      return rawMap.map((key, value) {
        if (value is List) {
          return MapEntry(key, List<dynamic>.from(value));
        }
        return const MapEntry('', []);
      });
    } catch (e) {
      return {};
    }
  }

  @override
  Map<String, dynamic>? toJson(Map<String, List<dynamic>> state) {
    return {
      'user_carts': state,
    };
  }
}

// ==========================================================================
// ORDER MODEL
// ==========================================================================

class OrderModel {
  final String id;
  final List<CartItem> items;
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
      'items': items.map((e) => e.toJson()).toList(),
      'total': total,
      'address': address,
      'date': date.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id']?.toString() ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      address: map['address']?.toString() ?? '',
      date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

// ==========================================================================
// ORDER CUBIT
// ==========================================================================

class OrderCubit extends HydratedCubit<Map<String, List<dynamic>>> {
  OrderCubit() : super({});

  List<OrderModel> getOrdersForUser(String email) {
    final list = state[email] ?? [];

    return list.map((item) {
      try {
        return OrderModel.fromMap(Map<String, dynamic>.from(item));
      } catch (e) {
        return OrderModel(
          id: '',
          items: [],
          total: 0,
          address: '',
          date: DateTime.now(),
        );
      }
    }).toList();
  }

  void addOrder(
    String email,
    List<CartItem> items,
    double total,
    String address,
  ) {
    final currentMap = Map<String, List<dynamic>>.from(state);
    final userOrders = List<dynamic>.from(currentMap[email] ?? []);

    final newOrder = OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      items: List<CartItem>.from(items),
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
      final rawMap = json['user_orders'] as Map<String, dynamic>?;
      if (rawMap == null) return {};

      return rawMap.map((key, value) {
        if (value is List) {
          return MapEntry(key, List<dynamic>.from(value));
        }
        return const MapEntry('', []);
      });
    } catch (e) {
      return {};
    }
  }

  @override
  Map<String, dynamic>? toJson(Map<String, List<dynamic>> state) {
    return {
      'user_orders': state,
    };
  }
}