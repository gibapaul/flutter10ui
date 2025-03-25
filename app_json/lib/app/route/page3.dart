import 'package:app_json/app/model/product.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/product_viewmodel.dart';

class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    final productsVM = Provider.of<ProductsVM>(context);
    final List<Product> products = productsVM.products;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Xem sản phẩm 3D'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(product: product);
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  // Định dạng giá tiền theo VND
  String _formatPrice(double price) {
    return "${(price * 1000).toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )} VNĐ";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Hình ảnh sản phẩm (2D ban đầu)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/${product.img}',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 40),
              ),
            ),
            const SizedBox(width: 16),
            // Thông tin sản phẩm
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatPrice(product.price.toDouble()),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Nút xem 3D
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Product3DViewer(product: product),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Xem 3D'),
            ),
          ],
        ),
      ),
    );
  }
}

class Product3DViewer extends StatefulWidget {
  final Product product;

  const Product3DViewer({super.key, required this.product});

  @override
  State<Product3DViewer> createState() => _Product3DViewerState();
}

class _Product3DViewerState extends State<Product3DViewer> {
  double _rotationAngle = 0.0; // Góc xoay
  double _scale = 1.0; // Tỷ lệ phóng to/thu nhỏ
  int _currentImageIndex = 0; // Chỉ số hình ảnh hiện tại (giả lập 3D)

  // Danh sách hình ảnh giả lập (các góc độ khác nhau của sản phẩm)
  List<String> getProductImages() {
    // Giả lập: mỗi sản phẩm có 4 hình ảnh từ các góc độ khác nhau
    // Trong thực tế, bạn cần chuẩn bị hình ảnh từ các góc độ (ví dụ: front, side, back, top)
    return [
      widget.product.img, // Hình ảnh chính
      widget.product
          .img, // Giả lập: dùng lại hình ảnh chính (bạn có thể thay bằng hình ảnh khác)
      widget.product.img,
      widget.product.img,
    ];
  }

  // Xử lý cả xoay và phóng to/thu nhỏ trong onScaleUpdate
  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // Xử lý phóng to/thu nhỏ
      _scale = (details.scale * 1.0)
          .clamp(0.5, 3.0); // Giới hạn tỷ lệ phóng to/thu nhỏ

      // Xử lý xoay: sử dụng focalPointDelta.dx để phát hiện thao tác kéo ngang
      _rotationAngle += details.focalPointDelta.dx * 0.05;
      _currentImageIndex = (_rotationAngle / 0.5).round() % 4;
      if (_currentImageIndex < 0) _currentImageIndex += 4;
    });
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
    final images = getProductImages();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Khu vực xem 3D
          Expanded(
            child: GestureDetector(
              onScaleUpdate: _onScaleUpdate, // Chỉ sử dụng onScaleUpdate
              child: Center(
                child: Transform.scale(
                  scale: _scale,
                  child: Image.asset(
                    'assets/images/${images[_currentImageIndex]}',
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
            ),
          ),
          // Thông tin sản phẩm
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatPrice(widget.product.price.toDouble()),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Kéo ngang để xoay sản phẩm, pinch để phóng to/thu nhỏ.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Nút thêm vào giỏ hàng
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Provider.of<ProductsVM>(context, listen: false)
                    .addToCart(widget.product);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã thêm vào giỏ hàng!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Thêm vào giỏ hàng',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
