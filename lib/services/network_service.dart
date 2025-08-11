import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  http.Client? _client;
  bool _isOnline = true;
  String? _authToken;
  DateTime? _lastSyncTime;

  // Initialize the service
  Future<void> initialize() async {
    _client = http.Client();
    await _loadAuthToken();
    await _checkConnectivity();
  }

  // Dispose resources
  void dispose() {
    _client?.close();
  }

  // Load auth token from storage
  Future<void> _loadAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString(AppConstants.authTokenKey);
    } catch (e) {
      print('Error loading auth token: $e');
    }
  }

  // Save auth token to storage
  Future<void> _saveAuthToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.authTokenKey, token);
      _authToken = token;
    } catch (e) {
      print('Error saving auth token: $e');
    }
  }

  // Check network connectivity
  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      _isOnline = false;
    }
    return _isOnline;
  }

  // Get auth headers
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // Handle API response
  ApiResponse<T> _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>) fromJson) {
    try {
      final body = json.decode(response.body);
      
      switch (response.statusCode) {
        case ApiConstants.success:
        case ApiConstants.created:
          return ApiResponse.success(fromJson(body));
        
        case ApiConstants.noContent:
          return ApiResponse.success(null as T);
        
        case ApiConstants.unauthorized:
          return ApiResponse.error(ApiConstants.unauthorizedError, response.statusCode);
        
        case ApiConstants.forbidden:
          return ApiResponse.error('Access forbidden', response.statusCode);
        
        case ApiConstants.notFound:
          return ApiResponse.error(ApiConstants.notFoundError, response.statusCode);
        
        case ApiConstants.conflict:
          return ApiResponse.error('Resource conflict', response.statusCode);
        
        case ApiConstants.unprocessableEntity:
          final errors = body['errors'] ?? body['message'] ?? ApiConstants.validationError;
          return ApiResponse.error(errors.toString(), response.statusCode);
        
        case ApiConstants.internalServerError:
        case ApiConstants.serviceUnavailable:
          return ApiResponse.error(ApiConstants.serverError, response.statusCode);
        
        default:
          return ApiResponse.error(ApiConstants.unknownError, response.statusCode);
      }
    } catch (e) {
      return ApiResponse.error('Invalid response format: $e', response.statusCode);
    }
  }

  // Handle network errors
  ApiResponse<T> _handleNetworkError<T>(dynamic error) {
    if (error is SocketException) {
      return ApiResponse.error(ApiConstants.networkError, 0);
    } else if (error is HttpException) {
      return ApiResponse.error('HTTP error: ${error.message}', 0);
    } else if (error is FormatException) {
      return ApiResponse.error('Data format error: ${error.message}', 0);
    } else {
      return ApiResponse.error('Network error: $error', 0);
    }
  }

  // GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
    bool retryOnFailure = true,
  }) async {
    return _makeRequest<T>(
      'GET',
      endpoint,
      queryParameters: queryParameters,
      fromJson: fromJson,
      timeout: timeout,
      retryOnFailure: retryOnFailure,
    );
  }

  // POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
    bool retryOnFailure = true,
  }) async {
    return _makeRequest<T>(
      'POST',
      endpoint,
      body: body,
      fromJson: fromJson,
      timeout: timeout,
      retryOnFailure: retryOnFailure,
    );
  }

  // PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
    bool retryOnFailure = true,
  }) async {
    return _makeRequest<T>(
      'PUT',
      endpoint,
      body: body,
      fromJson: fromJson,
      timeout: timeout,
      retryOnFailure: retryOnFailure,
    );
  }

  // DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
    bool retryOnFailure = true,
  }) async {
    return _makeRequest<T>(
      'DELETE',
      endpoint,
      fromJson: fromJson,
      timeout: timeout,
      retryOnFailure: retryOnFailure,
    );
  }

  // Make HTTP request with retry logic
  Future<ApiResponse<T>> _makeRequest<T>(
    String method,
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
    Duration? timeout,
    bool retryOnFailure = true,
  }) async {
    if (_client == null) {
      await initialize();
    }

    // Check connectivity
    await _checkConnectivity();
    if (!_isOnline && retryOnFailure) {
      return ApiResponse.error(ApiConstants.networkError, 0);
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint')
        .replace(queryParameters: queryParameters?.map((key, value) => MapEntry(key, value.toString())));

    final headers = _getHeaders();
    final requestTimeout = timeout ?? ApiConstants.timeout;

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount <= maxRetries) {
      try {
        http.Response response;

        switch (method.toUpperCase()) {
          case 'GET':
            response = await _client!
                .get(uri, headers: headers)
                .timeout(requestTimeout);
            break;
          case 'POST':
            response = await _client!
                .post(
                  uri,
                  headers: headers,
                  body: body != null ? json.encode(body) : null,
                )
                .timeout(requestTimeout);
            break;
          case 'PUT':
            response = await _client!
                .put(
                  uri,
                  headers: headers,
                  body: body != null ? json.encode(body) : null,
                )
                .timeout(requestTimeout);
            break;
          case 'DELETE':
            response = await _client!
                .delete(uri, headers: headers)
                .timeout(requestTimeout);
            break;
          default:
            return ApiResponse.error('Unsupported HTTP method: $method', 0);
        }

        // Handle token refresh if needed
        if (response.statusCode == ApiConstants.unauthorized) {
          final refreshed = await _refreshToken();
          if (refreshed && retryCount < maxRetries) {
            retryCount++;
            continue;
          }
        }

        // Update last sync time for successful requests
        if (response.statusCode >= 200 && response.statusCode < 300) {
          _lastSyncTime = DateTime.now();
        }

        return _handleResponse(response, fromJson ?? (json) => json as T);

      } catch (error) {
        retryCount++;
        
        if (retryCount > maxRetries || !retryOnFailure) {
          return _handleNetworkError(error);
        }

        // Wait before retrying
        await Future.delayed(Duration(seconds: retryCount));
      }
    }

    return ApiResponse.error('Max retries exceeded', 0);
  }

  // Refresh auth token
  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(AppConstants.refreshTokenKey);
      
      if (refreshToken == null) {
        return false;
      }

      final response = await _client!.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.authEndpoint}/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': refreshToken}),
      ).timeout(ApiConstants.shortTimeout);

      if (response.statusCode == ApiConstants.success) {
        final body = json.decode(response.body);
        await _saveAuthToken(body['access_token']);
        if (body['refresh_token'] != null) {
          await prefs.setString(AppConstants.refreshTokenKey, body['refresh_token']);
        }
        return true;
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }
    
    return false;
  }

  // Set auth token (for login)
  Future<void> setAuthToken(String token, {String? refreshToken}) async {
    await _saveAuthToken(token);
    if (refreshToken != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.refreshTokenKey, refreshToken);
    }
  }

  // Clear auth token (for logout)
  Future<void> clearAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.authTokenKey);
      await prefs.remove(AppConstants.refreshTokenKey);
      _authToken = null;
    } catch (e) {
      print('Error clearing auth token: $e');
    }
  }

  // Check if online
  bool get isOnline => _isOnline;

  // Get last sync time
  DateTime? get lastSyncTime => _lastSyncTime;

  // Check if data is stale (needs refresh)
  bool isDataStale(DateTime? lastUpdate) {
    if (lastUpdate == null) return true;
    final difference = DateTime.now().difference(lastUpdate);
    return difference.inMinutes > AppConstants.cacheExpirationMinutes;
  }
}

// API Response wrapper
class ApiResponse<T> {
  final T? data;
  final String? error;
  final int statusCode;
  final bool isSuccess;

  ApiResponse._({
    this.data,
    this.error,
    required this.statusCode,
    required this.isSuccess,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse._(
      data: data,
      statusCode: ApiConstants.success,
      isSuccess: true,
    );
  }

  factory ApiResponse.error(String error, int statusCode) {
    return ApiResponse._(
      error: error,
      statusCode: statusCode,
      isSuccess: false,
    );
  }

  // Helper methods
  bool get hasError => !isSuccess;
  bool get hasData => data != null;
  
  // Safe data access
  T? get safeData => isSuccess ? data : null;
  
  // Error message
  String get errorMessage => error ?? ApiConstants.unknownError;
}

// Offline data storage
class OfflineData {
  final String key;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String operation; // 'create', 'update', 'delete'

  OfflineData({
    required this.key,
    required this.data,
    required this.timestamp,
    required this.operation,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'operation': operation,
    };
  }

  factory OfflineData.fromJson(Map<String, dynamic> json) {
    return OfflineData(
      key: json['key'],
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      operation: json['operation'],
    );
  }
} 