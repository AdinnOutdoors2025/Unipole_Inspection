import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:unipole_inspection/service/api_constants.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  // Unga backend login API URL inga podunga
  // final String loginUrl = 'https://your-domain.com/api/login';

  Future<Map<String, dynamic>> login({
    required String employeeId,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}${ApiConstants.login}"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'phone': employeeId, 'password': password}),
    );

    final responseJson = jsonDecode(response.body);
    print("responseJson : $responseJson");

    if (response.statusCode == 200) {
      final token = responseJson['data']?['token'];
      final user = responseJson['data']?['user'];
      if (kDebugMode) {
        print("token: $token");
      }

      if (token != null && token.toString().isNotEmpty) {
        await _storage.write(key: _tokenKey, value: token);
      }
      if (user != null) {
        await _storage.write(key: "userName", value: user['name']);
      }

      return {
        "success": true,
        "data": responseJson['data'],
        "message": responseJson['message'] ?? "Login successful",
      };
    } else {
      return {
        "success": false,
        "message": responseJson['message'] ?? "Login failed",
      };
    }
  }

  Future<Map<String, dynamic>> signUp({
    required String name,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}${ApiConstants.register}"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'phone': phoneNumber,
          'password': password,
        }),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("RAW BODY: ${response.body}");

      final responseJson = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          "success": true,
          "data": responseJson['data'],
          "message": responseJson['message'] ?? "Signup successful",
        };
      } else {
        return {
          "success": false,
          "message": responseJson['message'] ?? "Signup failed",
        };
      }
    } catch (e) {
      print("SIGNUP ERROR: $e");

      return {
        "success": false,
        "message": "Something went wrong. Please try again",
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}${ApiConstants.verifyOtp}"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({"phone": phone, "otp": otp}),
      );
      final responseJson = jsonDecode(response.body);
      print("VERIFY OTP RESPONSE: $responseJson");
      if (response.statusCode == 200) {
        final token = responseJson['data']?['token'];
        final user = responseJson['data']?['user'];

        if (token != null) {
          await _storage.write(key: _tokenKey, value: token);
        }
        if (user != null) {
          await _storage.write(key: "userName", value: user['name']);
        }
        return {
          "success": true,
          "message": responseJson['message'],
          "data": responseJson['data'],
        };
      } else {
        return {
          "success": false,
          "message": responseJson['message'] ?? "OTP verification failed",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Something went wrong"};
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (kDebugMode) {
      print("token: $token");
    }
    if (token == null || token.isEmpty) {
      return false;
    }

    if (JwtDecoder.isExpired(token)) {
      await logout();
      return false;
    }

    return true;
  }

  Future<Map<String, dynamic>?> getDecodedToken() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    return JwtDecoder.decode(token);
  }
}
