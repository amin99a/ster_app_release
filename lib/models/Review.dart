enum ReviewType { 
  car, 
  host, 
  rental_experience, 
  app_experience 
}

enum ReviewStatus { 
  pending, 
  approved, 
  rejected, 
  flagged 
}

class Review {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerImage;
  final String targetId; // carId, hostId, or rentalId
  final ReviewType type;
  final double overallRating;
  final Map<String, double> categoryRatings; // cleanliness, performance, etc.
  final String title;
  final String content;
  final List<String> photos;
  final ReviewStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? publishedAt;
  final int helpfulVotes;
  final int totalVotes;
  final List<String> helpfulVoters; // user IDs who found it helpful
  final List<String> reportedBy; // user IDs who reported the review
  final String? moderatorNotes;
  final bool isVerifiedRental; // true if reviewer actually rented the car
  final String? rentalId; // reference to the actual rental
  final Map<String, dynamic>? metadata;

  Review({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerImage,
    required this.targetId,
    required this.type,
    required this.overallRating,
    this.categoryRatings = const {},
    required this.title,
    required this.content,
    this.photos = const [],
    this.status = ReviewStatus.pending,
    required this.createdAt,
    this.updatedAt,
    this.publishedAt,
    this.helpfulVotes = 0,
    this.totalVotes = 0,
    this.helpfulVoters = const [],
    this.reportedBy = const [],
    this.moderatorNotes,
    this.isVerifiedRental = false,
    this.rentalId,
    this.metadata,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      reviewerId: json['reviewerId'] ?? '',
      reviewerName: json['reviewerName'] ?? '',
      reviewerImage: json['reviewerImage'],
      targetId: json['targetId'] ?? '',
      type: ReviewType.values.firstWhere(
        (type) => type.toString() == 'ReviewType.${json['type'] ?? 'car'}',
        orElse: () => ReviewType.car,
      ),
      overallRating: (json['overallRating'] ?? 0.0).toDouble(),
      categoryRatings: json['categoryRatings'] != null 
          ? Map<String, double>.from(json['categoryRatings']) 
          : {},
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      photos: List<String>.from(json['photos'] ?? []),
      status: ReviewStatus.values.firstWhere(
        (status) => status.toString() == 'ReviewStatus.${json['status'] ?? 'pending'}',
        orElse: () => ReviewStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      publishedAt: json['publishedAt'] != null ? DateTime.parse(json['publishedAt']) : null,
      helpfulVotes: json['helpfulVotes'] ?? 0,
      totalVotes: json['totalVotes'] ?? 0,
      helpfulVoters: List<String>.from(json['helpfulVoters'] ?? []),
      reportedBy: List<String>.from(json['reportedBy'] ?? []),
      moderatorNotes: json['moderatorNotes'],
      isVerifiedRental: json['isVerifiedRental'] ?? false,
      rentalId: json['rentalId'],
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewerImage': reviewerImage,
      'targetId': targetId,
      'type': type.toString().split('.').last,
      'overallRating': overallRating,
      'categoryRatings': categoryRatings,
      'title': title,
      'content': content,
      'photos': photos,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'helpfulVotes': helpfulVotes,
      'totalVotes': totalVotes,
      'helpfulVoters': helpfulVoters,
      'reportedBy': reportedBy,
      'moderatorNotes': moderatorNotes,
      'isVerifiedRental': isVerifiedRental,
      'rentalId': rentalId,
      'metadata': metadata,
    };
  }

  Review copyWith({
    String? id,
    String? reviewerId,
    String? reviewerName,
    String? reviewerImage,
    String? targetId,
    ReviewType? type,
    double? overallRating,
    Map<String, double>? categoryRatings,
    String? title,
    String? content,
    List<String>? photos,
    ReviewStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    int? helpfulVotes,
    int? totalVotes,
    List<String>? helpfulVoters,
    List<String>? reportedBy,
    String? moderatorNotes,
    bool? isVerifiedRental,
    String? rentalId,
    Map<String, dynamic>? metadata,
  }) {
    return Review(
      id: id ?? this.id,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerImage: reviewerImage ?? this.reviewerImage,
      targetId: targetId ?? this.targetId,
      type: type ?? this.type,
      overallRating: overallRating ?? this.overallRating,
      categoryRatings: categoryRatings ?? this.categoryRatings,
      title: title ?? this.title,
      content: content ?? this.content,
      photos: photos ?? this.photos,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      helpfulVotes: helpfulVotes ?? this.helpfulVotes,
      totalVotes: totalVotes ?? this.totalVotes,
      helpfulVoters: helpfulVoters ?? this.helpfulVoters,
      reportedBy: reportedBy ?? this.reportedBy,
      moderatorNotes: moderatorNotes ?? this.moderatorNotes,
      isVerifiedRental: isVerifiedRental ?? this.isVerifiedRental,
      rentalId: rentalId ?? this.rentalId,
      metadata: metadata ?? this.metadata,
    );
  }

  // Check if review is published and visible
  bool get isPublished {
    return status == ReviewStatus.approved && publishedAt != null;
  }

  // Check if review is pending moderation
  bool get isPending {
    return status == ReviewStatus.pending;
  }

  // Check if review is rejected
  bool get isRejected {
    return status == ReviewStatus.rejected;
  }

  // Check if review is flagged for moderation
  bool get isFlagged {
    return status == ReviewStatus.flagged;
  }

  // Calculate helpful percentage
  double get helpfulPercentage {
    if (totalVotes == 0) return 0.0;
    return (helpfulVotes / totalVotes) * 100;
  }

  // Check if review is highly rated
  bool get isHighlyRated {
    return overallRating >= 4.0;
  }

  // Check if review is low rated
  bool get isLowRated {
    return overallRating <= 2.0;
  }

  // Check if review has photos
  bool get hasPhotos {
    return photos.isNotEmpty;
  }

  // Check if review has category ratings
  bool get hasCategoryRatings {
    return categoryRatings.isNotEmpty;
  }

  // Get review age in days
  int get ageInDays {
    final now = DateTime.now();
    return now.difference(createdAt).inDays;
  }

  // Check if review is recent (within 30 days)
  bool get isRecent {
    return ageInDays <= 30;
  }

  // Check if review is verified (from actual rental)
  bool get isVerified {
    return isVerifiedRental;
  }

  // Get review sentiment
  String get sentiment {
    if (overallRating >= 4.5) return 'Excellent';
    if (overallRating >= 4.0) return 'Very Good';
    if (overallRating >= 3.5) return 'Good';
    if (overallRating >= 3.0) return 'Average';
    if (overallRating >= 2.0) return 'Poor';
    return 'Very Poor';
  }

  // Get review type display name
  String get typeDisplayName {
    switch (type) {
      case ReviewType.car:
        return 'Car Review';
      case ReviewType.host:
        return 'Host Review';
      case ReviewType.rental_experience:
        return 'Rental Experience';
      case ReviewType.app_experience:
        return 'App Experience';
    }
  }

  // Get review type emoji
  String get typeEmoji {
    switch (type) {
      case ReviewType.car:
        return '🚗';
      case ReviewType.host:
        return '👤';
      case ReviewType.rental_experience:
        return '⭐';
      case ReviewType.app_experience:
        return '📱';
    }
  }

  // Check if user has voted helpful
  bool hasUserVotedHelpful(String userId) {
    return helpfulVoters.contains(userId);
  }

  // Check if user has reported this review
  bool hasUserReported(String userId) {
    return reportedBy.contains(userId);
  }

  // Get average category rating
  double get averageCategoryRating {
    if (categoryRatings.isEmpty) return overallRating;
    final sum = categoryRatings.values.fold(0.0, (sum, rating) => sum + rating);
    return sum / categoryRatings.length;
  }

  // Get review summary (first 100 characters)
  String get summary {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  // Check if review needs moderation
  bool get needsModeration {
    return reportedBy.length >= 3 || 
           content.length > 1000 || 
           photos.length > 10;
  }

  // Get review quality score
  double get qualityScore {
    double score = 0.0;
    
    // Content quality
    if (content.length >= 50) score += 1.0;
    if (content.length >= 200) score += 1.0;
    
    // Photo quality
    if (hasPhotos) score += 1.0;
    if (photos.length >= 3) score += 1.0;
    
    // Category ratings
    if (hasCategoryRatings) score += 1.0;
    if (categoryRatings.length >= 3) score += 1.0;
    
    // Verification
    if (isVerifiedRental) score += 2.0;
    
    // Helpful votes
    if (helpfulVotes >= 5) score += 1.0;
    if (helpfulPercentage >= 80) score += 1.0;
    
    return score;
  }

  // Check if review is high quality
  bool get isHighQuality {
    return qualityScore >= 5.0;
  }

  // Get review display title with emoji
  String get displayTitle {
    return '$typeEmoji $title';
  }

  // Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
} 