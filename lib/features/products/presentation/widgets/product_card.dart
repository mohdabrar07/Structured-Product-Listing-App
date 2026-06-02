import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';
import 'package:structured_product_listing_app/features/products/presentation/screens/product_detail_screen.dart';
import 'package:structured_product_listing_app/features/wishlist/logic/cubit/wishlist_cubit.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final originalPrice = (product.price ?? 0) * 1.35;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Hero(
                        tag: 'product_image_${product.id}',
                        child: Image.network(
                          product.image ?? '',
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: BlocBuilder<WishlistCubit, List<ProductModel>>(
                      builder: (context, wishlist) {
                        final isFavorite = wishlist.any((item) => item.id == product.id);
                        return Container(
                          height: 32,
                          width: 32,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: isFavorite ? Colors.redAccent : Colors.grey,
                            ),
                            onPressed: () => context.read<WishlistCubit>().toggleWishlist(product),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.3, color: Colors.black87),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (product.category ?? '').toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '\$${product.price?.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.indigo),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '\$${originalPrice.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 11, decoration: TextDecoration.lineThrough, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}