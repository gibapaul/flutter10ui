import 'dart:convert';
import 'dart:io';
import 'package:app_json/app/data/sharepre.dart';
import 'package:app_json/app/model/cartcounter.dart';
import 'package:app_json/app/model/user.dart';
import 'package:app_json/app/page/defaultwidget.dart';
import 'package:app_json/app/page/detail.dart';
import 'package:app_json/app/page/home.dart';
import 'package:app_json/app/route/page1.dart';
import 'package:app_json/app/route/page2.dart';
import 'package:app_json/app/route/page3.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:app_json/app/page/product/productcart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:app_json/app/model/product_viewmodel.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  User user = User.userEmpty();
  int _selectedIndex = 0;

  Future<void> getDataUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String strUser = pref.getString('signup_info') ?? '';
    if (strUser.isNotEmpty) {
      if (mounted) {
        setState(() {
          user = User.fromJson(jsonDecode(strUser));
        });
      }
    } else {
      if (mounted) {
        setState(() {
          user = User.userEmpty();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getDataUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final int? initialIndex =
          ModalRoute.of(context)?.settings.arguments as int?;
      if (initialIndex != null) {
        setState(() {
          _selectedIndex = initialIndex;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getDataUser();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 3) {
      Future.delayed(Duration.zero, () {
        getDataUser();
      });
    }
  }

  Widget _loadWidget(int index) {
    switch (index) {
      case 0:
        return const Home();
      case 1:
        return const DefaultWidget(title: "Lịch sử");
      case 2:
        return const ProductCart();
      case 3:
        return const Detail();
      default:
        return const DefaultWidget(title: "Không có");
    }
  }

  Widget _buildAnimatedIcon(IconData icon, int index) {
    bool isActive = _selectedIndex == index;
    return AnimatedScale(
      scale: isActive ? 1.3 : 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutBack,
      child: Container(
        decoration: isActive
            ? BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.6),
                    blurRadius: 15,
                    spreadRadius: 3,
                  )
                ],
              )
            : null,
        child: Icon(
          icon,
          size: 30,
          color: isActive ? Colors.white : Colors.white70,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Xin chào',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  user.fullName ?? 'Khách',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Page1()),
              );
            },
          ),
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProductCart()),
                  );
                },
              ),
              const Positioned(
                right: 8,
                top: 8,
                child: CartCounter(),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green[800]!,
                    Colors.green[200]!,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 20,
                    left: 30,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    right: 40,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    right: 20,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.25),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.transparent,
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user.fullName ?? 'Khách',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Yêu thích'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Page1()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_florist),
              title: const Text('Tìm cây phong thủy'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Page2()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_in_ar),
              title: const Text('Xem 3D'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Page3()),
                );
              },
            ),
            const Divider(color: Colors.black),
            user.accountId == ''
                ? const SizedBox()
                : ListTile(
                    leading: const Icon(Icons.exit_to_app),
                    title: const Text(
                      'Đăng xuất',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      logOut(context);
                    },
                  ),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 65.0,
        items: <Widget>[
          _buildAnimatedIcon(Icons.home, 0),
          _buildAnimatedIcon(Icons.history, 1),
          _buildAnimatedIcon(Icons.shopping_cart, 2),
          _buildAnimatedIcon(Icons.person, 3),
        ],
        color: Colors.green.shade300,
        buttonBackgroundColor: Colors.green.shade600,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 500),
        onTap: _onItemTapped,
        letIndexChange: (index) => true,
      ),
      body: Consumer<ProductsVM>(
        builder: (context, provider, child) {
          return _loadWidget(_selectedIndex);
        },
      ),
    );
  }
}
