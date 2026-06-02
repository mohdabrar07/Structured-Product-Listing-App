import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';

class OrderModel {
  final String id;
  final List<ProductModel> items;
  final double total;
  final String address;
  final DateTime date;

  OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.address,
    required this.date,
  });
}

class OrderCubit extends Cubit<List<OrderModel>> {
  OrderCubit() : super([]);

  void addOrder(List<ProductModel> items, double total, String address) {
    final newOrder = OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      items: List.from(items),
      total: total,
      address: address,
      date: DateTime.now(),
    );
    emit([newOrder, ...state]);
  }
}