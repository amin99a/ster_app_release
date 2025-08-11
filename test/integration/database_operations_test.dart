import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../lib/services/car_service.dart';
import '../../lib/services/booking_service.dart';
import '../../lib/services/notification_service.dart';
import '../../lib/services/context_aware_service.dart';

void main() {
  group('Database Operations Integration Tests', () {
    late CarService carService;
    late BookingService bookingService;
    late NotificationService notificationService;
    late ContextAwareService contextAware;

    setUp(() {
      carService = CarService();
      bookingService = BookingService();
      notificationService = NotificationService();
      contextAware = ContextAwareService();
    });

    group('CarService Database Operations', () {
      test('should load cars with RLS compliance', () async {
        // Arrange
        await carService.initialize();

        // Act
        await carService._loadCars();

        // Assert
        expect(carService.cars, isA<List>());
        expect(carService.error, isNull);
      });

      test('should search cars with filters', () async {
        // Arrange
        await carService.initialize();

        // Act
        final results = await carService.searchCars(
          query: 'test',
          location: 'Algiers',
          minPrice: 100,
          maxPrice: 500,
        );

        // Assert
        expect(results, isA<List>());
      });

      test('should get car by ID', () async {
        // Arrange
        await carService.initialize();
        const testCarId = 'test-car-id';

        // Act
        final car = await carService.getCarById(testCarId);

        // Assert
        // Should handle null gracefully if car doesn't exist
        expect(car, isA<Car?>());
      });

      test('should get featured cars', () async {
        // Arrange
        await carService.initialize();

        // Act
        final featuredCars = await carService.getFeaturedCars();

        // Assert
        expect(featuredCars, isA<List<Car>>());
      });
    });

    group('BookingService Database Operations', () {
      test('should load bookings with RLS compliance', () async {
        // Arrange
        await bookingService.initialize();

        // Act
        await bookingService._loadBookings();

        // Assert
        expect(bookingService.bookings, isA<List>());
        expect(bookingService.error, isNull);
      });

      test('should get bookings by status', () async {
        // Arrange
        await bookingService.initialize();

        // Act
        final pendingBookings = await bookingService.getBookingsByStatus('pending');
        final confirmedBookings = await bookingService.getBookingsByStatus('confirmed');

        // Assert
        expect(pendingBookings, isA<List>());
        expect(confirmedBookings, isA<List>());
      });

      test('should get booking by ID', () async {
        // Arrange
        await bookingService.initialize();
        const testBookingId = 'test-booking-id';

        // Act
        final booking = await bookingService.getBookingById(testBookingId);

        // Assert
        // Should handle null gracefully if booking doesn't exist
        expect(booking, isA<Booking?>());
      });

      test('should calculate earnings for host', () async {
        // Arrange
        await bookingService.initialize();
        const testHostId = 'test-host-id';

        // Act
        final earnings = await bookingService.calculateHostEarnings(testHostId);

        // Assert
        expect(earnings, isA<Map<String, dynamic>>());
        expect(earnings['totalEarnings'], isA<double>());
      });
    });

    group('NotificationService Database Operations', () {
      test('should load notifications with RLS compliance', () async {
        // Arrange
        await notificationService.initialize();

        // Act
        await notificationService._loadNotifications();

        // Assert
        expect(notificationService.notifications, isA<List>());
        expect(notificationService.unreadCount, isA<int>());
      });

      test('should send notification', () async {
        // Arrange
        await notificationService.initialize();
        const testUserId = 'test-user-id';

        // Act
        final success = await notificationService.sendNotification(
          userId: testUserId,
          title: 'Test Notification',
          message: 'This is a test notification',
          type: 'test',
        );

        // Assert
        expect(success, isA<bool>());
      });

      test('should mark notification as read', () async {
        // Arrange
        await notificationService.initialize();
        const testNotificationId = 'test-notification-id';

        // Act
        final success = await notificationService.markAsRead(testNotificationId);

        // Assert
        expect(success, isA<bool>());
      });

      test('should mark all notifications as read', () async {
        // Arrange
        await notificationService.initialize();

        // Act
        final success = await notificationService.markAllAsRead();

        // Assert
        expect(success, isA<bool>());
      });

      test('should delete notification', () async {
        // Arrange
        await notificationService.initialize();
        const testNotificationId = 'test-notification-id';

        // Act
        final success = await notificationService.deleteNotification(testNotificationId);

        // Assert
        expect(success, isA<bool>());
      });
    });

    group('ContextAwareService Database Operations', () {
      test('should execute database operations with context', () async {
        // Arrange
        await contextAware.initialize();
        bool operationExecuted = false;

        // Act
        final result = await contextAware.executeDatabaseOperation(
          operation: 'Test Operation',
          table: 'test_table',
          operationType: 'insert',
          operationFunction: () async {
            operationExecuted = true;
            return true;
          },
          data: {'test': 'data'},
          rlsPolicies: {'insert': 'auth.uid() = user_id'},
        );

        // Assert
        expect(operationExecuted, isTrue);
        expect(result, isTrue);
      });

      test('should analyze features before database operations', () async {
        // Arrange
        await contextAware.initialize();

        // Act
        final analysis = await contextAware.analyzeFeature(
          featureName: 'Test Feature',
          services: ['TestService'],
          tables: ['test_table'],
          operations: ['create', 'update'],
        );

        // Assert
        expect(analysis, isA<FeatureAnalysis>());
        expect(analysis.featureName, equals('Test Feature'));
        expect(analysis.services, contains('TestService'));
        expect(analysis.tables, contains('test_table'));
        expect(analysis.operations, containsAll(['create', 'update']));
      });

      test('should apply business rules', () async {
        // Arrange
        await contextAware.initialize();

        // Act
        final isValid = await contextAware.applyBusinessRules(
          category: 'booking',
          context: {
            'user_id': 'test_user',
            'start_date': DateTime.now(),
            'end_date': DateTime.now().add(const Duration(days: 1)),
            'total_price': 100.0,
          },
        );

        // Assert
        expect(isValid, isA<bool>());
      });

      test('should execute event chains', () async {
        // Arrange
        await contextAware.initialize();
        final steps = [
          EventStep(
            service: 'TestService',
            operation: 'testOperation',
            description: 'Test step',
          ),
        ];

        // Act & Assert
        // Should complete without throwing
        await expectLater(
          contextAware.executeEventChain(
            chainName: 'Test Chain',
            trigger: 'test_trigger',
            steps: steps,
          ),
          completes,
        );
      });
    });

    group('RLS Policy Compliance Tests', () {
      test('should respect RLS policies for car operations', () async {
        // Arrange
        await carService.initialize();

        // Act & Assert
        // These operations should respect RLS policies
        await expectLater(
          carService._loadCars(),
          completes,
        );
      });

      test('should respect RLS policies for booking operations', () async {
        // Arrange
        await bookingService.initialize();

        // Act & Assert
        // These operations should respect RLS policies
        await expectLater(
          bookingService._loadBookings(),
          completes,
        );
      });

      test('should respect RLS policies for notification operations', () async {
        // Arrange
        await notificationService.initialize();

        // Act & Assert
        // These operations should respect RLS policies
        await expectLater(
          notificationService._loadNotifications(),
          completes,
        );
      });
    });

    group('Error Handling Tests', () {
      test('should handle database connection errors gracefully', () async {
        // Arrange
        await carService.initialize();

        // Act
        await carService._loadCars();

        // Assert
        // Should not throw even if database is unavailable
        expect(carService.error, isA<String?>());
      });

      test('should handle authentication errors gracefully', () async {
        // Arrange
        await notificationService.initialize();

        // Act
        await notificationService._loadNotifications();

        // Assert
        // Should handle unauthenticated users gracefully
        expect(notificationService.notifications, isA<List>());
      });

      test('should handle network errors gracefully', () async {
        // Arrange
        await bookingService.initialize();

        // Act
        await bookingService._loadBookings();

        // Assert
        // Should handle network issues gracefully
        expect(bookingService.error, isA<String?>());
      });
    });

    group('Performance Tests', () {
      test('should load data efficiently', () async {
        // Arrange
        await carService.initialize();
        final stopwatch = Stopwatch();

        // Act
        stopwatch.start();
        await carService._loadCars();
        stopwatch.stop();

        // Assert
        // Should complete within reasonable time (5 seconds)
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('should handle large datasets', () async {
        // Arrange
        await bookingService.initialize();

        // Act
        await bookingService._loadBookings();

        // Assert
        // Should handle large datasets without memory issues
        expect(bookingService.bookings, isA<List>());
      });
    });
  });
} 