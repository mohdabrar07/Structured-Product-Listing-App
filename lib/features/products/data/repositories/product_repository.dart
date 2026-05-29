import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductRepository {
  final ProductService productService;

  ProductRepository({required this.productService});

  Future<List<Product>> getProductsList() async {
    final List<dynamic> rawData = await productService.fetchRawProductsFromApi();
    // Safely transforms map structures directly into our new model format
    return rawData.map((item) => Product.fromJson(Map<String, dynamic>.from(item))).toList();
  }
}