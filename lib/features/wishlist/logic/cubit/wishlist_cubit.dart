import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:structured_product_listing_app/core/services/storage_service.dart';
import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';

class WishlistCubit extends Cubit<List<ProductModel>> {
  final StorageService _storageService;
  static const String _wishlistKey = 'cached_user_wishlist_items';

  WishlistCubit(this._storageService) : super([]) {
    _hydrateWishlistFromStorage();
  }

  /// Reads persistent string indexes directly out of the primary Hive storage file
  void _hydrateWishlistFromStorage() {
    try {
      final rawData = _storageService.retrieveData(_wishlistKey);
      if (rawData != null && rawData is String) {
        final List<dynamic> decoded = jsonDecode(rawData);
        final products = decoded.map((item) => ProductModel.fromJson(item)).toList();
        emit(products);
      }
    } catch (_) {}
  }

  /// Commits updates to disk
  Future<void> _persistWishlistToCache(List<ProductModel> currentList) async {
    final mappedList = currentList.map((item) => item.toJson()).toList();
    final jsonString = jsonEncode(mappedList);
    await _storageService.persistData(_wishlistKey, jsonString);
  }

  /// Toggles the favorite status of a item, saving the updated list locally
  void toggleWishlist(ProductModel targetProduct) {
    final currentList = List<ProductModel>.from(state);
    final existsIndex = currentList.indexWhere((element) => element.id == targetProduct.id);

    if (existsIndex >= 0) {
      currentList.removeAt(existsIndex);
    } else {
      currentList.add(targetProduct);
    }

    emit(currentList);
    _persistWishlistToCache(currentList);
  }
}