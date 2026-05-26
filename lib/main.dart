import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'features/products/data/repositories/product_repository.dart';
import 'features/products/data/services/product_service.dart';
import 'features/products/logic/cubit/product_cubit.dart';
import 'features/products/presentation/screens/product_list_screen.dart';

void main() {
  
  final httpClient = http.Client();
  final productService = ProductService(client: httpClient);
  final productRepository = ProductRepository(productService: productService);

  runApp(MyApp(productRepository: productRepository));
}

class MyApp extends StatelessWidget {
  final ProductRepository productRepository;

  const MyApp({super.key, required this.productRepository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductCubit(repository: productRepository)..loadProducts(),
      child: MaterialApp(
        title: 'Product Explorer Architecture',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey.shade50,
        ),
        home: const ProductListScreen(),
      ),
    );
  }
}