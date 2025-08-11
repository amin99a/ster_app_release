import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/car.dart';
import 'context_aware_service.dart';
import 'context_tracking_service.dart';

class Booking {
  final String id;
  final String carId;
  final String carName;
  final String userId;
  final String userName;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final double depositAmount;
  final double remainingAmount;
  final String status; // 'pending', 'confirmed', 'active', 'completed', 'cancelled'
  final DateTime createdAt;
  final String? hostId;
  final String? hostName;
  final String? notes;
  final String? pickupLocation;
  final String? dropoffLocation;
  final String? paymentMethod;
  final String? insuranceType;
  final double? insuranceCost;

  Booking({
    required this.id,
    required this.carId,
    required this.carName,
    required this.userId,
    required this.userName,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.depositAmount,
    required this.remainingAmount,
    required this.status,
    required this.createdAt,
    this.hostId,
    this.hostName,
    this.notes,
    this.pickupLocation,
    this.dropoffLocation,
    this.paymentMethod,
    this.insuranceType,
    this.insuranceCost,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString() ?? '',
      carId: json['car_id']?.toString() ?? '',
      carName: json['car_name']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '',
      startDate: DateTime.tryParse(json['start_date']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date']?.toString() ?? '') ?? DateTime.now(),
      totalPrice: (json['total_price'] ?? 0.0).toDouble(),
      depositAmount: (json['deposit_amount'] ?? 0.0).toDouble(),
      remainingAmount: (json['remaining_amount'] ?? 0.0).toDouble(),
      status: json['status']?.toString() ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      hostId: json['host_id']?.toString(),
      hostName: json['host_name']?.toString(),
      notes: json['notes']?.toString(),
      pickupLocation: json['pickup_location']?.toString(),
      dropoffLocation: json['dropoff_location']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      insuranceType: json['insurance_type']?.toString(),
      insuranceCost: (json['insurance_cost'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'car_id': carId,
      'car_name': carName,
      'user_id': userId,
      'user_name': userName,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_price': totalPrice,
      'deposit_amount': depositAmount,
      'remaining_amount': remainingAmount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'host_id': hostId,
      'host_name': hostName,
      'notes': notes,
      'pickup_location': pickupLocation,
      'dropoff_location': dropoffLocation,
      'payment_method': paymentMethod,
      'insurance_type': insuranceType,
      'insurance_cost': insuranceCost,
    };
  }
}

class BookingService extends ChangeNotifier {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal();

  SupabaseClient get client => Supabase.instance.client;
  
  // Context-aware service for tracking and validation
  final ContextAwareService _contextAware = ContextAwareService();

  // Initialize the service with context tracking
  Future<void> initialize() async {
    await _contextAware.initialize();
    debugPrint('🚀 BookingService initialized with context tracking');
  }

  // Check car availability for given dates
  Future<bool?> checkCarAvailability({
    required String carId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _contextAware.executeWithContext(
      operation: 'checkCarAvailability',
      service: 'BookingService',
      operationFunction: () async {
        try {
          final response = await client
              .from('bookings')
              .select('id')
              .eq('car_id', carId)
              .inFilter('status', ['confirmed', 'active'])
              .or('start_date.lte.${endDate.toIso8601String()},end_date.gte.${startDate.toIso8601String()}')
              .limit(1);

          return response.isEmpty;
        } catch (e) {
          debugPrint('Error checking car availability: $e');
          return false;
        }
      },
      metadata: {
        'car_id': carId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      },
    );
  }

  // Calculate booking price with discounts
  Future<Map<String, double>?> calculateBookingPrice({
    required Car car,
    required DateTime startDate,
    required DateTime endDate,
    String? insuranceType,
  }) async {
    return await _contextAware.executeWithContext(
      operation: 'calculateBookingPrice',
      service: 'BookingService',
      operationFunction: () async {
        final days = endDate.difference(startDate).inDays;
        final basePrice = (car.dailyRate ?? 0.0) * days;
        
        // Apply discounts based on rental duration
        double discount = 0.0;
        if (days >= 7) {
          discount = 0.10; // 10% discount for 7+ days
        } else if (days >= 3) {
          discount = 0.05; // 5% discount for 3+ days
        }
        
        final discountedPrice = basePrice * (1 - discount);
        
        // Calculate insurance cost
        double insuranceCost = 0.0;
        if (insuranceType != null) {
          switch (insuranceType) {
            case 'basic':
              insuranceCost = discountedPrice * 0.05; // 5% of rental price
              break;
            case 'comprehensive':
              insuranceCost = discountedPrice * 0.10; // 10% of rental price
              break;
            case 'premium':
              insuranceCost = discountedPrice * 0.15; // 15% of rental price
              break;
          }
        }
        
        final totalPrice = discountedPrice + insuranceCost;
        final depositAmount = totalPrice * 0.20; // 20% deposit
        final remainingAmount = totalPrice - depositAmount;
        
        return {
          'basePrice': basePrice,
          'discountedPrice': discountedPrice,
          'insuranceCost': insuranceCost,
          'totalPrice': totalPrice,
          'depositAmount': depositAmount,
          'remainingAmount': remainingAmount,
        };
      },
      metadata: {
        'car_id': car.id,
        'daily_rate': car.dailyRate,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'insurance_type': insuranceType,
      },
    );
  }

  // Create a new booking with context tracking and business rule validation
  Future<Booking?> createBooking({
    required String carId,
    required String carName,
    required String userId,
    required String userName,
    required DateTime startDate,
    required DateTime endDate,
    required double totalPrice,
    required double depositAmount,
    required double remainingAmount,
    String? hostId,
    String? hostName,
    String? notes,
    String? pickupLocation,
    String? dropoffLocation,
    String? paymentMethod,
    String? insuranceType,
    double? insuranceCost,
  }) async {
    // First, analyze the feature for potential conflicts
    final analysis = await _contextAware.analyzeFeature(
      featureName: 'Create Booking',
      services: ['BookingService', 'PaymentService', 'NotificationService'],
      tables: ['bookings', 'payments', 'notifications'],
      operations: ['create', 'insert'],
    );

    if (analysis.hasWarnings) {
      debugPrint('⚠️ Warnings detected for booking creation:');
      for (final warning in analysis.warnings) {
        debugPrint('   - $warning');
      }
    }

    // Apply business rules before creating booking
    final businessRuleValid = await _contextAware.applyBusinessRules(
      category: 'booking',
      context: {
        'user_id': userId,
        'car_id': carId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'total_price': totalPrice,
        'deposit_amount': depositAmount,
      },
    );

    if (!businessRuleValid) {
      debugPrint('❌ Business rule validation failed for booking creation');
      throw Exception('Business rule validation failed');
    }

    return await _contextAware.executeDatabaseOperation(
      operation: 'Create Booking',
      table: 'bookings',
      operationType: 'insert',
      operationFunction: () async {
        try {
          final bookingData = {
            'car_id': carId,
            'car_name': carName,
            'user_id': userId,
            'user_name': userName,
            'start_date': startDate.toIso8601String(),
            'end_date': endDate.toIso8601String(),
            'total_price': totalPrice,
            'deposit_amount': depositAmount,
            'remaining_amount': remainingAmount,
            'status': 'pending',
            'host_id': hostId,
            'host_name': hostName,
            'notes': notes,
            'pickup_location': pickupLocation,
            'dropoff_location': dropoffLocation,
            'payment_method': paymentMethod,
            'insurance_type': insuranceType,
            'insurance_cost': insuranceCost,
            'created_at': DateTime.now().toIso8601String(),
          };

          final response = await client
              .from('bookings')
              .insert(bookingData)
              .select()
              .single();

          final booking = Booking.fromJson(response);
          
          // Execute the booking creation event chain
          await _executeBookingCreationChain(booking);
          
          notifyListeners();
          return booking;
        } catch (e) {
          debugPrint('Error creating booking: $e');
          return null;
        }
      },
      data: {
        'car_id': carId,
        'user_id': userId,
        'total_price': totalPrice,
        'status': 'pending',
      },
      rlsPolicies: {
        'insert': 'auth.uid() = user_id',
        'select': 'auth.uid() = user_id OR auth.uid() = host_id',
        'update': 'auth.uid() = user_id OR auth.uid() = host_id',
      },
    );
  }

  // Execute the booking creation event chain
  Future<void> _executeBookingCreationChain(Booking booking) async {
    await _contextAware.executeEventChain(
      chainName: 'Booking Creation Flow',
      trigger: 'user_creates_booking',
      steps: [
        EventStep(
          service: 'BookingService',
          operation: 'createBooking',
          description: 'Create booking record',
          data: booking.toJson(),
        ),
        EventStep(
          service: 'PaymentService',
          operation: 'processDepositPayment',
          description: 'Process 20% deposit payment',
          data: {
            'booking_id': booking.id,
            'amount': booking.depositAmount,
            'user_id': booking.userId,
          },
        ),
        EventStep(
          service: 'NotificationService',
          operation: 'sendBookingNotification',
          description: 'Send confirmation to user and host',
          data: {
            'booking_id': booking.id,
            'user_id': booking.userId,
            'host_id': booking.hostId,
            'car_name': booking.carName,
          },
        ),
        EventStep(
          service: 'CarService',
          operation: 'updateCarAvailability',
          description: 'Update car availability status',
          data: {
            'car_id': booking.carId,
            'available': false,
          },
        ),
      ],
    );
  }

  // Update booking status with context tracking
  Future<bool> updateBookingStatus({
    required String bookingId,
    required String status,
    String? notes,
  }) async {
    return await _contextAware.executeWithContext(
      operation: 'updateBookingStatus',
      service: 'BookingService',
      operationFunction: () async {
        try {
          final updateData = {
            'status': status,
            if (notes != null) 'notes': notes,
            'updated_at': DateTime.now().toIso8601String(),
          };

          await client
              .from('bookings')
              .update(updateData)
              .eq('id', bookingId);

          notifyListeners();
          return true;
        } catch (e) {
          debugPrint('Error updating booking status: $e');
          return false;
        }
      },
      metadata: {
        'booking_id': bookingId,
        'status': status,
        'notes': notes,
      },
    ) ?? false;
  }

  // Cancel booking with refund calculation and business rule validation
  Future<Map<String, dynamic>?> cancelBooking({
    required String bookingId,
    required DateTime cancellationDate,
  }) async {
    // Apply cancellation business rules
    final cancellationValid = await _contextAware.applyBusinessRules(
      category: 'booking',
      context: {
        'cancellation_date': cancellationDate.toIso8601String(),
        'booking_id': bookingId,
      },
    );

    if (!cancellationValid) {
      debugPrint('❌ Cancellation business rule validation failed');
      throw Exception('Cancellation not allowed');
    }

    return await _contextAware.executeWithContext(
      operation: 'cancelBooking',
      service: 'BookingService',
      operationFunction: () async {
        try {
          final booking = await getBookingById(bookingId);
          if (booking == null) {
            throw Exception('Booking not found');
          }

          final hoursUntilStart = booking.startDate.difference(cancellationDate).inHours;
          double refundPercentage = 0.0;
          String refundReason = '';

          if (hoursUntilStart > 48) {
            refundPercentage = 1.0; // 100% refund
            refundReason = 'Cancelled more than 48 hours before trip';
          } else if (hoursUntilStart > 24) {
            refundPercentage = 0.5; // 50% refund
            refundReason = 'Cancelled between 24-48 hours before trip';
          } else {
            refundPercentage = 0.0; // No refund
            refundReason = 'Cancelled less than 24 hours before trip';
          }

          final refundAmount = booking.depositAmount * refundPercentage;

          // Update booking status
          await updateBookingStatus(
            bookingId: bookingId,
            status: 'cancelled',
            notes: refundReason,
          );

          return {
            'success': true,
            'refundPercentage': refundPercentage,
            'refundAmount': refundAmount,
            'refundReason': refundReason,
          };
        } catch (e) {
          debugPrint('Error cancelling booking: $e');
          return {
            'success': false,
            'error': e.toString(),
          };
        }
      },
      metadata: {
        'booking_id': bookingId,
        'cancellation_date': cancellationDate.toIso8601String(),
      },
    );
  }

  // Get booking by ID with context tracking
  Future<Booking?> getBookingById(String bookingId) async {
    return await _contextAware.executeWithContext(
      operation: 'getBookingById',
      service: 'BookingService',
      operationFunction: () async {
        try {
          final response = await client
              .from('bookings')
              .select()
              .eq('id', bookingId)
              .single();

          return Booking.fromJson(response);
        } catch (e) {
          debugPrint('Error getting booking by ID: $e');
          return null;
        }
      },
      metadata: {
        'booking_id': bookingId,
      },
    );
  }

  // Get user bookings with context tracking
  Future<List<Booking>?> getUserBookings({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    return await _contextAware.executeWithContext(
      operation: 'getUserBookings',
      service: 'BookingService',
      operationFunction: () async {
        try {
          final currentUser = client.auth.currentUser;
          if (currentUser == null) return [];

          var query = client
              .from('bookings')
              .select()
              .eq('user_id', currentUser.id);

          if (status != null) {
            query = query.eq('status', status);
          }

          final response = await query
              .order('created_at', ascending: false)
              .range(offset, offset + limit - 1);
          return response.map((json) => Booking.fromJson(json)).toList();
        } catch (e) {
          debugPrint('Error fetching user bookings: $e');
          return [];
        }
      },
      metadata: {
        'status': status,
        'limit': limit,
        'offset': offset,
      },
    );
  }

  // Get host bookings with context tracking
  Future<List<Booking>?> getHostBookings({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    return await _contextAware.executeWithContext(
      operation: 'getHostBookings',
      service: 'BookingService',
      operationFunction: () async {
        try {
          final currentUser = client.auth.currentUser;
          if (currentUser == null) return [];

          var query = client
              .from('bookings')
              .select()
              .eq('host_id', currentUser.id);

          if (status != null) {
            query = query.eq('status', status);
          }

          final response = await query
              .order('created_at', ascending: false)
              .range(offset, offset + limit - 1);
          return response.map((json) => Booking.fromJson(json)).toList();
        } catch (e) {
          debugPrint('Error fetching host bookings: $e');
          return [];
        }
      },
      metadata: {
        'status': status,
        'limit': limit,
        'offset': offset,
      },
    );
  }

  // Get active bookings count
  Future<int> getActiveBookingsCount(String userId) async {
    try {
      final bookings = await getUserBookings(status: 'active');
      return bookings?.length ?? 0;
    } catch (e) {
      debugPrint('Error getting active bookings count: $e');
      return 0;
    }
  }

  // Get pending bookings count
  Future<int> getPendingBookingsCount(String userId) async {
    try {
      final bookings = await getUserBookings(status: 'pending');
      return bookings?.length ?? 0;
    } catch (e) {
      debugPrint('Error getting pending bookings count: $e');
      return 0;
    }
  }

  // Get total earnings for a host
  Future<double> getTotalEarnings(String hostId) async {
    try {
      final response = await client
          .from('bookings')
          .select('total_price')
          .eq('host_id', hostId)
          .eq('status', 'completed');

      double totalEarnings = 0.0;
      for (final booking in response) {
        totalEarnings += (booking['total_price'] ?? 0.0).toDouble();
      }

      return totalEarnings;
    } catch (e) {
      debugPrint('Error getting total earnings: $e');
      return 0.0;
    }
  }

  // Get context summary for debugging
  Map<String, dynamic> getContextSummary() {
    return _contextAware.getContextSummary();
  }
} 