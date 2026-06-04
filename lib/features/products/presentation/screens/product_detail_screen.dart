import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:structured_product_listing_app/features/auth/logic/cubit/auth_cubit.dart';
import 'package:structured_product_listing_app/features/cart/logic/cubit/cart_cubit.dart';
import 'package:structured_product_listing_app/features/cart/logic/cubit/cart_state.dart';
import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';
import 'package:structured_product_listing_app/features/wishlist/logic/cubit/wishlist_cubit.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {

    final authState = context.watch<AuthCubit>().state;

    final String userEmail =
        authState is Authenticated
            ? authState.email
            : "Guest";

    // =========================
    // CART ITEMS
    // =========================
    final List<CartItem> cartItems =
        context.watch<CartCubit>()
            .getCartForUser(userEmail);

    // ✅ FIXED
    final bool isInCart = cartItems.any(
      (item) =>
          item.product.id.toString() ==
          product.id.toString(),
    );

    // =========================
    // WISHLIST
    // =========================
    final wishlist =
        context.watch<WishlistCubit>()
            .getWishlistForUser(userEmail);

    final bool isInWishlist = wishlist.any(
      (item) =>
          item.id.toString() ==
          product.id.toString(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.title ?? 'Product Details',
        ),

        actions: [

          // WISHLIST BUTTON
          IconButton(
            icon: Icon(
              isInWishlist
                  ? Icons.favorite
                  : Icons.favorite_border,
              color:
                  isInWishlist
                      ? Colors.red
                      : null,
            ),

            onPressed: () {

              context
                  .read<WishlistCubit>()
                  .toggleWishlist(
                    userEmail,
                    product,
                  );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // PRODUCT IMAGE
            Center(
              child: Image.network(
                product.image ?? '',
                height: 250,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 20),

            // PRODUCT TITLE
            Text(
              product.title ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // PRODUCT PRICE
            Text(
              '\$${product.price}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            // DESCRIPTION
            Text(
              product.description ??
                  'No description available.',
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 30),

            // ADD / REMOVE CART BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isInCart
                          ? Colors.red
                          : Colors.indigo,

                  foregroundColor: Colors.white,
                ),

                onPressed: () {

                  if (isInCart) {

                    context
                        .read<CartCubit>()
                        .removeFromCart(
                          userEmail,
                          product,
                        );

                  } else {

                    context
                        .read<CartCubit>()
                        .addToCart(
                          userEmail,
                          product,
                        );
                  }
                },

                child: Text(
                  isInCart
                      ? 'REMOVE FROM CART'
                      : 'ADD TO CART',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}