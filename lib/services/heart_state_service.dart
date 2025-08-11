import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'favorite_service.dart';
import '../constants.dart';

class HeartStateService {
  static const String baseUrl = ApiConstants.baseUrl;
  static const String _heartStatesKey = 'heart_states';
  static const String _lastUpdateKey = 'heart_states_last_update';
  static const Duration _cacheExpiry = Duration(minutes: 5);

  // Initialize the service
  static Future<void> initialize() async {
    // Service is stateless, no initialization needed
    print('HeartStateService initialized');
  }

  // Clear all cached heart states
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_heartStatesKey);
      await prefs.remove(_lastUpdateKey);
      print('Heart state cache cleared');
    } catch (e) {
      print('Error clearing heart state cache: $e');
    }
  }

  // Check if a car is saved in any favorite list
  static Future<bool> isCarSaved(String carId, String userId) async {
    try {
      print('Checking heart state for car: $carId');
      
      // Check cache first
      final cachedState = await _getCachedHeartState(carId);
      if (cachedState != null) {
        print('Found cached state for $carId: $cachedState');
        return cachedState;
      }

      // Check from favorite service
      final isSaved = await FavoriteService.isCarFavorited(carId, userId);
      print('Service returned state for $carId: $isSaved');
      
      // Cache the result
      await _cacheHeartState(carId, isSaved);
      
      return isSaved;
    } catch (e) {
      print('Error checking heart state for car $carId: $e');
      return false;
    }
  }

  // Get heart states for multiple cars efficiently
  static Future<Map<String, bool>> getHeartStates(List<String> carIds, String userId) async {
    try {
      final Map<String, bool> states = {};
      
      // Check cache first for each car
      for (final carId in carIds) {
        final cachedState = await _getCachedHeartState(carId);
        if (cachedState != null) {
          states[carId] = cachedState;
        }
      }

      // For cars not in cache, check from service
      final uncachedCarIds = carIds.where((id) => !states.containsKey(id)).toList();
      if (uncachedCarIds.isNotEmpty) {
        // Try batch API call first, fallback to individual calls
        try {
          final batchStates = await _getBatchHeartStates(uncachedCarIds, userId);
          states.addAll(batchStates);
          
          // Cache the batch results
          await batchUpdateHeartStates(batchStates);
        } catch (e) {
          print('Batch API failed, falling back to individual calls: $e');
          // Fallback to individual calls
          for (final carId in uncachedCarIds) {
            final isSaved = await FavoriteService.isCarFavorited(carId, userId);
            states[carId] = isSaved;
            await _cacheHeartState(carId, isSaved);
          }
        }
      }

      return states;
    } catch (e) {
      print('Error getting heart states: $e');
      return {};
    }
  }

  // Batch API call for multiple car heart states
  static Future<Map<String, bool>> _getBatchHeartStates(List<String> carIds, String userId) async {
    try {
      if (baseUrl == 'https://your-api-domain.com/api') {
        // If using placeholder API, return empty map to trigger fallback
        return {};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/favorite-items/batch-check'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'userId': userId,
          'carIds': carIds,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final Map<String, bool> states = {};
        
        for (final carId in carIds) {
          states[carId] = data[carId] ?? false;
        }
        
        return states;
      } else {
        throw Exception('Batch API returned ${response.statusCode}');
      }
    } catch (e) {
      print('Error in batch heart states API: $e');
      rethrow;
    }
  }

  // Update heart state when a car is saved/unsaved
  static Future<void> updateHeartState(String carId, bool isSaved) async {
    try {
      await _cacheHeartState(carId, isSaved);
    } catch (e) {
      print('Error updating heart state for car $carId: $e');
    }
  }

  // Clear heart state cache (useful when user logs out or cache is stale)
  static Future<void> clearHeartStateCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_heartStatesKey);
      await prefs.remove(_lastUpdateKey);
    } catch (e) {
      print('Error clearing heart state cache: $e');
    }
  }

  // Refresh heart states from server (clear cache and reload)
  static Future<void> refreshHeartStates(String userId) async {
    try {
      await clearHeartStateCache();
      // The next call to isCarSaved will fetch fresh data
    } catch (e) {
      print('Error refreshing heart states: $e');
    }
  }

  // Private methods for cache management
  static Future<bool?> _getCachedHeartState(String carId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdate = prefs.getInt(_lastUpdateKey);
      
      // Check if cache is expired
      if (lastUpdate != null) {
        final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
        if (DateTime.now().difference(lastUpdateTime) > _cacheExpiry) {
          // Cache expired, clear it
          print('Cache expired, clearing for $carId');
          await clearHeartStateCache();
          return null;
        }
      }

      final heartStatesString = prefs.getString(_heartStatesKey);
      if (heartStatesString != null) {
        final Map<String, dynamic> heartStates = jsonDecode(heartStatesString);
        final cachedState = heartStates[carId] as bool?;
        print('Retrieved cached state for $carId: $cachedState');
        return cachedState;
      }
      
      print('No cached state found for $carId');
      return null;
    } catch (e) {
      print('Error getting cached heart state: $e');
      return null;
    }
  }

  static Future<void> _cacheHeartState(String carId, bool isSaved) async {
    try {
      print('Caching heart state for $carId: $isSaved');
      final prefs = await SharedPreferences.getInstance();
      final heartStatesString = prefs.getString(_heartStatesKey);
      
      Map<String, dynamic> heartStates = {};
      if (heartStatesString != null) {
        heartStates = Map<String, dynamic>.from(jsonDecode(heartStatesString));
      }
      
      heartStates[carId] = isSaved;
      
      await prefs.setString(_heartStatesKey, jsonEncode(heartStates));
      await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
      print('Successfully cached heart state for $carId');
    } catch (e) {
      print('Error caching heart state: $e');
    }
  }

  // Batch update heart states (useful when multiple cars are affected)
  static Future<void> batchUpdateHeartStates(Map<String, bool> carStates) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final heartStatesString = prefs.getString(_heartStatesKey);
      
      Map<String, dynamic> heartStates = {};
      if (heartStatesString != null) {
        heartStates = Map<String, dynamic>.from(jsonDecode(heartStatesString));
      }
      
      heartStates.addAll(carStates);
      
      await prefs.setString(_heartStatesKey, jsonEncode(heartStates));
      await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error batch updating heart states: $e');
    }
  }

  // Get authentication token (placeholder - replace with actual auth implementation)
  static Future<String> _getAuthToken() async {
    // TODO: Replace with actual authentication token retrieval
    return 'placeholder_token';
  }
} 