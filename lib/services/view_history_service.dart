import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/view_history.dart';
import 'network_service.dart';
import 'offline_storage_service.dart';

class ViewHistoryService {
  static final NetworkService _networkService = NetworkService();
  static final OfflineStorageService _offlineStorage = OfflineStorageService();

  // Initialize services
  static Future<void> initialize() async {
    await _networkService.initialize();
    await _offlineStorage.initialize();
  }

  // Add car view to history with offline-first approach
  static Future<void> addCarView({
    required String userId,
    required String carId,
    required String carModel,
    required String carImage,
    required double carRating,
    required int carTrips,
    required String hostName,
    required bool isAllStarHost,
    String? price,
    String? location,
    String? hostImage,
    double? hostRating,
    String? responseTime,
    List<String>? features,
    Map<String, String>? specs,
    List<String>? images,
    String? hostId,
  }) async {
    try {
      print('DEBUG: Adding car view - carModel: "$carModel", carImage: "$carImage", hostName: "$hostName"');
      
      final viewHistory = ViewHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        carId: carId,
        carModel: carModel,
        carImage: carImage,
        carRating: carRating,
        carTrips: carTrips,
        hostName: hostName,
        isAllStarHost: isAllStarHost,
        viewedAt: DateTime.now(),
        metadata: {
          'price': price,
          'location': location,
          'hostImage': hostImage,
          'hostRating': hostRating,
          'responseTime': responseTime,
          'features': features,
          'specs': specs,
          'images': images,
          'hostId': hostId,
        },
      );

      final data = {
        'user_id': userId,
        'car_id': carId,
        'car_model': carModel,
        'car_image': carImage,
        'car_rating': carRating,
        'car_trips': carTrips,
        'host_name': hostName,
        'is_all_star_host': isAllStarHost,
        'viewed_at': DateTime.now().toIso8601String(),
      };

      // Add to local storage first (immediate)
      await _addToLocalHistory(viewHistory, userId);

      // Try API if online
      if (_networkService.isOnline) {
        final response = await _networkService.post<Map<String, dynamic>>(
          ApiConstants.viewHistoryEndpoint,
          body: data,
          fromJson: (json) => json,
        );

        if (response.isSuccess) {
          // Clear cache to force refresh
          await _offlineStorage.clearCache(key: 'view_history_$userId');
        } else {
          print('API error: ${response.errorMessage}');
          // Queue for sync if API failed
          await _offlineStorage.addOfflineOperation(
            'view_history_add_${DateTime.now().millisecondsSinceEpoch}',
            data,
            'create',
          );
        }
      } else {
        // Queue for sync if offline
        await _offlineStorage.addOfflineOperation(
          'view_history_add_${DateTime.now().millisecondsSinceEpoch}',
          data,
          'create',
        );
      }
    } catch (e) {
      print('Error adding car view: $e');
    }
  }

  // Get recent view history with offline-first approach
  static Future<List<ViewHistory>> getRecentViewHistory(String userId, {int limit = 5}) async {
    try {
      // Check cache first
      final cachedData = _offlineStorage.getCachedData<List<dynamic>>(
        'view_history_$userId',
        userId: userId,
      );

      if (cachedData != null) {
        final histories = cachedData.map((json) => ViewHistory.fromJson(json)).toList();
        print('DEBUG: Loaded ${histories.length} cached view histories');
        for (int i = 0; i < histories.length; i++) {
          final h = histories[i];
          print('DEBUG: History $i - carModel: "${h.carModel}", carImage: "${h.carImage}", hostName: "${h.hostName}"');
        }
        return histories.take(limit).toList();
      }

      // If not cached, try API
      if (_networkService.isOnline) {
        final response = await _networkService.get<List<dynamic>>(
          '${ApiConstants.viewHistoryEndpoint}/user/$userId/recent',
          queryParameters: {'limit': limit},
          fromJson: (json) => json['data'] as List<dynamic>,
        );

        if (response.isSuccess && response.data != null) {
          final histories = response.data!.map((json) => ViewHistory.fromJson(json)).toList();
          
          // Cache the data
          await _offlineStorage.cacheData(
            'view_history_$userId',
            response.data!,
            userId: userId,
          );
          
          return histories;
        } else {
          print('API error: ${response.errorMessage}');
        }
      }

      // Fallback to local storage
      return await _getLocalHistory(userId, limit);
    } catch (e) {
      print('Error getting recent view history: $e');
      return await _getLocalHistory(userId, limit);
    }
  }

  // Clear view history
  static Future<bool> clearViewHistory(String userId) async {
    try {
      final data = {
        'user_id': userId,
      };

      // Clear local storage first
      await _clearLocalHistory(userId);

      // Try API if online
      if (_networkService.isOnline) {
        final response = await _networkService.delete<Map<String, dynamic>>(
          '${ApiConstants.viewHistoryEndpoint}/user/$userId',
          fromJson: (json) => json,
        );

        if (response.isSuccess) {
          // Clear cache
          await _offlineStorage.clearCache(key: 'view_history_$userId', userId: userId);
          return true;
        } else {
          print('API error: ${response.errorMessage}');
        }
      }

      // Queue for sync if offline or API failed
      await _offlineStorage.addOfflineOperation(
        'view_history_clear_${DateTime.now().millisecondsSinceEpoch}',
        data,
        'delete',
      );

      return true;
    } catch (e) {
      print('Error clearing view history: $e');
      return false;
    }
  }

  // Get view statistics
  static Future<Map<String, dynamic>> getViewStatistics(String userId) async {
    try {
      // Check cache first
      final cachedData = _offlineStorage.getCachedData<Map<String, dynamic>>(
        'view_stats_$userId',
        userId: userId,
      );

      if (cachedData != null) {
        return cachedData;
      }

      // If not cached, try API
      if (_networkService.isOnline) {
        final response = await _networkService.get<Map<String, dynamic>>(
          '${ApiConstants.viewHistoryEndpoint}/user/$userId/stats',
          fromJson: (json) => json,
        );

        if (response.isSuccess && response.data != null) {
          // Cache the data
          await _offlineStorage.cacheData(
            'view_stats_$userId',
            response.data!,
            userId: userId,
            expiration: const Duration(hours: 1), // Cache stats longer
          );
          
          return response.data!;
        } else {
          print('API error: ${response.errorMessage}');
        }
      }

      // Fallback to local statistics
      return await _getLocalViewStatistics(userId);
    } catch (e) {
      print('Error getting view statistics: $e');
      return await _getLocalViewStatistics(userId);
    }
  }

  // Sync pending operations
  static Future<void> syncPendingOperations() async {
    try {
      await _offlineStorage.syncPendingOperations();
      await _offlineStorage.saveLastSyncTime();
    } catch (e) {
      print('Error syncing pending operations: $e');
    }
  }

  // Local storage methods (fallback)
  static Future<void> _addToLocalHistory(ViewHistory history, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final histories = await _getLocalHistory(userId, 50); // Keep 50 for fallback
      
      // Remove if already exists (to avoid duplicates)
      histories.removeWhere((h) => h.carId == history.carId);
      
      // Add to beginning
      histories.insert(0, history);
      
      // Keep only last 50 items
      if (histories.length > 50) {
        histories.removeRange(50, histories.length);
      }
      
      final historiesJson = histories.map((h) => jsonEncode(h.toJson())).toList();
      await prefs.setStringList('${AppConstants.viewHistoryKey}_$userId', historiesJson);
    } catch (e) {
      print('Error adding to local history: $e');
    }
  }

  static Future<List<ViewHistory>> _getLocalHistory(String userId, int limit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historiesJson = prefs.getStringList('${AppConstants.viewHistoryKey}_$userId') ?? [];
      
      final histories = historiesJson
          .map((json) => ViewHistory.fromJson(jsonDecode(json)))
          .toList();
      
      return histories.take(limit).toList();
    } catch (e) {
      print('Error getting local history: $e');
      return [];
    }
  }

  static Future<void> _clearLocalHistory(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${AppConstants.viewHistoryKey}_$userId');
    } catch (e) {
      print('Error clearing local history: $e');
    }
  }

  static Future<Map<String, dynamic>> _getLocalViewStatistics(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historiesJson = prefs.getStringList('${AppConstants.viewHistoryKey}_$userId') ?? [];
      
      final histories = historiesJson
          .map((json) => ViewHistory.fromJson(jsonDecode(json)))
          .toList();

      final totalViews = histories.length;
      final uniqueCars = histories.map((h) => h.carId).toSet().length;
      
      // Calculate average rating
      double totalRating = 0;
      int ratedViews = 0;
      
      for (final history in histories) {
        if (history.carRating > 0) {
          totalRating += history.carRating;
          ratedViews++;
        }
      }
      
      final averageRating = ratedViews > 0 ? totalRating / ratedViews : 0.0;

      // Get most viewed car categories (simplified)
      final carModels = histories.map((h) => h.carModel).toList();
      final modelCounts = <String, int>{};
      
      for (final model in carModels) {
        modelCounts[model] = (modelCounts[model] ?? 0) + 1;
      }
      
      final sortedModels = modelCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final topModels = sortedModels.take(3).map((e) => e.key).toList();

      return {
        'total_views': totalViews,
        'unique_cars': uniqueCars,
        'average_rating': averageRating,
        'top_models': topModels,
        'last_viewed': histories.isNotEmpty ? histories.first.viewedAt.toIso8601String() : null,
      };
    } catch (e) {
      print('Error getting local view statistics: $e');
      return {
        'total_views': 0,
        'unique_cars': 0,
        'average_rating': 0.0,
        'top_models': [],
        'last_viewed': null,
      };
    }
  }
} 