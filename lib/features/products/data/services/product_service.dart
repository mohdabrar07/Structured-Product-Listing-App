import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';

class ProductService {
  final http.Client _client;

  ProductService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches raw product inventory arrays from the public API endpoint
  Future<List<ProductModel>> fetchProductsFromApi() async {
    final url = Uri.parse('https://fakestoreapi.com/products');
    
    try {
      final response = await _client.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> decodedData = jsonDecode(response.body);
        return decodedData.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Server returned an error status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network connection failure: $e');
    }
  }
}