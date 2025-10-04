import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a venue that can be booked
class VenueModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> photoUrls;
  final double pricePerHour;
  final String currency;
  final double rating;
  final int reviewCount;
  final String ownerId;
  final List<String> amenities;
  final int capacity;
  final Map<String, bool> availability; // day of week -> available
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final Map<String, dynamic>? operatingHours; // { "monday": {"open": "09:00", "close": "18:00"}, ... }

  VenueModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.photoUrls,
    required this.pricePerHour,
    required this.currency,
    required this.rating,
    required this.reviewCount,
    required this.ownerId,
    required this.amenities,
    required this.capacity,
    required this.availability,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.phoneNumber,
    this.email,
    this.website,
    this.operatingHours,
  });

  /// Create VenueModel from Firestore document
  factory VenueModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VenueModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      address: data['address'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      pricePerHour: (data['pricePerHour'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'MAD',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      ownerId: data['ownerId'] ?? '',
      amenities: List<String>.from(data['amenities'] ?? []),
      capacity: data['capacity'] ?? 0,
      availability: Map<String, bool>.from(data['availability'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      phoneNumber: data['phoneNumber'],
      email: data['email'],
      website: data['website'],
      operatingHours: data['operatingHours'] as Map<String, dynamic>?,
    );
  }

  /// Convert VenueModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'photoUrls': photoUrls,
      'pricePerHour': pricePerHour,
      'currency': currency,
      'rating': rating,
      'reviewCount': reviewCount,
      'ownerId': ownerId,
      'amenities': amenities,
      'capacity': capacity,
      'availability': availability,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      if (website != null) 'website': website,
      if (operatingHours != null) 'operatingHours': operatingHours,
    };
  }

  /// Create a copy with updated fields
  VenueModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? photoUrls,
    double? pricePerHour,
    String? currency,
    double? rating,
    int? reviewCount,
    String? ownerId,
    List<String>? amenities,
    int? capacity,
    Map<String, bool>? availability,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? phoneNumber,
    String? email,
    String? website,
    Map<String, dynamic>? operatingHours,
  }) {
    return VenueModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoUrls: photoUrls ?? this.photoUrls,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      currency: currency ?? this.currency,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      ownerId: ownerId ?? this.ownerId,
      amenities: amenities ?? this.amenities,
      capacity: capacity ?? this.capacity,
      availability: availability ?? this.availability,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      operatingHours: operatingHours ?? this.operatingHours,
    );
  }
}

/// Represents a review for a venue
class VenueReviewModel {
  final String id;
  final String venueId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String>? photoUrls;

  VenueReviewModel({
    required this.id,
    required this.venueId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.photoUrls,
  });

  factory VenueReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VenueReviewModel(
      id: doc.id,
      venueId: data['venueId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      photoUrls: data['photoUrls'] != null ? List<String>.from(data['photoUrls']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'venueId': venueId,
      'userId': userId,
      'userName': userName,
      if (userPhotoUrl != null) 'userPhotoUrl': userPhotoUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      if (photoUrls != null) 'photoUrls': photoUrls,
    };
  }
}
