import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

class ProductService {
  final http.Client client;

  ProductService({required this.client});

  Future<List<dynamic>> fetchRawProducts() async {
    final response = await client.get(Uri.parse(ApiConstants.productsEndpoint));
    
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Server returned status code: ${response.statusCode}');
    }
  }
}