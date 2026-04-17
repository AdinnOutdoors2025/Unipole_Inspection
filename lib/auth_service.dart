import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  // Unga backend login API URL inga podunga
  final String loginUrl = 'https://your-domain.com/api/login';

  Future<bool> login({
    required String employeeId,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'employeeId': employeeId,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // backend token field name match pannanum
      final token = data['token'];

      if (token != null && token.toString().isNotEmpty) {
        await _storage.write(key: _tokenKey, value: token);
        return true;
      }
    }

    return false;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();

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