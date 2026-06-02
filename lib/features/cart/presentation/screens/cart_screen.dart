import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:structured_product_listing_app/features/cart/logic/cubit/cart_cubit.dart';
import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';
import 'package:structured_product_listing_app/features/cart/presentation/screens/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Shopping Cart', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: BlocBuilder<CartCubit, List<ProductModel>>(
        builder: (context, cartList) {
          if (cartList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text('Your cart is empty', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          // Group the flat list dynamically to display quantities accurately in the UI
          final Map<String, int> quantities = {};
          final List<ProductModel> uniqueCartItems = [];

          for (var item in cartList) {
            final String itemKey = item.title ?? '';
            if (!quantities.containsKey(itemKey)) {
              uniqueCartItems.add(item);
            }
            quantities[itemKey] = (quantities[itemKey] ?? 0) + 1;
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: uniqueCartItems.length,
            itemBuilder: (context, index) {
              final product = uniqueCartItems[index];
              final quantity = quantities[product.title ?? ''] ?? 1;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Image.network(product.image ?? '', width: 60, height: 60, fit: BoxFit.contain),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title ?? '', 
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis, 
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${(product.price ?? 0).toStringAsFixed(2)}', 
                              style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline), 
                            // In our flat list, removing an item naturally decrements the count by one
                            onPressed: () => context.read<CartCubit>().removeFromCart(product),
                          ),
                          Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline), 
                            onPressed: () => context.read<CartCubit>().addToCart(product),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<CartCubit, List<ProductModel>>(
        builder: (context, cartList) {
          if (cartList.isEmpty) return const SizedBox.shrink();

          // Calculate the total bill dynamically from the list state
          final double totalPrice = cartList.fold(0.0, (sum, item) => sum + (item.price ?? 0.0));

          return Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Bill:', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Text(
                        '\$${totalPrice.toStringAsFixed(2)}', 
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(
                            cartItems: cartList, 
                            totalAmount: totalPrice,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo, 
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    ),
                    child: const Text('CHECKOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}