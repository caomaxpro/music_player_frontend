import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiService {
  final Dio _dio;

  ApiService()
    : _dio = Dio(
        BaseOptions(
          // http://192.168.12.103:5000
          baseUrl: "http://192.168.12.103:5000/",
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
          debugPrint('Request: ${options.method} ${options.path}');
          debugPrint('Full URL: ${options.baseUrl}${options.path}');
          return handler.next(options); // Continue the request
        },
        onResponse: (response, handler) {
          debugPrint('Response: ${response.statusCode} ${response.data}');
          return handler.next(response); // Continue the response
        },
        onError: (DioException e, handler) {
          debugPrint('Error: ${e.response?.statusCode} ${e.message}');
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

  Future<dynamic> post(String endpoint, {required FormData formData}) async {
    try {
      final response = await _dio.post(endpoint, data: formData);
      return response.data;
    } catch (e) {
      throw Exception('Failed to perform POST request: $e');
    }
  }
}
