# Context Tracking System Guide

## Overview

The Context Tracking System helps maintain consistency and avoid breaking existing flows when implementing new features in the STER car rental app. It tracks:

- **Implementation Patterns**: How features are implemented
- **Data Flows**: How data moves between services
- **Business Rules**: Business logic constraints
- **Database Operations**: RLS policies and database patterns
- **Event Chains**: Multi-step processes (e.g., booking → payment → notification)

## 🎯 Goals

1. **Remember Previous Implementations**: Track existing patterns and reuse them
2. **Link Related Logic**: Connect data flows and business rules
3. **Avoid Breaking Connections**: Warn about potential conflicts
4. **Maintain Consistency**: Follow established patterns

## 📋 Core Services

### ContextTrackingService
Tracks and stores context information about the codebase.

### ContextAwareService
Provides guidance and warnings when implementing new features.

## 🔧 Usage Examples

### 1. Analyzing a New Feature

```dart
final contextAware = ContextAwareService();

// Analyze a new feature before implementing
final analysis = await contextAware.analyzeFeature(
  featureName: 'User Review System',
  services: ['ReviewService', 'NotificationService', 'UserService'],
  tables: ['reviews', 'notifications', 'users'],
  operations: ['create', 'update', 'delete'],
);

// Check for warnings
if (analysis.hasWarnings) {
  print('⚠️ Potential conflicts detected:');
  for (final warning in analysis.warnings) {
    print('   - $warning');
  }
}

// Get recommendations
analysis.printAnalysis();
```

### 2. Executing with Context Tracking

```dart
// Execute a service method with context tracking
final result = await contextAware.executeWithContext(
  operation: 'createReview',
  service: 'ReviewService',
  operationFunction: () async {
    // Your actual implementation here
    return await reviewService.createReview(reviewData);
  },
  metadata: {
    'user_id': userId,
    'car_id': carId,
    'rating': rating,
  },
);
```

### 3. Database Operations with RLS Awareness

```dart
// Execute database operation with RLS policy tracking
final result = await contextAware.executeDatabaseOperation(
  operation: 'Create Review',
  table: 'reviews',
  operationType: 'insert',
  operationFunction: () async {
    return await supabase
        .from('reviews')
        .insert(reviewData)
        .select()
        .single();
  },
  data: reviewData,
  rlsPolicies: {
    'insert': 'auth.uid() = reviewer_id',
    'select': 'status = \'approved\' OR auth.uid() = reviewer_id',
  },
);
```

### 4. Event Chain Execution

```dart
// Execute a multi-step event chain
final success = await contextAware.executeEventChain(
  chainName: 'Review Creation Flow',
  trigger: 'user_creates_review',
  steps: [
    EventStep(
      service: 'ReviewService',
      operation: 'createReview',
      description: 'Create review record',
    ),
    EventStep(
      service: 'NotificationService',
      operation: 'sendReviewNotification',
      description: 'Notify host about new review',
    ),
    EventStep(
      service: 'UserService',
      operation: 'updateUserRating',
      description: 'Update user average rating',
    ),
  ],
);
```

### 5. Business Rule Validation

```dart
// Check business rules before executing
final isValid = contextAware.checkBusinessRule(
  category: 'review',
  ruleName: 'Review Moderation Policy',
  context: {
    'user_role': 'user',
    'review_count': 5,
    'rating': 4.5,
  },
);

if (!isValid) {
  print('❌ Business rule violation detected');
  return;
}
```

## 📊 Tracked Patterns

### Database Operations
- **Cars Table**: CRUD operations with host-based RLS
- **Bookings Table**: User/host access patterns
- **Payments Table**: Payment processing flows
- **Reviews Table**: Moderation and rating patterns

### Event Chains
1. **Booking Creation Flow**:
   - BookingService.createBooking()
   - PaymentService.processDepositPayment()
   - NotificationService.sendBookingNotification()
   - CarService.updateCarAvailability()

2. **Payment Processing Flow**:
   - PaymentService.updatePaymentStatus()
   - BookingService.updateBookingStatus()
   - NotificationService.sendPaymentNotification()

### Business Rules
1. **Booking Cancellation Policy**:
   - 48h before: 100% refund
   - 24h before: 50% refund
   - Less than 24h: No refund

2. **Host Verification Required**:
   - Document upload required
   - Background check required
   - Verification before listing cars

## 🔍 Conflict Detection

The system automatically detects:

### Service Conflicts
- Multiple services modifying the same data
- Inconsistent business logic across services
- Broken data flows

### Database Conflicts
- RLS policy violations
- Constraint violations
- Inconsistent data patterns

### Business Rule Conflicts
- Rule violations in new implementations
- Inconsistent policy application
- Missing validation logic

## 📝 Best Practices

### 1. Always Analyze Before Implementing
```dart
// Before implementing a new feature
final analysis = await contextAware.analyzeFeature(
  featureName: 'New Feature',
  services: ['Service1', 'Service2'],
  tables: ['table1', 'table2'],
  operations: ['create', 'update'],
);

if (analysis.hasWarnings) {
  // Address warnings before proceeding
  print('Warnings found: ${analysis.warnings}');
}
```

