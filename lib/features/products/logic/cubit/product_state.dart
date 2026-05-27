import '../../data/models/product_model.dart';

// Sorting configuration options state criteria matrix
enum SortOrder { none, priceLowToHigh, priceHighToLow }

sealed class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoadingState extends ProductState {}

class ProductErrorState extends ProductState {
  final String message;
  ProductErrorState(this.message);
}

class ProductSuccessState extends ProductState {
  // Master cache: The original, pristine list untouched from the single API call
  final List<Product> masterProducts;
  
  // Active UI list: The subset altered dynamically by search, sorting, or categories
  final List<Product> displayedProducts;
  
  // Active UI Filtering Values
  final List<String> categories;
  final String selectedCategory;
  final String searchQuery;
  final SortOrder activeSortOrder;

  ProductSuccessState({
    required this.masterProducts,
    required this.displayedProducts,
    required this.categories,
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.activeSortOrder = SortOrder.none,
  });

  // Structural state modifier matrix
  ProductSuccessState copyWith({
    List<Product>? masterProducts,
    List<Product>? displayedProducts,
    List<String>? categories,
    String? selectedCategory,
    String? searchQuery,
    SortOrder? activeSortOrder,
  }) {
    return ProductSuccessState(
      masterProducts: masterProducts ?? this.masterProducts,
      displayedProducts: displayedProducts ?? this.displayedProducts,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      activeSortOrder: activeSortOrder ?? this.activeSortOrder,
    );
  }
}