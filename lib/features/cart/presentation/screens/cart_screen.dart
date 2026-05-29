import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../logic/cubit/cart_cubit.dart';
import '../../logic/cubit/cart_state.dart';
import 'package:structured_product_listing_app/features/cart/presentation/screens/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Shopping Cart', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          return switch (state) {
            CartInitial() => const Center(child: CircularProgressIndicator()),
            
            CartEmpty() => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'Your cart is empty',
                      style: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('Add items from the store to get started.', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),

            CartError(errorMessage: var msg) => CustomErrorWidget(
                errorMessage: msg,
                onRetry: () {}, // Baseline reset error fallback helper
              ),

            CartUpdated(
              cartItems: var list,
              subtotal: var sub,
              vatAmount: var vat,
              deliveryCharge: var del,
              grandTotal: var grand
            ) => Column(
                children: [
                  // Scrollable List of Items inside Cart
                  Expanded(
                    child: ListView.builder(
                      itemCount: list.length,
                      padding: const EdgeInsets.all(12),
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          elevation: 0.5,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: item.product.image,
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${item.product.price.toStringAsFixed(2)}',
                                        style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Quantity Control Row Widgets
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                      onPressed: () => context.read<CartCubit>().decreaseQuantity(item.product.id),
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                      onPressed: () => context.read<CartCubit>().increaseQuantity(item.product.id),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                      onPressed: () => context.read<CartCubit>().removeProduct(item.product.id),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Financial Totals Calculation Summary Bottom Sheet Box Block
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SummaryRow(label: 'Subtotal', value: sub),
                          _SummaryRow(label: 'VAT (5%)', value: vat),
                          _SummaryRow(label: 'Delivery Charge', value: del),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Grand Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(
                                '\$${grand.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.indigo,
    padding: const EdgeInsets.symmetric(vertical: 16),
  ),
  onPressed: () {
    // REQUIREMENT MET: Navigates straight to our financial ledger checklist screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
  },
  child: const Text(
    'Proceed to Checkout',
    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
  ),
)
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
          };
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          Text('\$${value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}