import 'dart:convert';
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: "http://192.168.12.101:5000/",
          connectTimeout: Duration(
            milliseconds: 5000,
          ), // Timeout for connection (in milliseconds)
          receiveTimeout: Duration(
            milliseconds: 120000,
          ), // Timeout for receiving data
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('Request: ${options.method} ${options.path}');
          print('Full URL: ${options.baseUrl}${options.path}');
          return handler.next(options); // Continue the request
        },
        onResponse: (response, handler) {
          print('Response: ${response.statusCode} ${response.data}');
          return handler.next(response); // Continue the response
        },
        onError: (DioError e, handler) {
          print('Error: ${e.response?.statusCode} ${e.message}');
          return handler.next(e); // Continue the error
        },
      ),
    );
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } catch (e) {
      throw Exception('Failed to perform GET request: $e');
    }
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } catch (e) {
      throw Exception('Failed to perform POST request: $e');
    }
  }
}
