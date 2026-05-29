import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductService {
  final http.Client client;

  ProductService({required this.client});

  Future<List<dynamic>> fetchRawProductsFromApi() async {
    final response = await client.get(Uri.parse('https://fakestoreapi.com/products'));
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to pull server items');
    }
  }
}