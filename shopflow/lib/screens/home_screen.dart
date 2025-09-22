import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/product_provider_manual.dart';
import '../widgets/product_grid.dart';
import '../widgets/search_bar.dart' as app_search;
import '../widgets/category_filter.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart' as app_error;
import 'product_detail_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Widget _buildBrandRow({double iconSize = 24, double fontSize = 20}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.shopping_bag,
          size: iconSize,
          color: Colors.white,
        ),
        const SizedBox(width: 8),
        Text(
          'ShopFlow',
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productNotifierProvider);
    final searchQuery = ref.watch(searchNotifierProvider);
    final favorites = ref.watch(favoritesNotifierProvider);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildAppBar(),
            _buildSearchSection(),
            _buildCategoryFilter(),
          ];
        },
        body: productsAsync.when(
          data: (products) => products.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async {
                    ref.read(productNotifierProvider.notifier).refresh();
                  },
                  child: ProductGrid(
                    products: products,
                    onProductTap: (product) => _navigateToProductDetail(product),
                  ),
                ),
          loading: () => const LoadingWidget(),
          error: (error, stack) => app_error.ErrorWidget(
            error: error,
            onRetry: () {
              ref.read(productNotifierProvider.notifier).refresh();
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToFavorites(),
        child: Badge(
          label: Text('${favorites.length}'),
          isLabelVisible: favorites.isNotEmpty,
          child: const Icon(Icons.favorite),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final double currentHeight = constraints.biggest.height;
          // SliverAppBar collapsed height approximates kToolbarHeight + status/padding handled by the widget.
          final bool isCollapsed = currentHeight <= (kToolbarHeight + 24);

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Centered brand row for expanded state
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: isCollapsed ? 0 : 1,
                  child: Center(
                    child: _buildBrandRow(iconSize: 28, fontSize: 22),
                  ),
                ),
                // Top-left brand row for collapsed state
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: isCollapsed ? 1 : 0,
                    child: _buildBrandRow(iconSize: 24, fontSize: 20),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        Consumer(
          builder: (context, ref, child) {
            final isDarkMode = ref.watch(themeNotifierProvider);
            return IconButton(
              onPressed: () {
                ref.read(themeNotifierProvider.notifier).toggleTheme();
              },
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              tooltip: isDarkMode ? 'Light Mode' : 'Dark Mode',
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: app_search.SearchBar(
          onSearchChanged: (query) {
            ref.read(searchNotifierProvider.notifier).updateQuery(query);
            ref.read(productNotifierProvider.notifier).searchProducts(query);
          },
          onClear: () {
            ref.read(searchNotifierProvider.notifier).clearQuery();
            ref.read(productNotifierProvider.notifier).refresh();
          },
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CategoryFilter(
          onCategorySelected: (category) {
            if (category == 'All') {
              ref.read(productNotifierProvider.notifier).refresh();
            } else {
              ref.read(productNotifierProvider.notifier).filterByCategory(category);
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Products Found',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(searchNotifierProvider.notifier).clearQuery();
                ref.read(productNotifierProvider.notifier).refresh();
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProductDetail(product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  void _navigateToFavorites() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FavoritesScreen(),
      ),
    );
  }
}
