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
import 'package:structured_product_listing_app/features/address/presentation/screens/address_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? _selectedCategory;
  String _searchQuery = ""; 
  String _selectedSortOption = "Default"; // 💡 NEW: Holds current active sorting method
  final TextEditingController _searchController = TextEditingController();

  final List<String> _titles = [
    'Mega Store',
    'My Wishlist',
    'Shopping Cart',
    'My Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final String userEmail = authState is Authenticated ? authState.email : "Guest User";

    final wishlistItems = context.watch<WishlistCubit>().getWishlistForUser(userEmail);
    final cartItems = context.watch<CartCubit>().getCartForUser(userEmail);
    
    final List<Widget> pages = [
      _buildShopTabHomePage(userEmail),
      _buildWishlistTab(userEmail, wishlistItems),
      _buildCartTab(userEmail, cartItems),
      _buildProfileTab(userEmail),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          // 💡 NEW: Sort Actions Dropdown Menu Button visible on Shop Tab
          if (_currentIndex == 0)
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              tooltip: "Sort Products",
              onSelected: (String value) {
                setState(() {
                  _selectedSortOption = value;
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(value: 'Default', child: Text('Default Sorting')),
                const PopupMenuItem<String>(value: 'PriceLowHigh', child: Text('Price: Low to High')),
                const PopupMenuItem<String>(value: 'PriceHighLow', child: Text('Price: High to Low')),
                const PopupMenuItem<String>(value: 'NameAZ', child: Text('Name: A to Z')),
              ],
            ),
          if (_currentIndex == 0 && (_selectedCategory != null || _searchQuery.isNotEmpty || _selectedSortOption != "Default"))
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                label: const Text('Clear Filters', style: TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: Colors.indigo.shade400,
                side: BorderSide.none,
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                    _searchQuery = "";
                    _selectedSortOption = "Default";
                    _searchController.clear();
                  });
                },
              ),
            )
        ],
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo.shade700,
        unselectedItemColor: Colors.grey.shade500,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Shop'),
          BottomNavigationBarItem(icon: CustomBadge(count: wishlistItems.length, child: const Icon(Icons.favorite)), label: 'Wishlist'),
          BottomNavigationBarItem(icon: CustomBadge(count: cartItems.length, child: const Icon(Icons.shopping_cart)), label: 'Cart'),
          const BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildShopTabHomePage(String userEmail) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoadingState) return const Center(child: CircularProgressIndicator(color: Colors.indigo));
        if (state is ProductErrorState) return Center(child: Text('Error: ${state.message}'));

        if (state is ProductSuccessState) {
          final List<ProductModel> allProducts = state.allProducts;
          if (allProducts.isEmpty) return const Center(child: Text('No storefront items active.'));

          // Filter items based on criteria first
          var displayedGridProducts = allProducts.where((product) {
            final matchesCategory = _selectedCategory == null || product.category == _selectedCategory;
            final matchesSearch = product.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? true;
            return matchesCategory && matchesSearch;
          }).toList();

          // 💡 NEW: Apply sorting mechanics to the filtered list layout
          if (_selectedSortOption == 'PriceLowHigh') {
            displayedGridProducts.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
          } else if (_selectedSortOption == 'PriceHighLow') {
            displayedGridProducts.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
          } else if (_selectedSortOption == 'NameAZ') {
            displayedGridProducts.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
          }

          final trendingProducts = allProducts.reversed.take(6).toList();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPromoBannerCard(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search products by name...',
                        prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                        suffixIcon: _searchQuery.isNotEmpty 
                            ? IconButton(
                                icon: const Icon(Icons.clear), 
                                onPressed: () => setState(() { _searchQuery = ""; _searchController.clear(); }))
                            : null,
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 16, bottom: 10),
                  child: Text('Browse Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                          onSelected: (selected) => setState(() => _selectedCategory = selected ? categoryName : null),
                        ),
                      );
                    },
                  ),
                ),

                if (_selectedCategory == null && _searchQuery.isEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 20, bottom: 12),
                    child: Row(children: [Icon(Icons.bolt, color: Colors.orange), SizedBox(width: 6), Text('Trending Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                  ),
                  SizedBox(
                    height: 190,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: trendingProducts.length,
                      itemBuilder: (context, index) => _buildTrendingHorizontalCard(trendingProducts[index]),
                    ),
                  ),
                ],

                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 20, bottom: 12),
                  child: Text('Our Recommendations (${displayedGridProducts.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                
                displayedGridProducts.isEmpty 
                ? const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: Text("No products match your search query Criteria.")))
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(left: 12, right: 12, bottom: 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.74),
                    itemCount: displayedGridProducts.length,
                    itemBuilder: (context, index) => _buildStandardGridProductCard(userEmail, displayedGridProducts[index]),
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
        gradient: LinearGradient(colors: [Colors.indigo.shade800, Colors.purple.shade700]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SUMMER SALE', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Up to 50% OFF\non Elite Gadgets', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTrendingHorizontalCard(ProductModel product) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Card(
        color: Colors.white,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(child: Image.network(product.image ?? '', fit: BoxFit.contain)),
                Text(product.title ?? '', maxLines: 1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text('\$${product.price}', style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardGridProductCard(String email, ProductModel product) {
    return Card(
      color: Colors.white,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Container(width: double.infinity, padding: const EdgeInsets.all(8), child: Image.network(product.image ?? '', fit: BoxFit.contain))),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title ?? '', maxLines: 1, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${product.price}', style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.add_circle, color: Colors.indigo), onPressed: () => context.read<CartCubit>().addToCart(email, product)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistTab(String email, List<ProductModel> items) {
    if (items.isEmpty) return const Center(child: Text('Your Wishlist is empty.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final product = items[index];
        return Card(
          child: ListTile(
            leading: Image.network(product.image ?? '', width: 50, fit: BoxFit.contain),
            title: Text(product.title ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red), 
              onPressed: () => context.read<WishlistCubit>().toggleWishlist(email, product),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartTab(String email, List<ProductModel> items) {
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
                  leading: Image.network(product.image ?? '', width: 50, fit: BoxFit.contain),
                  title: Text(product.title ?? ''),
                  trailing: IconButton(icon: const Icon(Icons.remove_shopping_cart, color: Colors.red), onPressed: () => context.read<CartCubit>().removeFromCart(email, product)),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total: \$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen(cartItems: items, totalAmount: total))), child: const Text('CHECKOUT')),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildProfileTab(String email) {
    final currentAddress = context.watch<AddressCubit>().getAddressForUser(email);
    final orderHistory = context.watch<OrderCubit>().getOrdersForUser(email);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(email),
          trailing: IconButton(icon: const Icon(Icons.logout, color: Colors.red), onPressed: () => context.read<AuthCubit>().logoutUserPermanently()),
        ),
        const Divider(),
        ListTile(
          title: const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(currentAddress.isEmpty ? 'No address specified.' : currentAddress),
          trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressScreen()))),
        ),
        const Divider(),
        const Text('Order History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ...orderHistory.map((order) => Card(
              child: ExpansionTile(
                title: Text(order.id),
                subtitle: Text('\$${order.total} • ${order.items.length} items'),
                children: order.items.map((i) => ListTile(title: Text(i.title ?? ''), trailing: Text('\$${i.price}'))).toList(),
              ),
            )),
      ],
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
    return Stack(children: [child, Positioned(right: 0, top: 0, child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 8))))]);
  }
}