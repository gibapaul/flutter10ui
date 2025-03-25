import 'package:flutter/material.dart';
import 'package:app_json/app/model/product.dart';

class CartItem {
  Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });
}

class ProductsVM extends ChangeNotifier {
  // Danh sách sản phẩm (giả lập)
  final List<Product> _products = [
    Product(
      id: 1,
      name: 'Cây Kim Tiền',
      price: 150, // Kiểu int
      img: 'kimtien.png',
      des: 'Cây mang lại tài lộc và may mắn.', // Sửa description thành des
      catId: 'cat1',
      catName: 'Cây phong thủy',
      rating: 4.5, // Kiểu double
      sold: 100, // Kiểu int
      reviews: 50, // Kiểu int
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

  // Getter để truy cập danh sách sản phẩm
  List<Product> get products => _products;

  List<CartItem> lst = [];
  List<Product> favoriteProducts = []; // Danh sách sản phẩm yêu thích

  // Thêm sản phẩm vào giỏ hàng với số lượng tùy chỉnh
  void addToCart(Product product, {int quantity = 1}) {
    int index = lst.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      // Nếu sản phẩm đã có trong giỏ hàng, tăng số lượng
      lst[index].quantity += quantity;
    } else {
      // Nếu sản phẩm chưa có, thêm mới với số lượng được chỉ định
      lst.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  // Xóa sản phẩm khỏi giỏ hàng
  void removeProduct(int index) {
    lst.removeAt(index);
    notifyListeners();
  }

  // Tăng số lượng
  void increaseQuantity(int index) {
    lst[index].quantity += 1;
    notifyListeners();
  }

  // Giảm số lượng
  void decreaseQuantity(int index) {
    if (lst[index].quantity > 1) {
      lst[index].quantity -= 1;
      notifyListeners();
    }
  }

  // Xóa toàn bộ giỏ hàng
  void clearCart() {
    lst.clear();
    notifyListeners();
  }

  // Tính tổng số lượng sản phẩm
  int getTotalQuantity() {
    return lst.fold(0, (sum, item) => sum + item.quantity);
  }

  // Tính tổng tiền (theo VND)
  double getTotalPrice() {
    return lst.fold(
        0,
        (sum, item) =>
            sum + (item.product.price.toDouble() * 1000 * item.quantity));
  }

  // Thêm sản phẩm vào danh sách yêu thích
  void toggleFavorite(Product product) {
    if (favoriteProducts.contains(product)) {
      favoriteProducts.remove(product);
    } else {
      favoriteProducts.add(product);
    }
    notifyListeners();
  }

  // Kiểm tra xem sản phẩm có trong danh sách yêu thích không
  bool isFavorite(Product product) {
    return favoriteProducts.contains(product);
  }
}
