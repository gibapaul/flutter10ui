import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_json/app/model/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }
}

class Order {
  final List<CartItem> items;
  final double totalPrice;
  final DateTime orderDate;
  final String address;
  final String paymentMethod;

  Order({
    required this.items,
    required this.totalPrice,
    required this.orderDate,
    required this.address,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'orderDate': orderDate.toIso8601String(),
      'address': address,
      'paymentMethod': paymentMethod,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      orderDate: DateTime.parse(json['orderDate']),
      address: json['address'],
      paymentMethod: json['paymentMethod'],
    );
  }
}

class ProductsVM extends ChangeNotifier {
  final List<Product> _products = [
    Product(
      id: 1,
      name: 'Cây Kim Tiền',
      price: 150,
      img: 'kimtien.png',
      des: 'Cây mang lại tài lộc và may mắn.',
      catId: 'cat1',
      catName: 'Cây phong thủy',
      rating: 4.5,
      sold: 100,
      reviews: 50,
    ),
    Product(
      id: 2,
      name: 'Cây Lưỡi Hổ',
      price: 120,
      img: 'luoiho.png',
      des: 'Cây giúp thanh lọc không khí.',
      catId: 'cat1',
      catName: 'Cây phong thủy',
      rating: 4.2,
      sold: 80,
      reviews: 40,
    ),
    Product(
      id: 3,
      name: 'Cây Thủy Tùng',
      price: 200,
      img: 'thuy_tung.png',
      des: 'Cây mang lại sự bình an.',
      catId: 'cat1',
      catName: 'Cây phong thủy',
      rating: 4.7,
      sold: 120,
      reviews: 60,
    ),
    Product(
      id: 4,
      name: 'Cây Hồng Môn',
      price: 180,
      img: 'hong_mon.png',
      des: 'Cây mang lại năng lượng tích cực.',
      catId: 'cat1',
      catName: 'Cây phong thủy',
      rating: 4.3,
      sold: 90,
      reviews: 45,
    ),
  ];

  List<Product> get products => _products;

  List<CartItem> lst = [];
  List<Product> favoriteProducts = [];
  List<Order> orders = [];

  ProductsVM() {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? cartJson = prefs.getString('cart');
      if (cartJson != null && cartJson.isNotEmpty) {
        List<dynamic> cartList = jsonDecode(cartJson);
        lst = cartList.map((json) => CartItem.fromJson(json)).toList();
      } else {
        lst = [];
      }

      String? favoritesJson = prefs.getString('favorites');
      if (favoritesJson != null && favoritesJson.isNotEmpty) {
        List<dynamic> favoritesList = jsonDecode(favoritesJson);
        favoriteProducts =
            favoritesList.map((json) => Product.fromJson(json)).toList();
      } else {
        favoriteProducts = [];
      }

      String? ordersJson = prefs.getString('orders');
      if (ordersJson != null && ordersJson.isNotEmpty) {
        List<dynamic> ordersList = jsonDecode(ordersJson);
        orders = ordersList.map((json) => Order.fromJson(json)).toList();
      } else {
        orders = [];
      }

      notifyListeners();
    } catch (e) {
      print("Error loading data: $e");
      lst = [];
      favoriteProducts = [];
      orders = [];
      notifyListeners();
    }
  }

  Future<void> _saveData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String cartJson = jsonEncode(lst.map((item) => item.toJson()).toList());
      await prefs.setString('cart', cartJson);

      String favoritesJson = jsonEncode(
          favoriteProducts.map((product) => product.toJson()).toList());
      await prefs.setString('favorites', favoritesJson);

      String ordersJson =
          jsonEncode(orders.map((order) => order.toJson()).toList());
      await prefs.setString('orders', ordersJson);

      notifyListeners();
    } catch (e) {
      print("Error saving data: $e");
    }
  }

  void addOrder(Order order) {
    orders.insert(0, order);
    _saveData();
  }

  void addToCart(Product product, {int quantity = 1}) {
    int index = lst.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      lst[index].quantity += quantity;
    } else {
      lst.add(CartItem(product: product, quantity: quantity));
    }
    _saveData();
    notifyListeners();
  }

  void removeProduct(int index) {
    lst.removeAt(index);
    _saveData();
    notifyListeners();
  }

  void increaseQuantity(int index) {
    lst[index].quantity += 1;
    _saveData();
    notifyListeners();
  }

  void decreaseQuantity(int index) {
    if (lst[index].quantity > 1) {
      lst[index].quantity -= 1;
      _saveData();
      notifyListeners();
    }
  }

  void clearCart() {
    lst.clear();
    _saveData();
    notifyListeners();
  }

  int getTotalQuantity() {
    return lst.fold(0, (sum, item) => sum + item.quantity);
  }

  double getTotalPrice() {
    return lst.fold(
        0,
        (sum, item) =>
            sum + (item.product.price.toDouble() * 1000 * item.quantity));
  }

  void toggleFavorite(Product product) {
    if (favoriteProducts.contains(product)) {
      favoriteProducts.remove(product);
    } else {
      favoriteProducts.add(product);
    }
    _saveData();
    notifyListeners();
  }

  bool isFavorite(Product product) {
    return favoriteProducts.contains(product);
  }

  void resetState() {
    lst.clear();
    favoriteProducts.clear();
    orders.clear();
    _saveData();
    notifyListeners();
  }
}
