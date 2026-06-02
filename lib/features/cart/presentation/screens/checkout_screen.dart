import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:structured_product_listing_app/features/auth/logic/cubit/auth_cubit.dart';
import 'package:structured_product_listing_app/features/address/logic/cubit/address_cubit.dart';
import 'package:structured_product_listing_app/features/cart/logic/cubit/cart_cubit.dart';
import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';
import 'package:structured_product_listing_app/features/cart/logic/cubit/cart_cubit.dart' show OrderCubit;

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
    final authState = context.watch<AuthCubit>().state;
    final String userEmail = authState is Authenticated ? authState.email : "Guest";

    final currentAddress = context.watch<AddressCubit>().getAddressForUser(userEmail);
    final bool hasAddress = currentAddress.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Logistics Destination Target', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.local_shipping, color: Colors.indigo),
                title: Text(
                  hasAddress ? currentAddress : 'No shipping address set. Please add an address profile to continue.',
                  style: TextStyle(color: hasAddress ? Colors.black : Colors.red, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Package Line-Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Image.network(item.image ?? '', width: 40, fit: BoxFit.contain),
                    title: Text(item.title ?? '', maxLines: 1),
                    trailing: Text('\$${item.price}'),
                  );
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Payment Owed:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('\$${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                onPressed: !hasAddress ? null : () {
                  context.read<OrderCubit>().addOrder(userEmail, cartItems, totalAmount, currentAddress);
                  context.read<CartCubit>().clearCart(userEmail);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order Dispatched Successfully!'), backgroundColor: Colors.green),
                  );
                  Navigator.pop(context);
                },
                child: const Text('CONFIRM & PLACE ORDER'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}