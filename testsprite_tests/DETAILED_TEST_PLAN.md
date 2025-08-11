# STER Car Rental App - Detailed Test Plan

## Test Environment Setup

### Prerequisites
- Flutter SDK 3.2.3+
- Supabase project configured
- Supabase CLI installed
- Stripe test account
- Google Maps API key

### Test Data Setup
```sql
-- Sample test users (Supabase Auth)
INSERT INTO auth.users (email, encrypted_password, email_confirmed_at, created_at, updated_at) VALUES 
('testuser@example.com', crypt('password123', gen_salt('bf')), now(), now(), now()),
('testhost@example.com', crypt('password123', gen_salt('bf')), now(), now(), now()),
('admin@example.com', crypt('password123', gen_salt('bf')), now(), now(), now());

-- Sample test cars (Supabase Database)
INSERT INTO public.cars (name, brand, model, price_per_day, location, host_id, created_at) VALUES 
('BMW X5', 'BMW', 'X5', 150.00, 'Alger', 'testhost@example.com', now()),
('Mercedes C-Class', 'Mercedes', 'C-Class', 120.00, 'Oran', 'testhost@example.com', now()),
('Audi A4', 'Audi', 'A4', 100.00, 'Constantine', 'testhost@example.com', now());
```

## 1. Authentication API Testing

### 1.1 User Registration
**Endpoint:** `POST /auth/v1/signup`  
**Test Cases:**

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| TC-AUTH-001 | Valid user registration | 200 OK, user created |
| TC-AUTH-002 | Duplicate email registration | 400 Bad Request, error message |
| TC-AUTH-003 | Invalid email format | 400 Bad Request, validation error |
| TC-AUTH-004 | Weak password | 400 Bad Request, password requirements |
| TC-AUTH-005 | Missing required fields | 400 Bad Request, field validation |

**Test Data:**
```json
{
  "email": "newuser@example.com",
  "password": "SecurePass123!",
  "data": {
    "username": "newuser",
    "firstName": "John",
    "lastName": "Doe"
  }
}
```

### 1.2 User Login
**Endpoint:** `POST /auth/v1/token`  
**Test Cases:**

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| TC-AUTH-006 | Valid credentials | 200 OK, JWT token returned |
| TC-AUTH-007 | Invalid email | 400 Bad Request, invalid credentials |
| TC-AUTH-008 | Invalid password | 400 Bad Request, invalid credentials |
| TC-AUTH-009 | Non-existent user | 400 Bad Request, user not found |
| TC-AUTH-010 | Account locked | 403 Forbidden, account locked |

### 1.3 Password Reset
**Endpoint:** `POST /auth/v1/recover`  
**Test Cases:**

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| TC-AUTH-011 | Valid email reset request | 200 OK, reset email sent |
| TC-AUTH-012 | Non-existent email | 200 OK, no error (security) |
| TC-AUTH-013 | Invalid email format | 400 Bad Request, validation error |

## 2. Car Management API Testing

### 2.1 Car Search
**Endpoint:** `GET /rest/v1/cars`  
**Test Cases:**

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| TC-CAR-001 | Basic search without filters | 200 OK, all cars returned |
| TC-CAR-002 | Search by location | 200 OK, filtered results |
| TC-CAR-003 | Search by price range | 200 OK, price filtered results |
| TC-CAR-004 | Search by date availability | 200 OK, available cars only |
| TC-CAR-005 | Search with multiple filters | 200 OK, combined filter results |
| TC-CAR-006 | Search with pagination | 200 OK, paginated results |
| TC-CAR-007 | Search with invalid filters | 400 Bad Request, validation error |

**Test Parameters:**
```json
{
  "select": "*",
  "location": "eq.Alger",
  "price_per_day": "gte.50&lte.200",
  "limit": 10,
  "offset": 0
}
```

### 2.2 Car CRUD Operations
**Endpoints:** `GET/POST/PUT/DELETE /rest/v1/cars`  
**Test Cases:**

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| TC-CAR-008 | Create new car | 201 Created, car created |
| TC-CAR-009 | Get car by ID | 200 OK, car details |
| TC-CAR-010 | Update car details | 200 OK, car updated |
| TC-CAR-011 | Delete car | 200 OK, car deleted |
| TC-CAR-012 | Get non-existent car | 404 Not Found |
| TC-CAR-013 | Update with invalid data | 400 Bad Request, validation error |
| TC-CAR-014 | Unauthorized car access | 403 Forbidden (RLS) |

### 2.3 Car Image Management
**Endpoints:** `POST/DELETE /storage/v1/object/car-images`  
**Test Cases:**

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| TC-CAR-015 | Upload car image | 201 Created, image uploaded |
| TC-CAR-016 | Upload multiple images | 201 Created, all images uploaded |
| TC-CAR-017 | Upload invalid file type | 400 Bad Request, file type error |
| TC-CAR-018 | Upload oversized file | 400 Bad Request, file size error |
| TC-CAR-019 | Delete car image | 200 OK, image deleted |
| TC-CAR-020 | Delete non-existent image | 404 Not Found |

