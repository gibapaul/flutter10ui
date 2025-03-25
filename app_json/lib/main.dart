import 'package:app_json/app/page/auth/login.dart';
import 'package:app_json/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_json/app/model/product_viewmodel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => ProductsVM()), // Khởi tạo ViewModel
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // Đặt route ban đầu là /login
      routes: {
        '/login': (context) =>
            const LoginScreen(), // Route cho màn hình đăng nhập
        '/mainpage': (context) => const Mainpage(), // Route cho Mainpage
      },
      onGenerateRoute: (settings) {
        // Xử lý các route động nếu cần
        if (settings.name == '/mainpage') {
          final int? index = settings.arguments as int?;
          return MaterialPageRoute(
            builder: (context) => const Mainpage(),
            settings: RouteSettings(arguments: index),
          );
        }
        return null;
      },
      onUnknownRoute: (settings) {
        // Xử lý route không xác định
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text("Route không tồn tại")),
          ),
        );
      },
    );
  }
}
