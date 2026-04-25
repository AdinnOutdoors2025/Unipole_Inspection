import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:unipole_inspection/service/api_constants.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'model/inspection_model.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _inspectionKey = 'inspection_id';

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

  Future<Map<String, dynamic>> createInspection({
    required String location,
    required String latitude,
    required String longitude,
    required String unipoleHeight,
    required String adStructureSize,
  }) async {
    final token = await getToken();

    final body = {
      "location": location,
      "latitude": latitude,
      "longitude": longitude,
      "unipole_height": unipoleHeight,
      "ad_structure_size": adStructureSize,
    };

    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}${ApiConstants.createInspection}"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      final responseJson = jsonDecode(response.body);
      print("Status Code: ${response.statusCode}");
      print("Response Body: $responseJson");
      String message = responseJson['message'] ?? "Something went wrong";

      String? inspectionId = responseJson['data']?['inspection_id'];
      if (inspectionId != null) {
        await _storage.write(key: _inspectionKey, value: inspectionId);
      }

      return {
        "success": response.statusCode == 200 || response.statusCode == 201,
        "message": message,
      };
    } catch (e) {
      print("Update Error: $e");
      return {"success": false, "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateInspection({
    required String inspectionId,
    required String key,
    required bool status,
    required List<File> files,
  }) async {
    final token = await getToken();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${ApiConstants.baseUrl}/inspections/$inspectionId/update"),
    );

    request.headers["Authorization"] = "Bearer $token";

    request.fields["${key}_status"] = status.toString();

    for (var file in files) {
      print("Uploading file: ${file.path}");

      final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
      final mimeParts = mimeType.split('/');

      request.files.add(
        await http.MultipartFile.fromPath(
          "${key}_images",
          file.path,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        ),
      );
    }

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      final json = jsonDecode(responseBody);
      print("Status Code: ${response.statusCode}");
      print("Response Body: $json");

      return {
        "success": response.statusCode == 200,
        "message": json["message"] ?? "Something went wrong",
      };
    } catch (e) {
      print("Update Error: $e");
      return {"success": false, "message": e.toString()};
    }
  }

  Future<InspectionModel> getInspection() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}${ApiConstants.getInspectionDetails}"),
      headers: {"Authorization": "Bearer $token"},
    );

    final json = jsonDecode(response.body);

    return InspectionModel.fromJson(json);
  }

  Future<Map> deleteInspectionMedia({
    required String inspectionId,
    required String url,
  }) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/inspections/$inspectionId/delete"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"url": url}),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> submitInspection({
    required String inspectionId,
    required File file,
  }) async {
    final token = await getToken();

    final newPath =
        "${file.parent.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final fixedFile = await file.copy(newPath);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
        "${ApiConstants.baseUrl}/inspections/$inspectionId/submitinspection",
      ),
    );

    request.headers['Authorization'] = "Bearer $token";

    request.files.add(
      await http.MultipartFile.fromPath(
        'selfie_image',
        fixedFile.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    return jsonDecode(responseBody);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<String?> getInspectionId() async {
    return await _storage.read(key: _inspectionKey);
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