### 2. Reuse Existing Patterns
```dart
// Check for existing patterns
final patterns = contextAware.suggestPatterns('payment');
for (final pattern in patterns) {
  print('Reusable pattern: ${pattern.pattern}');
  print('Description: ${pattern.description}');
}
```

### 3. Follow Established Data Flows
```dart
// Get existing flows for a service
final flows = contextAware.getServicePatterns('BookingService');
for (final flow in flows) {
  print('Existing flow: ${flow.pattern}');
}
```

### 4. Validate Business Rules
```dart
// Apply business rules to operations
final isValid = await contextAware.applyBusinessRules(
  category: 'booking',
  context: {
    'user_id': userId,
    'booking_date': bookingDate,
    'cancellation_date': cancellationDate,
  },
);
```

## 🚨 Warning Types

### Service Warnings
- `⚠️ Feature "X" may conflict with business rule "Y" in category Z`
- `⚠️ Feature "X" may affect data flow: ServiceA → ServiceB`

### Database Warnings
- `⚠️ Feature "X" will interact with RLS policies on table "Y"`
- `⚠️ Feature "X" may violate existing constraints on table "Y"`

### Business Rule Warnings
- `⚠️ Feature "X" may violate business rule "Y"`
- `⚠️ Feature "X" missing required validation for rule "Y"`

## 🔄 Integration with Existing Services

### CarService Integration
```dart
class CarService extends ChangeNotifier {
  final ContextAwareService _contextAware = ContextAwareService();

  Future<bool> addCar(Car car) async {
    return await _contextAware.executeWithContext(
      operation: 'addCar',
      service: 'CarService',
      operationFunction: () async {
        // Existing implementation
        final response = await Supabase.instance.client
            .from('cars')
            .insert(car.toJson())
            .select()
            .single();
        return true;
      },
      metadata: {
        'host_id': car.hostId,
        'car_name': car.name,
      },
    );
  }
}
```

### BookingService Integration
```dart
class BookingService extends ChangeNotifier {
  final ContextAwareService _contextAware = ContextAwareService();

  Future<String?> createBooking(Booking booking) async {
    // Check business rules first
    final isValid = await _contextAware.applyBusinessRules(
      category: 'booking',
      context: {
        'user_id': booking.userId,
        'start_date': booking.startDate,
        'end_date': booking.endDate,
      },
    );

    if (!isValid) {
      throw Exception('Business rule validation failed');
    }

    return await _contextAware.executeWithContext(
      operation: 'createBooking',
      service: 'BookingService',
      operationFunction: () async {
        // Existing implementation
        final response = await client
            .from('bookings')
            .insert(booking.toJson())
            .select()
            .single();
        return response['id'];
      },
    );
  }
}
```

## 📈 Monitoring and Debugging

### Get Context Summary
```dart
final summary = contextAware.getContextSummary();
print('Tracked patterns: ${summary['implementationPatterns']}');
print('Data flows: ${summary['dataFlows']}');
print('Business rules: ${summary['businessRules']}');
print('Database operations: ${summary['databaseOperations']}');
print('Event chains: ${summary['eventChains']}');
```

### Debug Context Tracking
```dart
// Enable debug logging
debugPrint('🔍 Context tracking enabled');

// Check specific patterns
final carPatterns = contextAware.getServicePatterns('CarService');
print('Car service patterns: ${carPatterns.length}');

// Check specific flows
final bookingFlows = contextAware.getDataFlows('BookingService');
print('Booking service flows: ${bookingFlows.length}');
```

## 🎯 Arabic Context (السياق العربي)

### الأهداف الرئيسية:
- **تذكر التنفيذات السابقة**: تتبع الأنماط الموجودة وإعادة استخدامها
- **ربط المنطق المرتبط**: ربط تدفقات البيانات وقواعد العمل
- **تجنب كسر الاتصالات**: تحذير من التعارضات المحتملة
- **الحفاظ على الاتساق**: اتباع الأنماط المؤسسة

### الاستخدام:
```dart
// تحليل ميزة جديدة قبل التنفيذ
final analysis = await contextAware.analyzeFeature(
  featureName: 'نظام المراجعات',
  services: ['ReviewService', 'NotificationService'],
  tables: ['reviews', 'notifications'],
  operations: ['create', 'update'],
);

// التحقق من التحذيرات
if (analysis.hasWarnings) {
  print('⚠️ تم اكتشاف تعارضات محتملة');
  for (final warning in analysis.warnings) {
    print('   - $warning');
  }
}
```

## 🔧 Setup and Initialization

### Initialize in main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(/* config */);
  
  // Initialize context tracking
  final contextAware = ContextAwareService();
  await contextAware.initialize();
  
  runApp(MyApp());
}
```

### Initialize in services
```dart
class MyService extends ChangeNotifier {
  final ContextAwareService _contextAware = ContextAwareService();
  
  @override
  void initState() {
    super.initState();
    _contextAware.initialize();
  }
}
```

This context tracking system ensures that new features are implemented consistently with existing patterns and don't break established data flows or business rules. 