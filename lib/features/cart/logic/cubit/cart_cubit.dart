import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/storage_service.dart'; // Import storage engine
import '../../../products/data/models/product_model.dart';
import '../../data/models/cart_item_model.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  // Local active memory instance of items in cart
  final List<CartItem> _internalCartItems = [];

  CartCubit() : super(CartInitial()) {
    // RESTART TESTING ACTION: Hydrate memory array with saved storage blocks immediately on construction
    _loadCartFromLocalStorage();
  }

  // Core Hydration Method
  void _loadCartFromLocalStorage() {
    try {
      final savedItems = StorageService.getCart();
      if (savedItems.isNotEmpty) {
        _internalCartItems.addAll(savedItems);
        _calculateAndEmitTotals();
      } else {
        emit(CartEmpty());
      }
    } catch (_) {
      emit(CartEmpty());
    }
  }

  void addProduct(Product product) {
    final existingIndex = _internalCartItems.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final currentQty = _internalCartItems[existingIndex].quantity;
      _internalCartItems[existingIndex] = _internalCartItems[existingIndex].copyWith(
        quantity: currentQty + 1,
      );
    } else {
      _internalCartItems.add(CartItem(product: product, quantity: 1));
    }

    _calculateAndEmitTotals();
  }

  void increaseQuantity(int productId) {
    final index = _internalCartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final currentQty = _internalCartItems[index].quantity;
      _internalCartItems[index] = _internalCartItems[index].copyWith(quantity: currentQty + 1);
      _calculateAndEmitTotals();
    }
  }

  void decreaseQuantity(int productId) {
    final index = _internalCartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final currentQty = _internalCartItems[index].quantity;
      if (currentQty > 1) {
        _internalCartItems[index] = _internalCartItems[index].copyWith(quantity: currentQty - 1);
        _calculateAndEmitTotals();
      }
    }
  }

  void removeProduct(int productId) {
    _internalCartItems.removeWhere((item) => item.product.id == productId);
    _calculateAndEmitTotals();
  }

  void _calculateAndEmitTotals() {
    // Requirement Met: Write updated array immediately to device storage cache
    StorageService.saveCart(_internalCartItems);

    if (_internalCartItems.isEmpty) {
      emit(CartEmpty());
      return;
    }

    double calculatedSubtotal = _internalCartItems.fold(0.0, (sum, item) => sum + item.totalLinePrice);
    double calculatedVat = calculatedSubtotal * ApiConstants.vatPercentage;
    double calculatedDelivery = _internalCartItems.length * ApiConstants.deliveryChargePerItem;
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