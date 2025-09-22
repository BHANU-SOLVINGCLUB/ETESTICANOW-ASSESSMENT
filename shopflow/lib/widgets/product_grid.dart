import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import '../providers/product_provider_manual.dart';
import 'product_card.dart';

class ProductGrid extends ConsumerWidget {
  final List<Product> products;
  final Function(Product) onProductTap;

  const ProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          // Taller tiles so text fits without overflow on smaller screens
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () => onProductTap(product),
            onFavoriteToggle: () => _toggleFavorite(ref, product),
            isFavorite: ref.watch(favoritesNotifierProvider).contains(product.id),
          );
        },
      ),
    );
  }

  void _toggleFavorite(WidgetRef ref, Product product) {
    ref.read(favoritesNotifierProvider.notifier).toggleFavorite(product.id);
  }
}
