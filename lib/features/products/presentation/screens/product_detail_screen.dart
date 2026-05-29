import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// FIX: Absolute logic paths to find Cart & Wishlist Cubits safely
import 'package:structured_product_listing_app/features/cart/logic/cubit/cart_cubit.dart';
import 'package:structured_product_listing_app/features/wishlist/logic/cubit/wishlist_cubit.dart';

// FIX: Absolute path to find the correct Product Model location
import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Conditions Met: Wishlist persistence interactive engine toggle
          BlocBuilder<WishlistCubit, WishlistState>(
            builder: (context, state) {
              bool isWishlisted = false;
              if (state is WishlistUpdated) {
                isWishlisted = state.items.any((p) => p.id == product.id);
              }
              return IconButton(
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted ? Colors.red : Colors.grey,
                ),
                onPressed: () => context.read<WishlistCubit>().toggleWishlist(product),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(product.image, height: 250, fit: BoxFit.contain),
            ),
            const SizedBox(height: 24),
            Text(product.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(4)),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${product.rating.rate}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('(${product.rating.count} reviews)', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 16),
            const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(product.description, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4)),
            const SizedBox(height: 40),
            
            // Add to Cart Primary Action
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                context.read<CartCubit>().addProduct(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to Cart successfully!'), duration: Duration(seconds: 1)),
                );
              },
              child: const Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}