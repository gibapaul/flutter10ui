import 'dart:convert';
import 'package:app_json/app/model/product_viewmodel.dart';
import 'package:app_json/app/model/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> items; // Danh sách sản phẩm cần thanh toán
  final double totalPrice; // Tổng tiền

  const CheckoutPage({
    super.key,
    required this.items,
    required this.totalPrice,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _paymentMethod =
      'Thanh toán khi nhận hàng'; // Phương thức thanh toán mặc định
  String? _selectedAddress; // Địa chỉ được chọn
  List<String> _addresses = []; // Danh sách địa chỉ
  User user = User.userEmpty(); // Thông tin người dùng
  final TextEditingController _addressController =
      TextEditingController(); // Controller để nhập địa chỉ

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  // Hàm tải thông tin người dùng và địa chỉ
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? strUser = prefs.getString('signup_info');
    if (strUser != null && strUser.isNotEmpty) {
      setState(() {
        user = User.fromJson(jsonDecode(strUser));
      });

      // Lấy danh sách địa chỉ từ SharedPreferences (nếu có)
      List<String>? savedAddresses = prefs.getStringList('user_addresses');
      if (savedAddresses != null && savedAddresses.isNotEmpty) {
        setState(() {
          _addresses = savedAddresses;
          _selectedAddress =
              _addresses[0]; // Chọn địa chỉ đầu tiên làm mặc định
        });
      } else {
        // Nếu không có địa chỉ, yêu cầu người dùng thêm
        setState(() {
          _addresses = [];
          _selectedAddress = null;
        });
      }
    }
  }

  // Hàm lưu địa chỉ mới vào SharedPreferences
  Future<void> _saveAddress(String newAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _addresses.add(newAddress);
      _selectedAddress = newAddress;
    });
    await prefs.setStringList('user_addresses', _addresses);
  }

  // Hàm cập nhật địa chỉ đã chọn
  Future<void> _updateAddress(String updatedAddress, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _addresses[index] = updatedAddress;
      _selectedAddress = updatedAddress;
    });
    await prefs.setStringList('user_addresses', _addresses);
  }

  // Hàm hiển thị dialog để thêm/sửa địa chỉ
  void _showAddressDialog({String? existingAddress, int? index}) {
    if (existingAddress != null) {
      _addressController.text = existingAddress;
    } else {
      _addressController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingAddress == null ? "Thêm địa chỉ" : "Sửa địa chỉ"),
          content: TextField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: "Địa chỉ",
              prefixIcon: const Icon(Icons.location_on, color: Colors.green),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _addressController.clear();
              },
              child: const Text(
                "Hủy",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_addressController.text.isNotEmpty) {
                  if (existingAddress == null) {
                    // Thêm địa chỉ mới
                    await _saveAddress(_addressController.text);
                  } else {
                    // Sửa địa chỉ hiện tại
                    await _updateAddress(_addressController.text, index!);
                  }
                  Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(existingAddress == null
                            ? "Đã thêm địa chỉ thành công!"
                            : "Đã cập nhật địa chỉ thành công!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Vui lòng nhập địa chỉ!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  // Hàm định dạng giá tiền
  String formatPrice(double price) {
    String formattedPrice = price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return '$formattedPrice VNĐ';
  }

  // Hàm xử lý thanh toán
  void _processPayment(BuildContext context) {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng thêm địa chỉ giao hàng!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Giả lập quá trình thanh toán
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Đang xử lý thanh toán..."),
          ],
        ),
      ),
    );

    // Giả lập thời gian xử lý thanh toán
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Đóng dialog

      // Tạo đơn hàng mới
      final order = Order(
        items: widget.items,
        totalPrice: widget.totalPrice,
        orderDate: DateTime.now(),
        address: _selectedAddress!, // Sử dụng địa chỉ đã chọn
        paymentMethod: _paymentMethod,
      );

      // Lưu đơn hàng vào lịch sử
      Provider.of<ProductsVM>(context, listen: false).addOrder(order);

      // Xóa giỏ hàng nếu thanh toán từ giỏ hàng
      if (widget.items.length ==
          Provider.of<ProductsVM>(context, listen: false).lst.length) {
        Provider.of<ProductsVM>(context, listen: false).clearCart();
      }

      // Hiển thị thông báo đặt hàng thành công
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.only(top: 20),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image, size: 100),
                ),
              ),
              const SizedBox(height: 20),
              // Tiêu đề "Đặt hàng thành công!" với gradient
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.green, Colors.lightGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    "Đặt hàng thành công!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Dòng chữ phụ
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  "Cảm ơn bạn đã mua hàng. Đơn hàng của bạn đã được ghi nhận.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Nút "OK" với hiệu ứng ombre
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                width: 120,
                child: ElevatedButton(
                  onPressed: () {
                    // Quay lại trang Home
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/mainpage',
                      (route) => false,
                      arguments: 0, // Chuyển về tab Home (index 0)
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.green.withOpacity(0.3),
                  ).copyWith(
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => Colors.transparent,
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith(
                      (states) => Colors.white,
                    ),
                    overlayColor: WidgetStateProperty.resolveWith(
                      (states) => Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.green, Colors.lightGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Center(
                      child: Text(
                        "OK",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Địa chỉ giao hàng
            const Text(
              "Địa chỉ giao hàng",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _addresses.isEmpty
                ? Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Bạn chưa có địa chỉ giao hàng. Vui lòng thêm địa chỉ!",
                          style: TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _showAddressDialog(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Thêm địa chỉ"),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedAddress,
                          onChanged: (value) {
                            setState(() {
                              _selectedAddress = value!;
                            });
                          },
                          items: _addresses.map((address) {
                            return DropdownMenuItem(
                              value: address,
                              child: Text(address),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Colors.green, width: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () {
                          int index = _addresses.indexOf(_selectedAddress!);
                          _showAddressDialog(
                              existingAddress: _selectedAddress, index: index);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.green),
                        onPressed: () => _showAddressDialog(),
                      ),
                    ],
                  ),
            const SizedBox(height: 24),

            // Phương thức thanh toán
            const Text(
              "Phương thức thanh toán",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
              items: const [
                DropdownMenuItem(
                  value: "Thanh toán khi nhận hàng",
                  child: Text("Thanh toán khi nhận hàng"),
                ),
                DropdownMenuItem(
                  value: "Chuyển khoản ngân hàng",
                  child: Text("Chuyển khoản ngân hàng"),
                ),
                DropdownMenuItem(
                  value: "Thanh toán qua MoMo",
                  child: Text("Thanh toán qua MoMo"),
                ),
              ],
              decoration: InputDecoration(
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

            // Danh sách sản phẩm
            const Text(
              "Sản phẩm",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Image.asset(
                      'assets/images/${item.product.img}',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 50),
                    ),
                    title: Text(
                      item.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${formatPrice(item.product.price.toDouble() * 1000)} x ${item.quantity}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    trailing: Text(
                      formatPrice(
                          item.product.price.toDouble() * 1000 * item.quantity),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Tổng tiền
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Tổng tiền:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  formatPrice(widget.totalPrice),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Nút thanh toán
            Center(
              child: ElevatedButton(
                onPressed: () => _processPayment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                  shadowColor: Colors.green.withOpacity(0.5),
                ),
                child: const Text(
                  "Xác nhận thanh toán",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
