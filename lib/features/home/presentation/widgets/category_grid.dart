import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:structured_product_listing_app/features/products/logic/cubit/product_cubit.dart';
import 'package:structured_product_listing_app/features/products/logic/cubit/product_state.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  // Maps the precise API category strings to your requested icons
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.phone_iphone;
      case 'jewelery':
      case 'jewelry':
        return Icons.diamond;
      case "men's clothing":
        return Icons.man;
      case "women's clothing":
        return Icons.woman;
      default:
        return Icons.category_outlined; // Fallback safe icon
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductSuccessState) {
          // Removes any generic 'All' tabs from the grid matrix if present
          final categories = state.categories.where((c) => c != 'All').toList();

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shrinkWrap: true, // Keeps layout height bounded inside CustomScrollView
            physics: const NeverScrollableScrollPhysics(), // Passes scroll behavior up to parent sliver
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 items per row
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.4, // Gives a clean horizontal layout card aspect ratio
            ),
            itemBuilder: (context, index) {
              final categoryName = categories[index];
              
              return InkWell(
                onTap: () {
                  // 1. Updates state engine logic to target this specific category
                  context.read<ProductCubit>().updateCategory(categoryName);
                  
                  // 2. Note: If using tabs, trigger your index change here to pop over to catalog view
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      // Icon Circle Window Capsule
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.indigo.shade50,
                        child: Icon(
                          _getCategoryIcon(categoryName),
                          color: Colors.indigo.shade700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Styled Text Block
                      Expanded(
                        child: Text(
                          categoryName[0].toUpperCase() + categoryName.substring(1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        
        // Quiet spacer placeholder fallback if state isn't ready yet
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(color: Colors.indigo),
          ),
        );
      },
    );
  }
}