import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/Document.dart';
import '../constants.dart';

class DocumentService {
  static const String baseUrl = ApiConstants.baseUrl;
  static const String endpoint = '/documents';

  // Upload document
  static Future<Document> uploadDocument({
    required String userId,
    required File file,
    required DocumentType type,
    required DocumentCategory category,
    String? description,
    List<String> tags = const [],
    bool isPublic = false,
    bool isRequired = false,
    DateTime? expiresAt,
    String? rentalId,
    String? carId,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );

      request.headers['Authorization'] = 'Bearer ${await _getAuthToken()}';
      request.fields['userId'] = userId;
      request.fields['type'] = type.toString().split('.').last;
      request.fields['category'] = category.toString().split('.').last;
      if (description != null) request.fields['description'] = description;
      request.fields['tags'] = jsonEncode(tags);
      request.fields['isPublic'] = isPublic.toString();
      request.fields['isRequired'] = isRequired.toString();
      if (expiresAt != null) request.fields['expiresAt'] = expiresAt.toIso8601String();
      if (rentalId != null) request.fields['rentalId'] = rentalId;
      if (carId != null) request.fields['carId'] = carId;

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return Document.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to upload document: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading document: $e');
    }
  }

  // Get document by ID
  static Future<Document> getDocument(String documentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint/$documentId'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        return Document.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get document: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting document: $e');
    }
  }

  // Get user documents
  static Future<List<Document>> getUserDocuments({
    required String userId,
    DocumentType? type,
    DocumentStatus? status,
    DocumentCategory? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (type != null) queryParams['type'] = type.toString().split('.').last;
      if (status != null) queryParams['status'] = status.toString().split('.').last;
      if (category != null) queryParams['category'] = category.toString().split('.').last;

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
        return data.map((json) => Document.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get user documents: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting user documents: $e');
    }
  }

  // Get rental documents
  static Future<List<Document>> getRentalDocuments(String rentalId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint/rental/$rentalId'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Document.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get rental documents: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting rental documents: $e');
    }
  }

  // Update document
  static Future<Document> updateDocument({
    required String documentId,
    String? description,
    List<String>? tags,
    bool? isPublic,
    Map<String, dynamic>? customFields,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint/$documentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'description': description,
          'tags': tags,
          'isPublic': isPublic,
          'customFields': customFields,
        }),
      );

      if (response.statusCode == 200) {
        return Document.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update document: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating document: $e');
    }
  }

  // Delete document
  static Future<void> deleteDocument(String documentId, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint/$documentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'deletedBy': userId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete document: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting document: $e');
    }
  }

  // Review document (admin/moderator only)
  static Future<Document> reviewDocument({
    required String documentId,
    required DocumentStatus status,
    required String reviewedBy,
    String? approvalNotes,
    String? rejectionReason,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint/$documentId/review'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'status': status.toString().split('.').last,
          'reviewedBy': reviewedBy,
          'approvalNotes': approvalNotes,
          'rejectionReason': rejectionReason,
        }),
      );

      if (response.statusCode == 200) {
        return Document.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to review document: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error reviewing document: $e');
    }
  }

  // Verify document
  static Future<Document> verifyDocument({
    required String documentId,
    required String verificationMethod,
    required String verifiedBy,
    Map<String, dynamic>? extractedData,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint/$documentId/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode({
          'verificationMethod': verificationMethod,
          'verifiedBy': verifiedBy,
          'extractedData': extractedData,
        }),
      );

      if (response.statusCode == 200) {
        return Document.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to verify document: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error verifying document: $e');
    }
  }

  // Get document download URL
  static Future<String> getDocumentDownloadUrl(String documentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint/$documentId/download'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['downloadUrl'];
      } else {
        throw Exception('Failed to get document download URL: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting document download URL: $e');
    }
  }

  // Get document thumbnail URL
  static Future<String?> getDocumentThumbnailUrl(String documentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint/$documentId/thumbnail'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['thumbnailUrl'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Get pending documents for review
  static Future<List<Document>> getPendingDocuments({
    DocumentType? type,
    DocumentCategory? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (type != null) queryParams['type'] = type.toString().split('.').last;
      if (category != null) queryParams['category'] = category.toString().split('.').last;

      final uri = Uri.parse('$baseUrl$endpoint/pending').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Document.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get pending documents: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting pending documents: $e');
    }
  }

  // Get expired documents
  static Future<List<Document>> getExpiredDocuments({
    String? userId,
    DocumentType? type,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (userId != null) queryParams['userId'] = userId;
      if (type != null) queryParams['type'] = type.toString().split('.').last;

      final uri = Uri.parse('$baseUrl$endpoint/expired').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Document.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get expired documents: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting expired documents: $e');
    }
  }

  // Search documents
  static Future<List<Document>> searchDocuments({
    String? query,
    DocumentType? type,
    DocumentStatus? status,
    DocumentCategory? category,
    String? userId,
    String? rentalId,
    String? carId,
    List<String>? tags,
    bool? isVerified,
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
      if (category != null) queryParams['category'] = category.toString().split('.').last;
      if (userId != null) queryParams['userId'] = userId;
      if (rentalId != null) queryParams['rentalId'] = rentalId;
      if (carId != null) queryParams['carId'] = carId;
      if (tags != null) queryParams['tags'] = jsonEncode(tags);
      if (isVerified != null) queryParams['isVerified'] = isVerified.toString();
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
        return data.map((json) => Document.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search documents: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error searching documents: $e');
    }
  }

  // Get document statistics
  static Future<Map<String, dynamic>> getDocumentStatistics({
    String? userId,
    DocumentType? type,
    DocumentCategory? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (userId != null) queryParams['userId'] = userId;
      if (type != null) queryParams['type'] = type.toString().split('.').last;
      if (category != null) queryParams['category'] = category.toString().split('.').last;
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
        throw Exception('Failed to get document statistics: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting document statistics: $e');
    }
  }

  // Helper method to get auth token
  static Future<String> _getAuthToken() async {
    // This should be implemented based on your auth system
    // For now, returning a placeholder
    return 'your-auth-token';
  }
} 