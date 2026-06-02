import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:structured_product_listing_app/features/products/data/models/product_model.dart'; // Ensure this import is here
import 'package:structured_product_listing_app/features/products/logic/cubit/product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final dynamic productRepository; 

  ProductCubit(this.productRepository) : super(const ProductInitial());

  Future<void> loadProducts() async {
    emit(const ProductLoadingState());
    try {
      final products = await productRepository.getProducts(); 
      
      emit(ProductSuccessState(
        allProducts: products,
        displayedProducts: products,
        sortOrder: SortOrder.none,
      ));
    } catch (failure) {
      emit(ProductErrorState(failure.toString()));
    }
  }

  void updateSearchQuery(String query) {
    final currentState = state;
    if (currentState is ProductSuccessState) {
      _filterAndSort(currentState.copyWith(searchQuery: query));
    }
  }

  void updateCategory(String? category) {
    final currentState = state;
    if (currentState is ProductSuccessState) {
      _filterAndSort(currentState.copyWith(selectedCategory: category));
    }
  }

  void updateSortOrder(SortOrder order) {
    final currentState = state;
    if (currentState is ProductSuccessState) {
      _filterAndSort(currentState.copyWith(sortOrder: order));
    }
  }

  void _filterAndSort(ProductSuccessState baselineState) {
    // 💡 FIX: Using baselineState.allProducts.toList() explicitly retains List<ProductModel>
    List<ProductModel> filtered = baselineState.allProducts.toList();

    if (baselineState.selectedCategory != null && baselineState.selectedCategory!.isNotEmpty) {
      filtered = filtered
          .where((p) => (p.category ?? '').toLowerCase() == baselineState.selectedCategory!.toLowerCase())
          .toList();
    }

    if (baselineState.searchQuery != null && baselineState.searchQuery!.isNotEmpty) {
      final query = baselineState.searchQuery!.toLowerCase();
      filtered = filtered
          .where((p) => (p.title ?? '').toLowerCase().contains(query))
          .toList();
    }

    if (baselineState.sortOrder == SortOrder.priceLowToHigh) {
      filtered.sort((a, b) => (a.price ?? 0.0).compareTo(b.price ?? 0.0));
    } else if (baselineState.sortOrder == SortOrder.priceHighToLow) {
      filtered.sort((a, b) => (b.price ?? 0.0).compareTo(a.price ?? 0.0));
    }

    emit(baselineState.copyWith(displayedProducts: filtered));
  }
}