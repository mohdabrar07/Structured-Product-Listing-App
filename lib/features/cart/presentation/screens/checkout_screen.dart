import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:structured_product_listing_app/features/address/logic/cubit/address_cubit.dart';
import 'package:structured_product_listing_app/features/cart/logic/cubit/cart_cubit.dart'; // 💡 Modified to access unified file
import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';

class CheckoutScreen extends StatelessWidget {
  final List<ProductModel> cartItems;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final currentAddress = context.watch<AddressCubit>().state;
    final hasAddress = currentAddress.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout Summary', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Delivery Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    color: hasAddress ? Colors.white : Colors.red.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: hasAddress ? Colors.grey.shade300 : Colors.red.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: hasAddress ? Colors.indigo : Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              hasAddress ? currentAddress : 'No shipping address set. Please add an address to continue.',
                              style: TextStyle(color: hasAddress ? Colors.black87 : Colors.red.shade700, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text('Invoice Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Items count (${cartItems.length}):', style: const TextStyle(color: Colors.grey)),
                              Text('\$${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Grand Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text('\$${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10)]),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasAddress ? Colors.indigo : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                onPressed: hasAddress
                    ? () {
                        context.read<OrderCubit>().addOrder(cartItems, totalAmount, currentAddress);
                        context.read<CartCubit>().clearCart();

                        Navigator.pop(context); 
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Success! 🎉'),
                            content: const Text('Your order has been safely recorded in your order history.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Awesome'),
                              )
                            ],
                          ),
                        );
                      }
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('⚠️ Cannot place order without a delivery address. Add one in your Profile!'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      },
                child: const Text('CONFIRM & PLACE ORDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}