// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:app_json/app/page/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user.dart';

Future<bool> saveUser(User objUser) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String strUser = jsonEncode(objUser.toJson());
    await prefs.setString('user', strUser);
    print("Lưu thành công: $strUser");
    return true;
  } catch (e) {
    print("Lỗi khi lưu user: $e");
    return false;
  }
}

Future<bool> logOut(BuildContext context) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user'); // Chỉ xóa thông tin người dùng
    print("Logout thành công");

    // Đảm bảo điều hướng được thực hiện trên main thread
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    });
    return true;
  } catch (e) {
    print("Lỗi khi logout: $e");
    return false;
  }
}

Future<bool> deleteAccount(BuildContext context) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Xóa toàn bộ dữ liệu trong SharedPreferences
    print("Xóa tài khoản thành công");

    // Đảm bảo điều hướng được thực hiện trên main thread
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    });
    return true;
  } catch (e) {
    print("Lỗi khi xóa tài khoản: $e");
    return false;
  }
}

Future<User> getUser() async {
  try {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? strUser = pref.getString('user');
    if (strUser == null || strUser.isEmpty) {
      print("Không tìm thấy user trong SharedPreferences, trả về user rỗng");
      return User.userEmpty();
    }
    return User.fromJson(jsonDecode(strUser));
  } catch (e) {
    print("Lỗi khi lấy user: $e");
    return User.userEmpty();
  }
}
