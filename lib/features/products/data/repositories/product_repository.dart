import 'package:structured_product_listing_app/core/errors/failures.dart';
import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';
import 'package:structured_product_listing_app/features/products/data/services/product_service.dart';

class ProductRepository {
  final ProductService _productService;

  ProductRepository(this._productService);

  /// Acquires products and transforms any structural errors into clean Failures
  Future<List<ProductModel>> getProducts() async {
    try {
      return await _productService.fetchProductsFromApi();
    } catch (e) {
      // Intercept execution issues and rethrow standard architectural failures
      throw ServerFailure(e.toString());
    }
  }
}