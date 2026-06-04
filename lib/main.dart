import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

// Services & Core Configuration
import 'package:structured_product_listing_app/core/services/storage_service.dart';
import 'package:structured_product_listing_app/features/products/data/services/product_service.dart';
import 'package:structured_product_listing_app/features/products/data/repositories/product_repository.dart';

// State Management Cubits
import 'package:structured_product_listing_app/features/auth/logic/cubit/auth_cubit.dart';
import 'package:structured_product_listing_app/features/products/logic/cubit/product_cubit.dart';
import 'package:structured_product_listing_app/features/cart/logic/cubit/cart_cubit.dart'; // 💡 Contains both CartCubit and OrderCubit
import 'package:structured_product_listing_app/features/wishlist/logic/cubit/wishlist_cubit.dart';
import 'package:structured_product_listing_app/features/address/logic/cubit/address_cubit.dart';

// Presentation Layer Screens
import 'package:structured_product_listing_app/features/auth/presentation/screens/login_screen.dart';
import 'package:structured_product_listing_app/features/home/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final HydratedStorageDirectory storageDirectory;
  
  if (kIsWeb) {
    storageDirectory = HydratedStorageDirectory.web;
  } else {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    storageDirectory = HydratedStorageDirectory(documentsDirectory.path);
  }

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: storageDirectory,
  );

  final storageService = StorageService();
  await storageService.init();

  final productService = ProductService();
  final productRepository = ProductRepository(productService);

  runApp(
    MyApp(
      storageService: storageService,
      productRepository: productRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final StorageService storageService;
  final ProductRepository productRepository;

  const MyApp({
    super.key,
    required this.storageService,
    required this.productRepository,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<StorageService>.value(
      value: storageService,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(storageService)..checkAuthenticationSession(), 
          ),
          BlocProvider<ProductCubit>(
            create: (_) => ProductCubit(productRepository)..loadProducts(),
          ),
          BlocProvider<WishlistCubit>(
            create: (_) => WishlistCubit(storageService),
          ),
          BlocProvider<CartCubit>(
            create: (_) => CartCubit(),
          ),
          BlocProvider<AddressCubit>(
            create: (_) => AddressCubit(),
          ),
          BlocProvider<OrderCubit>(
            create: (_) => OrderCubit(), // ✅ Works perfectly now because of the cart_cubit import above
          ),
        ],
        child: MaterialApp(
          title: 'Structured Mini E-Commerce App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            primarySwatch: Colors.indigo,
            scaffoldBackgroundColor: Colors.grey.shade50,
          ),
          home: const AppNavigationGatekeeper(),
        ),
      ),
    );
  }
}

class AppNavigationGatekeeper extends StatelessWidget {
  const AppNavigationGatekeeper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const HomeScreen();
        }
        
        if (state is Unauthenticated || state is AuthError) {
          return const LoginScreen();
        }

        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.indigo),
                SizedBox(height: 16),
                Text("Restoring session data...", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
      },
    );
  }
}