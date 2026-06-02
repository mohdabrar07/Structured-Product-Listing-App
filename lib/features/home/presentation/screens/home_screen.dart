import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:structured_product_listing_app/features/auth/logic/cubit/auth_cubit.dart';
import 'package:structured_product_listing_app/features/products/logic/cubit/product_cubit.dart';
import 'package:structured_product_listing_app/features/products/logic/cubit/product_state.dart'; 
import 'package:structured_product_listing_app/features/wishlist/logic/cubit/wishlist_cubit.dart';
import 'package:structured_product_listing_app/features/cart/logic/cubit/cart_cubit.dart'; 
import 'package:structured_product_listing_app/features/address/logic/cubit/address_cubit.dart';
import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';
import 'package:structured_product_listing_app/features/products/presentation/screens/product_detail_screen.dart';
import 'package:structured_product_listing_app/features/cart/presentation/screens/checkout_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? _selectedCategory;

  final List<String> _titles = [
    'Discover Products',
    'My Wishlist',
    'Shopping Cart',
    'My Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final wishlistItems = context.watch<WishlistCubit>().state;
    final cartItems = context.watch<CartCubit>().state;
    
    final authState = context.watch<AuthCubit>().state;
    String userEmail = authState is Authenticated ? authState.email : "Guest User";

    final List<Widget> pages = [
      _buildProductsTab(),
      _buildWishlistTab(wishlistItems),
      _buildCartTab(cartItems),
      _buildProfileTab(userEmail),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedCategory != null && _currentIndex == 0
              ? _selectedCategory!.toUpperCase()
              : _titles[_currentIndex], 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        leading: _selectedCategory != null && _currentIndex == 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedCategory = null),
              )
            : null,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Shop'),
          BottomNavigationBarItem(
            icon: CustomBadge(
              count: wishlistItems.length,
              child: const Icon(Icons.favorite_border),
            ),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: CustomBadge(
              count: cartItems.length,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoadingState) return const Center(child: CircularProgressIndicator(color: Colors.indigo));
        if (state is ProductErrorState) return Center(child: Text('Error: ${state.message}'));

        if (state is ProductSuccessState) {
          final List<ProductModel> allProducts = state.allProducts;
          if (allProducts.isEmpty) return const Center(child: Text('No products found.'));

          // 1. CATEGORIES VIEW
          if (_selectedCategory == null) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 14, 
                mainAxisSpacing: 14, 
                childAspectRatio: 1.1
              ),
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final cat = state.categories[index];
                return InkWell(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Card(
                    color: Colors.indigo.shade50,
                    child: Center(
                      child: Text(cat.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                    ),
                  ),
                );
              },
            );
          }

          // 2. PRODUCT LIST VIEW (MODIFIED FROM LIST TO E-COMMERCE GRID)
          final filteredProducts = allProducts.where((p) => (p.category ?? 'uncategorized') == _selectedCategory).toList();

          if (filteredProducts.isEmpty) {
            return const Center(child: Text('No products available in this category.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,          // Shows 2 items per row (perfect for seeing 4-6 cards on screen)
              crossAxisSpacing: 12,       // Horizontal gap spacing between grid elements
              mainAxisSpacing: 12,        // Vertical gap spacing between grid elements
              childAspectRatio: 0.76,     // Dictates specific card height-to-width proportions
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image Container Panel
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.white,
                          width: double.infinity,
                          child: Image.network(
                            product.image ?? '',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // Product Metadata Label Stack
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '\$${(product.price ?? 0).toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: Text('Unknown State'));
      },
    );
  }

  Widget _buildWishlistTab(List<ProductModel> items) {
    if (items.isEmpty) return const Center(child: Text('Your Wishlist is empty.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final product = items[index];
        return Card(
          child: ListTile(
            leading: Image.network(product.image ?? '', width: 50, height: 50, fit: BoxFit.contain),
            title: Text(product.title ?? '', maxLines: 1),
            subtitle: Text('\$${product.price}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => context.read<WishlistCubit>().toggleWishlist(product),
            ),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
          ),
        );
      },
    );
  }

  Widget _buildCartTab(List<ProductModel> items) {
    if (items.isEmpty) return const Center(child: Text('Your Shopping Cart is empty.'));
    
    double total = items.fold(0, (sum, item) => sum + (item.price ?? 0.0));

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final product = items[index];
              return Card(
                child: ListTile(
                  leading: Image.network(product.image ?? '', width: 50, height: 50, fit: BoxFit.contain),
                  title: Text(product.title ?? '', maxLines: 1),
                  subtitle: Text('\$${product.price}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_shopping_cart, color: Colors.red),
                    onPressed: () => context.read<CartCubit>().removeFromCart(product),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10)]),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total amount:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CheckoutScreen(cartItems: items, totalAmount: total),
                      ),
                    );
                  },
                  child: const Text('PROCEED TO CHECKOUT', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildProfileTab(String email) {
    final currentAddress = context.watch<AddressCubit>().state;
    final orderHistory = context.watch<OrderCubit>().state;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.person, color: Colors.white)),
              title: Text(email, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: const Text('Verified Customer'),
              trailing: IconButton(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                onPressed: () => context.read<AuthCubit>().logoutUserPermanently(),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shipping Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => _showAddressEditDialog(context, currentAddress),
                icon: const Icon(Icons.edit, size: 16),
                label: Text(currentAddress.isEmpty ? 'Add' : 'Edit'),
              )
            ],
          ),
          Card(
            margin: const EdgeInsets.only(top: 4, bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.map_outlined, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      currentAddress.isEmpty ? 'No address specified yet.' : currentAddress,
                      style: TextStyle(color: currentAddress.isEmpty ? Colors.grey : Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Text('My Orders History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          if (orderHistory.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: Text('No previous orders found.', style: TextStyle(color: Colors.grey))),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orderHistory.length,
              itemBuilder: (context, index) {
                final order = orderHistory[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: const Icon(Icons.receipt_long, color: Colors.indigo),
                    title: Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('\$${order.total.toStringAsFixed(2)} • ${order.items.length} items'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date Placed: ${order.date.toString().substring(0, 16)}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text('Shipped To: ${order.address}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            const Divider(height: 20),
                            ...order.items.map((item) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(item.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
                                      Text('\$${item.price}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showAddressEditDialog(BuildContext context, String currentAddress) {
    final controller = TextEditingController(text: currentAddress);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Update Delivery Address'),
        content: TextFormField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter your full street address details...'),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<AddressCubit>().updateAddress(controller.text);
              Navigator.pop(dialogCtx);
            },
            child: const Text('Save Address'),
          ),
        ],
      ),
    );
  }
}

class CustomBadge extends StatelessWidget {
  final Widget child;
  final int count;
  const CustomBadge({super.key, required this.child, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return child;
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Center(
              child: Text(
                '$count',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        )
      ],
    );
  }
}