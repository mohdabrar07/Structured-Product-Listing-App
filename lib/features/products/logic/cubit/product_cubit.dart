import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository repository;

  ProductCubit({required this.repository}) : super(ProductLoadingState());

  Future<void> loadProducts() async {
    emit(ProductLoadingState());
    try {
      final products = await repository.getProducts();
      final distinctCategories = ['All', ...products.map((p) => p.category).toSet()];

      emit(ProductSuccessState(
        masterProducts: products,
        displayedProducts: products,
        categories: distinctCategories,
      ));
    } catch (error) {
      if (error is Failure) {
        emit(ProductErrorState(error.message));
      } else {
        emit(ProductErrorState('An unexpected systemic issue occurred.'));
      }
    }
  }

  void updateSearchQuery(String query) {
    final currentState = state;
    if (currentState is ProductSuccessState) {
      _applyPipeline(currentState.copyWith(searchQuery: query));
    }
  }

  void updateCategory(String category) {
    final currentState = state;
    if (currentState is ProductSuccessState) {
      _applyPipeline(currentState.copyWith(selectedCategory: category));
    }
  }

  void updateSortOrder(SortOrder order) {
    final currentState = state;
    if (currentState is ProductSuccessState) {
      _applyPipeline(currentState.copyWith(selectedSortOrder: order));
    }
  }

  // The Unified Processing Matrix Pipeline
  void _applyPipeline(ProductSuccessState baselineState) {
    List<Product> processedList = List.from(baselineState.masterProducts);

    // 1. Filter by Search Query
    if (baselineState.searchQuery.isNotEmpty) {
      processedList = processedList
          .where((p) => p.title.toLowerCase().contains(baselineState.searchQuery.toLowerCase()))
          .toList();
    }

    // 2. Filter by Category
    if (baselineState.selectedCategory != 'All') {
      processedList = processedList.where((p) => p.category == baselineState.selectedCategory).toList();
    }

    // 3. Apply Sorting Matrices
    if (baselineState.selectedSortOrder == SortOrder.priceLowToHigh) {
      processedList.sort((a, b) => a.price.compareTo(b.price));
    } else if (baselineState.selectedSortOrder == SortOrder.priceHighToLow) {
      processedList.sort((a, b) => b.price.compareTo(a.price));
    }

    emit(baselineState.copyWith(displayedProducts: processedList));
  }

  Product? getProductDetailsFromCache(int id) {
    final currentState = state;
    if (currentState is ProductSuccessState) {
      try {
        return currentState.masterProducts.firstWhere((p) => p.id == id);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}