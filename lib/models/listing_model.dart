import 'package:cloud_firestore/cloud_firestore.dart';

class ListingModel {
  final String id;
  final String name;
  final String category;
  final String address;
  final String contactNumber;
  final String description;
  final double latitude;
  final double longitude;
  final String createdBy;
  final DateTime timestamp;
  final double rating; // average rating (0.0–5.0)
  final int reviewCount;
  final bool isBookmarked; // local UI state only

  ListingModel({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contactNumber,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.timestamp,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isBookmarked = false,
  });

  // Firestore → ListingModel
  factory ListingModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ListingModel(
      id: doc.id,
      name: d['name'] ?? '',
      category: d['category'] ?? '',
      address: d['address'] ?? '',
      contactNumber: d['contactNumber'] ?? '',
      description: d['description'] ?? '',
      latitude: (d['latitude'] ?? -1.9441).toDouble(),
      longitude: (d['longitude'] ?? 30.0619).toDouble(),
      createdBy: d['createdBy'] ?? '',
      timestamp: (d['timestamp'] as Timestamp).toDate(),
      rating: (d['rating'] ?? 0.0).toDouble(),
      reviewCount: (d['reviewCount'] ?? 0),
    );
  }

  // ListingModel → Firestore map
  Map<String, dynamic> toMap() => {
    'name': name,
    'category': category,
    'address': address,
    'contactNumber': contactNumber,
    'description': description,
    'latitude': latitude,
    'longitude': longitude,
    'createdBy': createdBy,
    'timestamp': Timestamp.fromDate(timestamp),
    'rating': rating,
    'reviewCount': reviewCount,
  };

  // Copy with modifications
  ListingModel copyWith({
    String? id,
    String? name,
    String? category,
    String? address,
    String? contactNumber,
    String? description,
    double? latitude,
    double? longitude,
    double? rating,
    int? reviewCount,
    bool? isBookmarked,
  }) => ListingModel(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    address: address ?? this.address,
    contactNumber: contactNumber ?? this.contactNumber,
    description: description ?? this.description,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    createdBy: createdBy,
    timestamp: timestamp,
    rating: rating ?? this.rating,
    reviewCount: reviewCount ?? this.reviewCount,
    isBookmarked: isBookmarked ?? this.isBookmarked,
  );
}
