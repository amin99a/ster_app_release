import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/favorite_list.dart';
import '../models/favorite_item.dart';
import 'network_service.dart';
import 'offline_storage_service.dart';

class FavoriteService {
  static final NetworkService _networkService = NetworkService();
  static final OfflineStorageService _offlineStorage = OfflineStorageService();

  // Initialize services
  static Future<void> initialize() async {
    await _networkService.initialize();
    await _offlineStorage.initialize();
  }

  // Get user's favorite lists with offline-first approach
  static Future<List<FavoriteList>> getUserFavoriteLists(String userId) async {
    try {
      // Check cache first
      final cachedData = _offlineStorage.getCachedData<List<dynamic>>(
        AppConstants.favoritesCacheKey,
        userId: userId,
      );

      if (cachedData != null) {
        return cachedData.map((json) => FavoriteList.fromJson(json)).toList();
      }

      // If not cached, try API
      if (_networkService.isOnline) {
        final response = await _networkService.get<List<dynamic>>(
          '${ApiConstants.favoritesEndpoint}/lists',
          queryParameters: {'user_id': userId},
          fromJson: (json) => json['data'] as List<dynamic>,
        );

        if (response.isSuccess && response.data != null) {
          final lists = response.data!.map((json) => FavoriteList.fromJson(json)).toList();
          
          // Cache the data
          await _offlineStorage.cacheData(
            AppConstants.favoritesCacheKey,
            response.data!,
            userId: userId,
          );
          
          return lists;
        } else {
          print('API error: ${response.errorMessage}');
        }
      }

      // Fallback to local storage
      return await _getLocalFavoriteLists(userId);
    } catch (e) {
      print('Error getting favorite lists: $e');
      return await _getLocalFavoriteLists(userId);
    }
  }

  // Get items in a specific list
  static Future<List<FavoriteItem>> getListItems(String listId) async {
    try {
      // Check cache first
      final cachedData = _offlineStorage.getCachedData<List<dynamic>>(
        'favorites_items_$listId',
      );

      if (cachedData != null) {
        return cachedData.map((json) => FavoriteItem.fromJson(json)).toList();
      }

      // If not cached, try API
      if (_networkService.isOnline) {
        final response = await _networkService.get<List<dynamic>>(
          '${ApiConstants.favoritesEndpoint}/lists/$listId/items',
          fromJson: (json) => json['data'] as List<dynamic>,
        );

        if (response.isSuccess && response.data != null) {
          final items = response.data!.map((json) => FavoriteItem.fromJson(json)).toList();
          
          // Cache the data
          await _offlineStorage.cacheData(
            'favorites_items_$listId',
            response.data!,
          );
          
          return items;
        } else {
          print('API error: ${response.errorMessage}');
        }
      }

      // Fallback to local storage
      return await _getLocalFavoriteItems(listId);
    } catch (e) {
      print('Error getting list items: $e');
      return await _getLocalFavoriteItems(listId);
    }
  }

