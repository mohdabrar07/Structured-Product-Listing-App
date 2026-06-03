import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:structured_product_listing_app/core/services/storage_service.dart';
import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';

class WishlistCubit extends Cubit<Map<String, List<ProductModel>>> {
  final StorageService _storageService;
  static const String _wishlistKey = 'cached_user_multi_wishlists';

  WishlistCubit(this._storageService) : super({}) {
    _hydrateWishlistFromStorage();
  }

  /// Reads global storage and builds the multi-user wishlist directory map safely
  void _hydrateWishlistFromStorage() {
    try {
      final rawData = _storageService.retrieveData(_wishlistKey);
      if (rawData != null && rawData is String) {
        final Map<String, dynamic> decodedMap = jsonDecode(rawData);
        
        final Map<String, List<ProductModel>> parsedState = {};
        decodedMap.forEach((email, listData) {
          final List<dynamic> rawList = listData;
          parsedState[email] = rawList.map((item) => ProductModel.fromJson(item)).toList();
        });
        
        emit(parsedState);
      }
    } catch (_) {}
  }

  /// Commits updates to structural storage
  Future<void> _persistWishlistToCache(Map<String, List<ProductModel>> currentMap) async {
    final Map<String, dynamic> serializableMap = {};
    currentMap.forEach((email, productsList) {
      serializableMap[email] = productsList.map((item) => item.toJson()).toList();
    });
    
    final jsonString = jsonEncode(serializableMap);
    await _storageService.persistData(_wishlistKey, jsonString);
  }

  /// Gets isolation list bound exclusively to the parameter identity profile
  List<ProductModel> getWishlistForUser(String email) {
    return state[email] ?? [];
  }

  /// Toggles favorite status under the authenticated user space scope
  void toggleWishlist(String email, ProductModel targetProduct) {
    final currentMap = Map<String, List<ProductModel>>.from(state);
    final userWishlist = List<ProductModel>.from(currentMap[email] ?? []);

    final existsIndex = userWishlist.indexWhere((element) => element.id == targetProduct.id);

    if (existsIndex >= 0) {
      userWishlist.removeAt(existsIndex);
    } else {
      userWishlist.add(targetProduct);
    }

    currentMap[email] = userWishlist;
    
    emit(currentMap);
    _persistWishlistToCache(currentMap);
  }
}