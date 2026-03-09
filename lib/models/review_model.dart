import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String listingId;
  final String authorName;
  final String authorUid;
  final String body;
  final double rating;
  final DateTime timestamp;

  ReviewModel({
    required this.id,
    required this.listingId,
    required this.authorName,
    required this.authorUid,
    required this.body,
    required this.rating,
    required this.timestamp,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      listingId: d['listingId'] ?? '',
      authorName: d['authorName'] ?? 'Anonymous',
      authorUid: d['authorUid'] ?? '',
      body: d['body'] ?? '',
      rating: (d['rating'] ?? 0.0).toDouble(),
      timestamp: (d['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'listingId': listingId,
    'authorName': authorName,
    'authorUid': authorUid,
    'body': body,
    'rating': rating,
    'timestamp': Timestamp.fromDate(timestamp),
  };
}
