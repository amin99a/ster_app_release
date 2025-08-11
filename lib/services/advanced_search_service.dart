import 'package:flutter/foundation.dart';
import '../models/car.dart';
import '../models/search_filter.dart';
import 'car_service.dart';

class AdvancedSearchService extends ChangeNotifier {
  static final AdvancedSearchService _instance = AdvancedSearchService._internal();
  factory AdvancedSearchService() => _instance;
  AdvancedSearchService._internal();

  final CarService _carService = CarService();
  
  List<Car> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  SearchFilter _currentFilter = SearchFilter();
  String _searchQuery = '';

  // Getters
  List<Car> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  SearchFilter get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;

  // Search with filters
  Future<void> searchCars({
    String query = '',
    SearchFilter? filter,
  }) async {
    _isLoading = true;
    _error = null;
    _searchQuery = query;
    
    if (filter != null) {
      _currentFilter = filter;
    }
    
    notifyListeners();

    try {
      // Get all cars from service
      final allCars = _carService.cars;
      
      // Apply text search filter
      List<Car> filteredCars = allCars;
      if (query.isNotEmpty) {
        filteredCars = allCars.where((car) =>
          car.name.toLowerCase().contains(query.toLowerCase()) ||
          car.category.toLowerCase().contains(query.toLowerCase()) ||
          car.location.toLowerCase().contains(query.toLowerCase()) ||
          car.hostName.toLowerCase().contains(query.toLowerCase()) ||
          car.description.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }

      // Apply advanced filters
      filteredCars = _applyFilters(filteredCars, _currentFilter);
      
      // Apply sorting
      filteredCars = _applySorting(filteredCars, _currentFilter.sortBy, _currentFilter.sortAscending);
      
      _searchResults = filteredCars;
      _isLoading = false;
      
    } catch (e) {
      _error = 'Failed to search cars: $e';
      _isLoading = false;
    }
    
    notifyListeners();
  }

  // Apply filters to car list
  List<Car> _applyFilters(List<Car> cars, SearchFilter filter) {
    return cars.where((car) {
      // Price filter
      final price = _extractPrice(car.price);
      if (price < filter.minPrice || price > filter.maxPrice) {
        return false;
      }

      // Location filter
      if (filter.selectedWilaya != null && 
          !car.location.toLowerCase().contains(filter.selectedWilaya!.toLowerCase())) {
        return false;
      }

      // Car type filter
      if (filter.carTypes.isNotEmpty && 
          !filter.carTypes.contains(car.category)) {
        return false;
      }

      // Brand filter (extract from car name)
      if (filter.brands.isNotEmpty) {
        final carBrand = _extractBrand(car.name);
        if (carBrand == null || !filter.brands.contains(carBrand)) {
          return false;
        }
      }

      // Transmission filter
      if (filter.transmissions.isNotEmpty) {
        final transmission = car.specs['transmission'] ?? 'Automatic';
        if (!filter.transmissions.contains(transmission)) {
          return false;
        }
      }

      // Fuel type filter
      if (filter.fuelTypes.isNotEmpty) {
        final fuelType = car.specs['fuel'] ?? 'Petrol';
        if (!filter.fuelTypes.contains(fuelType)) {
          return false;
        }
      }

      // Features filter
      if (filter.features.isNotEmpty) {
        final hasRequiredFeatures = filter.features.every((feature) =>
          car.features.any((carFeature) =>
            carFeature.toLowerCase().contains(feature.toLowerCase())
          )
        );
        if (!hasRequiredFeatures) {
          return false;
        }
      }

      // Rating filter
      if (filter.minRating != null && car.rating < filter.minRating!) {
        return false;
      }

      // Trips filter
      if (filter.minTrips != null && car.trips < filter.minTrips!) {
        return false;
      }

      // All-star hosts filter
      if (filter.allStarHostsOnly && car.hostRating < 4.8) {
        return false;
      }

      // Response time filter
      if (filter.responseTime != null && filter.responseTime != 'any') {
        final responseTime = _getResponseTimeCategory(car.responseTime);
        if (responseTime != filter.responseTime) {
          return false;
        }
      }

      // Car use type filter
      if (filter.useType != null && filter.useType!.isNotEmpty) {
        if (car.useType.name != filter.useType) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Apply sorting to car list
  List<Car> _applySorting(List<Car> cars, SortOption sortBy, bool ascending) {
    final sortedCars = List<Car>.from(cars);
    
    switch (sortBy) {
      case SortOption.relevance:
        // Keep original order for relevance
        break;
        
      case SortOption.priceAsc:
        sortedCars.sort((a, b) {
          final priceA = _extractPrice(a.price);
          final priceB = _extractPrice(b.price);
          return priceA.compareTo(priceB);
        });
        break;
        
      case SortOption.priceDesc:
        sortedCars.sort((a, b) {
          final priceA = _extractPrice(a.price);
          final priceB = _extractPrice(b.price);
          return priceB.compareTo(priceA);
        });
        break;
        
      case SortOption.ratingDesc:
        sortedCars.sort((a, b) => b.rating.compareTo(a.rating));
        break;
        
      case SortOption.tripsDesc:
        sortedCars.sort((a, b) => b.trips.compareTo(a.trips));
        break;
        
      case SortOption.newest:
        // For demo purposes, sort by name (in real app, would use creation date)
        sortedCars.sort((a, b) => b.name.compareTo(a.name));
        break;
        
      case SortOption.distance:
        // For demo purposes, sort by location (in real app, would use GPS distance)
        sortedCars.sort((a, b) => a.location.compareTo(b.location));
        break;
    }

    if (!ascending && sortBy != SortOption.priceDesc && sortBy != SortOption.ratingDesc && sortBy != SortOption.tripsDesc) {
      return sortedCars.reversed.toList();
    }

    return sortedCars;
  }

  // Helper methods
  double _extractPrice(String priceString) {
    final cleanPrice = priceString
        .replaceAll('UK£', '')
        .replaceAll(' total', '')
        .replaceAll(',', '');
    return double.tryParse(cleanPrice) ?? 0.0;
  }

  String? _extractBrand(String carName) {
    for (final brand in FilterData.brands) {
      if (carName.toLowerCase().contains(brand.toLowerCase())) {
        return brand;
      }
    }
    return null;
  }

  String _getResponseTimeCategory(String responseTime) {
    if (responseTime.contains('1 hour') || responseTime.contains('30 min')) {
      return 'within_hour';
    } else if (responseTime.contains('24 hour') || responseTime.contains('1 day')) {
      return 'within_day';
    }
    return 'any';
  }

  // Update filter
  void updateFilter(SearchFilter newFilter) {
    _currentFilter = newFilter;
    searchCars(query: _searchQuery, filter: newFilter);
  }

  // Clear filters
  void clearFilters() {
    _currentFilter = SearchFilter();
    searchCars(query: _searchQuery, filter: _currentFilter);
  }

  // Get popular searches
  List<String> getPopularSearches() {
    return [
      'BMW',
      'Mercedes',
      'SUV',
      'Luxury',
      'Automatic',
      'Electric',
      'Convertible',
      'Sports Car',
    ];
  }

  // Get search suggestions
  List<String> getSearchSuggestions(String query) {
    if (query.isEmpty) return [];
    
    final allCars = _carService.cars;
    final suggestions = <String>{};
    
    // Add car names
    for (final car in allCars) {
      if (car.name.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(car.name);
      }
      if (car.category.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(car.category);
      }
      if (car.location.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(car.location);
      }
    }
    
    // Add brands
    for (final brand in FilterData.brands) {
      if (brand.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(brand);
      }
    }
    
    // Add car types
    for (final type in FilterData.carTypes) {
      if (type.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(type);
      }
    }
    
    return suggestions.take(8).toList();
  }

  // Get filter statistics
  Map<String, int> getFilterStats() {
    final allCars = _carService.cars;
    return {
      'totalCars': allCars.length,
      'filteredCars': _searchResults.length,
      'activeFilters': _currentFilter.activeFilterCount,
    };
  }
}