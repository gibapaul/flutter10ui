import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_json/app/model/product_viewmodel.dart';

class CartCounter extends StatelessWidget {
  const CartCounter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsVM>(
      builder: (context, value, child) {
        int totalItems = value.lst.fold(0, (sum, item) => sum + item.quantity);
        // Đếm tổng số lượng sản phẩm trong giỏ

        return Container(
          height: 18,
          width: 18,
          decoration: BoxDecoration(
            color: Colors.red[800],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              totalItems.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        );
      },
    );
  }
}
