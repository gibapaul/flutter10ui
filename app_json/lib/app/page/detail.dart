import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../model/user.dart';
import '../model/register.dart';
import '../data/sharepre.dart'; // Import để sử dụng logOut

class Detail extends StatefulWidget {
  const Detail({super.key});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  User user = User.userEmpty();
  bool isLoading = true;

  // Các controller để chỉnh sửa thông tin
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _birthDayController = TextEditingController();
  final TextEditingController _schoolYearController = TextEditingController();
  final TextEditingController _schoolKeyController = TextEditingController();
  File? _selectedImage; // Lưu trữ file ảnh đã chọn
  String? _imagePath; // Đường dẫn ảnh (lưu trữ lâu dài)
  final ImagePicker _picker = ImagePicker();

  Future<void> getDataUser() async {
    if (!mounted) return; // Kiểm tra trước khi gọi setState
    setState(() {
      isLoading = true;
    });

    try {
      Signup? signup = await getSignupInfo();
      if (signup != null) {
        user = User(
          status: true,
          accountId: signup.accountID,
          idNumber: signup.numberID,
          fullName: signup.fullName,
          phoneNumber: signup.phoneNumber,
          gender: signup.gender,
          birthDay: signup.birthDay,
          schoolYear: signup.schoolYear,
          schoolKey: signup.schoolKey,
          imageURL: signup.imageUrl,
          dateCreated: DateTime.now().toString(),
        );
        // Khởi tạo giá trị cho các controller
        _fullNameController.text = user.fullName ?? '';
        _phoneNumberController.text = user.phoneNumber ?? '';
        _birthDayController.text = user.birthDay ?? '';
        _schoolYearController.text = user.schoolYear ?? '';
        _schoolKeyController.text = user.schoolKey ?? '';
        // Khởi tạo ảnh đã lưu (nếu có)
        if (user.imageURL != null && user.imageURL!.isNotEmpty) {
          _imagePath = user.imageURL;
          if (await File(user.imageURL!).exists()) {
            _selectedImage = File(user.imageURL!);
          }
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Không thể tải thông tin người dùng!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi khi tải thông tin: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getDataUser();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _birthDayController.dispose();
    _schoolYearController.dispose();
    _schoolKeyController.dispose();
    super.dispose();
  }

  // Hàm chọn ngày sinh
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

  // Hàm hiển thị dialog chỉnh sửa thông tin
  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Chỉnh sửa thông tin"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  controller: _fullNameController,
                  label: "Họ và tên",
                  icon: Icons.person,
                ),
                _buildTextField(
                  controller: _phoneNumberController,
                  label: "Số điện thoại",
                  icon: Icons.phone,
                ),
                _buildTextField(
                  controller: _birthDayController,
                  label: "Ngày sinh",
                  icon: Icons.date_range,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
                _buildTextField(
                  controller: _schoolYearController,
                  label: "Năm học",
                  icon: Icons.school,
                ),
                _buildTextField(
                  controller: _schoolKeyController,
                  label: "Mã trường",
                  icon: Icons.vpn_key,
                ),
                // Thay thế TextField nhập URL bằng nút chọn ảnh
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ảnh đại diện",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Hủy",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Cập nhật thông tin người dùng
                if (mounted) {
                  setState(() {
                    user = User(
                      status: user.status,
                      accountId: user.accountId,
                      idNumber: user.idNumber,
                      fullName: _fullNameController.text,
                      phoneNumber: _phoneNumberController.text,
                      gender: user.gender,
                      birthDay: _birthDayController.text,
                      schoolYear: _schoolYearController.text,
                      schoolKey: _schoolKeyController.text,
                      imageURL: _imagePath ??
                          user.imageURL, // Sử dụng đường dẫn ảnh mới
                      dateCreated: user.dateCreated,
                    );
                  });
                }

                // Lưu thông tin đã chỉnh sửa vào SharedPreferences
                final signup = Signup(
                  accountID: user.accountId!,
                  numberID: user.idNumber!,
                  fullName: user.fullName!,
                  phoneNumber: user.phoneNumber!,
                  gender: user.gender!,
                  birthDay: user.birthDay!,
                  schoolYear: user.schoolYear!,
                  schoolKey: user.schoolKey!,
                  imageUrl: user.imageURL!,
                  password: '',
                  confirmPassword: '',
                );
                await saveSignupInfo(signup);

                Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Cập nhật thông tin thành công!"),
                      backgroundColor: Colors.green,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Ảnh đại diện và nút chỉnh sửa
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: user.imageURL != null &&
                                user.imageURL!.isNotEmpty &&
                                File(user.imageURL!).existsSync()
                            ? FileImage(File(user.imageURL!))
                            : const AssetImage('assets/images/user.png')
                                as ImageProvider,
                        backgroundColor: Colors.grey.shade200,
                        child: user.imageURL == null || user.imageURL!.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showEditDialog,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tên người dùng
                  Text(
                    user.fullName ?? 'Không có tên',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Thông tin chi tiết
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoTile(
                            icon: Icons.key,
                            title: "Mã số",
                            value: user.idNumber ?? 'Không có',
                          ),
                          _buildInfoTile(
                            icon: Icons.phone,
                            title: "Số điện thoại",
                            value: user.phoneNumber ?? 'Không có',
                          ),
                          _buildInfoTile(
                            icon: Icons.transgender,
                            title: "Giới tính",
                            value: user.gender ?? 'Không có',
                          ),
                          _buildInfoTile(
                            icon: Icons.cake,
                            title: "Ngày sinh",
                            value: user.birthDay ?? 'Không có',
                          ),
                          _buildInfoTile(
                            icon: Icons.school,
                            title: "Năm học",
                            value: user.schoolYear ?? 'Không có',
                          ),
                          _buildInfoTile(
                            icon: Icons.vpn_key,
                            title: "Mã trường",
                            value: user.schoolKey ?? 'Không có',
                          ),
                          _buildInfoTile(
                            icon: Icons.calendar_today,
                            title: "Ngày tạo",
                            value: user.dateCreated ?? 'Không có',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Nút đăng xuất
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        logOut(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Đăng xuất",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Widget để hiển thị một mục thông tin
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.green.shade700,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget để tạo TextField trong dialog chỉnh sửa
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
        ),
      ),
    );
  }
}
