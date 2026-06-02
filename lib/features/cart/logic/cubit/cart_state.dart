import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';

class CartItem {
  final ProductModel product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  CartItem copyWith({ProductModel? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    product: ProductModel.fromJson(json['product']),
    quantity: json['quantity'] as int,
  );
}

class CartState {
  final List<CartItem> cartItems;

  const CartState({this.cartItems = const []});

  double get totalPrice => cartItems.fold(0.0, (sum, element) => sum + ((element.product.price ?? 0) * element.quantity));

  CartState copyWith({List<CartItem>? cartItems}) => CartState(cartItems: cartItems ?? this.cartItems);
}