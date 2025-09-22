import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';

// Manual Provider Implementation (Production Ready)
// This approach is more stable and doesn't rely on code generation

// Product Notifier Provider
class ProductNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  ProductNotifier() : super(const AsyncValue.loading()) {
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      state = const AsyncValue.loading();
      final products = await ApiService.getProducts();
      state = AsyncValue.data(products);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadProducts();
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      await _loadProducts();
      return;
    }

    try {
      state = const AsyncValue.loading();
      final products = await ApiService.getProducts();
      final filteredProducts = products.where((product) {
        return product.title.toLowerCase().contains(query.toLowerCase()) ||
               product.category.toLowerCase().contains(query.toLowerCase()) ||
               product.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
      
      state = AsyncValue.data(filteredProducts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> filterByCategory(String category) async {
    try {
      state = const AsyncValue.loading();
      final products = await ApiService.getProductsByCategory(category);
      state = AsyncValue.data(products);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Categories Provider
class CategoriesNotifier extends StateNotifier<AsyncValue<List<String>>> {
  CategoriesNotifier() : super(const AsyncValue.loading()) {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      state = const AsyncValue.loading();
      final categories = await ApiService.getCategories();
      state = AsyncValue.data(categories);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Favorites Notifier Provider
class FavoritesNotifier extends StateNotifier<Set<int>> {
  FavoritesNotifier() : super(FavoritesService.getFavoriteIds().toSet());

  Future<void> toggleFavorite(int productId) async {
    final isFavorite = await FavoritesService.toggleFavorite(productId);
    if (isFavorite) {
      state = {...state, productId};
    } else {
      state = Set.from(state)..remove(productId);
    }
  }

  Future<void> addToFavorites(int productId) async {
    await FavoritesService.addToFavorites(productId);
    state = {...state, productId};
  }

  Future<void> removeFromFavorites(int productId) async {
    await FavoritesService.removeFromFavorites(productId);
    state = Set.from(state)..remove(productId);
  }

  Future<void> clearFavorites() async {
    await FavoritesService.clearFavorites();
    state = {};
  }
}

// Search Query Notifier Provider
class SearchNotifier extends StateNotifier<String> {
  SearchNotifier() : super('');

  void updateQuery(String query) {
    state = query;
  }

  void clearQuery() {
    state = '';
  }
}

// Theme Notifier Provider
class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false); // false = light mode, true = dark mode

  void toggleTheme() {
    state = !state;
  }
}

// Product Detail Notifier Provider
class ProductDetailNotifier extends StateNotifier<AsyncValue<Product>> {
  ProductDetailNotifier() : super(const AsyncValue.loading());

  Future<void> loadProduct(int productId) async {
    try {
      state = const AsyncValue.loading();
      final product = await ApiService.getProduct(productId);
      state = AsyncValue.data(product);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Provider Instances
final productNotifierProvider = StateNotifierProvider<ProductNotifier, AsyncValue<List<Product>>>(
  (ref) => ProductNotifier(),
);

final categoriesNotifierProvider = StateNotifierProvider<CategoriesNotifier, AsyncValue<List<String>>>(
  (ref) => CategoriesNotifier(),
);

final favoritesNotifierProvider = StateNotifierProvider<FavoritesNotifier, Set<int>>(
  (ref) => FavoritesNotifier(),
);

final searchNotifierProvider = StateNotifierProvider<SearchNotifier, String>(
  (ref) => SearchNotifier(),
);

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, bool>(
  (ref) => ThemeNotifier(),
);

final productDetailNotifierProvider = StateNotifierProvider<ProductDetailNotifier, AsyncValue<Product>>(
  (ref) => ProductDetailNotifier(),
);

// Convenience providers for backward compatibility
final categoriesProvider = categoriesNotifierProvider;
