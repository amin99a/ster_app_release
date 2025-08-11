import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../lib/services/context_tracking_service.dart';
import '../../lib/services/context_aware_service.dart';

// Generate mocks
@GenerateMocks([SupabaseClient])
import 'context_tracking_test.mocks.dart';

void main() {
  group('ContextTrackingService Tests', () {
    late ContextTrackingService contextTracking;
    late MockSupabaseClient mockSupabaseClient;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      contextTracking = ContextTrackingService();
    });

    tearDown(() {
      contextTracking.dispose();
    });

    test('should initialize successfully', () async {
      // Act
      await contextTracking.initialize();

      // Assert
      expect(contextTracking.isInitialized, isTrue);
    });

    test('should track implementation patterns', () async {
      // Arrange
      await contextTracking.initialize();
      const pattern = ImplementationPattern(
        service: 'TestService',
        operation: 'testOperation',
        pattern: 'test_pattern',
        description: 'Test pattern',
        metadata: {'key': 'value'},
      );

      // Act
      contextTracking.trackImplementationPattern(pattern);

      // Assert
      final patterns = contextTracking.getImplementationPatterns('TestService');
      expect(patterns, hasLength(1));
      expect(patterns.first.pattern, equals('test_pattern'));
    });

    test('should track data flows', () async {
      // Arrange
      await contextTracking.initialize();
      const flow = DataFlow(
        source: 'ServiceA',
        target: 'ServiceB',
        dataType: 'user_data',
        description: 'User data flow',
        metadata: {'key': 'value'},
      );

      // Act
      contextTracking.trackDataFlow(flow);

      // Assert
      final flows = contextTracking.getDataFlows('ServiceA');
      expect(flows, hasLength(1));
      expect(flows.first.target, equals('ServiceB'));
    });

    test('should track business rules', () async {
      // Arrange
      await contextTracking.initialize();
      const rule = BusinessRule(
        category: 'booking',
        rule: 'cancellation_policy',
        description: '48h cancellation policy',
        metadata: {'hours': 48},
      );

      // Act
      contextTracking.trackBusinessRule(rule);

      // Assert
      final rules = contextTracking.getBusinessRules('booking');
      expect(rules, hasLength(1));
      expect(rules.first.rule, equals('cancellation_policy'));
    });

    test('should track database operations', () async {
      // Arrange
      await contextTracking.initialize();
      const operation = DatabaseOperation(
        table: 'cars',
        operation: 'insert',
        rlsPolicy: 'auth.uid() = host_id',
        description: 'Car insertion',
        metadata: {'key': 'value'},
      );

      // Act
      contextTracking.trackDatabaseOperation(operation);

      // Assert
      final operations = contextTracking.getDatabaseOperations('cars');
      expect(operations, hasLength(1));
      expect(operations.first.operation, equals('insert'));
    });

    test('should track event chains', () async {
      // Arrange
      await contextTracking.initialize();
      const chain = EventChain(
        name: 'Booking Flow',
        trigger: 'user_creates_booking',
        steps: [
          EventStep(
            service: 'BookingService',
            operation: 'createBooking',
            description: 'Create booking',
          ),
        ],
        metadata: {'key': 'value'},
      );

      // Act
      contextTracking.trackEventChain(chain);

      // Assert
      final chains = contextTracking.getEventChains('Booking Flow');
      expect(chains, hasLength(1));
      expect(chains.first.trigger, equals('user_creates_booking'));
    });

    test('should detect conflicts', () async {
      // Arrange
      await contextTracking.initialize();
      
      // Add conflicting patterns
      contextTracking.trackImplementationPattern(
        const ImplementationPattern(
          service: 'ServiceA',
          operation: 'operation1',
          pattern: 'pattern1',
          description: 'Pattern 1',
        ),
      );
      
      contextTracking.trackImplementationPattern(
        const ImplementationPattern(
          service: 'ServiceA',
          operation: 'operation1',
          pattern: 'pattern2',
          description: 'Pattern 2',
        ),
      );

      // Act
      final conflicts = contextTracking.detectConflicts();

      // Assert
      expect(conflicts, isNotEmpty);
      expect(conflicts.first.service, equals('ServiceA'));
    });

    test('should provide context summary', () async {
      // Arrange
      await contextTracking.initialize();
      
      // Add some data
      contextTracking.trackImplementationPattern(
        const ImplementationPattern(
          service: 'TestService',
          operation: 'testOperation',
          pattern: 'test_pattern',
          description: 'Test pattern',
        ),
      );

      // Act
      final summary = contextTracking.getContextSummary();

      // Assert
      expect(summary, isA<Map<String, dynamic>>());
      expect(summary['implementationPatterns'], isNotEmpty);
    });
  });

  group('ContextAwareService Tests', () {
    late ContextAwareService contextAware;

    setUp(() {
      contextAware = ContextAwareService();
    });

    test('should initialize successfully', () async {
      // Act
      await contextAware.initialize();

      // Assert
      expect(contextAware.isInitialized, isTrue);
    });

    test('should analyze features', () async {
      // Arrange
      await contextAware.initialize();

      // Act
      final analysis = await contextAware.analyzeFeature(
        featureName: 'Test Feature',
        services: ['TestService'],
        tables: ['test_table'],
        operations: ['create'],
      );

      // Assert
      expect(analysis, isA<FeatureAnalysis>());
      expect(analysis.featureName, equals('Test Feature'));
    });

    test('should execute with context', () async {
      // Arrange
      await contextAware.initialize();
      bool operationExecuted = false;

      // Act
      await contextAware.executeWithContext(
        operation: 'Test Operation',
        service: 'TestService',
        operationFunction: () async {
          operationExecuted = true;
          return 'success';
        },
        metadata: {'key': 'value'},
      );

      // Assert
      expect(operationExecuted, isTrue);
    });

    test('should execute database operations', () async {
      // Arrange
      await contextAware.initialize();
      bool operationExecuted = false;

      // Act
      final result = await contextAware.executeDatabaseOperation(
        operation: 'Test DB Operation',
        table: 'test_table',
        operationType: 'insert',
        operationFunction: () async {
          operationExecuted = true;
          return true;
        },
        data: {'key': 'value'},
        rlsPolicies: {'insert': 'auth.uid() = user_id'},
      );

      // Assert
      expect(operationExecuted, isTrue);
      expect(result, isTrue);
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

      // Act
      await contextAware.executeEventChain(
        chainName: 'Test Chain',
        trigger: 'test_trigger',
        steps: steps,
      );

      // Assert
      // Should complete without throwing
      expect(true, isTrue);
    });

    test('should track events', () async {
      // Arrange
      await contextAware.initialize();

      // Act
      contextAware.trackEvent(
        eventType: 'test_event',
        service: 'TestService',
        data: {'key': 'value'},
      );

      // Assert
      final summary = contextAware.getContextSummary();
      expect(summary, isA<Map<String, dynamic>>());
    });

    test('should provide context summary', () {
      // Act
      final summary = contextAware.getContextSummary();

      // Assert
      expect(summary, isA<Map<String, dynamic>>());
    });
  });
} 