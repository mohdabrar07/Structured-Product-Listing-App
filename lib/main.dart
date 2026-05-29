import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

// Core Services
import 'core/services/storage_service.dart';

// Logic Layers (Cubits)
import 'package:structured_product_listing_app/features/auth/logic/cubit/auth_cubit.dart';
import 'package:structured_product_listing_app/features/wishlist/logic/cubit/wishlist_cubit.dart';
import 'package:structured_product_listing_app/features/address/logic/cubit/address_cubit.dart';
import 'package:structured_product_listing_app/features/cart/logic/cubit/cart_cubit.dart';
import 'package:structured_product_listing_app/features/products/logic/cubit/product_cubit.dart';

// Data Repositories & Services
import 'package:structured_product_listing_app/features/products/data/repositories/product_repository.dart';
import 'package:structured_product_listing_app/features/products/data/services/product_service.dart';

// Presentation Layer (Screens)
import 'package:structured_product_listing_app/features/auth/presentation/screens/login_screen.dart'; // <── Fixes 'LoginScreen' error
import 'package:structured_product_listing_app/features/products/presentation/screens/product_list_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Requirement Met: Instantiate the local key-value configuration storage file
  await StorageService.init();

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
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => AuthCubit()),
        BlocProvider<WishlistCubit>(create: (context) => WishlistCubit()),
        BlocProvider<AddressCubit>(create: (context) => AddressCubit()),
        BlocProvider<CartCubit>(create: (context) => CartCubit()),
        BlocProvider<ProductCubit>(
          create: (context) => ProductCubit(repository: productRepository)..loadProducts(),
        ),
      ],
      child: MaterialApp(
        title: 'Structured Persistent E-Commerce Store',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
        ),
        // Update your home parameter inside lib/main.dart to look like this:
home: BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    if (state is AuthLoggedIn) {
      return const ProductListScreen();
    }
    return const LoginScreen(); // Blocks access until user taps login button
  },
),
      ),
    );
  }
}