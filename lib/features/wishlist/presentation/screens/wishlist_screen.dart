import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../../logic/cubit/wishlist_cubit.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocBuilder<WishlistCubit, WishlistState>(
        builder: (context, state) {
          if (state is WishlistEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your wishlist is empty.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          if (state is WishlistUpdated) {
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                return ProductCard(product: state.items[index]);
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}