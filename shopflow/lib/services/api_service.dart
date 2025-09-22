import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String _baseUrl = 'https://fakestoreapi.com';
  static const Duration _timeout = Duration(seconds: 10);
  // Injectable HTTP client for testing
  static http.Client client = http.Client();

  // Get all products
  static Future<List<Product>> getProducts() async {
    try {
      final response = await client
          .get(
            Uri.parse('$_baseUrl/products'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // Get product by ID
  static Future<Product> getProduct(int id) async {
    try {
      final response = await client
          .get(
            Uri.parse('$_baseUrl/products/$id'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return Product.fromJson(json);
      } else {
        throw ApiException('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // Get products by category
  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await client
          .get(
            Uri.parse('$_baseUrl/products/category/$category'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // Get all categories
  static Future<List<String>> getCategories() async {
    try {
      final response = await client
          .get(
            Uri.parse('$_baseUrl/products/categories'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.cast<String>();
      } else {
        throw ApiException('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  
  @override
  String toString() => 'ApiException: $message';
}
