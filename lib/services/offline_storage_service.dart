import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'network_service.dart';

class OfflineStorageService {
  static final OfflineStorageService _instance = OfflineStorageService._internal();
  factory OfflineStorageService() => _instance;
  OfflineStorageService._internal();

  SharedPreferences? _prefs;
  final List<OfflineData> _pendingOperations = [];

  // Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadPendingOperations();
  }

  // Load pending operations from storage
  Future<void> _loadPendingOperations() async {
    try {
      final operationsJson = _prefs?.getStringList(AppConstants.offlineDataKey) ?? [];
      _pendingOperations.clear();
      
      for (final operationJson in operationsJson) {
        final operation = OfflineData.fromJson(json.decode(operationJson));
        _pendingOperations.add(operation);
      }
    } catch (e) {
      print('Error loading pending operations: $e');
    }
  }

  // Save pending operations to storage
  Future<void> _savePendingOperations() async {
    try {
      final operationsJson = _pendingOperations
          .map((op) => json.encode(op.toJson()))
          .toList();
      
      await _prefs?.setStringList(AppConstants.offlineDataKey, operationsJson);
    } catch (e) {
      print('Error saving pending operations: $e');
    }
  }

  // Cache data locally
  Future<void> cacheData<T>(
    String key,
    T data, {
    Duration? expiration,
    String? userId,
  }) async {
    try {
      final cacheKey = _getCacheKey(key, userId);
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'expiration': expiration?.inMinutes ?? AppConstants.cacheExpirationMinutes,
      };

      if (data is Map<String, dynamic>) {
        await _prefs?.setString(cacheKey, json.encode(cacheData));
      } else {
        await _prefs?.setString(cacheKey, json.encode(cacheData));
      }
    } catch (e) {
      print('Error caching data: $e');
    }
  }

  // Get cached data
  T? getCachedData<T>(
    String key, {
    String? userId,
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    try {
      final cacheKey = _getCacheKey(key, userId);
      final cachedJson = _prefs?.getString(cacheKey);
      
      if (cachedJson == null) return null;

      final cached = json.decode(cachedJson);
      final timestamp = DateTime.parse(cached['timestamp']);
      final expirationMinutes = cached['expiration'] ?? AppConstants.cacheExpirationMinutes;
      
      // Check if data is expired
      final difference = DateTime.now().difference(timestamp);
      if (difference.inMinutes > expirationMinutes) {
        _prefs?.remove(cacheKey);
        return null;
      }

      final data = cached['data'];
      if (fromJson != null && data is Map<String, dynamic>) {
        return fromJson(data);
      }
      
      return data as T?;
    } catch (e) {
      print('Error getting cached data: $e');
      return null;
    }
  }

  // Check if data is cached and fresh
  bool isDataCached(String key, {String? userId}) {
    try {
      final cacheKey = _getCacheKey(key, userId);
      final cachedJson = _prefs?.getString(cacheKey);
      
      if (cachedJson == null) return false;

      final cached = json.decode(cachedJson);
      final timestamp = DateTime.parse(cached['timestamp']);
      final expirationMinutes = cached['expiration'] ?? AppConstants.cacheExpirationMinutes;
      
      final difference = DateTime.now().difference(timestamp);
      return difference.inMinutes <= expirationMinutes;
    } catch (e) {
      return false;
    }
  }

  // Clear cached data
  Future<void> clearCache({String? key, String? userId}) async {
    try {
      if (key != null) {
        final cacheKey = _getCacheKey(key, userId);
        await _prefs?.remove(cacheKey);
      } else {
        // Clear all cache
        final keys = _prefs?.getKeys() ?? {};
        for (final cacheKey in keys) {
          if (cacheKey.startsWith('cache_')) {
            await _prefs?.remove(cacheKey);
          }
        }
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Clear all cached data
  Future<void> clearAllCache() async {
    try {
      print('Clearing all offline storage cache...');
      
      if (_prefs != null) {
        final keys = _prefs!.getKeys();
        for (final key in keys) {
          if (key.startsWith('cache_') || key.startsWith('offline_')) {
            await _prefs!.remove(key);
          }
        }
      }
      
      // Clear pending operations
      _pendingOperations.clear();
      await _savePendingOperations();
      
      print('✅ Offline storage cache cleared');
    } catch (e) {
      print('❌ Error clearing offline storage cache: $e');
    }
  }

  // Add offline operation
  Future<void> addOfflineOperation(
    String key,
    Map<String, dynamic> data,
    String operation,
  ) async {
    try {
      final offlineData = OfflineData(
        key: key,
        data: data,
        timestamp: DateTime.now(),
        operation: operation,
      );

      _pendingOperations.add(offlineData);
      
      // Limit the number of pending operations
      if (_pendingOperations.length > AppConstants.maxOfflineItems) {
        _pendingOperations.removeAt(0);
      }
      
      await _savePendingOperations();
    } catch (e) {
      print('Error adding offline operation: $e');
    }
  }

  // Get pending operations
  List<OfflineData> getPendingOperations() {
    return List.unmodifiable(_pendingOperations);
  }

  // Remove pending operation
  Future<void> removePendingOperation(OfflineData operation) async {
    try {
      _pendingOperations.remove(operation);
      await _savePendingOperations();
    } catch (e) {
      print('Error removing pending operation: $e');
    }
  }

  // Clear all pending operations
  Future<void> clearPendingOperations() async {
    try {
      _pendingOperations.clear();
      await _savePendingOperations();
    } catch (e) {
      print('Error clearing pending operations: $e');
    }
  }

  // Sync pending operations when online
  Future<void> syncPendingOperations() async {
    if (!NetworkService().isOnline) {
      return;
    }

    final operations = List<OfflineData>.from(_pendingOperations);
    
    for (final operation in operations) {
      try {
        bool success = false;
        
        switch (operation.operation) {
          case 'create':
            success = await _syncCreateOperation(operation);
            break;
          case 'update':
            success = await _syncUpdateOperation(operation);
            break;
          case 'delete':
            success = await _syncDeleteOperation(operation);
            break;
        }
        
        if (success) {
          await removePendingOperation(operation);
        }
      } catch (e) {
        print('Error syncing operation ${operation.key}: $e');
      }
    }
  }

  // Sync create operation
  Future<bool> _syncCreateOperation(OfflineData operation) async {
    try {
      final endpoint = _getEndpointFromKey(operation.key);
      final response = await NetworkService().post(endpoint, body: operation.data);
      return response.isSuccess;
    } catch (e) {
      print('Error syncing create operation: $e');
      return false;
    }
  }

  // Sync update operation
  Future<bool> _syncUpdateOperation(OfflineData operation) async {
    try {
      final endpoint = _getEndpointFromKey(operation.key);
      final response = await NetworkService().put(endpoint, body: operation.data);
      return response.isSuccess;
    } catch (e) {
      print('Error syncing update operation: $e');
      return false;
    }
  }

  // Sync delete operation
  Future<bool> _syncDeleteOperation(OfflineData operation) async {
    try {
      final endpoint = _getEndpointFromKey(operation.key);
      final response = await NetworkService().delete(endpoint);
      return response.isSuccess;
    } catch (e) {
      print('Error syncing delete operation: $e');
      return false;
    }
  }

  // Get endpoint from operation key
  String _getEndpointFromKey(String key) {
    if (key.startsWith('favorites_')) {
      return ApiConstants.favoritesEndpoint;
    } else if (key.startsWith('cars_')) {
      return ApiConstants.carsEndpoint;
    } else if (key.startsWith('rentals_')) {
      return ApiConstants.rentalsEndpoint;
    } else if (key.startsWith('users_')) {
      return ApiConstants.usersEndpoint;
    } else if (key.startsWith('payments_')) {
      return ApiConstants.paymentsEndpoint;
    } else if (key.startsWith('notifications_')) {
      return ApiConstants.notificationsEndpoint;
    } else if (key.startsWith('view_history_')) {
      return ApiConstants.viewHistoryEndpoint;
    } else if (key.startsWith('disputes_')) {
      return ApiConstants.disputesEndpoint;
    } else if (key.startsWith('messages_')) {
      return ApiConstants.messagesEndpoint;
    } else if (key.startsWith('reviews_')) {
      return ApiConstants.reviewsEndpoint;
    } else if (key.startsWith('insurance_')) {
      return ApiConstants.insuranceEndpoint;
    } else if (key.startsWith('documents_')) {
      return ApiConstants.documentsEndpoint;
    } else if (key.startsWith('locations_')) {
      return ApiConstants.locationsEndpoint;
    } else if (key.startsWith('availability_')) {
      return ApiConstants.availabilityEndpoint;
    }
    
    return '/unknown';
  }

  // Get cache key
  String _getCacheKey(String key, String? userId) {
    final userSuffix = userId != null ? '_$userId' : '';
    return 'cache_$key$userSuffix';
  }

  // Save last sync time
  Future<void> saveLastSyncTime() async {
    try {
      await _prefs?.setString(
        AppConstants.lastSyncKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Error saving last sync time: $e');
    }
  }

  // Get last sync time
  DateTime? getLastSyncTime() {
    try {
      final syncTimeStr = _prefs?.getString(AppConstants.lastSyncKey);
      return syncTimeStr != null ? DateTime.parse(syncTimeStr) : null;
    } catch (e) {
      print('Error getting last sync time: $e');
      return null;
    }
  }

  // Check if sync is needed
  bool isSyncNeeded() {
    final lastSync = getLastSyncTime();
    if (lastSync == null) return true;
    
    final difference = DateTime.now().difference(lastSync);
    return difference > AppConstants.syncRetryDelay;
  }

  // Get pending operations count
  int get pendingOperationsCount => _pendingOperations.length;

  // Check if there are pending operations
  bool get hasPendingOperations => _pendingOperations.isNotEmpty;
} 