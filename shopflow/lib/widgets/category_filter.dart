import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/product_provider_manual.dart';

class CategoryFilter extends ConsumerStatefulWidget {
  final Function(String) onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.onCategorySelected,
  });

  @override
  ConsumerState<CategoryFilter> createState() => _CategoryFilterState();
}

class _CategoryFilterState extends ConsumerState<CategoryFilter> {
  String _selected = 'All';

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) => _buildCategoryList(categories),
      loading: () => _buildLoadingState(context),
      error: (error, stack) => _buildErrorState(context),
    );
  }

  Widget _buildCategoryList(List<String> categories) {
    final allCategories = ['All', ...categories];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final bool isSelected = _selected == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                _formatCategoryName(category),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onSecondaryContainer
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selected = category;
                });
                widget.onCategorySelected(category);
              },
              backgroundColor: Theme.of(context).colorScheme.surface,
              selectedColor: Theme.of(context).colorScheme.secondaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.onSecondaryContainer,
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              width: 80,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Text(
          'Failed to load categories',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  String _formatCategoryName(String category) {
    switch (category.toLowerCase()) {
      case "men's clothing":
        return "Men's";
      case "women's clothing":
        return "Women's";
      case "jewelery":
        return "Jewelry";
      case "electronics":
        return "Electronics";
      default:
        return category;
    }
  }
}
