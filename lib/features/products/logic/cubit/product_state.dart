import '../../data/models/product_model.dart';

enum SortOrder { none, priceLowToHigh, priceHighToLow }

sealed class ProductState {}

class ProductLoadingState extends ProductState {}

class ProductErrorState extends ProductState {
  final String message;
  ProductErrorState(this.message);
}

class ProductSuccessState extends ProductState {
  // Contains the raw unmodified source data
  final List<Product> masterProducts;
  // Contains the dynamic filtered result slice pushed directly to the UI
  final List<Product> displayedProducts;
  final List<String> categories;
  
  // Track current criteria filters
  final String searchQuery;
  final String selectedCategory;
  final SortOrder selectedSortOrder;

  ProductSuccessState({
    required this.masterProducts,
    required this.displayedProducts,
    required this.categories,
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.selectedSortOrder = SortOrder.none,
  });

  ProductSuccessState copyWith({
    List<Product>? displayedProducts,
    String? searchQuery,
    String? selectedCategory,
    SortOrder? selectedSortOrder,
  }) {
    return ProductSuccessState(
      masterProducts: this.masterProducts,
      categories: this.categories,
      displayedProducts: displayedProducts ?? this.displayedProducts,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedSortOrder: selectedSortOrder ?? this.selectedSortOrder,
    );
  }
}