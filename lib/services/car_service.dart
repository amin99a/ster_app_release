import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/car.dart';
import '../services/logging_service.dart';
import 'context_aware_service.dart';

class CarService extends ChangeNotifier {
  static final CarService _instance = CarService._internal();
  factory CarService() => _instance;
  CarService._internal();

  List<Car> _cars = [];
  bool _isLoading = false;
  String? _error;
  
  // Context-aware service for tracking and validation
  final ContextAwareService _contextAware = ContextAwareService();

  List<Car> get cars => _cars;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize car service with context tracking
  Future<void> initialize() async {
    logger.info('Initializing CarService with context tracking', tag: 'CAR_SERVICE');
    
    // Initialize context tracking
    await _contextAware.initialize();
    
    await _loadCars();
  }

  // Load cars from Supabase with context tracking
  Future<void> _loadCars() async {
    return await _contextAware.executeWithContext(
      operation: 'loadCars',
      service: 'CarService',
      operationFunction: () async {
        try {
          _isLoading = true;
          _error = null;
          notifyListeners();

          logger.info('Loading cars from Supabase', tag: 'CAR_SERVICE');
          final response = await Supabase.instance.client
              .from('cars')
              .select();

          logger.info('Successfully loaded ${response.length} cars', tag: 'CAR_SERVICE');
          _cars = (response as List)
              .map((json) => Car.fromJson(json))
              .toList();
        } catch (e, stackTrace) {
          logger.logError('Loading cars', e, tag: 'CAR_SERVICE', stackTrace: stackTrace);
          _error = 'Failed to load cars: $e';
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      },
      metadata: {
        'operation': 'load_cars',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Get car by ID with context tracking
  Future<Car?> getCarById(String id) async {
    return await _contextAware.executeWithContext(
      operation: 'getCarById',
      service: 'CarService',
      operationFunction: () async {
        try {
          logger.info('Fetching car by ID: $id', tag: 'CAR_SERVICE');
          final response = await Supabase.instance.client
              .from('cars')
              .select()
              .eq('id', id)
              .single();
          
          logger.info('Successfully fetched car: $id', tag: 'CAR_SERVICE');
          return Car.fromJson(response);
        } catch (e, stackTrace) {
          logger.logError('Fetching car $id', e, tag: 'CAR_SERVICE', stackTrace: stackTrace);
          return null;
        }
      },
      metadata: {
        'car_id': id,
        'operation': 'get_car_by_id',
      },
    );
  }

  // Search cars with context tracking
  Future<List<Car>?> searchCars({
    String? query,
    String? location,
    String? category,
    String? useType,
    double? minPrice,
    double? maxPrice,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _contextAware.executeWithContext(
      operation: 'searchCars',
      service: 'CarService',
      operationFunction: () async {
        try {
          logger.info('Searching cars with filters: query=$query, location=$location, category=$category', tag: 'CAR_SERVICE');
          
          var queryBuilder = Supabase.instance.client
              .from('cars')
              .select();

          if (query != null && query.isNotEmpty) {
            queryBuilder = queryBuilder.or('name.ilike.%$query%,description.ilike.%$query%');
          }

          if (location != null && location.isNotEmpty) {
            queryBuilder = queryBuilder.eq('location', location);
          }

          if (category != null && category.isNotEmpty) {
            queryBuilder = queryBuilder.eq('category', category);
          }

          if (useType != null && useType.isNotEmpty) {
            queryBuilder = queryBuilder.eq('use_type', useType.toLowerCase());
          }

          if (minPrice != null) {
            queryBuilder = queryBuilder.gte('price_per_day', minPrice);
          }

          if (maxPrice != null) {
            queryBuilder = queryBuilder.lte('price_per_day', maxPrice);
          }

          if (startDate != null && endDate != null) {
            // Check availability for the date range
            queryBuilder = queryBuilder.not('id', 'in', 
              Supabase.instance.client
                  .from('bookings')
                  .select('car_id')
                  .or('start_date.lte.${endDate.toIso8601String()},end_date.gte.${startDate.toIso8601String()}')
                  .eq('status', 'confirmed')
            );
          }

          final response = await queryBuilder;
          return (response as List).map((json) => Car.fromJson(json)).toList();
        } catch (e, stackTrace) {
          logger.logError('Searching cars', e, tag: 'CAR_SERVICE', stackTrace: stackTrace);
          return [];
        }
      },
      metadata: {
        'query': query,
        'location': location,
        'category': category,
        'min_price': minPrice,
        'max_price': maxPrice,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
      },
    );
  }

  // Add new car with context tracking and RLS validation
  Future<bool?> addCar(Car car) async {
    // Analyze the feature for potential conflicts
    final analysis = await _contextAware.analyzeFeature(
      featureName: 'Add Car',
      services: ['CarService', 'AuthService'],
              tables: ['cars', 'users'],
      operations: ['create', 'insert'],
    );

    if (analysis.hasWarnings) {
      logger.info('⚠️ Warnings detected for car creation: ${analysis.warnings}', tag: 'CAR_SERVICE');
    }

    return await _contextAware.executeDatabaseOperation(
      operation: 'Add Car',
      table: 'cars',
      operationType: 'insert',
      operationFunction: () async {
        try {
          logger.info('Adding new car: ${car.name}', tag: 'CAR_SERVICE');
          final response = await Supabase.instance.client
              .from('cars')
              .insert(car.toJson())
              .select()
              .single();

          logger.info('Successfully added car: ${car.name}', tag: 'CAR_SERVICE');
          await _loadCars(); // Refresh the list
          return true;
        } catch (e, stackTrace) {
          logger.logError('Adding car', e, tag: 'CAR_SERVICE', stackTrace: stackTrace);
          return false;
        }
      },
      data: car.toJson(),
      rlsPolicies: {
        'insert': 'auth.uid() = host_id',
        'select': 'available = true OR auth.uid() = host_id',
        'update': 'auth.uid() = host_id',
        'delete': 'auth.uid() = host_id',
      },
    );
  }

  // Update car with context tracking
  Future<bool?> updateCar(Car car) async {
    return await _contextAware.executeDatabaseOperation(
      operation: 'Update Car',
      table: 'cars',
      operationType: 'update',
      operationFunction: () async {
        try {
          logger.info('Updating car: ${car.id}', tag: 'CAR_SERVICE');
          final response = await Supabase.instance.client
              .from('cars')
              .update(car.toJson())
              .eq('id', car.id)
              .select()
              .single();

          logger.info('Successfully updated car: ${car.id}', tag: 'CAR_SERVICE');
          await _loadCars(); // Refresh the list
          return true;
        } catch (e, stackTrace) {
          logger.logError('Updating car', e, tag: 'CAR_SERVICE', stackTrace: stackTrace);
          return false;
        }
      },
      data: car.toJson(),
      rlsPolicies: {
        'update': 'auth.uid() = host_id',
      },
    );
  }

  // Delete car with context tracking
  Future<bool?> deleteCar(String id) async {
    return await _contextAware.executeDatabaseOperation(
      operation: 'Delete Car',
      table: 'cars',
      operationType: 'delete',
      operationFunction: () async {
        try {
          logger.info('Deleting car: $id', tag: 'CAR_SERVICE');
          await Supabase.instance.client
              .from('cars')
              .delete()
              .eq('id', id);

          logger.info('Successfully deleted car: $id', tag: 'CAR_SERVICE');
          await _loadCars(); // Refresh the list
          return true;
        } catch (e, stackTrace) {
          logger.logError('Deleting car', e, tag: 'CAR_SERVICE', stackTrace: stackTrace);
          return false;
        }
      },
      data: {'id': id},
      rlsPolicies: {
        'delete': 'auth.uid() = host_id',
      },
    );
  }

  // Get featured cars with context tracking
  Future<List<Car>?> getFeaturedCars() async {
    return await _contextAware.executeWithContext(
      operation: 'getFeaturedCars',
      service: 'CarService',
      operationFunction: () async {
        try {
          logger.info('Loading featured cars', tag: 'CAR_SERVICE');
          final response = await Supabase.instance.client
              .from('cars')
              .select()
              .eq('featured', true)
              .eq('available', true)
              .order('rating', ascending: false)
              .limit(10);

          logger.info('Successfully loaded ${response.length} featured cars', tag: 'CAR_SERVICE');
          return (response as List).map((json) => Car.fromJson(json)).toList();
        } catch (e, stackTrace) {
          logger.logError('Loading featured cars', e, tag: 'CAR_SERVICE', stackTrace: stackTrace);
          return [];
        }
      },
      metadata: {
        'operation': 'get_featured_cars',
        'limit': 10,
      },
    );
  }

  // Update car availability with context tracking
  Future<bool?> updateCarAvailability(String carId, bool available) async {
    return await _contextAware.executeDatabaseOperation(
      operation: 'Update Car Availability',
      table: 'cars',
      operationType: 'update',
      operationFunction: () async {
        try {
          logger.info('Updating car availability: $carId to $available', tag: 'CAR_SERVICE');
          await Supabase.instance.client
              .from('cars')
              .update({'available': available})
              .eq('id', carId);

          logger.info('Successfully updated car availability: $carId', tag: 'CAR_SERVICE');
          await _loadCars(); // Refresh the list
          return true;
        } catch (e, stackTrace) {
          logger.logError('Updating car availability', e, tag: 'CAR_SERVICE', stackTrace: stackTrace);
          return false;
        }
      },
      data: {
        'car_id': carId,
        'available': available,
      },
      rlsPolicies: {
        'update': 'auth.uid() = host_id',
      },
    );
  }

  // Get context summary for debugging
  Map<String, dynamic> getContextSummary() {
    return _contextAware.getContextSummary();
  }

  // Get all cars with context tracking
  Future<List<Car>?> getCars() async {
    return await _contextAware.executeWithContext(
      operation: 'getCars',
      service: 'CarService',
      operationFunction: () async {
        try {
          logger.info('Loading all cars', tag: 'CAR_SERVICE');
          final response = await Supabase.instance.client
              .from('cars')
              .select()
              .eq('available', true)
              .order('created_at', ascending: false);

          logger.info('Successfully loaded ${response.length} cars', tag: 'CAR_SERVICE');
          return (response as List).map((json) => Car.fromJson(json)).toList();
        } catch (e, stackTrace) {
          logger.logError('Loading cars', e, tag: 'CAR_SERVICE', stackTrace: stackTrace);
          return [];
        }
      },
      metadata: {
        'operation': 'get_all_cars',
      },
    );
  }

  // Get cars by host name with context tracking
  Future<List<Car>?> getCarsByHostName(String hostName) async {
    return await _contextAware.executeWithContext(
      operation: 'getCarsByHostName',
      service: 'CarService',
      operationFunction: () async {
        try {
          logger.info('Loading cars for host: $hostName', tag: 'CAR_SERVICE');
          final response = await Supabase.instance.client
              .from('cars')
              .select()
              .eq('host_name', hostName)
              .order('created_at', ascending: false);

          logger.info('Successfully loaded ${response.length} cars for host: $hostName', tag: 'CAR_SERVICE');
          return (response as List).map((json) => Car.fromJson(json)).toList();
        } catch (e, stackTrace) {
          logger.logError('Loading cars by host name', e, tag: 'CAR_SERVICE', stackTrace: stackTrace);
          return [];
        }
      },
      metadata: {
        'operation': 'get_cars_by_host',
        'host_name': hostName,
      },
    );
  }
} 