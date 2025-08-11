class FavoriteList {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? coverImage;
  final int itemCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPublic;
  final List<String> tags;
  final Map<String, dynamic>? metadata;

  FavoriteList({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.coverImage,
    this.itemCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.isPublic = false,
    this.tags = const [],
    this.metadata,
  });

  factory FavoriteList.fromJson(Map<String, dynamic> json) {
    return FavoriteList(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      coverImage: json['coverImage'],
      itemCount: json['itemCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isPublic: json['isPublic'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'coverImage': coverImage,
      'itemCount': itemCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isPublic': isPublic,
      'tags': tags,
      'metadata': metadata,
    };
  }

  FavoriteList copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? coverImage,
    int? itemCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return FavoriteList(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      itemCount: itemCount ?? this.itemCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteList && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FavoriteList(id: $id, name: $name, itemCount: $itemCount)';
  }
} 