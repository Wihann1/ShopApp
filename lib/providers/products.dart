import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app_2/models/http_eception.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  Products(this.authToken, this._items, this.userId);

  List<Product> get items {
    return [..._items];
  }

  final String? authToken;
  final String? userId;

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    var url = Uri.https(
      'flutter-shop-source-default-rtdb.firebaseio.com',
      '/products.json',
      filterByUser
          ? {
              'auth': '$authToken',
              'orderBy': '"creatorId"',
              'equalTo': '"$userId"',
            }
          : {'auth': '$authToken'},
    );
    try {
      final response = await http.get(url);
      final extractedDate = json.decode(response.body) as Map<String, dynamic>;

      url = Uri.https('flutter-shop-source-default-rtdb.firebaseio.com',
          '/userFavorites/$userId.json', {
        'auth': authToken,
      });

      final favoriteResponse = await http.get(url);
      final favoriteData = jsonDecode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedDate.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false,
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https('flutter-shop-source-default-rtdb.firebaseio.com',
        '/products.json', {'auth': '$authToken'});
    try {
      final result = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId
          }));

      final newProduct = Product(
          id: json.decode(result.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
    } catch (e) {
      rethrow;
    }

    notifyListeners();
  }

  Future<void> updateProducts(String id, Product newProduct) async {
    final url = Uri.https('flutter-shop-source-default-rtdb.firebaseio.com',
        '/products/$id.json', {'auth': '$authToken'});
    await http.patch(url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price,
        }));
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    final url = Uri.https('flutter-shop-source-default-rtdb.firebaseio.com',
        '/products/$id.json', {'auth': '$authToken'});
    final excistingProductIndex =
        _items.indexWhere((element) => element.id == id);
    Product? excistingProduct = _items[excistingProductIndex];
    _items.removeAt(excistingProductIndex);
    _items.removeWhere((element) => element.id == id);
    http.delete(url).then((response) {
      if (response.statusCode >= 400) {
        throw HttpException('Could not delete product');
      }
      excistingProduct = null;
    }).catchError((e) {
      _items.insert(excistingProductIndex, excistingProduct!);
    });
    notifyListeners();
  }
}
