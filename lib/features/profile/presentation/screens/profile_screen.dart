import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:structured_product_listing_app/core/services/storage_service.dart';
import 'package:structured_product_listing_app/features/address/logic/cubit/address_cubit.dart';
import 'package:structured_product_listing_app/features/address/presentation/screens/address_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = RepositoryProvider.of<StorageService>(context);
    final String userEmail = storage.getUserEmail();
    
    // Retrieve historical storage records directly from the user scope layout
    final List<dynamic> rawOrders = storage.retrieveData('orders_history') ?? [];
    final List<String> ordersLog = List<String>.from(rawOrders);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('User Account Control', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Log out of session',
            onPressed: () async {
              await storage.clearAuthSession();
              // Strip navigation history and enforce returning to entry authentication layer
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Identity Card Block
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo.shade900,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Active Identity', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(userEmail, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Live Reactive Shipping Address Component Frame
            const Text('Configured Logistics Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 8),
            
            // 🛠️ FIXED: Changed type argument bound from String to Map<String, String>
            BlocBuilder<AddressCubit, Map<String, String>>(
              builder: (context, addressMap) {
                // 🛠️ FIXED: Extract specific user value safely from state dictionary Map
                final String currentAddress = addressMap[userEmail] ?? '';

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(12), 
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.indigo),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          currentAddress.isEmpty ? "No active logistical address saved yet." : currentAddress,
                          style: TextStyle(
                            fontSize: 14, 
                            color: currentAddress.isEmpty ? Colors.grey : Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_note_rounded, color: Colors.indigo),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressScreen())),
                      )
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Order History Execution Manifest Pipeline
            const Text('Historical Orders Placed Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 8),
            ordersLog.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text('No verified orders logged to this account profile.', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ordersLog.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade100)),
                        child: Row(
                          children: [
                            const Icon(Icons.local_shipping_outlined, color: Colors.green, size: 18),
                            const SizedBox(width: 12),
                            Expanded(child: Text(ordersLog[index], style: const TextStyle(fontSize: 13, color: Colors.black87))),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}