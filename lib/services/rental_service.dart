import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/rental.dart';
import '../models/payment.dart' as payment_model;

class RentalService extends ChangeNotifier {
  static final RentalService _instance = RentalService._internal();
  factory RentalService() => _instance;
  RentalService._internal();

  List<Rental> _rentals = [];
  bool _isLoading = false;
  String? _error;

  List<Rental> get rentals => _rentals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize rental service
  Future<void> initialize() async {
    await _loadRentals();
  }

  // Load rentals from Supabase
  Future<void> _loadRentals() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await Supabase.instance.client
          .from('rentals')
          .select()
          .order('created_at', ascending: false);

      _rentals = (response as List)
          .map((data) => Rental.fromJson(data))
          .toList();

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load rentals: $e';
      notifyListeners();
    }
  }

  // Create a new rental
  Future<Rental> createRental({
    required String carId,
    required String userId,
    required String hostId,
    required DateTime startDate,
    required DateTime endDate,
    required int rentalDays,
    required double totalPrice,
    required double dailyRate,
    required double depositAmount,
    String? notes,
    Map<String, dynamic>? additionalServices,
    Map<String, double>? additionalCharges,
  }) async {
    try {
      final rentalData = {
        'car_id': carId,
        'user_id': userId,
        'host_id': hostId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'rental_days': rentalDays,
        'total_price': totalPrice,
        'daily_rate': dailyRate,
        'deposit_amount': depositAmount,
        'status': RentalStatus.pending.name,
        'payment_status': RentalPaymentStatus.pending.name,
        'notes': notes,
        'additional_services': additionalServices,
        'additional_charges': additionalCharges,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await Supabase.instance.client
          .from('rentals')
          .insert(rentalData)
          .select()
          .single();

      final rental = Rental.fromJson(response);
      _rentals.insert(0, rental);
      notifyListeners();

      return rental;
    } catch (e) {
      throw Exception('Failed to create rental: $e');
    }
  }

  // Update rental status
  Future<Rental> updateRentalStatus({
    required String rentalId,
    required RentalStatus status,
    String? notes,
  }) async {
    try {
      final updateData = {
        'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (notes != null) {
        updateData['notes'] = notes;
      }

      final response = await Supabase.instance.client
          .from('rentals')
          .update(updateData)
          .eq('id', rentalId)
          .select()
          .single();

      final updatedRental = Rental.fromJson(response);
      final index = _rentals.indexWhere((r) => r.id == rentalId);
      if (index != -1) {
        _rentals[index] = updatedRental;
    notifyListeners();
  }

      return updatedRental;
    } catch (e) {
      throw Exception('Failed to update rental status: $e');
    }
  }

  // Update payment status
  Future<Rental> updatePaymentStatus({
    required String rentalId,
    required RentalPaymentStatus paymentStatus,
  }) async {
    try {
      final response = await Supabase.instance.client
          .from('rentals')
          .update({
            'payment_status': paymentStatus.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', rentalId)
          .select()
          .single();

      final updatedRental = Rental.fromJson(response);
      final index = _rentals.indexWhere((r) => r.id == rentalId);
      if (index != -1) {
        _rentals[index] = updatedRental;
    notifyListeners();
  }

      return updatedRental;
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  // Get rental by ID
  Future<Rental?> getRentalById(String rentalId) async {
    try {
      final response = await Supabase.instance.client
          .from('rentals')
          .select()
          .eq('id', rentalId)
          .single();

      return Rental.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Get rentals by user ID
  Future<List<Rental>> getRentalsByUserId(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('rentals')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => Rental.fromJson(data))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get rentals by host ID
  Future<List<Rental>> getRentalsByHostId(String hostId) async {
    try {
      final response = await Supabase.instance.client
          .from('rentals')
          .select()
          .eq('host_id', hostId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => Rental.fromJson(data))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Cancel rental
  Future<Rental> cancelRental({
    required String rentalId,
    required String cancellationReason,
  }) async {
    try {
      final response = await Supabase.instance.client
          .from('rentals')
          .update({
            'status': RentalStatus.cancelled.name,
            'cancellation_reason': cancellationReason,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', rentalId)
          .select()
          .single();

      final updatedRental = Rental.fromJson(response);
      final index = _rentals.indexWhere((r) => r.id == rentalId);
    if (index != -1) {
        _rentals[index] = updatedRental;
      notifyListeners();
      }

      return updatedRental;
    } catch (e) {
      throw Exception('Failed to cancel rental: $e');
    }
  }

  // Complete rental
  Future<Rental> completeRental({
    required String rentalId,
    required DateTime actualEndDate,
    String? notes,
  }) async {
    try {
      final updateData = {
        'status': RentalStatus.completed.name,
        'actual_end_date': actualEndDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (notes != null) {
        updateData['notes'] = notes;
      }

      final response = await Supabase.instance.client
          .from('rentals')
          .update(updateData)
          .eq('id', rentalId)
          .select()
          .single();

      final updatedRental = Rental.fromJson(response);
      final index = _rentals.indexWhere((r) => r.id == rentalId);
      if (index != -1) {
        _rentals[index] = updatedRental;
    notifyListeners();
  }

      return updatedRental;
    } catch (e) {
      throw Exception('Failed to complete rental: $e');
    }
  }

  // Get active rentals
  List<Rental> getActiveRentals() {
    return _rentals.where((rental) => rental.status == RentalStatus.active).toList();
  }

  // Get completed rentals
  List<Rental> getCompletedRentals() {
    return _rentals.where((rental) => rental.status == RentalStatus.completed).toList();
  }

  // Get cancelled rentals
  List<Rental> getCancelledRentals() {
    return _rentals.where((rental) => rental.status == RentalStatus.cancelled).toList();
  }

  // Get upcoming rentals
  List<Rental> getUpcomingRentals() {
    final now = DateTime.now();
    return _rentals.where((rental) => 
      rental.status == RentalStatus.confirmed && 
      rental.startDate.isAfter(now)
    ).toList();
  }

  // Calculate rental duration
  int calculateRentalDuration(DateTime startDate, DateTime endDate) {
    return endDate.difference(startDate).inDays;
  }

  // Calculate total price
  double calculateTotalPrice({
    required double dailyRate,
    required int rentalDays,
    required double depositAmount,
    Map<String, double>? additionalCharges,
  }) {
    double basePrice = dailyRate * rentalDays;
    double additionalCosts = 0.0;
    if (additionalCharges != null) {
      additionalCosts = additionalCharges.values.fold(0.0, (sum, cost) => sum + cost);
    }
    return basePrice + depositAmount + additionalCosts;
  }

  // Check if rental dates conflict
  bool checkDateConflict({
    required String carId,
    required DateTime startDate,
    required DateTime endDate,
    String? excludeRentalId,
  }) {
    return _rentals.any((rental) {
      if (rental.carId != carId) return false;
      if (excludeRentalId != null && rental.id == excludeRentalId) return false;
      
      // Check if the new rental period overlaps with existing rentals
      return (startDate.isBefore(rental.endDate) && endDate.isAfter(rental.startDate));
    });
  }

  // Get rental statistics
  Map<String, dynamic> getRentalStatistics() {
    final totalRentals = _rentals.length;
    final activeRentals = getActiveRentals().length;
    final completedRentals = getCompletedRentals().length;
    final cancelledRentals = getCancelledRentals().length;
    final upcomingRentals = getUpcomingRentals().length;

    double totalRevenue = _rentals
        .where((r) => r.status == RentalStatus.completed)
        .fold(0.0, (sum, rental) => sum + rental.totalPrice);

    return {
      'totalRentals': totalRentals,
      'activeRentals': activeRentals,
      'completedRentals': completedRentals,
      'cancelledRentals': cancelledRentals,
      'upcomingRentals': upcomingRentals,
      'totalRevenue': totalRevenue,
    };
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 