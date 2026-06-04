import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// State Management Cubits & States
import 'package:structured_product_listing_app/features/auth/logic/cubit/auth_cubit.dart';
import 'package:structured_product_listing_app/features/products/logic/cubit/product_cubit.dart';
import 'package:structured_product_listing_app/features/products/logic/cubit/product_state.dart';
import 'package:structured_product_listing_app/features/wishlist/logic/cubit/wishlist_cubit.dart';
import 'package:structured_product_listing_app/features/cart/logic/cubit/cart_cubit.dart'; // 💡 Contains both CartCubit and OrderCubit
import 'package:structured_product_listing_app/features/cart/logic/cubit/cart_state.dart';
import 'package:structured_product_listing_app/features/address/logic/cubit/address_cubit.dart';

// Models
import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';

// Presentation Layer Screens
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
  String _selectedSortOption = "Default";

  final TextEditingController _searchController = TextEditingController();

  final List<String> _titles = [
    'Mega Store',
    'My Wishlist',
    'Shopping Cart',
    'My Profile',
  ];

  // =====================================
  // 1. ADDED BACK BUTTON FIX METHOD
  // =====================================
  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Safely extract the user identification string
    final authState = context.watch<AuthCubit>().state;
    final String userEmail = authState is Authenticated ? authState.email : "Guest";

    // Continuous streams targeted precisely via context.watch
    final wishlistItems = context.watch<WishlistCubit>().getWishlistForUser(userEmail);
    final cartItems = context.watch<CartCubit>().getCartForUser(userEmail);

    final List<Widget> pages = [
      _buildShopTabHomePage(userEmail),
      _buildWishlistTab(userEmail, wishlistItems),
      _buildCartTab(userEmail, cartItems),
      _buildProfileTab(userEmail),
    ];

    // =====================================
    // 2 & 3. WRAPPED WITH WILLPOPSCOPE
    // =====================================
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _titles[_currentIndex],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          actions: [
            if (_currentIndex == 0)
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
                onSelected: (value) {
                  setState(() {
                    _selectedSortOption = value;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'Default', child: Text('Default')),
                  const PopupMenuItem(value: 'PriceLowHigh', child: Text('Price Low → High')),
                  const PopupMenuItem(value: 'PriceHighLow', child: Text('Price High → Low')),
                  const PopupMenuItem(value: 'NameAZ', child: Text('Name A → Z')),
                ],
              ),
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() {
            _currentIndex = index;
          }),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.indigo,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: CustomBadge(
                count: wishlistItems.length,
                child: const Icon(Icons.favorite),
              ),
              label: 'Wishlist',
            ),
            BottomNavigationBarItem(
              icon: CustomBadge(
                count: cartItems.length,
                child: const Icon(Icons.shopping_cart),
              ),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================
  // SHOP TAB
  // ===================================================
  Widget _buildShopTabHomePage(String userEmail) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProductErrorState) {
          return Center(child: Text(state.message));
        }

        if (state is ProductSuccessState) {
          final allProducts = state.allProducts;

          if (allProducts.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          // FILTERING LOGIC
          List<ProductModel> filteredProducts = allProducts.where((product) {
            final matchesCategory = _selectedCategory == null || product.category == _selectedCategory;
            final matchesSearch = product.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
            return matchesCategory && matchesSearch;
          }).toList();

          // SORTING LOGIC
          if (_selectedSortOption == 'PriceLowHigh') {
            filteredProducts.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
          } else if (_selectedSortOption == 'PriceHighLow') {
            filteredProducts.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
          } else if (_selectedSortOption == 'NameAZ') {
            filteredProducts.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
          }

          final trendingProducts = allProducts.reversed.take(6).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SEARCH BAR
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),

                // CATEGORIES CHIPS CONTAINER
                const Padding(
                  padding: EdgeInsets.only(left: 16, bottom: 10),
                  child: Text(
                    'Categories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      final isSelected = _selectedCategory == category;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          selectedColor: Colors.indigo,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : null;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

                // TRENDING PRODUCTS SECTION
                if (_selectedCategory == null && _searchQuery.isEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 20, bottom: 10),
                    child: Text(
                      'Trending Products',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: trendingProducts.length,
                      itemBuilder: (context, index) {
                        final product = trendingProducts[index];

                        return Container(
                          width: 160,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Card(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(product: product),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Image.network(
                                        product.image ?? '',
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product.title ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '\$${product.price}',
                                      style: const TextStyle(
                                        color: Colors.indigo,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // MAIN GRID PRODUCTS LISTING
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Products (${filteredProducts.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filteredProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];

                    return Card(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(product: product),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Center(
                                  child: Image.network(
                                    product.image ?? '',
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '\$${product.price}',
                                        style: const TextStyle(
                                          color: Colors.indigo,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_shopping_cart,
                                          color: Colors.indigo,
                                        ),
                                        onPressed: () {
                                          context.read<CartCubit>().addToCart(userEmail, product);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${product.title} added to cart!'),
                                              duration: const Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  // ===================================================
  // WISHLIST TAB
  // ===================================================
  Widget _buildWishlistTab(String email, List<ProductModel> items) {
    if (items.isEmpty) {
      return const Center(child: Text('Wishlist is empty'));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final product = items[index];

        return ListTile(
          leading: Image.network(
            product.image ?? '',
            width: 50,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
          ),
          title: Text(product.title ?? ''),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              context.read<WishlistCubit>().toggleWishlist(email, product);
            },
          ),
        );
      },
    );
  }

  // ===================================================
  // 4. REPLACED ENTIRE _buildCartTab() METHOD
  // ===================================================
  Widget _buildCartTab(
    String email,
    List<CartItem> items,
  ) {
    if (items.isEmpty) {
      return const Center(
        child: Text('Cart is empty'),
      );
    }

    double total = items.fold(
      0,
      (sum, item) =>
          sum +
          ((item.product.price ?? 0) *
              item.quantity),
    );

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final cartItem = items[index];
              final product = cartItem.product;

              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Image.network(
                        product.image ?? '',
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '\$${product.price}',
                              style: const TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              context
                                  .read<CartCubit>()
                                  .removeFromCart(
                                    email,
                                    product,
                                  );
                            },
                          ),
                          Text(
                            '${cartItem.quantity}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.green,
                            ),
                            onPressed: () {
                              context
                                  .read<CartCubit>()
                                  .addToCart(
                                    email,
                                    product,
                                  );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutScreen(
                        cartItems: items,
                        totalAmount: total,
                      ),
                    ),
                  );
                },
                child: const Text('CHECKOUT'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===================================================
  // PROFILE TAB
  // ===================================================
  Widget _buildProfileTab(String email) {
    final currentAddress = context.watch<AddressCubit>().getAddressForUser(email);
    final orderHistory = context.watch<OrderCubit>().getOrdersForUser(email);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(email),
          trailing: IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              context.read<AuthCubit>().logoutUserPermanently();
            },
          ),
        ),
        const Divider(),
        ListTile(
          title: const Text('Delivery Address'),
          subtitle: Text(currentAddress.isEmpty ? 'No address added' : currentAddress),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressScreen()),
              );
            },
          ),
        ),
        const Divider(),
        const Text(
          'Order History',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 10),
        ...orderHistory.map(
          (order) => Card(
            child: ExpansionTile(
              title: Text(order.id),
              subtitle: Text('\$${order.total.toStringAsFixed(2)}'),
              children: order.items.map((item) {
                return ListTile(
                  title: Text(item.product.title ?? ''),
                  subtitle: Text('Qty: ${item.quantity}'),
                  trailing: Text('\$${item.product.price}'),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomBadge extends StatelessWidget {
  final Widget child;
  final int count;

  const CustomBadge({
    super.key,
    required this.child,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return child;

    return Stack(
      children: [
        child,
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(
              minWidth: 14,
              minHeight: 14,
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}