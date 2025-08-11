import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Location.dart';
import '../constants.dart';

class LocationService {
  static const String baseUrl = ApiConstants.baseUrl;
  static const String endpoint = '/locations';

  // Get nearby cars
  static Future<List<Map<String, dynamic>>> getNearbyCars({
    required double latitude,
    required double longitude,
    double radius = 50.0, // km
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radius.toString(),
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$baseUrl$endpoint/nearby-cars')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Map<String, dynamic>.from(json)).toList();
      } else {
        throw Exception('Failed to get nearby cars: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting nearby cars: $e');
    }
  }

  // Calculate distance between two points
  static Future<double> calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) async {
    try {
      final queryParams = <String, String>{
        'lat1': lat1.toString(),
        'lon1': lon1.toString(),
        'lat2': lat2.toString(),
        'lon2': lon2.toString(),
      };

      final uri = Uri.parse('$baseUrl$endpoint/calculate-distance')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['distance'] ?? 0.0).toDouble();
      } else {
        throw Exception('Failed to calculate distance: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error calculating distance: $e');
    }
  }

  // Get location by coordinates
  static Future<Location> getLocationByCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final queryParams = <String, String>{
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      };

      final uri = Uri.parse('$baseUrl$endpoint/coordinates')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        return Location.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get location by coordinates: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting location by coordinates: $e');
    }
  }

  // Search locations
  static Future<List<Location>> searchLocations({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'query': query,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$baseUrl$endpoint/search')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Location.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search locations: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error searching locations: $e');
    }
  }

  // Get popular destinations
  static Future<List<Location>> getPopularDestinations({
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$baseUrl$endpoint/popular')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Location.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get popular destinations: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting popular destinations: $e');
    }
  }

  // Get user's recent locations
  static Future<List<Location>> getUserRecentLocations({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };

      final uri = Uri.parse('$baseUrl$endpoint/user/$userId/recent')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Location.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get user recent locations: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting user recent locations: $e');
    }
  }

  // Save user location
  static Future<Location> saveUserLocation({
    required String userId,
    required double latitude,
    required double longitude,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? label,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'address': address,
          'city': city,
          'state': state,
          'country': country,
          'postalCode': postalCode,
          'label': label,
        }),
      );

      if (response.statusCode == 201) {
        return Location.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to save user location: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saving user location: $e');
    }
  }

  // Get cars within geofence
  static Future<List<Map<String, dynamic>>> getCarsInGeofence({
    required double centerLatitude,
    required double centerLongitude,
    required double radius,
    List<String>? carTypes,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'centerLatitude': centerLatitude.toString(),
        'centerLongitude': centerLongitude.toString(),
        'radius': radius.toString(),
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (carTypes != null) queryParams['carTypes'] = jsonEncode(carTypes);
      if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();

      final uri = Uri.parse('$baseUrl$endpoint/geofence-cars')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Map<String, dynamic>.from(json)).toList();
      } else {
        throw Exception('Failed to get cars in geofence: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting cars in geofence: $e');
    }
  }

  // Get route between two points
  static Future<Map<String, dynamic>> getRoute({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
    String? mode = 'driving', // driving, walking, bicycling, transit
  }) async {
    try {
      final queryParams = <String, String>{
        'startLatitude': startLatitude.toString(),
        'startLongitude': startLongitude.toString(),
        'endLatitude': endLatitude.toString(),
        'endLongitude': endLongitude.toString(),
        'mode': mode!,
      };

      final uri = Uri.parse('$baseUrl$endpoint/route')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get route: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting route: $e');
    }
  }

  // Get estimated travel time
  static Future<Map<String, dynamic>> getEstimatedTravelTime({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
    String? mode = 'driving',
    DateTime? departureTime,
  }) async {
    try {
      final queryParams = <String, String>{
        'startLatitude': startLatitude.toString(),
        'startLongitude': startLongitude.toString(),
        'endLatitude': endLatitude.toString(),
        'endLongitude': endLongitude.toString(),
        'mode': mode!,
      };
      
      if (departureTime != null) {
        queryParams['departureTime'] = departureTime.toIso8601String();
      }

      final uri = Uri.parse('$baseUrl$endpoint/travel-time')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get estimated travel time: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting estimated travel time: $e');
    }
  }

  // Get location statistics
  static Future<Map<String, dynamic>> getLocationStatistics({
    double? latitude,
    double? longitude,
    double? radius,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (radius != null) queryParams['radius'] = radius.toString();
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final uri = Uri.parse('$baseUrl$endpoint/statistics')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get location statistics: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting location statistics: $e');
    }
  }

  // Helper method to get auth token
  static Future<String> _getAuthToken() async {
    // This should be implemented based on your auth system
    // For now, returning a placeholder
    return 'your-auth-token';
  }
} 