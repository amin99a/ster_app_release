import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/car.dart';

class SearchCacheService {
  static const String _cacheKey = 'search_cache';
  static const String _cacheTimestampKey = 'search_cache_timestamp';
  static const Duration _cacheExpiry = Duration(hours: 1); // Cache for 1 hour

  // Cache search results
  static Future<void> cacheSearchResults(String query, List<Car> results) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'query': query.toLowerCase().trim(),
        'results': results.map((car) => car.toJson()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await prefs.setString(_cacheKey, jsonEncode(cacheData));
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching search results: $e');
    }
  }

  // Get cached search results
  static Future<List<Car>?> getCachedResults(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheString = prefs.getString(_cacheKey);
      final timestamp = prefs.getInt(_cacheTimestampKey);
      
      if (cacheString == null || timestamp == null) {
        return null;
      }

      // Check if cache is expired
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      if (now.difference(cacheTime) > _cacheExpiry) {
        await clearCache();
        return null;
      }

      final cacheData = jsonDecode(cacheString) as Map<String, dynamic>;
      final cachedQuery = cacheData['query'] as String;
      
      // Check if query matches (case-insensitive)
      if (cachedQuery != query.toLowerCase().trim()) {
        return null;
      }

      final resultsJson = cacheData['results'] as List<dynamic>;
      return resultsJson.map((json) => Car.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error retrieving cached results: $e');
      return null;
    }
  }

  // Check if we have cached data for a query
  static Future<bool> hasCachedData(String query) async {
    final cachedResults = await getCachedResults(query);
    return cachedResults != null;
  }

  // Clear all cached data
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimestampKey);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Get cache statistics
  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheString = prefs.getString(_cacheKey);
      final timestamp = prefs.getInt(_cacheTimestampKey);
      
      if (cacheString == null || timestamp == null) {
        return {
          'hasData': false,
          'age': null,
          'size': 0,
        };
      }

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final age = now.difference(cacheTime);
      
      return {
        'hasData': true,
        'age': age,
        'size': cacheString.length,
        'isExpired': age > _cacheExpiry,
      };
    } catch (e) {
      return {
        'hasData': false,
        'age': null,
        'size': 0,
      };
    }
  }
} 