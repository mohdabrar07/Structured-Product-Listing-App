import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';

class CartItem {
  final ProductModel product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  CartItem copyWith({
    ProductModel? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  // =========================
  // TO JSON
  // =========================
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  // =========================
  // FROM JSON (SAFE VERSION)
  // =========================
  factory CartItem.fromJson(
    Map<String, dynamic>? json,
  ) {
    if (json == null) {
      return CartItem(
        product: ProductModel(),
        quantity: 1,
      );
    }

    // SAFE PRODUCT PARSING
    final productData =
        json['product'] as Map<String, dynamic>?;

    // SAFE QUANTITY PARSING
    final qtyRaw = json['quantity'];

    int parsedQty = 1;

    if (qtyRaw is int) {
      parsedQty = qtyRaw;
    } else if (qtyRaw is String) {
      parsedQty = int.tryParse(qtyRaw) ?? 1;
    }

    return CartItem(
      product: ProductModel.fromJson(
        productData ?? {},
      ),
      quantity: parsedQty,
    );
  }
}

class CartState {
  final List<CartItem> cartItems;

  const CartState({
    this.cartItems = const [],
  });

  // =========================
  // TOTAL PRICE
  // =========================
  double get totalPrice {
    return cartItems.fold(
      0.0,
      (sum, element) =>
          sum +
          ((element.product.price ?? 0.0) *
              element.quantity),
    );
  }

  // =========================
  // COPY WITH
  // =========================
  CartState copyWith({
    List<CartItem>? cartItems,
  }) {
    return CartState(
      cartItems: cartItems ?? this.cartItems,
    );
  }
}