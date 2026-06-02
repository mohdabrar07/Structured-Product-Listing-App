import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';
import 'package:structured_product_listing_app/features/wishlist/logic/cubit/wishlist_cubit.dart';
import 'package:structured_product_listing_app/features/cart/logic/cubit/cart_cubit.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistCubit>().state;
    final cart = context.watch<CartCubit>().state;

    final isInWishlist = wishlist.any((item) => item.id == product.id);
    final isInCart = cart.any((item) => item.id == product.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title ?? 'Product Details'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? Colors.red : Colors.white,
            ),
            onPressed: () {
              context.read<WishlistCubit>().toggleWishlist(product);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                product.image ?? '',
                height: 250,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 150),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              product.title ?? 'No Title',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '\$${(product.price ?? 0.0).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, color: Colors.indigo, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              product.description ?? 'No description available.',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInCart ? Colors.red.shade600 : Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (isInCart) {
                    context.read<CartCubit>().removeFromCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from cart.')));
                  } else {
                    context.read<CartCubit>().addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart!')));
                  }
                },
                child: Text(
                  isInCart ? 'REMOVE FROM CART' : 'ADD TO CART',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}