
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static const Duration _timeout = Duration(seconds: 20);

  static Uri _uri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${ApiConfig.baseUrl}$normalizedPath');
  }

  static Future<Map<String, String>> _headers({
    bool authenticated = true,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (authenticated) {
      final token = await TokenStorage.readToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static dynamic _decodeResponse(http.Response response) {
    final body = response.body.trim();

    dynamic decoded;

    if (body.isNotEmpty) {
      try {
        decoded = jsonDecode(body);
      } on FormatException {
        decoded = body;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    String message = 'Request failed (${response.statusCode}).';

    if (decoded is Map<String, dynamic>) {
      final detail = decoded['detail'];

      if (detail is String) {
        message = detail;
      } else if (detail != null) {
        message = detail.toString();
      }
    } else if (decoded is String && decoded.isNotEmpty) {
      message = decoded;
    }

    if (response.statusCode == 401) {
      message = 'Your session has expired. Please log in again.';
    }

    throw ApiException(
      message,
      statusCode: response.statusCode,
    );
  }

  static Future<dynamic> get(
      String path, {
        bool authenticated = true,
        Map<String, String>? queryParameters,
      }) async {
    try {
      final uri = _uri(path).replace(
        queryParameters: queryParameters,
      );

      final response = await http
          .get(
        uri,
        headers: await _headers(authenticated: authenticated),
      )
          .timeout(_timeout);

      return _decodeResponse(response);
    } on TimeoutException {
      throw const ApiException(
        'The server took too long to respond.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Cannot connect to CareCircle. Check the server and network.',
      );
    }
  }

  static Future<dynamic> post(
      String path, {
        Map<String, dynamic>? body,
        bool authenticated = true,
      }) async {
    try {
      final response = await http
          .post(
        _uri(path),
        headers: await _headers(authenticated: authenticated),
        body: jsonEncode(body ?? <String, dynamic>{}),
      )
          .timeout(_timeout);

      return _decodeResponse(response);
    } on TimeoutException {
      throw const ApiException(
        'The server took too long to respond.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Cannot connect to CareCircle. Check the server and network.',
      );
    }
  }

  static Future<dynamic> put(
      String path, {
        required Map<String, dynamic> body,
      }) async {
    try {
      final response = await http
          .put(
        _uri(path),
        headers: await _headers(),
        body: jsonEncode(body),
      )
          .timeout(_timeout);

      return _decodeResponse(response);
    } on TimeoutException {
      throw const ApiException(
        'The server took too long to respond.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Cannot connect to CareCircle. Check the server and network.',
      );
    }
  }

  static Future<dynamic> patch(
      String path, {
        required Map<String, dynamic> body,
      }) async {
    try {
      final response = await http
          .patch(
        _uri(path),
        headers: await _headers(),
        body: jsonEncode(body),
      )
          .timeout(_timeout);

      return _decodeResponse(response);
    } on TimeoutException {
      throw const ApiException(
        'The server took too long to respond.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Cannot connect to CareCircle. Check the server and network.',
      );
    }
  }
}
