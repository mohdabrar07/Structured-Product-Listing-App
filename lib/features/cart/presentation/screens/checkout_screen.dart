import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Fixed: Correct absolute logic paths to find Cart Cubit & States
import 'package:structured_product_listing_app/features/cart/logic/cubit/cart_cubit.dart';
import 'package:structured_product_listing_app/features/cart/logic/cubit/cart_state.dart';

// Address Layer Dependencies
import 'package:structured_product_listing_app/features/address/logic/cubit/address_cubit.dart';
import 'package:structured_product_listing_app/features/address/presentation/screens/address_screen.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          // Explicit type check block to satisfy the compiler's null safety rules
          if (state is! CartUpdated) {
            return const Center(
              child: Text('No active order data found.', style: TextStyle(color: Colors.grey)),
            );
          }

          // Because the type is proven to be CartUpdated here, grandTotal is 100% safe to read
          final cartState = state; 

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Shipping Destination Panel
                Card(
                  color: Colors.indigo.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BlocBuilder<AddressCubit, AddressState>(
                      builder: (context, addrState) {
                        final hasAddress = addrState.shippingAddress.trim().isNotEmpty;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.location_on, color: Colors.indigo),
                                    SizedBox(width: 6),
                                    Text('Deliver To:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context, 
                                    MaterialPageRoute(builder: (_) => const AddressScreen())
                                  ),
                                  child: Text(hasAddress ? 'Change' : 'Add Address', style: const TextStyle(fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: Text(
                                hasAddress ? addrState.shippingAddress : 'No active address registered on file.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: hasAddress ? Colors.black87 : Colors.red.shade700, 
                                  fontStyle: hasAddress ? FontStyle.normal : FontStyle.italic
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                const Text('Order Pricing Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                
                // 2. Financial Receipt Breakdown Panel
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Subtotal:'), Text('\$${cartState.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500))]),
                        const SizedBox(height: 12),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Est. VAT (5%):'), Text('\$${cartState.vatAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500))]),
                        const SizedBox(height: 12),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Delivery Fees:'), Text('\$${cartState.deliveryCharge.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500))]),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Grand Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text('\$${cartState.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // 3. Complete Checkout Form CTA Action
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600, 
                    foregroundColor: Colors.white, 
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('🎉 Order Successfully Placed! Delivery on the way.')),
                    );
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Place Order & Pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}