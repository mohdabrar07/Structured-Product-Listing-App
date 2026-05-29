import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/storage_service.dart';
import '../../../products/data/models/product_model.dart';

sealed class WishlistState {}
class WishlistEmpty extends WishlistState {}
class WishlistUpdated extends WishlistState {
  final List<Product> items;
  WishlistUpdated(this.items);
}

class WishlistCubit extends Cubit<WishlistState> {
  final List<Product> _internalWishlist = [];

  WishlistCubit() : super(WishlistEmpty()) {
    _hydrateWishlist();
  }

  void _hydrateWishlist() {
    final savedItems = StorageService.getWishlist();
    if (savedItems.isNotEmpty) {
      _internalWishlist.addAll(savedItems);
      emit(WishlistUpdated(List.from(_internalWishlist)));
    }
  }

  void toggleWishlist(Product product) {
    final exists = _internalWishlist.any((p) => p.id == product.id);
    if (exists) {
      _internalWishlist.removeWhere((p) => p.id == product.id);
    } else {
      _internalWishlist.add(product);
    }

    // PERSISTENCE BLOCK: Write updated array instantly to storage cache
    StorageService.saveWishlist(_internalWishlist);

    if (_internalWishlist.isEmpty) {
      emit(WishlistEmpty());
    } else {
      emit(WishlistUpdated(List.from(_internalWishlist)));
    }
  }
}