import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Dispute.dart';
import '../constants.dart';

class DisputeService {
  static const String baseUrl = ApiConstants.baseUrl;
  static const String endpoint = '/disputes';

  // Create a new dispute
  static Future<Dispute> createDispute({
    required String rentalId,
    required String carId,
    required String initiatorId,
    required String initiatorName,
    required String respondentId,
    required String respondentName,
    required DisputeType type,
    required String title,
    required String description,
    double claimedAmount = 0.0,
    String? currency,
    List<String> evidence = const [],
    List<String> attachments = const [],
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
          'initiatorId': initiatorId,
          'initiatorName': initiatorName,
          'respondentId': respondentId,
          'respondentName': respondentName,
          'type': type.toString().split('.').last,
          'title': title,
          'description': description,
          'claimedAmount': claimedAmount,
          'currency': currency,
          'evidence': evidence,
          'attachments': attachments,
        }),
      );

      if (response.statusCode == 201) {
        return Dispute.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create dispute: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating dispute: $e');
    }
  }

  // Get dispute by ID
  static Future<Dispute> getDispute(String disputeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint/$disputeId'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        return Dispute.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get dispute: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting dispute: $e');
    }
  }

  // Get disputes for a user
  static Future<List<Dispute>> getUserDisputes(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint/user/$userId'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Dispute.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get user disputes: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting user disputes: $e');
    }
  }

  // Get disputes for a rental
  static Future<List<Dispute>> getRentalDisputes(String rentalId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint/rental/$rentalId'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Dispute.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get rental disputes: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting rental disputes: $e');
    }
  }

  // Update dispute status
  static Future<Dispute> updateDisputeStatus({
    required String disputeId,
    required DisputeStatus status,
    String? notes,
    String? assignedTo,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint/$disputeId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'status': status.toString().split('.').last,
          'notes': notes,
          'assignedTo': assignedTo,
        }),
      );

      if (response.statusCode == 200) {
        return Dispute.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update dispute status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating dispute status: $e');
    }
  }

  // Add evidence to dispute
  static Future<Dispute> addEvidence({
    required String disputeId,
    required List<String> evidence,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint/$disputeId/evidence'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'evidence': evidence,
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        return Dispute.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to add evidence: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding evidence: $e');
    }
  }

  // Add attachments to dispute
  static Future<Dispute> addAttachments({
    required String disputeId,
    required List<String> attachments,
    String? description,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint/$disputeId/attachments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'attachments': attachments,
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        return Dispute.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to add attachments: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding attachments: $e');
    }
  }

  // Resolve dispute
  static Future<Dispute> resolveDispute({
    required String disputeId,
    required DisputeResolution resolution,
    required String resolutionNotes,
    double? resolvedAmount,
    String? resolvedBy,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint/$disputeId/resolve'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'resolution': resolution.toString().split('.').last,
          'resolutionNotes': resolutionNotes,
          'resolvedAmount': resolvedAmount,
          'resolvedBy': resolvedBy,
        }),
      );

      if (response.statusCode == 200) {
        return Dispute.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to resolve dispute: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error resolving dispute: $e');
    }
  }

  // Escalate dispute
  static Future<Dispute> escalateDispute({
    required String disputeId,
    required String escalationReason,
    String? escalatedBy,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint/$disputeId/escalate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'escalationReason': escalationReason,
          'escalatedBy': escalatedBy,
        }),
      );

      if (response.statusCode == 200) {
        return Dispute.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to escalate dispute: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error escalating dispute: $e');
    }
  }

  // Add message to dispute timeline
  static Future<Dispute> addDisputeMessage({
    required String disputeId,
    required String message,
    required String senderId,
    required String senderName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint/$disputeId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'message': message,
          'senderId': senderId,
          'senderName': senderName,
          'metadata': metadata,
        }),
      );

      if (response.statusCode == 200) {
        return Dispute.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to add dispute message: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error adding dispute message: $e');
    }
  }

  // Get dispute statistics
  static Future<Map<String, dynamic>> getDisputeStatistics({
    String? userId,
    String? rentalId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (userId != null) queryParams['userId'] = userId;
      if (rentalId != null) queryParams['rentalId'] = rentalId;
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
        throw Exception('Failed to get dispute statistics: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting dispute statistics: $e');
    }
  }

  // Search disputes
  static Future<List<Dispute>> searchDisputes({
    String? query,
    DisputeType? type,
    DisputeStatus? status,
    DisputePriority? priority,
    String? initiatorId,
    String? respondentId,
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
      if (priority != null) queryParams['priority'] = priority.toString().split('.').last;
      if (initiatorId != null) queryParams['initiatorId'] = initiatorId;
      if (respondentId != null) queryParams['respondentId'] = respondentId;
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
        return data.map((json) => Dispute.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search disputes: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error searching disputes: $e');
    }
  }

  // Close dispute
  static Future<Dispute> closeDispute({
    required String disputeId,
    String? closeReason,
    String? closedBy,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint/$disputeId/close'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'closeReason': closeReason,
          'closedBy': closedBy,
        }),
      );

      if (response.statusCode == 200) {
        return Dispute.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to close dispute: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error closing dispute: $e');
    }
  }

  // Get urgent disputes
  static Future<List<Dispute>> getUrgentDisputes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint/urgent'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Dispute.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get urgent disputes: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting urgent disputes: $e');
    }
  }

  // Helper method to get auth token
  static Future<String> _getAuthToken() async {
    // This should be implemented based on your auth system
    // For now, returning a placeholder
    return 'your-auth-token';
  }
} 