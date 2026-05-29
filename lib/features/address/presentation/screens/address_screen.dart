import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/address_cubit.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Shipping Address')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<AddressCubit, AddressState>(
          builder: (context, state) {
            // Pre-fill the controller text field with the existing cached address
            if (controller.text.isEmpty) {
              controller.text = state.shippingAddress;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter delivery location:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Type your full physical address here...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<AddressCubit>().saveNewAddress(controller.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Address successfully saved to disk!')),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Save Address'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}