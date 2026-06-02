
import '../../../products/data/models/product_model.dart';

class CartItem {
  // 1. Changed 'Product' to 'ProductModel' to match your project schema
  final ProductModel product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  // 2. Fixed Null Safety: Added a fallback value (?? 0.0) in case price is null
  double get totalLinePrice => (product.price ?? 0.0) * quantity;

  // Copy with updated values
  CartItem copyWith({
    ProductModel? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  // Convert CartItem -> JSON
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  // Convert JSON -> CartItem
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: ProductModel.fromJson(
        Map<String, dynamic>.from(json['product']),
      ),
      quantity: json['quantity'] ?? 1,
    );
  }
}

