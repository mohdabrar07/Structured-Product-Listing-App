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
    'Mega Store',
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
      _buildShopTabHomePage(),
      _buildWishlistTab(wishlistItems),
      _buildCartTab(cartItems),
      _buildProfileTab(userEmail),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex], 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 0.5),
        ),
        actions: [
          if (_currentIndex == 0 && _selectedCategory != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                label: Text('Clear: $_selectedCategory', style: const TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: Colors.indigo.shade400,
                side: BorderSide.none,
                onPressed: () => setState(() => _selectedCategory = null),
              ),
            )
        ],
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo.shade700,
        unselectedItemColor: Colors.grey.shade500,
        showUnselectedLabels: true,
        elevation: 15,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Shop'),
          BottomNavigationBarItem(
            icon: CustomBadge(count: wishlistItems.length, child: const Icon(Icons.favorite)),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: CustomBadge(count: cartItems.length, child: const Icon(Icons.shopping_cart)),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
      ),
    );
  }

  // ==========================================================================
  // UPDATED RICH HOME STOREFRONT TAB MODIFICATIONS
  // ==========================================================================
  Widget _buildShopTabHomePage() {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoadingState) return const Center(child: CircularProgressIndicator(color: Colors.indigo));
        if (state is ProductErrorState) return Center(child: Text('Error: ${state.message}'));

        if (state is ProductSuccessState) {
          final List<ProductModel> allProducts = state.allProducts;
          if (allProducts.isEmpty) return const Center(child: Text('No storefront items active.'));

          // Calculate sub-lists for layout blocks
          final trendingProducts = allProducts.reversed.take(6).toList();
          final displayedGridProducts = _selectedCategory == null 
              ? allProducts 
              : allProducts.where((p) => p.category == _selectedCategory).toList();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. PROMOTIONAL ADS BANNER CARD HERO PANEL
                _buildPromoBannerCard(),

                // 2. HORIZONTAL CATEGORIES QUICK SELECT BAR
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 20, bottom: 10),
                  child: Text('Browse Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                ),
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final categoryName = state.categories[index];
                      final isSelected = _selectedCategory == categoryName;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(categoryName.toUpperCase()),
                          selected: isSelected,
                          selectedColor: Colors.indigo.shade700,
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? categoryName : null;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

                // 3. HORIZONTAL TRENDING OFFERS CAROUSEL BLOCK (Hidden when filtering categories)
                if (_selectedCategory == null) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 24, bottom: 12),
                    child: Row(
                      children: [
                        Icon(Icons.bolt, color: Colors.orange, size: 24),
                        SizedBox(width: 6),
                        Text('Trending Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 190,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: trendingProducts.length,
                      itemBuilder: (context, index) {
                        final product = trendingProducts[index];
                        return _buildTrendingHorizontalCard(product);
                      },
                    ),
                  ),
                ],

                // 4. MAIN ITEMS DYNAMIC PRODUCT LIST INTERFACE PANEL
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 26, bottom: 12),
                  child: Text(
                    _selectedCategory == null ? 'Our Recommendations' : 'Filtered Results (${displayedGridProducts.length})', 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                  ),
                ),
                
                GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  // 🛠️ FIXED: Replaced horizontal parameter with left and right parameters
  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 24), 
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    childAspectRatio: 0.74,
  ),
  itemCount: displayedGridProducts.length,
  itemBuilder: (context, index) {
    final product = displayedGridProducts[index];
    return _buildStandardGridProductCard(product);
  },
),
              ],
            ),
          );
        }
        return const Center(child: Text('Unknown State'));
      },
    );
  }

  Widget _buildPromoBannerCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade800, Colors.purple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: const Text('SUMMER SALE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const SizedBox(height: 12),
          const Text('Up to 50% OFF\non Elite Gadgets', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2)),
          const SizedBox(height: 8),
          Text('Free global distribution terms applied to items standard over \$50.', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTrendingHorizontalCard(ProductModel product) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: Image.network(product.image ?? '', fit: BoxFit.contain, height: 75),
                  ),
                ),
                const SizedBox(height: 8),
                Text(product.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 2),
                Text('\$${(product.price ?? 0).toStringAsFixed(2)}', style: TextStyle(color: Colors.indigo.shade700, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardGridProductCard(ProductModel product) {
    return Card(
      elevation: 1.5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                width: double.infinity,
                child: Image.network(product.image ?? '', fit: BoxFit.contain),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.2),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${(product.price ?? 0).toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.indigo.shade700, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Icon(Icons.add_circle, color: Colors.indigo.shade700, size: 22),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // UNCHANGED FEATURES SECURE STORAGE RESTORATION HOOKS
  // ==========================================================================
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
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen(cartItems: items, totalAmount: total)));
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