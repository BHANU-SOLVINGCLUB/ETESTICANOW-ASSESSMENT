import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';

class FavoritesService {
  static const String _favoritesBoxName = 'favorites';
  static late Box<int> _favoritesBox;

  static Future<void> init() async {
    _favoritesBox = await Hive.openBox<int>(_favoritesBoxName);
  }

  // Add product to favorites
  static Future<void> addToFavorites(int productId) async {
    await _favoritesBox.put(productId, productId);
  }

  // Remove product from favorites
  static Future<void> removeFromFavorites(int productId) async {
    await _favoritesBox.delete(productId);
  }

  // Check if product is favorite
  static bool isFavorite(int productId) {
    return _favoritesBox.containsKey(productId);
  }

  // Get all favorite product IDs
  static List<int> getFavoriteIds() {
    return _favoritesBox.values.toList();
  }

  // Toggle favorite status
  static Future<bool> toggleFavorite(int productId) async {
    if (isFavorite(productId)) {
      await removeFromFavorites(productId);
      return false;
    } else {
      await addToFavorites(productId);
      return true;
    }
  }

  // Clear all favorites
  static Future<void> clearFavorites() async {
    await _favoritesBox.clear();
  }

  // Get favorites count
  static int get favoritesCount => _favoritesBox.length;

  static Future<void> close() async {
    await _favoritesBox.close();
  }
}
