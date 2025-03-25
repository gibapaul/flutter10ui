import 'package:app_json/app/model/product.dart';
import 'package:app_json/app/model/product_viewmodel.dart';
import 'package:app_json/app/page/product/checkout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1; // Số lượng mặc định là 1

  // Hàm tăng số lượng
  void _incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  // Hàm giảm số lượng (không cho phép nhỏ hơn 1)
  void _decrementQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  // Hàm xử lý "Mua ngay"
  void _buyNow(BuildContext context) {
    // Chuyển đến trang thanh toán với sản phẩm và số lượng đã chọn
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          items: [CartItem(product: widget.product, quantity: quantity)],
          totalPrice: widget.product.price.toDouble() * 1000 * quantity,
        ),
      ),
    );
  }

  // Định dạng giá tiền theo VND
  String _formatPrice(double price) {
    return "${(price * 1000).toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )} VNĐ";
  }

  @override
  Widget build(BuildContext context) {
    // Tính giá tiền theo số lượng
    double totalPrice = widget.product.price.toDouble() * quantity;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ProductsVM>(context).isFavorite(widget.product)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () {
              Provider.of<ProductsVM>(context, listen: false)
                  .toggleFavorite(widget.product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(Provider.of<ProductsVM>(context, listen: false)
                          .isFavorite(widget.product)
                      ? "Đã thêm vào danh sách yêu thích!"
                      : "Đã xóa khỏi danh sách yêu thích!"),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Số lượng và giá tiền
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Số lượng
                Container(
                  width: 120,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _decrementQuantity,
                        child: const Text(
                          "−",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        "$quantity",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: _incrementQuantity,
                        child: const Text(
                          "+",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Giá tiền (tăng theo số lượng)
                Text(
                  _formatPrice(totalPrice),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Nút "Thêm vào giỏ hàng" và "Mua ngay"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<ProductsVM>(context, listen: false)
                          .addToCart(widget.product, quantity: quantity);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Đã thêm vào giỏ hàng!")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart,
                      size: 28,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _buyNow(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                    ),
                    child: const Text(
                      "Mua ngay",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh sản phẩm
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.white,
              child: Image.asset(
                'assets/images/${widget.product.img}',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 60),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên sản phẩm
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Giá tiền (dưới tên sản phẩm)
                  Text(
                    _formatPrice(widget.product.price.toDouble()),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Số lượng đã bán và đánh giá
                  Row(
                    children: [
                      Text(
                        "${(widget.product.sold / 1000).toStringAsFixed(2)}K Đã bán",
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        "${widget.product.rating} (${widget.product.reviews} đánh giá)",
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Mô tả
                  const Text(
                    "Mô tả sản phẩm",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.des,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
