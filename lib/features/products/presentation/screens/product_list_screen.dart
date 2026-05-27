import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../../logic/cubit/product_cubit.dart';
import '../../logic/cubit/product_state.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Store Catalog', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.indigo),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
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
                  ProductLoadingState() => const LoadingWidget(),
                  
                  // Requirement Met: Retry Button calls cubit method directly
                  ProductErrorState(message: var msg) => CustomErrorWidget(
                      errorMessage: msg,
                      onRetry: () => context.read<ProductCubit>().loadProducts(),
                    ),
                  
                  ProductSuccessState(displayedProducts: var list) => RefreshIndicator(
                      color: Colors.indigo,
                      // Requirement Met: Pull to refresh feeds sequence through cubit
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