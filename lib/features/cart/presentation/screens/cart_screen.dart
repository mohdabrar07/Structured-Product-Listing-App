import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:structured_product_listing_app/features/auth/logic/cubit/auth_cubit.dart';

import 'package:structured_product_listing_app/features/cart/logic/cubit/cart_cubit.dart';
import 'package:structured_product_listing_app/features/cart/logic/cubit/cart_state.dart';

import 'package:structured_product_listing_app/features/cart/presentation/screens/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    final String userEmail =
        authState is Authenticated
            ? authState.email
            : "Guest";

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text(
          "Shopping Cart",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: BlocBuilder<CartCubit, Map<String, List<dynamic>>>(
        builder: (context, state) {

          final List<CartItem> cartItems =
              context
                  .watch<CartCubit>()
                  .getCartForUser(userEmail);

          if (cartItems.isEmpty) {
            return const Center(
              child: Text(
                "Your cart is empty",
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {

              final CartItem cartItem =
                  cartItems[index];

              final product = cartItem.product;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(
                  bottom: 12,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [

                      // IMAGE
                      Image.network(
                        product.image ?? '',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),

                      const SizedBox(width: 12),

                      // DETAILS
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Text(
                              product.title ?? '',
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Qty: ${cartItem.quantity}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              '\$${((product.price ?? 0.0) * cartItem.quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // BUTTONS
                      Column(
                        children: [

                          // INCREMENT
                          IconButton(
                            onPressed: () {

                              context
                                  .read<CartCubit>()
                                  .addToCart(
                                    userEmail,
                                    product,
                                  );
                            },

                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.green,
                              size: 32,
                            ),
                          ),

                          // DECREMENT
                          IconButton(
                            onPressed: () {

                              context
                                  .read<CartCubit>()
                                  .removeFromCart(
                                    userEmail,
                                    product,
                                  );
                            },

                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      bottomNavigationBar:
          BlocBuilder<CartCubit, Map<String, List<dynamic>>>(
        builder: (context, state) {

          final List<CartItem> cartItems =
              context
                  .watch<CartCubit>()
                  .getCartForUser(userEmail);

          if (cartItems.isEmpty) {
            return const SizedBox();
          }

          double total = 0;

          for (var item in cartItems) {
            total +=
                (item.product.price ?? 0.0) *
                item.quantity;
          }

          return Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    'Total: \$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.indigo,
                      foregroundColor:
                          Colors.white,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14,
                      ),
                    ),

                    onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CheckoutScreen(
                            cartItems:
                                cartItems,
                            totalAmount:
                                total,
                          ),
                        ),
                      );
                    },

                    child: const Text(
                      "CHECKOUT",
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}