  // Add car to favorites with offline-first approach
  static Future<bool> addToFavorites({
    required String userId,
    required String listId,
    required String carId,
    required String carModel,
    required String carImage,
    required double carRating,
    required int carTrips,
    required String hostName,
    required bool isAllStarHost,
    required String carPrice,
    required String carLocation,
  }) async {
    try {
      final favoriteItem = FavoriteItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        listId: listId,
        carId: carId,
        carModel: carModel,
        carImage: carImage,
        carRating: carRating,
        carTrips: carTrips,
        hostName: hostName,
        isAllStarHost: isAllStarHost,
        carPrice: carPrice,
        carLocation: carLocation,
        savedAt: DateTime.now(),
      );

      final data = {
        'user_id': userId,
        'list_id': listId,
        'car_id': carId,
        'car_model': carModel,
        'car_image': carImage,
        'car_rating': carRating,
        'car_trips': carTrips,
        'host_name': hostName,
        'is_all_star_host': isAllStarHost,
        'car_price': carPrice,
        'car_location': carLocation,
      };

      // Try API first if online
      if (_networkService.isOnline) {
        final response = await _networkService.post<Map<String, dynamic>>(
          '${ApiConstants.favoritesEndpoint}/items',
          body: data,
          fromJson: (json) => json,
        );

        if (response.isSuccess) {
          // Update local storage
          await _addToLocalFavorites(favoriteItem, listId);
          
          // Clear cache to force refresh
          await _offlineStorage.clearCache(key: 'favorites_items_$listId');
          
          return true;
        } else {
          print('API error: ${response.errorMessage}');
        }
      }

      // If offline or API failed, store locally and queue for sync
      await _addToLocalFavorites(favoriteItem, listId);
      
      await _offlineStorage.addOfflineOperation(
        'favorites_add_${DateTime.now().millisecondsSinceEpoch}',
        data,
        'create',
      );

      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  // Remove car from favorites
  static Future<bool> removeFromFavorites(String itemId, String listId, String userId) async {
    try {
      final data = {
        'item_id': itemId,
        'list_id': listId,
        'user_id': userId,
      };

      // Try API first if online
      if (_networkService.isOnline) {
        final response = await _networkService.delete<Map<String, dynamic>>(
          '${ApiConstants.favoritesEndpoint}/items/$itemId',
          fromJson: (json) => json,
        );

        if (response.isSuccess) {
          // Update local storage
          await _removeFromLocalFavorites(itemId, listId);
          
          // Clear cache to force refresh
          await _offlineStorage.clearCache(key: 'favorites_items_$listId');
          
          return true;
        } else {
          print('API error: ${response.errorMessage}');
        }
      }

      // If offline or API failed, update locally and queue for sync
      await _removeFromLocalFavorites(itemId, listId);
      
      await _offlineStorage.addOfflineOperation(
        'favorites_remove_${DateTime.now().millisecondsSinceEpoch}',
        data,
        'delete',
      );

      return true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  // Create new favorite list
  static Future<FavoriteList?> createFavoriteList({
    required String userId,
    required String name,
    String? description,
    String? coverImage,
  }) async {
    try {
      final list = FavoriteList(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        name: name,
        description: description,
        coverImage: coverImage,
        itemCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final data = {
        'user_id': userId,
        'name': name,
        'description': description,
        'cover_image': coverImage,
      };

      // Try API first if online
      if (_networkService.isOnline) {
        final response = await _networkService.post<Map<String, dynamic>>(
          '${ApiConstants.favoritesEndpoint}/lists',
          body: data,
          fromJson: (json) => json,
        );

        if (response.isSuccess && response.data != null) {
          final createdList = FavoriteList.fromJson(response.data!);
          
          // Update local storage
          await _addToLocalFavoriteLists(createdList, userId);
          
          // Clear cache to force refresh
          await _offlineStorage.clearCache(key: AppConstants.favoritesCacheKey, userId: userId);
          
          return createdList;
        } else {
          print('API error: ${response.errorMessage}');
        }
      }

      // If offline or API failed, store locally and queue for sync
      await _addToLocalFavoriteLists(list, userId);
      
      await _offlineStorage.addOfflineOperation(
        'favorites_list_create_${DateTime.now().millisecondsSinceEpoch}',
        data,
        'create',
      );

      return list;
    } catch (e) {
      print('Error creating favorite list: $e');
      return null;
    }
  }

  // Delete favorite list
  static Future<bool> deleteFavoriteList(String listId, String userId) async {
    try {
      final data = {
        'list_id': listId,
        'user_id': userId,
      };

      // Try API first if online
      if (_networkService.isOnline) {
        final response = await _networkService.delete<Map<String, dynamic>>(
          '${ApiConstants.favoritesEndpoint}/lists/$listId',
          fromJson: (json) => json,
        );

        if (response.isSuccess) {
          // Update local storage
          await _removeFromLocalFavoriteLists(listId, userId);
          
          // Clear cache to force refresh
          await _offlineStorage.clearCache(key: AppConstants.favoritesCacheKey, userId: userId);
          
          return true;
        } else {
          print('API error: ${response.errorMessage}');
        }
      }

      // If offline or API failed, update locally and queue for sync
      await _removeFromLocalFavoriteLists(listId, userId);
      
      await _offlineStorage.addOfflineOperation(
        'favorites_list_delete_${DateTime.now().millisecondsSinceEpoch}',
        data,
        'delete',
      );

      return true;
    } catch (e) {
      print('Error deleting favorite list: $e');
      return false;
    }
  }

  // Check if car is favorited
  static Future<bool> isCarFavorited(String carId, String userId) async {
    try {
      // Check cache first
      final cachedData = _offlineStorage.getCachedData<Map<String, dynamic>>(
        'favorites_check_$carId',
        userId: userId,
      );

      if (cachedData != null) {
        return cachedData['is_favorited'] ?? false;
      }

      // If not cached, try API
      if (_networkService.isOnline) {
        final response = await _networkService.get<Map<String, dynamic>>(
          '${ApiConstants.favoritesEndpoint}/check',
          queryParameters: {
            'car_id': carId,
            'user_id': userId,
          },
          fromJson: (json) => json,
        );

        if (response.isSuccess && response.data != null) {
          final isFavorited = response.data!['is_favorited'] ?? false;
          
          // Cache the result
          await _offlineStorage.cacheData(
            'favorites_check_$carId',
            {'is_favorited': isFavorited},
            userId: userId,
            expiration: const Duration(minutes: 5), // Short cache for this
          );
          
          return isFavorited;
        } else {
          print('API error: ${response.errorMessage}');
        }
      }

      // Fallback to local check
      return await _isCarFavoritedLocally(carId, userId);
    } catch (e) {
      print('Error checking if car is favorited: $e');
      return await _isCarFavoritedLocally(carId, userId);
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

  // Clear all cached data
  static Future<void> clearCache() async {
    try {
      print('Clearing favorite service cache...');
      
      // Clear offline storage cache
      await _offlineStorage.clearAllCache();
      
      // Clear SharedPreferences for favorites
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('favorites_') || key.startsWith('favorite_')) {
          await prefs.remove(key);
        }
      }
      
      print('✅ Favorite service cache cleared');
    } catch (e) {
      print('❌ Error clearing favorite service cache: $e');
    }
  }

  // Local storage methods (fallback)
  static Future<List<FavoriteList>> _getLocalFavoriteLists(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listsJson = prefs.getStringList('${AppConstants.favoritesKey}_lists_$userId') ?? [];
      
      return listsJson
          .map((json) => FavoriteList.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error getting local favorite lists: $e');
      return [];
    }
  }

  static Future<List<FavoriteItem>> _getLocalFavoriteItems(String listId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getStringList('${AppConstants.favoritesKey}_items_$listId') ?? [];
      
      return itemsJson
          .map((json) => FavoriteItem.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error getting local favorite items: $e');
      return [];
    }
  }

  static Future<void> _addToLocalFavorites(FavoriteItem item, String listId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final items = await _getLocalFavoriteItems(listId);
      items.add(item);
      
      final itemsJson = items.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList('${AppConstants.favoritesKey}_items_$listId', itemsJson);
      
      // Update list item count
      await _updateListItemCount(listId, items.length);
    } catch (e) {
      print('Error adding to local favorites: $e');
    }
  }

  static Future<void> _removeFromLocalFavorites(String itemId, String listId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final items = await _getLocalFavoriteItems(listId);
      items.removeWhere((item) => item.id == itemId);
      
      final itemsJson = items.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList('${AppConstants.favoritesKey}_items_$listId', itemsJson);
      
      // Update list item count
      await _updateListItemCount(listId, items.length);
    } catch (e) {
      print('Error removing from local favorites: $e');
    }
  }

  static Future<void> _addToLocalFavoriteLists(FavoriteList list, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lists = await _getLocalFavoriteLists(userId);
      lists.add(list);
      
      final listsJson = lists.map((list) => jsonEncode(list.toJson())).toList();
      await prefs.setStringList('${AppConstants.favoritesKey}_lists_$userId', listsJson);
    } catch (e) {
      print('Error adding to local favorite lists: $e');
    }
  }

  static Future<void> _removeFromLocalFavoriteLists(String listId, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lists = await _getLocalFavoriteLists(userId);
      lists.removeWhere((list) => list.id == listId);
      
      final listsJson = lists.map((list) => jsonEncode(list.toJson())).toList();
      await prefs.setStringList('${AppConstants.favoritesKey}_lists_$userId', listsJson);
      
      // Also remove items for this list
      await prefs.remove('${AppConstants.favoritesKey}_items_$listId');
    } catch (e) {
      print('Error removing from local favorite lists: $e');
    }
  }

  static Future<bool> _isCarFavoritedLocally(String carId, String userId) async {
    try {
      final lists = await _getLocalFavoriteLists(userId);
      
      for (final list in lists) {
        final items = await _getLocalFavoriteItems(list.id);
        if (items.any((item) => item.carId == carId)) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Error checking local favorites: $e');
      return false;
    }
  }

  static Future<void> _updateListItemCount(String listId, int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listsJson = prefs.getStringList('${AppConstants.favoritesKey}_lists_${AppConstants.defaultUserId}') ?? [];
      
      final lists = listsJson
          .map((json) => FavoriteList.fromJson(jsonDecode(json)))
          .toList();
      
      final listIndex = lists.indexWhere((list) => list.id == listId);
      if (listIndex != -1) {
        lists[listIndex] = lists[listIndex].copyWith(
          itemCount: count,
          updatedAt: DateTime.now(),
        );
        
        final updatedListsJson = lists.map((list) => jsonEncode(list.toJson())).toList();
        await prefs.setStringList('${AppConstants.favoritesKey}_lists_${AppConstants.defaultUserId}', updatedListsJson);
      }
    } catch (e) {
      print('Error updating list item count: $e');
    }
  }
} 