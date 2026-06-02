import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';

// ==========================================================================
// 1. CART FEATURE STATE MANAGEMENT
// ==========================================================================
class CartCubit extends Cubit<List<ProductModel>> {
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
}

// ==========================================================================
// 2. ORDER HISTORY FEATURE DATA MODEL
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
}

// ==========================================================================
// 3. ORDER HISTORY FEATURE STATE MANAGEMENT
// ==========================================================================
class OrderCubit extends Cubit<List<OrderModel>> {
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
}