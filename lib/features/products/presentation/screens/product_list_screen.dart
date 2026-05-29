import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Logic Layer (Cubits & States)
import 'package:structured_product_listing_app/features/products/logic/cubit/product_cubit.dart';
import 'package:structured_product_listing_app/features/products/logic/cubit/product_state.dart';
import 'package:structured_product_listing_app/features/auth/logic/cubit/auth_cubit.dart';
import 'package:structured_product_listing_app/features/wishlist/logic/cubit/wishlist_cubit.dart';
import 'package:structured_product_listing_app/features/address/logic/cubit/address_cubit.dart';
import 'package:structured_product_listing_app/features/cart/logic/cubit/cart_cubit.dart';

// Presentation Layer (Screens & Widgets)
import 'package:structured_product_listing_app/features/wishlist/presentation/screens/wishlist_screen.dart';
import 'package:structured_product_listing_app/features/address/presentation/screens/address_screen.dart';
import 'package:structured_product_listing_app/features/cart/presentation/screens/cart_screen.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      // FIX 1: Moved the AppBar parameter out of the body column back to its proper Scaffold slot
      appBar: AppBar(
        title: const Text('Store Catalog', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.redAccent),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WishlistScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.location_on_outlined, color: Colors.teal),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddressScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.indigo),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // A. Interactive Search Text Processing Input Box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: (val) => context.read<ProductCubit>().updateSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // B. Category Dropdown & Sorting Filter Ribbon Controls
          BlocBuilder<ProductCubit, ProductState>(
            builder: (context, state) {
              if (state is ProductSuccessState) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: state.selectedCategory,
                              isExpanded: true,
                              items: state.categories.map((String cat) {
                                return DropdownMenuItem<String>(
                                  value: cat,
                                  child: Text(cat == 'All' ? 'All Categories' : cat),
                                );
                              }).toList(),
                              onChanged: (val) => context.read<ProductCubit>().updateCategory(val ?? 'All'),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: PopupMenuButton<SortOrder>(
                          icon: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.sort, color: Colors.black87),
                                SizedBox(width: 4),
                                Text('Sort', style: TextStyle(color: Colors.black87)),
                              ],
                            ),
                          ),
                          onSelected: (order) => context.read<ProductCubit>().updateSortOrder(order),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: SortOrder.none, child: Text('Default')),
                            const PopupMenuItem(value: SortOrder.priceLowToHigh, child: Text('Price: Low to High')),
                            const PopupMenuItem(value: SortOrder.priceHighToLow, child: Text('Price: High to Low')),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // C. Core Native Content State Machine Engine
          Expanded(
            child: BlocBuilder<ProductCubit, ProductState>(
              builder: (context, state) {
                return switch (state) {
                  ProductInitial() => const SizedBox.shrink(),
                  
                  // FIX 2: Replaced custom animation LoadingWidget with standard adaptive spinner
                  ProductLoadingState() => const Center(
    child: CircularProgressIndicator(color: Colors.indigo),
  ),
                  
                  // FIX 3: Replaced CustomErrorWidget with a built-in clean layout to prevent path failures
                  ProductErrorState(message: var msg) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                            const SizedBox(height: 12),
                            Text(
                              msg,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.black54, fontSize: 15),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => context.read<ProductCubit>().loadProducts(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                            )
                          ],
                        ),
                      ),
                    ),
                  
                  ProductSuccessState(displayedProducts: var list) => RefreshIndicator(
                      color: Colors.indigo,
                      onRefresh: () => context.read<ProductCubit>().loadProducts(),
                      child: list.isEmpty
                          ? const Center(
                              child: Text('No matching products found.', style: TextStyle(color: Colors.grey)),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: list.length,
                              itemBuilder: (context, index) => ProductCard(product: list[index]),
                            ),
                    ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}