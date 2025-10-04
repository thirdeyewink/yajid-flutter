import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Recommendation model for content suggestions
class Recommendation extends Equatable {
  final String id;
  final String category;
  final String title;
  final String creator; // Director, artist, author, etc.
  final String details; // Actors, genre, description
  final String platform; // Netflix, Spotify, Kindle, etc.
  final String whyLike; // Personalized explanation
  final double communityRating; // Average rating from all users
  final int ratingCount; // Number of ratings
  final String? imageUrl; // Optional image URL
  final List<String> tags; // Tags for filtering
  final DateTime createdAt;
  final DateTime updatedAt;

  const Recommendation({
    required this.id,
    required this.category,
    required this.title,
    required this.creator,
    required this.details,
    required this.platform,
    required this.whyLike,
    required this.communityRating,
    this.ratingCount = 0,
    this.imageUrl,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Recommendation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Recommendation(
      id: doc.id,
      category: data['category'] ?? '',
      title: data['title'] ?? '',
      creator: data['creator'] ?? '',
      details: data['details'] ?? '',
      platform: data['platform'] ?? '',
      whyLike: data['whyLike'] ?? '',
      communityRating: (data['communityRating'] ?? 0.0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      imageUrl: data['imageUrl'],
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'title': title,
      'creator': creator,
      'details': details,
      'platform': platform,
      'whyLike': whyLike,
      'communityRating': communityRating,
      'ratingCount': ratingCount,
      'imageUrl': imageUrl,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Recommendation copyWith({
    String? id,
    String? category,
    String? title,
    String? creator,
    String? details,
    String? platform,
    String? whyLike,
    double? communityRating,
    int? ratingCount,
    String? imageUrl,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recommendation(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      creator: creator ?? this.creator,
      details: details ?? this.details,
      platform: platform ?? this.platform,
      whyLike: whyLike ?? this.whyLike,
      communityRating: communityRating ?? this.communityRating,
      ratingCount: ratingCount ?? this.ratingCount,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        category,
        title,
        creator,
        details,
        platform,
        whyLike,
        communityRating,
        ratingCount,
        imageUrl,
        tags,
        createdAt,
        updatedAt,
      ];
}

/// Valid recommendation categories
enum RecommendationCategory {
  movies,
  music,
  books,
  tvShows,
  podcasts,
  sports,
  videogames,
  brands,
  recipes,
  events,
  activities,
  businesses;

  String get displayName {
    switch (this) {
      case RecommendationCategory.movies:
        return 'Movies';
      case RecommendationCategory.music:
        return 'Music';
      case RecommendationCategory.books:
        return 'Books';
      case RecommendationCategory.tvShows:
        return 'TV Shows';
      case RecommendationCategory.podcasts:
        return 'Podcasts';
      case RecommendationCategory.sports:
        return 'Sports';
      case RecommendationCategory.videogames:
        return 'Video Games';
      case RecommendationCategory.brands:
        return 'Brands';
      case RecommendationCategory.recipes:
        return 'Recipes';
      case RecommendationCategory.events:
        return 'Events';
      case RecommendationCategory.activities:
        return 'Activities';
      case RecommendationCategory.businesses:
        return 'Businesses';
    }
  }

  String get firestoreValue {
    switch (this) {
      case RecommendationCategory.tvShows:
        return 'tv shows';
      default:
        return name;
    }
  }

  static RecommendationCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'tv shows':
        return RecommendationCategory.tvShows;
      case 'videogames':
        return RecommendationCategory.videogames;
      default:
        return RecommendationCategory.values.firstWhere(
          (e) => e.name == value.toLowerCase(),
          orElse: () => RecommendationCategory.movies,
        );
    }
  }
}