## 3. Booking System API Testing

### 3.1 Booking Creation
**Endpoint:** `POST /rest/v1/bookings`  
**Test Cases:**

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| TC-BOOK-001 | Create valid booking | 201 Created, booking created |
| TC-BOOK-002 | Book unavailable dates | 400 Bad Request, date conflict |
| TC-BOOK-003 | Book past dates | 400 Bad Request, invalid dates |
| TC-BOOK-004 | Book same car overlapping | 400 Bad Request, conflict error |
| TC-BOOK-005 | Create booking without auth | 401 Unauthorized |
| TC-BOOK-006 | Book non-existent car | 404 Not Found |

**Test Data:**
```json
{
  "car_id": 1,
  "user_id": "testuser@example.com",
  "start_date": "2024-01-15T10:00:00Z",
  "end_date": "2024-01-17T10:00:00Z",
  "total_price": 300.00,
  "notes": "Early pickup requested"
}
```

### 3.2 Booking Management
**Endpoints:** `GET/PUT/DELETE /rest/v1/bookings`  
**Test Cases:**

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| TC-BOOK-007 | Get user bookings | 200 OK, user bookings |
| TC-BOOK-008 | Get host bookings | 200 OK, host bookings |
| TC-BOOK-009 | Update booking status | 200 OK, status updated |
| TC-BOOK-010 | Cancel booking | 200 OK, booking cancelled |
| TC-BOOK-011 | Get booking statistics | 200 OK, stats returned |
| TC-BOOK-012 | Access other user's booking | 403 Forbidden (RLS) |

### 3.3 Booking Status Updates
**Endpoint:** `PUT /rest/v1/bookings?id=eq.{bookingId}`  
**Test Cases:**

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| TC-BOOK-013 | Confirm booking | 200 OK, status: confirmed |
| TC-BOOK-014 | Start rental | 200 OK, status: active |
| TC-BOOK-015 | Complete rental | 200 OK, status: completed |
| TC-BOOK-016 | Cancel booking | 200 OK, status: cancelled |
| TC-BOOK-017 | Invalid status transition | 400 Bad Request, invalid status |

## 4. Payment Integration Testing

### 4.1 Stripe Payment Processing
**Frontend Service:** `PaymentService`  
**Test Cases:**

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| TC-PAY-001 | Create payment intent | Success, payment intent created |
| TC-PAY-002 | Confirm payment | Success, payment confirmed |
| TC-PAY-003 | Payment with invalid card | Error, payment failed |
| TC-PAY-004 | Insufficient funds | Error, payment declined |
| TC-PAY-005 | Process refund | Success, refund processed |
| TC-PAY-006 | Payment timeout | Error, timeout handling |

### 4.2 Currency Conversion
**Service:** `CurrencyService`  
**Test Cases:**

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| TC-CURR-001 | Get exchange rates | Success, rates returned |
| TC-CURR-002 | Convert currency | Success, converted amount |
| TC-CURR-003 | Invalid currency code | Error, invalid currency |
| TC-CURR-004 | API rate limit | Error, rate limit handling |
| TC-CURR-005 | Offline fallback | Success, cached rates used |

## 5. Real-time Messaging Testing

### 5.1 Chat Functionality
**Service:** `MessagingService` (Supabase Realtime)  
**Test Cases:**

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| TC-CHAT-001 | Send message | Success, message sent |
| TC-CHAT-002 | Receive real-time message | Success, message received |
| TC-CHAT-003 | Get chat history | Success, messages loaded |
| TC-CHAT-004 | Mark message as read | Success, read status updated |
| TC-CHAT-005 | Offline message handling | Success, message queued |
| TC-CHAT-006 | Message synchronization | Success, messages synced |

### 5.2 Notification System
**Service:** `NotificationService`  
**Test Cases:**

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| TC-NOTIF-001 | Send push notification | Success, notification sent |
| TC-NOTIF-002 | Get user notifications | Success, notifications loaded |
| TC-NOTIF-003 | Mark notification as read | Success, read status updated |
| TC-NOTIF-004 | Delete notification | Success, notification deleted |
| TC-NOTIF-005 | Notification permissions | Success, permissions handled |

## 6. User Management Testing

### 6.1 Profile Management
**Endpoints:** `GET/PUT /rest/v1/profiles`  
**Test Cases:**

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| TC-USER-001 | Get user profile | 200 OK, profile data |
| TC-USER-002 | Update profile | 200 OK, profile updated |
| TC-USER-003 | Upload profile picture | 200 OK, image uploaded |
| TC-USER-004 | Access other user's profile | 403 Forbidden (RLS) |
| TC-USER-005 | Invalid profile data | 400 Bad Request, validation error |

### 6.2 Favorites Management
**Service:** `FavoriteService`  
**Test Cases:**

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| TC-FAV-001 | Add car to favorites | Success, car added |
| TC-FAV-002 | Remove from favorites | Success, car removed |
| TC-FAV-003 | Create favorite list | Success, list created |
| TC-FAV-004 | Get favorite lists | Success, lists returned |
| TC-FAV-005 | Delete favorite list | Success, list deleted |

