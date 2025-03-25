import 'dart:convert';
import 'package:app_json/app/model/product.dart';
import 'package:app_json/app/model/product_viewmodel.dart';
import 'package:app_json/app/page/product/productdetail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart'; // Để sử dụng firstWhereOrNull

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  final TextEditingController _birthDayController = TextEditingController();
  String? userElement; // Mệnh của người dùng
  Product? recommendedTree;
  bool isLoading = false;
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final String response = await DefaultAssetBundle.of(context)
        .loadString('assets/json/data.json');
    final List<dynamic> data = jsonDecode(response);
    if (mounted) {
      setState(() {
        products = data.map((json) => Product.fromJson(json)).toList();
      });
    }
  }

  // Hàm xác định mệnh dựa trên năm sinh (dùng bảng ngũ hành nạp âm)
  String determineElement(int year) {
    // Tính chỉ số trong chu kỳ 60 năm (bắt đầu từ 1924)
    int cycleIndex = (year - 1924) % 60;
    if (cycleIndex < 0) {
      cycleIndex += 60; // Đảm bảo chỉ số không âm (cho các năm trước 1924)
    }

    // Bảng ngũ hành nạp âm (từ 1924 đến 1983, lặp lại sau mỗi 60 năm)
    const List<String> elements = [
      "Kim", "Kim", // 1924, 1925: Hải Trung Kim
      "Hỏa", "Hỏa", // 1926, 1927: Lư Trung Hỏa
      "Mộc", "Mộc", // 1928, 1929: Đại Lâm Mộc
      "Thổ", "Thổ", // 1930, 1931: Lộ Bàng Thổ
      "Kim", "Kim", // 1932, 1933: Kiếm Phong Kim
      "Hỏa", "Hỏa", // 1934, 1935: Sơn Đầu Hỏa
      "Thủy", "Thủy", // 1936, 1937: Giản Hạ Thủy
      "Thổ", "Thổ", // 1938, 1939: Thành Đầu Thổ
      "Kim", "Kim", // 1940, 1941: Bạch Lạp Kim
      "Mộc", "Mộc", // 1942, 1943: Dương Liễu Mộc
      "Thủy", "Thủy", // 1944, 1945: Tuyền Trung Thủy
      "Thổ", "Thổ", // 1946, 1947: Ốc Thượng Thổ
      "Hỏa", "Hỏa", // 1948, 1949: Tích Lịch Hỏa
      "Mộc", "Mộc", // 1950, 1951: Tùng Bách Mộc
      "Thủy", "Thủy", // 1952, 1953: Trường Lưu Thủy
      "Kim", "Kim", // 1954, 1955: Sa Trung Kim
      "Hỏa", "Hỏa", // 1956, 1957: Sơn Hạ Hỏa
      "Mộc", "Mộc", // 1958, 1959: Bình Địa Mộc
      "Thổ", "Thổ", // 1960, 1961: Bích Thượng Thổ
      "Kim", "Kim", // 1962, 1963: Kim Bạch Kim
      "Hỏa", "Hỏa", // 1964, 1965: Phú Đăng Hỏa
      "Thủy", "Thủy", // 1966, 1967: Thiên Hà Thủy
      "Thổ", "Thổ", // 1968, 1969: Đại Trạch Thổ
      "Kim", "Kim", // 1970, 1971: Thoa Xuyến Kim
      "Mộc", "Mộc", // 1972, 1973: Tang Đố Mộc
      "Thủy", "Thủy", // 1974, 1975: Đại Khê Thủy
      "Thổ", "Thổ", // 1976, 1977: Sa Trung Thổ
      "Hỏa", "Hỏa", // 1978, 1979: Thiên Thượng Hỏa
      "Mộc", "Mộc", // 1980, 1981: Thạch Lựu Mộc
      "Thủy", "Thủy", // 1982, 1983: Đại Hải Thủy
    ];

    return elements[cycleIndex];
  }

  // Hàm xác định các mệnh hợp với mệnh của người dùng (dựa trên tương sinh)
  List<String> getCompatibleElements(String element) {
    List<String> compatibleElements = [element]; // Mệnh hợp với chính nó
    switch (element) {
      case "Kim":
        compatibleElements.add("Thủy"); // Kim sinh Thủy
        compatibleElements.add("Thổ"); // Thổ sinh Kim
        break;
      case "Thủy":
        compatibleElements.add("Mộc"); // Thủy sinh Mộc
        compatibleElements.add("Kim"); // Kim sinh Thủy
        break;
      case "Mộc":
        compatibleElements.add("Hỏa"); // Mộc sinh Hỏa
        compatibleElements.add("Thủy"); // Thủy sinh Mộc
        break;
      case "Hỏa":
        compatibleElements.add("Thổ"); // Hỏa sinh Thổ
        compatibleElements.add("Mộc"); // Mộc sinh Hỏa
        break;
      case "Thổ":
        compatibleElements.add("Kim"); // Thổ sinh Kim
        compatibleElements.add("Hỏa"); // Hỏa sinh Thổ
        break;
    }
    return compatibleElements;
  }

  // Hàm gợi ý cây phong thủy dựa trên mệnh
  Product recommendTree(String element) {
    final fengShuiProducts =
        products.where((product) => product.element != null).toList();

    // Tìm sản phẩm khớp với mệnh của người dùng
    Product? matchedProduct = fengShuiProducts.firstWhereOrNull(
      (product) => product.element == element,
    );

    if (matchedProduct != null) {
      return matchedProduct;
    }

    // Nếu không tìm thấy sản phẩm khớp với mệnh, tìm sản phẩm hợp với mệnh (dựa trên tương sinh)
    List<String> compatibleElements = getCompatibleElements(element);
    // Loại bỏ mệnh chính để tìm mệnh tương sinh
    compatibleElements.remove(element);

    for (String compatibleElement in compatibleElements) {
      Product? compatibleProduct = fengShuiProducts.firstWhereOrNull(
        (product) => product.element == compatibleElement,
      );
      if (compatibleProduct != null) {
        return compatibleProduct;
      }
    }

    // Nếu vẫn không tìm thấy, trả về sản phẩm mặc định
    return fengShuiProducts.isNotEmpty
        ? fengShuiProducts.first
        : Product(
            id: 0,
            name: "Không tìm thấy cây phù hợp",
            img: "",
            des: "Không có cây phong thủy phù hợp với mệnh của bạn.",
            price: 0,
            catId: "Không",
            catName: "Không xác định",
            rating: 0.0,
            sold: 0,
            reviews: 0,
          );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDayController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _predictFengShuiTree() {
    if (_birthDayController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập ngày sinh!")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Giả lập thời gian "phân tích phong thủy"
    Future.delayed(const Duration(seconds: 2), () {
      final dateParts = _birthDayController.text.split('/');
      final year = int.parse(dateParts[2]);
      final element = determineElement(year);
      final tree = recommendTree(element);

      if (mounted) {
        setState(() {
          userElement = element;
          recommendedTree = tree;
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Cây phong thủy của bạn đã được tìm thấy!")),
        );
      }
    });
  }

  @override
  void dispose() {
    _birthDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Đặt nền tổng thể thành xám nhạt
      appBar: AppBar(
        title: const Text("Tìm cây phong thủy"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Nhập ngày sinh để tìm cây phong thủy hợp mệnh!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _birthDayController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: "Ngày sinh",
                  prefixIcon: const Icon(Icons.date_range, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: isLoading ? null : _predictFengShuiTree,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Tìm cây phong thủy",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              if (userElement != null && recommendedTree != null) ...[
                Text(
                  "Mệnh của bạn: $userElement",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Mệnh của bạn hợp với: ${getCompatibleElements(userElement!).join(", ")}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Cây phong thủy hợp mệnh của bạn:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Sử dụng ConstrainedBox để giới hạn chiều cao tối đa của Card
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      // Điều hướng đến trang chi tiết sản phẩm
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailPage(product: recommendedTree!),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 6,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/images/${recommendedTree!.img}',
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image,
                                                size: 60),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                recommendedTree!.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                recommendedTree!.des,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black54),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              // Bottom chỉ chứa hai nút
                              Container(
                                height: 48,
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.favorite_border,
                                          color: Colors.red, size: 28),
                                      onPressed: () {
                                        Provider.of<ProductsVM>(context,
                                                listen: false)
                                            .toggleFavorite(recommendedTree!);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Đã thêm vào danh sách yêu thích!")),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 16),
                                    IconButton(
                                      icon: const Icon(Icons.add_shopping_cart,
                                          color: Colors.green, size: 28),
                                      onPressed: () {
                                        Provider.of<ProductsVM>(context,
                                                listen: false)
                                            .addToCart(recommendedTree!);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Đã thêm vào giỏ hàng!")),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
