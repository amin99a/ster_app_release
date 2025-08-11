import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Insurance.dart';
import '../constants.dart';

class InsuranceService {
  static const String baseUrl = ApiConstants.baseUrl;
  static const String endpoint = '/insurance';

  // Create insurance policy
  static Future<Insurance> createInsurancePolicy({
    required String rentalId,
    required String carId,
    required String userId,
    String? ownerId,
    required InsuranceType type,
    required double coverageAmount,
    required double dailyRate,
    required double totalCost,
    required double deductible,
    List<CoverageEvent> coveredEvents = const [],
    Map<String, dynamic> coverageDetails = const {},
    required DateTime startDate,
    required DateTime endDate,
    String? policyNumber,
    String? insuranceProvider,
    String? providerContact,
    Map<String, dynamic>? terms,
    List<String>? exclusions,
    bool isRequired = false,
    bool isRefundable = true,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'rentalId': rentalId,
          'carId': carId,
          'userId': userId,
          'ownerId': ownerId,
          'type': type.toString().split('.').last,
          'coverageAmount': coverageAmount,
          'dailyRate': dailyRate,
          'totalCost': totalCost,
          'deductible': deductible,
          'coveredEvents': coveredEvents.map((e) => e.toString().split('.').last).toList(),
          'coverageDetails': coverageDetails,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'policyNumber': policyNumber,
          'insuranceProvider': insuranceProvider,
          'providerContact': providerContact,
          'terms': terms,
          'exclusions': exclusions,
          'isRequired': isRequired,
          'isRefundable': isRefundable,
          'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        return Insurance.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create insurance policy: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating insurance policy: $e');
    }
  }

  // Get insurance policy by ID
  static Future<Insurance> getInsurancePolicy(String insuranceId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint/$insuranceId'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        return Insurance.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get insurance policy: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting insurance policy: $e');
    }
  }

  // Get insurance policies for a rental
  static Future<List<Insurance>> getRentalInsurancePolicies(String rentalId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint/rental/$rentalId'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Insurance.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get rental insurance policies: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting rental insurance policies: $e');
    }
  }

  // Get user insurance policies
  static Future<List<Insurance>> getUserInsurancePolicies({
    required String userId,
    InsuranceStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (status != null) queryParams['status'] = status.toString().split('.').last;

      final uri = Uri.parse('$baseUrl$endpoint/user/$userId')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Insurance.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get user insurance policies: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting user insurance policies: $e');
    }
  }

  // Activate insurance policy
  static Future<Insurance> activateInsurancePolicy(String insuranceId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint/$insuranceId/activate'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        return Insurance.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to activate insurance policy: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error activating insurance policy: $e');
    }
  }

  // Cancel insurance policy
  static Future<Insurance> cancelInsurancePolicy({
    required String insuranceId,
    String? cancellationReason,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint/$insuranceId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'cancellationReason': cancellationReason,
        }),
      );

      if (response.statusCode == 200) {
        return Insurance.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to cancel insurance policy: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error cancelling insurance policy: $e');
    }
  }

  // Update insurance policy
  static Future<Insurance> updateInsurancePolicy({
    required String insuranceId,
    Map<String, dynamic>? coverageDetails,
    Map<String, dynamic>? terms,
    List<String>? exclusions,
    String? notes,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint/$insuranceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'coverageDetails': coverageDetails,
          'terms': terms,
          'exclusions': exclusions,
          'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        return Insurance.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update insurance policy: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating insurance policy: $e');
    }
  }

  // Submit insurance claim
  static Future<Map<String, dynamic>> submitClaim({
    required String insuranceId,
    required CoverageEvent eventType,
    required String description,
    required double claimedAmount,
    required DateTime incidentDate,
    String? location,
    List<String>? evidence,
    Map<String, dynamic>? additionalDetails,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint/$insuranceId/claim'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'eventType': eventType.toString().split('.').last,
          'description': description,
          'claimedAmount': claimedAmount,
          'incidentDate': incidentDate.toIso8601String(),
          'location': location,
          'evidence': evidence,
          'additionalDetails': additionalDetails,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit claim: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error submitting claim: $e');
    }
  }

  // Get insurance claims
  static Future<List<Map<String, dynamic>>> getInsuranceClaims({
    String? insuranceId,
    String? userId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (insuranceId != null) queryParams['insuranceId'] = insuranceId;
      if (userId != null) queryParams['userId'] = userId;
      if (status != null) queryParams['status'] = status;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final uri = Uri.parse('$baseUrl$endpoint/claims').replace(queryParameters: queryParams);
      
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
        throw Exception('Failed to get insurance claims: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting insurance claims: $e');
    }
  }

  // Get available insurance types for a car
  static Future<List<Map<String, dynamic>>> getAvailableInsuranceTypes({
    required String carId,
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
  }) async {
    try {
      final queryParams = <String, String>{
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };
      
      if (userId != null) queryParams['userId'] = userId;

      final uri = Uri.parse('$baseUrl$endpoint/available-types/$carId')
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
        throw Exception('Failed to get available insurance types: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting available insurance types: $e');
    }
  }

  // Calculate insurance cost
  static Future<Map<String, dynamic>> calculateInsuranceCost({
    required String carId,
    required InsuranceType type,
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
    Map<String, dynamic>? additionalOptions,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint/calculate-cost'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'carId': carId,
          'type': type.toString().split('.').last,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'userId': userId,
          'additionalOptions': additionalOptions,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to calculate insurance cost: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error calculating insurance cost: $e');
    }
  }

  // Verify insurance coverage
  static Future<bool> verifyInsuranceCoverage({
    required String insuranceId,
    required CoverageEvent eventType,
    required double amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint/$insuranceId/verify-coverage'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'eventType': eventType.toString().split('.').last,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isCovered'] ?? false;
      } else {
        throw Exception('Failed to verify insurance coverage: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error verifying insurance coverage: $e');
    }
  }

  // Get insurance statistics
  static Future<Map<String, dynamic>> getInsuranceStatistics({
    String? userId,
    String? carId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (userId != null) queryParams['userId'] = userId;
      if (carId != null) queryParams['carId'] = carId;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final uri = Uri.parse('$baseUrl$endpoint/statistics').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get insurance statistics: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting insurance statistics: $e');
    }
  }

  // Search insurance policies
  static Future<List<Insurance>> searchInsurancePolicies({
    String? query,
    InsuranceType? type,
    InsuranceStatus? status,
    String? userId,
    String? carId,
    String? rentalId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (query != null) queryParams['query'] = query;
      if (type != null) queryParams['type'] = type.toString().split('.').last;
      if (status != null) queryParams['status'] = status.toString().split('.').last;
      if (userId != null) queryParams['userId'] = userId;
      if (carId != null) queryParams['carId'] = carId;
      if (rentalId != null) queryParams['rentalId'] = rentalId;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final uri = Uri.parse('$baseUrl$endpoint/search').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Insurance.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search insurance policies: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error searching insurance policies: $e');
    }
  }

  // Helper method to get auth token
  static Future<String> _getAuthToken() async {
    // This should be implemented based on your auth system
    // For now, returning a placeholder
    return 'your-auth-token';
  }
} 