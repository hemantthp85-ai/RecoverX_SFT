// ============================================================
// RecoverX — API Client (HTTP service layer)
// All HTTP communication with the RecoverX FastAPI backend flows
// through this class.  UI widgets NEVER import 'package:http'.
// ============================================================

import 'dart:async' as async;
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../core/utils/api_exceptions.dart';
import '../core/utils/result.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // ── Base URL (never hardcoded anywhere else) ──────────────────
  static final Uri _base = Uri.parse(AppConstants.apiBaseUrl);

  // ── Default headers ──────────────────────────────────────────
  Map<String, String> _headers({String? authToken}) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  // ─────────────────────────────────────────────────────────────
  // Public HTTP verbs
  // Each method wraps exceptions into typed ApiException subtypes
  // and returns Result<Map<String,dynamic>>.
  // ─────────────────────────────────────────────────────────────

  /// GET request
  Future<Result<Map<String, dynamic>>> get(
    String path, {
    Map<String, String>? queryParams,
    String? authToken,
  }) =>
      _execute(() {
        final uri = _buildUri(path, queryParams);
        return _client.get(uri, headers: _headers(authToken: authToken));
      });

  /// POST request
  Future<Result<Map<String, dynamic>>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    String? authToken,
  }) =>
      _execute(() {
        final uri = _buildUri(path, queryParams);
        return _client.post(
          uri,
          headers: _headers(authToken: authToken),
          body: body != null ? jsonEncode(body) : null,
        );
      });

  /// PUT request
  Future<Result<Map<String, dynamic>>> put(
    String path, {
    Map<String, dynamic>? body,
    String? authToken,
  }) =>
      _execute(() {
        final uri = _buildUri(path, null);
        return _client.put(
          uri,
          headers: _headers(authToken: authToken),
          body: body != null ? jsonEncode(body) : null,
        );
      });

  /// DELETE request
  Future<Result<Map<String, dynamic>>> delete(
    String path, {
    String? authToken,
  }) =>
      _execute(() {
        final uri = _buildUri(path, null);
        return _client.delete(uri, headers: _headers(authToken: authToken));
      });

  // ── GET list variant (returns List) ──────────────────────────
  Future<Result<List<dynamic>>> getList(
    String path, {
    Map<String, String>? queryParams,
    String? authToken,
  }) async {
    try {
      final uri = _buildUri(path, queryParams);
      final response = await _client
          .get(uri, headers: _headers(authToken: authToken))
          .timeout(AppConstants.httpTimeout);
      return _parseListResponse(response);
    } catch (e) {
      return ResultFailure(_mapException(e));
    }
  }

  // ─────────────────────────────────────────────────────────────
  // Private helpers
  // ─────────────────────────────────────────────────────────────

  Uri _buildUri(String path, Map<String, String>? queryParams) {
    final uri = _base.resolve(path);
    if (queryParams == null || queryParams.isEmpty) return uri;
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...queryParams,
    });
  }

  Future<Result<Map<String, dynamic>>> _execute(
    Future<http.Response> Function() call,
  ) async {
    try {
      final response = await call().timeout(AppConstants.httpTimeout);
      return _parseResponse(response);
    } catch (e) {
      return ResultFailure(_mapException(e));
    }
  }

  Result<Map<String, dynamic>> _parseResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is Map<String, dynamic>) {
          return ResultSuccess(decoded);
        }
        // Wrap non-map success (e.g. plain string) in envelope
        return ResultSuccess({'data': decoded});
      }
      return ResultFailure(_errorFromResponse(response, decoded));
    } on FormatException {
      return ResultFailure(const ParseException());
    }
  }

  Result<List<dynamic>> _parseListResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is List) return ResultSuccess(decoded);
        // Backend might wrap list in a key
        if (decoded is Map<String, dynamic>) {
          final list = decoded['data'] ?? decoded['items'] ?? decoded['results'];
          if (list is List) return ResultSuccess(list);
        }
        return ResultSuccess([]);
      }
      return ResultFailure(_errorFromResponse(response, decoded));
    } on FormatException {
      return ResultFailure(const ParseException());
    }
  }

  ApiException _errorFromResponse(http.Response response, dynamic decoded) {
    final message = _extractMessage(decoded) ??
        'Request failed (${response.statusCode})';
    if (response.statusCode == 401) return UnauthorisedException(message);
    if (response.statusCode >= 400 && response.statusCode < 500) {
      return ClientException(message, statusCode: response.statusCode);
    }
    return ServerException(message, statusCode: response.statusCode);
  }

  String? _extractMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      return decoded['detail']?.toString() ??
          decoded['message']?.toString() ??
          decoded['error']?.toString();
    }
    return decoded?.toString();
  }

  ApiException _mapException(Object e) {
    if (e is ApiException) return e;
    if (e is SocketException || e is http.ClientException) {
      return const NetworkException();
    }
    // dart:async TimeoutException (from .timeout())
    if (e is async.TimeoutException) return const TimeoutException();
    if (e is FormatException) return const ParseException();
    return NetworkException(e.toString());
  }

  void dispose() => _client.close();
}
