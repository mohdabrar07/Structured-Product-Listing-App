import 'package:structured_product_listing_app/features/products/data/models/product_model.dart';

enum SortOrder { none, priceLowToHigh, priceHighToLow }

// 💡 CHANGE 'abstract' TO 'sealed' HERE
sealed class ProductState {
  const ProductState();
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoadingState extends ProductState {
  const ProductLoadingState();
}

class ProductSuccessState extends ProductState {
  final List<ProductModel> allProducts;
  final List<ProductModel> displayedProducts;
  final String? searchQuery;
  final String? selectedCategory;
  final SortOrder sortOrder;

  const ProductSuccessState({
    required this.allProducts,
    required this.displayedProducts,
    this.searchQuery,
    this.selectedCategory,
    this.sortOrder = SortOrder.none,
  });

  List<String> get categories => allProducts
      .map((product) => product.category ?? 'uncategorized')
      .toSet()
      .toList();

  ProductSuccessState copyWith({
    List<ProductModel>? allProducts,
    List<ProductModel>? displayedProducts,
    String? searchQuery,
    String? selectedCategory,
    SortOrder? sortOrder,
  }) {
    return ProductSuccessState(
      allProducts: allProducts ?? this.allProducts,
      displayedProducts: displayedProducts ?? this.displayedProducts,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class ProductErrorState extends ProductState {
  final String message;
  const ProductErrorState(this.message);
}