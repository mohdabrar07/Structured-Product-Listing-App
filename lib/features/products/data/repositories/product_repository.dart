import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/errors/failures.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductRepository {
  final ProductService productService;

  ProductRepository({required this.productService});

  Future<List<Product>> getProductsList() async {
    try {
      final rawData = await productService.fetchRawProducts();
      return rawData.map((item) => Product.fromJson(item)).toList();
    } on SocketException {
      throw const NetworkFailure('No internet connection. Please check your network.');
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}