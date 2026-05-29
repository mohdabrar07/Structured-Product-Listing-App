import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/models/product_model.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository repository;

  ProductCubit({required this.repository}) : super(ProductInitial());

  Future<void> loadProducts() async {
    emit(ProductLoadingState());
    try {
      final List<Product> products = await repository.getProductsList();
      
      // Fixed: Added explicit <String> type map filtering to satisfy the strict compiler
      final List<String> uniqueCategories = [
        'All', 
        ...products.map<String>((p) => p.category).toSet().toList()
      ];

      emit(ProductSuccessState(
        masterProducts: products,
        displayedProducts: products,
        categories: uniqueCategories,
      ));
    } catch (e) {
      emit(ProductErrorState('Failed to load store catalog. Please verify your connection.'));
    }
  }

  void updateSearchQuery(String query) {
    final currentState = state;
    if (currentState is ProductSuccessState) {
      _applyFiltersAndSort(currentState.copyWith(searchQuery: query));
    }
  }

  void updateCategory(String category) {
    final currentState = state;
    if (currentState is ProductSuccessState) {
      _applyFiltersAndSort(currentState.copyWith(selectedCategory: category));
    }
  }

  void updateSortOrder(SortOrder order) {
    final currentState = state;
    if (currentState is ProductSuccessState) {
      _applyFiltersAndSort(currentState.copyWith(activeSortOrder: order));
    }
  }

  void _applyFiltersAndSort(ProductSuccessState baselineState) {
    List<Product> runningFilteredList = List.from(baselineState.masterProducts);

    if (baselineState.selectedCategory != 'All') {
      runningFilteredList = runningFilteredList
          .where((p) => p.category.toLowerCase() == baselineState.selectedCategory.toLowerCase())
          .toList();
    }

    if (baselineState.searchQuery.isNotEmpty) {
      runningFilteredList = runningFilteredList
          .where((p) => p.title.toLowerCase().contains(baselineState.searchQuery.toLowerCase()))
          .toList();
    }

    switch (baselineState.activeSortOrder) {
      case SortOrder.priceLowToHigh:
        runningFilteredList.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOrder.priceHighToLow:
        runningFilteredList.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOrder.none:
        break;
    }

    emit(baselineState.copyWith(displayedProducts: runningFilteredList));
  }

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