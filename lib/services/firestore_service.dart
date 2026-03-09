import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';
import '../models/review_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ─── LISTINGS ──────────────────────────────────────────────────────────────

  /// Real-time stream of ALL listings.
  Stream<List<ListingModel>> getListings() {
    return _db
        .collection('listings')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ListingModel.fromFirestore).toList());
  }

  /// Real-time stream of listings belonging to [uid].
  Stream<List<ListingModel>> getUserListings(String uid) {
    return _db
        .collection('listings')
        .where('createdBy', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ListingModel.fromFirestore).toList());
  }

  /// Add a new listing. Returns the complete ListingModel with the generated ID.
  Future<ListingModel> addListing(ListingModel listing) async {
    final ref = await _db.collection('listings').add(listing.toMap());
    return listing.copyWith(id: ref.id);
  }

  /// Update fields of a listing by [id].
  Future<void> updateListing(String id, Map<String, dynamic> data) {
    return _db.collection('listings').doc(id).update(data);
  }

  /// Delete a listing and all its reviews.
  Future<void> deleteListing(String id) async {
    // Delete reviews subcollection first
    final reviews = await _db
        .collection('listings')
        .doc(id)
        .collection('reviews')
        .get();
    final batch = _db.batch();
    for (final doc in reviews.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_db.collection('listings').doc(id));
    await batch.commit();
  }

  // ─── REVIEWS ───────────────────────────────────────────────────────────────

  /// Real-time stream of reviews for a given listing.
  Stream<List<ReviewModel>> getReviews(String listingId) {
    return _db
        .collection('listings')
        .doc(listingId)
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ReviewModel.fromFirestore).toList());
  }

  /// Add a review and update the listing's average rating.
  Future<void> addReview(ReviewModel review) async {
    final listingRef = _db.collection('listings').doc(review.listingId);
    final reviewRef = listingRef.collection('reviews').doc();

    await _db.runTransaction((tx) async {
      final snap = await tx.get(listingRef);
      final oldRating = (snap.data()?['rating'] ?? 0.0).toDouble();
      final oldCount = (snap.data()?['reviewCount'] ?? 0);
      final newCount = oldCount + 1;
      final newRating = ((oldRating * oldCount) + review.rating) / newCount;

      tx.set(reviewRef, review.toMap());
      tx.update(listingRef, {'rating': newRating, 'reviewCount': newCount});
    });
  }
}
