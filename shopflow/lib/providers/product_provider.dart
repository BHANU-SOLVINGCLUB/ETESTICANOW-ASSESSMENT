import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';

// API State
@riverpod
class ProductNotifier extends _$ProductNotifier {
  @override
  Future<List<Product>> build() async {
    return await ApiService.getProducts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ApiService.getProducts());
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      state = await AsyncValue.guard(() => ApiService.getProducts());
      return;
    }

    state = const AsyncValue.loading();
    final products = await ApiService.getProducts();
    final filteredProducts = products.where((product) {
      return product.title.toLowerCase().contains(query.toLowerCase()) ||
             product.category.toLowerCase().contains(query.toLowerCase()) ||
             product.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
    
    state = AsyncValue.data(filteredProducts);
  }

  Future<void> filterByCategory(String category) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ApiService.getProductsByCategory(category));
  }
}

// Categories Provider
@riverpod
Future<List<String>> categories(CategoriesRef ref) async {
  return await ApiService.getCategories();
}

// Favorites Provider
@riverpod
class FavoritesNotifier extends _$FavoritesNotifier {
  @override
  Set<int> build() {
    return FavoritesService.getFavoriteIds().toSet();
  }

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

// Search Query Provider
@riverpod
class SearchNotifier extends _$SearchNotifier {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }

  void clearQuery() {
    state = '';
  }
}

// Theme Provider
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  bool build() => false; // false = light mode, true = dark mode

  void toggleTheme() {
    state = !state;
  }
}

// Product Detail Provider
@riverpod
Future<Product> productDetail(ProductDetailRef ref, int productId) async {
  return await ApiService.getProduct(productId);
}