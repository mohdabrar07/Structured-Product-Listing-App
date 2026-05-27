import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../products/data/models/product_model.dart';
import '../../data/models/cart_item_model.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  // Local active memory instance of items in cart
  final List<CartItem> _internalCartItems = [];

  CartCubit() : super(CartInitial()) {
    // Start app in empty cart state explicitly
    emit(CartEmpty());
  }

  // 1. ADD PRODUCT TO CART
  void addProduct(Product product) {
    try {
      // Check if product already exists in cart list
      final existingIndex = _internalCartItems.indexWhere((item) => item.product.id == product.id);

      if (existingIndex >= 0) {
        // Edge Case: If item exists, increase quantity
        final currentQty = _internalCartItems[existingIndex].quantity;
        _internalCartItems[existingIndex] = _internalCartItems[existingIndex].copyWith(
          quantity: currentQty + 1,
        );
      } else {
        // Item doesn't exist, create fresh entry
        _internalCartItems.add(CartItem(product: product, quantity: 1));
      }

      _calculateAndEmitTotals();
    } catch (e) {
      emit(CartError('Could not add item to cart.'));
    }
  }

  // 2. INCREASE QUANTITY
  void increaseQuantity(int productId) {
    final index = _internalCartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final currentQty = _internalCartItems[index].quantity;
      _internalCartItems[index] = _internalCartItems[index].copyWith(quantity: currentQty + 1);
      _calculateAndEmitTotals();
    }
  }

  // 3. DECREASE QUANTITY
  void decreaseQuantity(int productId) {
    final index = _internalCartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final currentQty = _internalCartItems[index].quantity;
      
      // Business Requirement Rule: Quantity should not go below 1
      if (currentQty > 1) {
        _internalCartItems[index] = _internalCartItems[index].copyWith(quantity: currentQty - 1);
        _calculateAndEmitTotals();
      }
    }
  }

  // 4. REMOVE PRODUCT FROM CART
  void removeProduct(int productId) {
    _internalCartItems.removeWhere((item) => item.product.id == productId);
    _calculateAndEmitTotals();
  }

  // 5. UNIFIED BUSINESS MATHEMATICS MATRIX PIPELINE
  void _calculateAndEmitTotals() {
    if (_internalCartItems.isEmpty) {
      emit(CartEmpty());
      return;
    }

    // A. Calculate Subtotal using functional programming fold accumulator
    double calculatedSubtotal = _internalCartItems.fold(0.0, (sum, item) => sum + item.totalLinePrice);

    // B. Calculate VAT (5% of Subtotal)
    double calculatedVat = calculatedSubtotal * ApiConstants.vatPercentage;

    // C. Calculate Delivery Charge (Flat rate applied per distinct line item)
    double calculatedDelivery = _internalCartItems.length * ApiConstants.deliveryChargePerItem;

    // D. Grand Total Matrix Combine
    double calculatedGrandTotal = calculatedSubtotal + calculatedVat + calculatedDelivery;

    emit(CartUpdated(
      cartItems: List.from(_internalCartItems),
      subtotal: calculatedSubtotal,
      vatAmount: calculatedVat,
      deliveryCharge: calculatedDelivery,
      grandTotal: calculatedGrandTotal,
    ));
  }
}