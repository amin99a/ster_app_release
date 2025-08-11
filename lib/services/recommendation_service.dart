import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/car.dart';
import '../models/user.dart' as app_user;

class RecommendationService extends ChangeNotifier {
  static final RecommendationService _instance = RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  List<Car> _recommendations = [];
  bool _isLoading = false;
  String? _error;

  List<Car> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize recommendation service
  Future<void> initialize() async {
    // Initialize with empty recommendations
    _recommendations = [];
    notifyListeners();
  }

  // Get personalized recommendations for a user
  Future<List<Car>> getPersonalizedRecommendations(app_user.User user, List<Car> availableCars) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simple recommendation algorithm based on user preferences
      List<Car> recommendations = [];
      
      // Filter cars based on user preferences
      for (Car car in availableCars) {
        double score = _calculateRecommendationScore(car, user);
        if (score > 0.5) {
          recommendations.add(car);
        }
      }

      // Sort by recommendation score
      recommendations.sort((a, b) {
        double scoreA = _calculateRecommendationScore(a, user);
        double scoreB = _calculateRecommendationScore(b, user);
        return scoreB.compareTo(scoreA);
      });

      _recommendations = recommendations.take(10).toList();
      _isLoading = false;
      notifyListeners();
      
      return _recommendations;
    } catch (e) {
      _error = 'Failed to get recommendations: $e';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Calculate recommendation score for a car based on user preferences
  double _calculateRecommendationScore(Car car, app_user.User user) {
    double score = 0.0;
    
    // Base score from car rating
    score += (car.rating / 5.0) * 0.3;
    
    // Price preference (assuming user prefers lower prices)
    if (car.dailyRate != null) {
      // Normalize price score (lower price = higher score)
      double normalizedPrice = 1.0 - (car.dailyRate! / 1000.0).clamp(0.0, 1.0);
      score += normalizedPrice * 0.2;
    }
    
    // Location preference (if user has location)
    if (user.location != null && car.latitude != null && car.longitude != null) {
      double distance = _calculateDistance(
        user.location!.latitude, 
        user.location!.longitude,
        car.latitude!,
        car.longitude!
      );
      // Closer cars get higher scores
      double distanceScore = 1.0 - (distance / 100.0).clamp(0.0, 1.0);
      score += distanceScore * 0.2;
    }
    
    // Host rating preference
    score += (car.hostRating / 5.0) * 0.15;
    
    // Trip count preference (more trips = more reliable)
    double tripScore = (car.trips / 100.0).clamp(0.0, 1.0);
    score += tripScore * 0.1;
    
    // Availability bonus
    if (car.isAvailable) {
      score += 0.05;
    }
    
    return score.clamp(0.0, 1.0);
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
                cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
                sin(dLon / 2) * sin(dLon / 2);
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Get recommendations by category
  Future<List<Car>> getRecommendationsByCategory(String category, List<Car> availableCars) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      List<Car> categoryCars = availableCars
          .where((car) => car.category.toLowerCase() == category.toLowerCase())
          .toList();

      // Sort by rating
      categoryCars.sort((a, b) => b.rating.compareTo(a.rating));

      _recommendations = categoryCars.take(10).toList();
      _isLoading = false;
      notifyListeners();
      
      return _recommendations;
    } catch (e) {
      _error = 'Failed to get category recommendations: $e';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Get recommendations by price range
  Future<List<Car>> getRecommendationsByPriceRange(double minPrice, double maxPrice, List<Car> availableCars) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      List<Car> priceFilteredCars = availableCars
          .where((car) {
            if (car.dailyRate == null) return false;
            return car.dailyRate! >= minPrice && car.dailyRate! <= maxPrice;
          })
          .toList();

      // Sort by price (lowest first)
      priceFilteredCars.sort((a, b) {
        if (a.dailyRate == null && b.dailyRate == null) return 0;
        if (a.dailyRate == null) return 1;
        if (b.dailyRate == null) return -1;
        return a.dailyRate!.compareTo(b.dailyRate!);
      });

      _recommendations = priceFilteredCars.take(10).toList();
      _isLoading = false;
      notifyListeners();
      
      return _recommendations;
    } catch (e) {
      _error = 'Failed to get price range recommendations: $e';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Get recommendations by location
  Future<List<Car>> getRecommendationsByLocation(double latitude, double longitude, double radiusKm, List<Car> availableCars) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      List<Car> nearbyCars = availableCars
          .where((car) {
            if (car.latitude == null || car.longitude == null) return false;
            double distance = _calculateDistance(latitude, longitude, car.latitude!, car.longitude!);
            return distance <= radiusKm;
          })
          .toList();

      // Sort by distance
      nearbyCars.sort((a, b) {
        if (a.latitude == null || a.longitude == null) return 1;
        if (b.latitude == null || b.longitude == null) return -1;
        
        double distanceA = _calculateDistance(latitude, longitude, a.latitude!, a.longitude!);
        double distanceB = _calculateDistance(latitude, longitude, b.latitude!, b.longitude!);
        return distanceA.compareTo(distanceB);
      });

      _recommendations = nearbyCars.take(10).toList();
      _isLoading = false;
      notifyListeners();
      
      return _recommendations;
    } catch (e) {
      _error = 'Failed to get location-based recommendations: $e';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Clear recommendations
  void clearRecommendations() {
    _recommendations = [];
    _error = null;
    notifyListeners();
  }
}