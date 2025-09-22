import 'package:flutter_test/flutter_test.dart';
import 'package:shopflow/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('should create a product from JSON', () {
      final json = {
        'id': 1,
        'title': 'Test Product',
        'price': 29.99,
        'description': 'Test Description',
        'category': 'electronics',
        'image': 'https://example.com/image.jpg',
        'rating': {
          'rate': 4.5,
          'count': 100,
        },
      };

      final product = Product.fromJson(json);

      expect(product.id, 1);
      expect(product.title, 'Test Product');
      expect(product.price, 29.99);
      expect(product.description, 'Test Description');
      expect(product.category, 'electronics');
      expect(product.image, 'https://example.com/image.jpg');
      expect(product.rating.rate, 4.5);
      expect(product.rating.count, 100);
    });

    test('should convert product to JSON', () {
      final product = Product(
        id: 1,
        title: 'Test Product',
        price: 29.99,
        description: 'Test Description',
        category: 'electronics',
        image: 'https://example.com/image.jpg',
        rating: const Rating(rate: 4.5, count: 100),
      );

      final json = product.toJson();

      expect(json['id'], 1);
      expect(json['title'], 'Test Product');
      expect(json['price'], 29.99);
      expect(json['description'], 'Test Description');
      expect(json['category'], 'electronics');
      expect(json['image'], 'https://example.com/image.jpg');
      // Depending on json_serializable version, nested objects may not be
      // expanded without build step. Validate via the object itself.
      final rating = json['rating'];
      if (rating is Map<String, dynamic>) {
        expect(rating['rate'], 4.5);
        expect(rating['count'], 100);
      } else if (rating is Rating) {
        expect(rating.rate, 4.5);
        expect(rating.count, 100);
      } else {
        fail('Unexpected rating type: ${rating.runtimeType}');
      }
    });

    test('should test product equality', () {
      final product1 = Product(
        id: 1,
        title: 'Test Product',
        price: 29.99,
        description: 'Test Description',
        category: 'electronics',
        image: 'https://example.com/image.jpg',
        rating: const Rating(rate: 4.5, count: 100),
      );

      final product2 = Product(
        id: 1,
        title: 'Different Title',
        price: 39.99,
        description: 'Different Description',
        category: 'clothing',
        image: 'https://example.com/different.jpg',
        rating: const Rating(rate: 3.0, count: 50),
      );

      final product3 = Product(
        id: 2,
        title: 'Test Product',
        price: 29.99,
        description: 'Test Description',
        category: 'electronics',
        image: 'https://example.com/image.jpg',
        rating: const Rating(rate: 4.5, count: 100),
      );

      expect(product1 == product2, true); // Same ID
      expect(product1 == product3, false); // Different ID
    });

    test('should format price correctly', () {
      final product = Product(
        id: 1,
        title: 'Test Product',
        price: 29.99,
        description: 'Test Description',
        category: 'electronics',
        image: 'https://example.com/image.jpg',
        rating: const Rating(rate: 4.5, count: 100),
      );

      expect(product.formattedPrice, '\$29.99');
    });

    test('should format rating correctly', () {
      final product = Product(
        id: 1,
        title: 'Test Product',
        price: 29.99,
        description: 'Test Description',
        category: 'electronics',
        image: 'https://example.com/image.jpg',
        rating: const Rating(rate: 4.5, count: 100),
      );

      expect(product.formattedRating, '4.5 (100)');
    });

    test('should format category display names', () {
      final product1 = Product(
        id: 1,
        title: 'Test Product',
        price: 29.99,
        description: 'Test Description',
        category: "men's clothing",
        image: 'https://example.com/image.jpg',
        rating: const Rating(rate: 4.5, count: 100),
      );

      final product2 = Product(
        id: 2,
        title: 'Test Product',
        price: 29.99,
        description: 'Test Description',
        category: 'jewelery',
        image: 'https://example.com/image.jpg',
        rating: const Rating(rate: 4.5, count: 100),
      );

      expect(product1.categoryDisplayName, "Men's Clothing");
      expect(product2.categoryDisplayName, 'Jewelry');
    });
  });
}
