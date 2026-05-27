import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/models/product_model.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository repository;

  ProductCubit({required this.repository}) : super(ProductInitial());

  // 1. CORE FETCH PIPELINE (Called on startup, pull-to-refresh, or manual retry)
  Future<void> loadProducts() async {
    emit(ProductLoadingState());
    try {
      final products = await repository.getProductsList();
      
      // Dynamically extract unique categories from dataset on the fly
      final uniqueCategories = ['All', ...products.map((p) => p.category).toSet().toList()];

      emit(ProductSuccessState(
        masterProducts: products,
        displayedProducts: products,
        categories: uniqueCategories,
      ));
    } catch (e) {
      emit(ProductErrorState('Failed to load store catalog. Please verify your connection.'));
    }
  }

  // 2. SEARCH QUERY UPDATE TRIGGER
  void updateSearchQuery(String query) {
    final currentState = state;
    if (currentState is ProductSuccessState) {
      _applyFiltersAndSort(currentState.copyWith(searchQuery: query));
    }
  }

  // 3. CATEGORY DROPDOWN SELECT TRIGGER
  void updateCategory(String category) {
    final currentState = state;
    if (currentState is ProductSuccessState) {
      _applyFiltersAndSort(currentState.copyWith(selectedCategory: category));
    }
  }

  // 4. POPUP SORT CRITERIA TRIGGER
  void updateSortOrder(SortOrder order) {
    final currentState = state;
    if (currentState is ProductSuccessState) {
      _applyFiltersAndSort(currentState.copyWith(activeSortOrder: order));
    }
  }

  // 5. UNIFIED MATH & SEARCH DATA PIPELINE
  void _applyFiltersAndSort(ProductSuccessState baselineState) {
    List<Product> runningFilteredList = List.from(baselineState.masterProducts);

    // Step A: Apply Category Filtering
    if (baselineState.selectedCategory != 'All') {
      runningFilteredList = runningFilteredList
          .where((p) => p.category.toLowerCase() == baselineState.selectedCategory.toLowerCase())
          .toList();
    }

    // Step B: Apply Text Input Search Filtering
    if (baselineState.searchQuery.isNotEmpty) {
      runningFilteredList = runningFilteredList
          .where((p) => p.title.toLowerCase().contains(baselineState.searchQuery.toLowerCase()))
          .toList();
    }

    // Step C: Apply Price Sorting
    switch (baselineState.activeSortOrder) {
      case SortOrder.priceLowToHigh:
        runningFilteredList.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOrder.priceHighToLow:
        runningFilteredList.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOrder.none:
        // Maintains initial master default sequence placement natively
        break;
    }

    // Emit fully processed list to presentation layer
    emit(baselineState.copyWith(displayedProducts: runningFilteredList));
  }

  // 6. LOCAL MEMORY OBJECT LOOKUP FOR THE DETAIL SCREEN
  Product? getProductDetailsFromCache(int id) {
    final currentState = state;
    if (currentState is ProductSuccessState) {
      try {
        return currentState.masterProducts.firstWhere((element) => element.id == id);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}