import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Review {
  final String id;
  final String carId;
  final String carName;
  final String userId;
  final String userName;
  final String hostId;
  final String hostName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.carId,
    required this.carName,
    required this.userId,
    required this.userName,
    required this.hostId,
    required this.hostName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      carId: json['car_id']?.toString() ?? '',
      carName: json['car_name']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name']?.toString() ?? '',
      hostId: json['host_id']?.toString() ?? '',
      hostName: json['host_name']?.toString() ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class ReviewService extends ChangeNotifier {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // Get reviews for a specific host
  Future<List<Review>> getHostReviews(String hostName) async {
    try {
      print('⭐ Fetching reviews for host: $hostName');
      
      final response = await client
          .from('reviews')
          .select()
          .eq('host_name', hostName)
          .order('created_at', ascending: false);
      
      print('📊 Found ${response.length} reviews for host');
      
      final reviews = <Review>[];
      for (int i = 0; i < response.length; i++) {
        try {
          final reviewData = response[i];
          print('🔍 Processing review ${i + 1}: ${reviewData['car_name']}');
          final review = Review.fromJson(reviewData);
          reviews.add(review);
          print('✅ Successfully parsed review: ${review.carName}');
        } catch (parseError) {
          print('❌ Error parsing review ${i + 1}: $parseError');
          print('📋 Review data: ${response[i]}');
        }
      }
      
      print('🎉 Successfully loaded ${reviews.length} reviews for host from database');
      return reviews;
    } catch (e) {
      print('❌ Error fetching host reviews: $e');
      // Return empty list if table doesn't exist or other errors
      return [];
    }
  }

  // Get average rating for a host
  Future<double> getHostAverageRating(String hostName) async {
    try {
      final reviews = await getHostReviews(hostName);
      if (reviews.isEmpty) return 0.0;
      
      final totalRating = reviews.fold(0.0, (sum, review) => sum + review.rating);
      return totalRating / reviews.length;
    } catch (e) {
      print('❌ Error getting host average rating: $e');
      return 0.0;
    }
  }

  // Get total reviews count for a host
  Future<int> getHostReviewsCount(String hostName) async {
    try {
      final reviews = await getHostReviews(hostName);
      return reviews.length;
    } catch (e) {
      print('❌ Error getting host reviews count: $e');
      return 0;
    }
  }
} 