import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiClient {
  static const String _tokenKey = 'jwt_sim_token';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _headers();
    final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 12));
    return _processResponse(response);
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _headers();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 12));
    return _processResponse(response);
  }

  static dynamic _processResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(utf8.decode(response.bodyBytes)) : null;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      final errorMsg = body is Map && body.containsKey('error')
          ? body['error']
          : (body is Map && body.containsKey('detail') ? body['detail'] : 'Request failed: ${response.statusCode}');
      throw HttpException(errorMsg.toString());
    }
  }
}
