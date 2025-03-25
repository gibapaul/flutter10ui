import 'package:app_json/app/model/register.dart';
import 'package:app_json/app/model/user.dart';
import 'package:dio/dio.dart';

class API {
  final Dio _dio = Dio();
  String baseUrl = "http://localhost:5000";

  API() {
    _dio.options.baseUrl = "$baseUrl/api";
  }

  Dio get sendRequest => _dio;
}

class APIRepository {
  final API api = API();

  Map<String, dynamic> header(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': '*/*',
      'Authorization': 'Bearer $token',
    };
  }

  Future<String> register(Signup user) async {
    try {
      final body = {
        "numberID": user.numberID,
        "accountID": user.accountID,
        "fullName": user.fullName,
        "phoneNumber": user.phoneNumber,
        "imageURL": user.imageUrl,
        "birthDay": user.birthDay,
        "gender": user.gender,
        "schoolYear": user.schoolYear,
        "schoolKey": user.schoolKey,
        "password": user.password,
        "confirmPassword": user.confirmPassword
      };

      Response res = await api.sendRequest.post(
        '/Student/signUp',
        options: Options(headers: header('no token')),
        data: body,
      );

      if (res.statusCode == 200 && res.data['success'] == true) {
        print("Đăng ký thành công");
        return "ok";
      } else {
        print("Đăng ký thất bại: ${res.data}");
        return "signup fail";
      }
    } catch (ex) {
      print("Lỗi khi đăng ký: $ex");
      return "signup error";
    }
  }

  Future<String> login(String accountID, String password) async {
    try {
      final body = {
        'AccountID': accountID,
        'Password': password,
      };

      Response res = await api.sendRequest.post(
        '/Auth/login',
        options: Options(headers: header('no token')),
        data: body,
      );

      if (res.statusCode == 200 && res.data['data'] != null) {
        final tokenData = res.data['data']['token'];
        print("Đăng nhập thành công");
        return tokenData;
      } else {
        print("Đăng nhập thất bại: ${res.data}");
        return "login fail";
      }
    } catch (ex) {
      print("Lỗi khi đăng nhập: $ex");
      return "login error";
    }
  }

  Future<User?> current(String token) async {
    try {
      Response res = await api.sendRequest.get(
        '/Auth/current',
        options: Options(headers: header(token)),
      );

      if (res.statusCode == 200) {
        return User.fromJson(res.data);
      } else {
        print("Lấy user hiện tại thất bại: ${res.data}");
        return null;
      }
    } catch (ex) {
      print("Lỗi khi lấy user hiện tại: $ex");
      return null;
    }
  }
}
