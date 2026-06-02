import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:structured_product_listing_app/features/auth/logic/cubit/auth_cubit.dart';
import 'package:structured_product_listing_app/features/address/logic/cubit/address_cubit.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    
    // Fetch current user email safely
    final authState = context.watch<AuthCubit>().state;
    final String currentUserEmail = authState is Authenticated ? authState.email : "Guest";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Shipping Destination'), elevation: 0.5, backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current Location Target:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            BlocBuilder<AddressCubit, Map<String, String>>(
              builder: (context, addressMap) {
                final userAddress = context.read<AddressCubit>().getAddressForUser(currentUserEmail);
                return Text(
                  userAddress.isEmpty ? "No address stored yet." : userAddress, 
                  style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)
                );
              }
            ),
            const SizedBox(height: 24),
            TextField(
              controller: textController,
              decoration: InputDecoration(hintText: 'Enter complete dropoff address...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (textController.text.isNotEmpty) {
                    context.read<AddressCubit>().saveUserShippingAddress(currentUserEmail, textController.text);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                child: const Text('UPDATE LOGISTICS PATH', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}