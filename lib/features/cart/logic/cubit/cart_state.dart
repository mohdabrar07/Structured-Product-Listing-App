import '../../data/models/cart_item_model.dart';

sealed class CartState {}

class CartInitial extends CartState {}

class CartEmpty extends CartState {}

class CartError extends CartState {
  final String errorMessage;
  CartError(this.errorMessage);
}

class CartUpdated extends CartState {
  final List<CartItem> cartItems;
  
  // Real-time computed totals
  final double subtotal;
  final double vatAmount;
  final double deliveryCharge;
  final double grandTotal;

  CartUpdated({
    required this.cartItems,
    required this.subtotal,
    required this.vatAmount,
    required this.deliveryCharge,
    required this.grandTotal,
  });
}