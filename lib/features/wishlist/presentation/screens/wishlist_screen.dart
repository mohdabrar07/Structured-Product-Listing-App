import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:structured_product_listing_app/features/auth/logic/cubit/auth_cubit.dart'; // 💡 IMPORTED: Essential to extract currently active user email
import 'package:structured_product_listing_app/features/wishlist/logic/cubit/wishlist_cubit.dart';
import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';
import 'package:structured_product_listing_app/features/products/presentation/widgets/product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🛠️ FIXED: Extract active login identifier payload profile string context safely
    final authState = context.watch<AuthCubit>().state;
    final String userEmail = authState is Authenticated ? authState.email : "Guest";

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Wishlist', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      // 🛠️ FIXED: Map generic type target arguments signatures matching Cubit implementation
      body: BlocBuilder<WishlistCubit, Map<String, List<ProductModel>>>(
        builder: (context, wishlistMap) {
          // 🛠️ FIXED: Extract exclusively this isolated user item list segment
          final List<ProductModel> items = context.read<WishlistCubit>().getWishlistForUser(userEmail);

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text('Your wishlist is empty', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => ProductCard(product: items[index]),
          );
        },
      ),
    );
  }
}