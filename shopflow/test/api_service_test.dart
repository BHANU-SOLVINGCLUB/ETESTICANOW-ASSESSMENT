import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shopflow/services/api_service.dart';

void main() {
  group('ApiService.getProducts', () {
    test('returns products on 200', () async {
      ApiService.client = MockClient((request) async {
        expect(request.url.path, contains('/products'));
        return http.Response(jsonEncode([
          {
            'id': 1,
            'title': 'Test',
            'price': 12.3,
            'description': 'Desc',
            'category': 'electronics',
            'image': 'u',
            'rating': {'rate': 4.2, 'count': 10}
          }
        ]), 200, headers: {'Content-Type': 'application/json'});
      });

      final products = await ApiService.getProducts();
      expect(products.length, 1);
      expect(products.first.id, 1);
    });

    test('throws ApiException on non-200', () async {
      ApiService.client = MockClient((request) async {
        return http.Response('err', 500);
      });

      expect(ApiService.getProducts(), throwsA(isA<ApiException>()));
    });
  });

  group('ApiService.getProduct', () {
    test('returns product on 200', () async {
      ApiService.client = MockClient((request) async {
        expect(request.url.path, contains('/products/1'));
        return http.Response(jsonEncode({
          'id': 1,
          'title': 'Test',
          'price': 12.3,
          'description': 'Desc',
          'category': 'electronics',
          'image': 'u',
          'rating': {'rate': 4.2, 'count': 10}
        }), 200, headers: {'Content-Type': 'application/json'});
      });

      final product = await ApiService.getProduct(1);
      expect(product.id, 1);
      expect(product.title, 'Test');
    });

    test('throws ApiException on non-200', () async {
      ApiService.client = MockClient((request) async {
        return http.Response('err', 404);
      });
      expect(ApiService.getProduct(1), throwsA(isA<ApiException>()));
    });
  });

  group('ApiService.getProductsByCategory', () {
    test('returns list on 200', () async {
      ApiService.client = MockClient((request) async {
        expect(request.url.path, contains('/products/category/'));
        return http.Response(jsonEncode([]), 200, headers: {'Content-Type': 'application/json'});
      });
      final list = await ApiService.getProductsByCategory('electronics');
      expect(list, isA<List>());
    });
  });
}