## 7. Performance Testing

### 7.1 Load Testing
**Test Scenarios:**

| Scenario | Users | Duration | Expected Result |
|----------|-------|----------|-----------------|
| LT-001 | 50 concurrent users | 5 minutes | Response time < 2s |
| LT-002 | 100 concurrent users | 10 minutes | Response time < 3s |
| LT-003 | 200 concurrent users | 15 minutes | Response time < 5s |

### 7.2 Stress Testing
**Test Scenarios:**

| Scenario | Users | Duration | Expected Result |
|----------|-------|----------|-----------------|
| ST-001 | 500 concurrent users | 30 minutes | System stability |
| ST-002 | 1000 concurrent users | 1 hour | Graceful degradation |

## 8. Security Testing

### 8.1 Authentication Security
**Test Cases:**

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| TC-SEC-001 | JWT token validation | Success, valid tokens accepted |
| TC-SEC-002 | Expired token handling | 401 Unauthorized |
| TC-SEC-003 | Invalid token format | 401 Unauthorized |
| TC-SEC-004 | Token refresh | Success, new token issued |
| TC-SEC-005 | Brute force protection | 429 Too Many Requests |

### 8.2 Authorization Testing (RLS)
**Test Cases:**

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| TC-SEC-006 | Row Level Security (RLS) | Success, proper access |
| TC-SEC-007 | Unauthorized resource access | 403 Forbidden |
| TC-SEC-008 | Cross-user data access | 403 Forbidden |
| TC-SEC-009 | Admin privilege escalation | 403 Forbidden |

## 9. Error Handling Testing

### 9.1 Network Error Handling
**Test Cases:**

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| TC-ERR-001 | Network timeout | Graceful error handling |
| TC-ERR-002 | Connection lost | Offline mode activation |
| TC-ERR-003 | Server unavailable | Retry mechanism |
| TC-ERR-004 | Data synchronization | Success, data synced |

### 9.2 Data Validation
**Test Cases:**

| Test Case | Description | Expected Result |
|-----------|-------------|-----------------|
| TC-ERR-005 | Invalid input data | 400 Bad Request |
| TC-ERR-006 | Missing required fields | 400 Bad Request |
| TC-ERR-007 | Data type validation | 400 Bad Request |
| TC-ERR-008 | Business rule validation | 400 Bad Request |

## 10. Integration Testing

### 10.1 End-to-End User Flows
**Test Scenarios:**

| Scenario | Description | Expected Result |
|----------|-------------|-----------------|
| E2E-001 | Complete booking flow | Success, booking completed |
| E2E-002 | Payment processing flow | Success, payment processed |
| E2E-003 | Host car management flow | Success, car managed |
| E2E-004 | User communication flow | Success, messages exchanged |

## Test Execution Plan

### Phase 1: Unit Testing (Week 1)
- Authentication service testing
- Car service testing
- Booking service testing
- Payment service testing

### Phase 2: Integration Testing (Week 2)
- Supabase API endpoint testing
- Database integration testing
- External service integration testing

### Phase 3: System Testing (Week 3)
- End-to-end flow testing
- Performance testing
- Security testing

### Phase 4: User Acceptance Testing (Week 4)
- Real user scenario testing
- Cross-platform testing
- Accessibility testing

## Test Reporting

### Daily Test Reports
- Test execution summary
- Defect tracking
- Performance metrics
- Coverage reports

### Weekly Test Reports
- Test progress summary
- Risk assessment
- Quality metrics
- Recommendations

### Final Test Report
- Overall test results
- Defect summary
- Performance analysis
- Release readiness assessment

## Test Automation Strategy

### Automated Test Categories
1. **Unit Tests:** Service layer functions
2. **API Tests:** Supabase REST endpoint validation
3. **Integration Tests:** Service interactions
4. **E2E Tests:** Complete user workflows
5. **Performance Tests:** Load and stress testing

### Test Tools
- **Flutter Testing:** Unit and widget tests
- **Postman/Newman:** API testing
- **JMeter:** Performance testing
- **Cypress:** E2E testing
- **TestSprite:** Automated test generation
- **Supabase CLI:** Local development and testing

## Risk Assessment

### High Risk Areas
1. **Payment Processing:** Financial transactions
2. **Authentication:** Security vulnerabilities
3. **Real-time Features:** Performance issues
4. **Data Integrity:** Data consistency problems
5. **RLS Policies:** Row Level Security validation

### Mitigation Strategies
1. **Comprehensive Testing:** Thorough test coverage
2. **Security Audits:** Regular security assessments
3. **Performance Monitoring:** Continuous monitoring
4. **Backup Strategies:** Data backup and recovery
5. **RLS Testing:** Validate Row Level Security policies

---

**Test Plan Version:** 1.0  
**Last Updated:** $(Get-Date)  
**Next Review:** $(Get-Date).AddDays(7)
