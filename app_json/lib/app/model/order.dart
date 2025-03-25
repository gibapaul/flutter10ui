import 'package:app_json/app/model/product.dart';

class Order {
  final List<CartItem> items; // Danh sách sản phẩm trong đơn hàng
  final double totalPrice; // Tổng tiền
  final DateTime orderDate; // Ngày đặt hàng
  final String address; // Địa chỉ giao hàng
  final String paymentMethod; // Phương thức thanh toán

  Order({
    required this.items,
    required this.totalPrice,
    required this.orderDate,
    required this.address,
    required this.paymentMethod,
  });

  // Chuyển đổi Order thành JSON để lưu vào SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'orderDate': orderDate.toIso8601String(),
      'address': address,
      'paymentMethod': paymentMethod,
    };
  }

  // Tạo Order từ JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      totalPrice: json['totalPrice'],
      orderDate: DateTime.parse(json['orderDate']),
      address: json['address'],
      paymentMethod: json['paymentMethod'],
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

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
