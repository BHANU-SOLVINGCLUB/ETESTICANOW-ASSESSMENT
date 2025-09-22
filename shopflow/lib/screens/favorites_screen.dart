import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/product_provider_manual.dart';
import '../widgets/product_grid.dart';
import '../widgets/empty_state.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesNotifierProvider);
    final productsAsync = ref.watch(productNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites (${favorites.length})',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (favorites.isNotEmpty)
            IconButton(
              onPressed: () => _showClearFavoritesDialog(context, ref),
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear All Favorites',
            ),
        ],
      ),
      body: productsAsync.when(
        data: (allProducts) {
          final favoriteProducts = allProducts
              .where((product) => favorites.contains(product.id))
              .toList();

          if (favoriteProducts.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border,
              title: 'No Favorites Yet',
              subtitle: 'Add some products to your favorites to see them here.',
              actionText: 'Browse Products',
              onActionPressed: () => Navigator.of(context).pop(),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.read(productNotifierProvider.notifier).refresh();
            },
            child: ProductGrid(
              products: favoriteProducts,
              onProductTap: (product) => _navigateToProductDetail(context, product),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error loading favorites: $error',
            style: GoogleFonts.inter(
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToProductDetail(BuildContext context, product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  void _showClearFavoritesDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear All Favorites',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to remove all products from your favorites?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(favoritesNotifierProvider.notifier).clearFavorites();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All favorites cleared'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
