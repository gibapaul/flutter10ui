import 'dart:io';
import 'package:app_json/app/model/register.dart';
import 'package:app_json/app/page/auth/login.dart';
import 'package:app_json/app/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  int _gender = 0;
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _numberIDController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _schoolKeyController = TextEditingController();
  final TextEditingController _schoolYearController = TextEditingController();
  final TextEditingController _birthDayController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  bool _isLoading = false;
  File? _selectedImage; // Lưu trữ file ảnh đã chọn
  String? _imagePath; // Đường dẫn ảnh
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _progressAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _pageController.addListener(() {
      final page = _pageController.page ?? 0;
      if (mounted) {
        setState(() {
          _currentStep = page.round();
        });
      }
      _animationController.animateTo(_currentStep == 0 ? 0.5 : 1.0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _accountController.dispose();
    _fullNameController.dispose();
    _numberIDController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneNumberController.dispose();
    _schoolKeyController.dispose();
    _schoolYearController.dispose();
    _birthDayController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (!mounted) return; // Kiểm tra trước khi gọi setState
    setState(() {
      _isLoading = true;
    });

    try {
      final signup = Signup(
        accountID: _accountController.text,
        birthDay: _birthDayController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        fullName: _fullNameController.text,
        phoneNumber: _phoneNumberController.text,
        schoolKey: _schoolKeyController.text,
        schoolYear: _schoolYearController.text,
        gender: getGender(),
        imageUrl: _imagePath ?? '', // Sử dụng đường dẫn ảnh
        numberID: _numberIDController.text,
      );

      // Lưu thông tin đăng ký cục bộ
      await saveSignupInfo(signup);

      // Điều hướng đến màn hình đăng nhập
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đăng ký thành công! Vui lòng đăng nhập."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi trong quá trình đăng ký: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String getGender() {
    if (_gender == 1) {
      return "Nam";
    } else if (_gender == 2) {
      return "Nữ";
    }
    return "Khác";
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
    if (picked != null && mounted) {
      setState(() {
        _birthDayController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // Hàm chọn ảnh từ thư viện hoặc camera
  Future<void> _pickImage(ImageSource source) async {
    // Kiểm tra quyền tương ứng
    Permission permission;
    String permissionName; // Tên quyền để hiển thị trong thông báo
    if (source == ImageSource.camera) {
      permission = Permission.camera;
      permissionName = "camera";
    } else {
      permission = Permission.photos; // Hoặc Permission.storage cho Android cũ
      permissionName = "thư viện ảnh";
    }

    // Kiểm tra trạng thái quyền
    var status = await permission.status;
    print("Trạng thái quyền $permissionName trước khi yêu cầu: $status");

    // Nếu quyền chưa được cấp hoặc chỉ được cấp một phần (limited)
    if (!(status.isGranted || status.isLimited)) {
      // Yêu cầu quyền
      status = await permission.request();
      print("Trạng thái quyền $permissionName sau khi yêu cầu: $status");

      // Nếu quyền vẫn không được cấp, hiển thị thông báo
      if (!(status.isGranted || status.isLimited) && mounted) {
        final String message = status.isPermanentlyDenied
            ? 'Quyền truy cập $permissionName bị từ chối vĩnh viễn. Vui lòng cấp quyền trong cài đặt.'
            : 'Quyền truy cập $permissionName bị từ chối. Vui lòng cấp quyền để tiếp tục.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Cấp quyền',
              textColor: Colors.white,
              onPressed: () async {
                // Mở cài đặt ứng dụng
                bool opened = await openAppSettings();
                if (opened && mounted) {
                  // Kiểm tra lại trạng thái quyền sau khi quay lại từ cài đặt
                  status = await permission.status;
                  print(
                      "Trạng thái quyền $permissionName sau khi quay lại từ cài đặt: $status");
                  if (status.isGranted || status.isLimited) {
                    // Nếu quyền đã được cấp hoặc cấp một phần, thử chọn ảnh lại
                    await _pickImage(source);
                  }
                }
              },
            ),
          ),
        );
        return; // Thoát hàm nếu quyền không được cấp
      }
    }

    // Nếu quyền đã được cấp hoặc cấp một phần, tiến hành chọn ảnh
    if (status.isGranted || status.isLimited) {
      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 300,
          maxHeight: 300,
          imageQuality: 85,
        );

        if (pickedFile != null && mounted) {
          // Lưu ảnh vào thư mục ứng dụng
          final directory = await getApplicationDocumentsDirectory();
          final String path =
              '${directory.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final File newImage = await File(pickedFile.path).copy(path);

          setState(() {
            _selectedImage = newImage;
            _imagePath = path;
          });
        } else if (pickedFile == null && mounted) {
          // Nếu người dùng không chọn ảnh (hủy), không hiển thị lỗi
          print("Người dùng đã hủy chọn ảnh.");
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi chọn ảnh: $e')),
          );
        }
      }
    }
  }

  // Hiển thị dialog chọn nguồn ảnh
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh mới'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Color.fromRGBO(76, 175, 80, 0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(76, 175, 80, 0.1),
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
                color: Color.fromRGBO(76, 175, 80, 0.2),
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
                color: Color.fromRGBO(76, 175, 80, 0.15),
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
                color: Color.fromRGBO(76, 175, 80, 0.1),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image, size: 80),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Đăng ký tài khoản",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Text(
                        "Bước ${_currentStep + 1} / 2",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Container(
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey.shade300,
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _progressAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.green,
                                      Colors.lightGreen,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      buildStep1(),
                      buildStep2(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      "Đã có tài khoản? Đăng nhập ngay",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeyStep1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.person, color: Colors.green, size: 18),
                SizedBox(width: 8),
                Text(
                  "Thông tin người dùng",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            textField(
              _fullNameController,
              "Họ và tên",
              Icons.text_fields_outlined,
            ),
            textField(
              _birthDayController,
              "Ngày sinh",
              Icons.date_range,
              onTap: () => _selectDate(context),
              readOnly: true,
            ),
            textField(_phoneNumberController, "Số điện thoại", Icons.phone),
            const SizedBox(height: 24),
            Row(
              children: const [
                Icon(Icons.transgender, color: Colors.green, size: 18),
                SizedBox(width: 8),
                Text(
                  "Giới tính",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _customIconButton("Nam", 1, Icons.male),
                _customIconButton("Nữ", 2, Icons.female),
                _customIconButton("Khác", 3, Icons.transgender),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                  backgroundColor: Colors.transparent,
                  shadowColor: Color.fromRGBO(76, 175, 80, 0.3),
                ).copyWith(
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (states) => Colors.transparent,
                  ),
                  foregroundColor: WidgetStateProperty.resolveWith(
                    (states) => Colors.white,
                  ),
                  overlayColor: WidgetStateProperty.resolveWith(
                    (states) => Color.fromRGBO(255, 255, 255, 0.1),
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Center(
                    child: Text(
                      "Tiếp tục",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStep2() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKeyStep2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.lock, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Thông tin tài khoản",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              textField(
                _accountController,
                "Tên tài khoản",
                Icons.person,
              ),
              textField(_numberIDController, "Mã số", Icons.key),
              textField(
                _passwordController,
                "Mật khẩu",
                Icons.lock,
                obscureText: _obscurePassword,
              ),
              textField(
                _confirmPasswordController,
                "Xác nhận mật khẩu",
                Icons.lock,
                obscureText: _obscureConfirmPassword,
              ),
              const SizedBox(height: 24),
              Row(
                children: const [
                  Icon(Icons.school, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Thông tin trường học",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              textField(_schoolYearController, "Năm học", Icons.school),
              textField(_schoolKeyController, "Mã trường", Icons.school),
              const SizedBox(height: 24),
              Row(
                children: const [
                  Icon(Icons.image, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Ảnh đại diện",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Thay thế TextField nhập URL bằng nút chọn ảnh
              Row(
                children: [
                  // Hiển thị ảnh đã chọn (nếu có)
                  _selectedImage != null
                      ? Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade200,
                          ),
                          child: const Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 30,
                          ),
                        ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showImageSourceDialog,
                      icon: const Icon(Icons.upload),
                      label: const Text("Chọn ảnh"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.green),
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                      ),
                      child: const Text(
                        "Quay lại",
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              await register();
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        backgroundColor: Colors.transparent,
                        shadowColor: Color.fromRGBO(76, 175, 80, 0.3),
                      ).copyWith(
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.transparent,
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith(
                          (states) => Colors.white,
                        ),
                        overlayColor: WidgetStateProperty.resolveWith(
                          (states) => Color.fromRGBO(255, 255, 255, 0.1),
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Đăng ký",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget textField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    bool isRequired = false,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          onTap: onTap,
          readOnly: readOnly,
          decoration: InputDecoration(
            label: Text(label),
            labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            floatingLabelStyle: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: label.toLowerCase().contains('mật khẩu')
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                    ),
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          if (label.toLowerCase() == "mật khẩu") {
                            _obscurePassword = !_obscurePassword;
                          } else if (label.toLowerCase() ==
                              "xác nhận mật khẩu") {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          }
                        });
                      }
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
            prefixIconColor: WidgetStateColor.resolveWith((states) =>
                states.contains(WidgetState.focused)
                    ? Colors.green
                    : Colors.black54),
            suffixIconColor: label.toLowerCase().contains('mật khẩu')
                ? WidgetStateColor.resolveWith((states) =>
                    states.contains(WidgetState.focused)
                        ? Colors.green
                        : Colors.black54)
                : null,
          ).copyWithFillColor(
              focusedFillColor: Color.fromRGBO(76, 175, 80, 0.05)),
        ),
      ),
    );
  }

  Widget _customIconButton(String title, int value, IconData icon) {
    bool isSelected = _gender == value;
    return GestureDetector(
      onTap: () {
        if (mounted) {
          setState(() {
            _gender = value;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              border: Border.all(
                color: isSelected ? Colors.green : Colors.grey,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.green : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.green : Colors.black87,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
