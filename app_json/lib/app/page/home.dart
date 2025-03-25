import 'package:app_json/app/model/category.dart';
import 'package:app_json/app/model/product.dart';
import 'package:app_json/app/page/product/productdetail.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:app_json/app/model/product_viewmodel.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  List<CategoryModel> categories = [];
  String selectedCategory = "Tất cả";
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> promotions = [
    {
      'icon': Icons.flash_on,
      'name': 'Khuyến Mãi',
    },
    {
      'icon': Icons.star,
      'name': 'Ưu Đãi',
    },
    {
      'icon': Icons.local_shipping,
      'name': 'Vận Chuyển',
    },
    {
      'icon': Icons.eco,
      'name': 'Thân Thiện',
    },
  ];

  @override
  void initState() {
    super.initState();
    loadCategories();
    loadProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged); // Hủy listener
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadCategories() async {
    try {
      final String response =
          await rootBundle.loadString('assets/json/categories.json');
      final List<dynamic> data = jsonDecode(response);
      if (mounted) {
        // Kiểm tra mounted trước khi gọi setState
        setState(() {
          categories =
              data.map((json) => CategoryModel.fromJson(json)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh mục: $e')),
        );
      }
    }
  }

  Future<void> loadProducts() async {
    try {
      if (!mounted) return; // Kiểm tra trước khi gọi setState
      setState(() {
        isLoading = true;
      });

      final String response =
          await rootBundle.loadString('assets/json/data.json');
      final List<dynamic> data = jsonDecode(response);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        // Kiểm tra mounted trước khi gọi setState
        setState(() {
          products = data.map((json) => Product.fromJson(json)).toList();
          filteredProducts = products;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải sản phẩm: $e')),
        );
      }
    }
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    if (mounted) {
      // Kiểm tra mounted trước khi gọi setState
      setState(() {
        if (query.isEmpty) {
          filteredProducts = products;
        } else {
          filteredProducts = products
              .where((product) => product.name.toLowerCase().contains(query))
              .toList();
        }
      });
    }
  }

  void filterProductsByCategory(String category) {
    if (mounted) {
      // Kiểm tra mounted trước khi gọi setState
      setState(() {
        if (selectedCategory == category) {
          // Nếu danh mục được chọn lại, không làm gì
          return;
        }
        selectedCategory = category;
        if (category == "Tất cả") {
          filteredProducts = products;
        } else {
          filteredProducts =
              products.where((product) => product.catName == category).toList();
        }
      });
    }
  }

  Widget shimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 4),
            Container(
              height: 12,
              width: 40,
              color: Colors.white,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 16,
                  width: 40,
                  color: Colors.white,
                ),
                Container(
                  height: 20,
                  width: 20,
                  color: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatPrice(double price) {
    double vndPrice = price * 1000;
    String formattedPrice = vndPrice.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return '$formattedPrice đ';
  }

  Widget mostPopularItem(Product product) {
    return Consumer<ProductsVM>(
      builder: (context, provider, child) {
        bool isFavorite = provider.isFavorite(product);
        return GestureDetector(
          onTap: () {
            // Điều hướng đến ProductDetailPage khi nhấn vào sản phẩm
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(product: product),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/${product.img}',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 60),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.green,
                          size: 24,
                        ),
                        onPressed: () {
                          provider.toggleFavorite(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isFavorite
                                    ? '${product.name} đã được xóa khỏi danh sách yêu thích!'
                                    : '${product.name} đã được thêm vào danh sách yêu thích!',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${product.rating} | ${product.sold} Đã bán',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatPrice(product.price.toDouble()),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.add_shopping_cart,
                              color: Colors.green,
                              size: 22,
                            ),
                            onPressed: () {
                              Provider.of<ProductsVM>(context, listen: false)
                                  .addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${product.name} đã được thêm vào giỏ hàng!'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCircle(CategoryModel category) {
    return GestureDetector(
      onTap: () {
        filterProductsByCategory(category.name);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.green,
                  width: 2.0,
                ),
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('assets/images/${category.img}'),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionItem(IconData icon, String name) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 30,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFilterCategoryCircle(String category, bool isSelected) {
    return GestureDetector(
      onTap: () {
        filterProductsByCategory(category);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          width: 70,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.green.withOpacity(0.2)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.green : Colors.black,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  void _showSortFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sắp xếp & Lọc',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Danh mục',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterCategoryCircle(
                              'Tất cả', selectedCategory == 'Tất cả'),
                          ...categories.map((category) =>
                              _buildFilterCategoryCircle(category.name,
                                  selectedCategory == category.name)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Khoảng giá',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    RangeSlider(
                      values: const RangeValues(10, 50),
                      min: 0,
                      max: 200,
                      divisions: 20,
                      labels: RangeLabels(
                        formatPrice(10),
                        formatPrice(50),
                      ),
                      onChanged: (RangeValues values) {
                        // Xử lý thay đổi giá
                      },
                      activeColor: Colors.green,
                      inactiveColor: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sắp xếp theo',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterButton('Phổ biến', false),
                          _buildFilterButton('Mới nhất', true),
                          _buildFilterButton('Giá cao', false),
                          _buildFilterButton('Giá thấp', false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Đánh giá',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterButton('Tất cả', true),
                          _buildFilterButton('5', false),
                          _buildFilterButton('4', false),
                          _buildFilterButton('3', false),
                          _buildFilterButton('2', false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Đặt lại'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Áp dụng'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterButton(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.green : Colors.grey.shade200,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Tìm kiếm",
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 20.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.black),
                    onPressed: () {
                      _showSortFilterDialog(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: Row(
                  children: promotions.map((promotion) {
                    return Expanded(
                      child: _buildPromotionItem(
                        promotion['icon'],
                        promotion['name'],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Danh mục',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _buildCategoryCircle(category);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sản phẩm',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      filterProductsByCategory("Tất cả");
                    },
                    child: Text(
                      'Tất cả',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.55,
                ),
                itemCount: isLoading ? 4 : filteredProducts.length,
                itemBuilder: (context, index) {
                  if (isLoading) {
                    return shimmerItem();
                  }
                  final product = filteredProducts[index];
                  return mostPopularItem(product);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
