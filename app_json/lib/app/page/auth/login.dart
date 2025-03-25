import 'package:app_json/app/page/register.dart';
import 'package:app_json/app/utils/extensions.dart'; // Import extension
import 'package:flutter/material.dart';
import 'package:app_json/app/model/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController accountController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSignupInfo();
  }

  // Tải thông tin đăng nhập đã lưu (nếu có)
  Future<void> _loadSignupInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool('remember_me') ?? false;
    if (rememberMe) {
      String? savedUsername = prefs.getString(
          'saved_username'); // Đổi từ saved_email thành saved_username
      String? savedPassword = prefs.getString('saved_password');
      if (savedUsername != null && savedPassword != null) {
        accountController.text = savedUsername;
        passwordController.text = savedPassword;
        setState(() {
          _rememberMe = true;
        });
      }
    }

    // Kiểm tra thông tin đăng ký
    Signup? signup = await getSignupInfo();
    if (signup != null && rememberMe) {
      accountController.text = signup.accountID ?? '';
      passwordController.text = signup.password ?? '';
    }
  }

  // Lưu thông tin đăng nhập nếu người dùng chọn "Lưu đăng nhập"
  Future<void> _saveLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('saved_username',
          accountController.text); // Đổi từ saved_email thành saved_username
      await prefs.setString('saved_password', passwordController.text);
    } else {
      await prefs.remove('remember_me');
      await prefs
          .remove('saved_username'); // Đổi từ saved_email thành saved_username
      await prefs.remove('saved_password');
    }
  }

  Future<void> login() async {
    Signup? signup = await getSignupInfo();
    if (signup != null) {
      if (signup.accountID == accountController.text &&
          signup.password == passwordController.text) {
        // Lưu thông tin đăng nhập nếu người dùng chọn "Lưu đăng nhập"
        await _saveLoginInfo();

        // Điều hướng đến Mainpage
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/mainpage',
            (route) => false,
            arguments: 0, // Chuyển về tab Home (index 0)
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Tên người dùng hoặc mật khẩu không đúng!"), // Đổi thông báo lỗi
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tài khoản không tồn tại! Vui lòng đăng ký."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Nền trắng
          Container(
            color: Colors.white,
          ),
          // Hình tròn trang trí ở các góc
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromRGBO(76, 175, 80, 0.1),
              ),
            ),
          ),
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromRGBO(76, 175, 80, 0.2),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromRGBO(76, 175, 80, 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromRGBO(76, 175, 80, 0.1),
              ),
            ),
          ),
          // Nội dung chính
          SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image, size: 120),
                  ),
                  const SizedBox(height: 30),
                  // Tiêu đề
                  const Text(
                    "Đăng nhập tài khoản",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Trường Tên người dùng
                  TextFormField(
                    controller: accountController,
                    decoration: InputDecoration(
                      labelText:
                          "Tên người dùng", // Đổi từ "Email" thành "Tên người dùng"
                      labelStyle: TextStyle(color: Colors.grey.shade600),
                      floatingLabelStyle: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: const Icon(Icons
                          .person), // Đổi từ Icons.email thành Icons.person
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2),
                      ),
                      prefixIconColor: WidgetStateColor.resolveWith((states) =>
                          states.contains(WidgetState.focused)
                              ? Colors.green
                              : Colors.black54),
                    ).copyWithFillColor(
                        focusedFillColor:
                            const Color.fromRGBO(76, 175, 80, 0.05)),
                  ),
                  const SizedBox(height: 16),
                  // Trường Password
                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu",
                      labelStyle: TextStyle(color: Colors.grey.shade600),
                      floatingLabelStyle: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2),
                      ),
                      prefixIconColor: WidgetStateColor.resolveWith((states) =>
                          states.contains(WidgetState.focused)
                              ? Colors.green
                              : Colors.black54),
                      suffixIconColor: WidgetStateColor.resolveWith((states) =>
                          states.contains(WidgetState.focused)
                              ? Colors.green
                              : Colors.black54),
                    ).copyWithFillColor(
                        focusedFillColor:
                            const Color.fromRGBO(76, 175, 80, 0.05)),
                  ),
                  const SizedBox(height: 16),
                  // Checkbox "Remember me" - Căn giữa
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: Colors.green,
                        checkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Text(
                        "Lưu đăng nhập",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Nút "Sign in" với hiệu ứng ombre
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        backgroundColor: Colors.transparent,
                        shadowColor: const Color.fromRGBO(76, 175, 80, 0.3),
                      ).copyWith(
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.transparent,
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.white,
                        ),
                        overlayColor: WidgetStateProperty.resolveWith(
                          (states) => const Color.fromRGBO(255, 255, 255, 0.1),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.green,
                              Colors.lightGreen,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Center(
                          child: Text(
                            "Đăng nhập",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Liên kết "Sign up"
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Register()),
                      );
                    },
                    child: const Text(
                      "Nếu chưa có tài khoản? Đăng ký nhé!",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
