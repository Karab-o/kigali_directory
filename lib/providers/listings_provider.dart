import 'dart:async';
import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../models/review_model.dart';
import '../services/firestore_service.dart';

class ListingsProvider extends ChangeNotifier {
  final _service = FirestoreService();

  List<ListingModel> _all = [];
  List<ListingModel> _mine = [];
  String? _currentUserId;
  Set<String> _bookmarks = {};
  bool _loading = false;
  String? _error;
  String _search = '';
  String _category = 'All';

  StreamSubscription? _allSub;
  StreamSubscription? _mineSub;

  // ─── Getters ───────────────────────────────────────────────────────────────

  bool get isLoading => _loading;
  String? get error => _error;
  String get category => _category;
  String get search => _search;
  List<ListingModel> get myListings => List.unmodifiable(_mine);
  List<ListingModel> get allListings => List.unmodifiable(_all);
  Set<String> get bookmarks => _bookmarks;
  String? get currentUserId => _currentUserId;

  List<ListingModel> get filtered {
    return _all.where((l) {
      final matchSearch =
          l.name.toLowerCase().contains(_search.toLowerCase()) ||
          l.address.toLowerCase().contains(_search.toLowerCase());
      final matchCategory = _category == 'All' || l.category == _category;
      return matchSearch && matchCategory;
    }).toList();
  }

  List<ListingModel> get bookmarkedListings =>
      _all.where((l) => _bookmarks.contains(l.id)).toList();

  bool isBookmarked(String id) => _bookmarks.contains(id);

  // ─── Subscriptions ─────────────────────────────────────────────────────────

  void subscribeAll() {
    _loading = true;
    notifyListeners();
    _allSub?.cancel();
    _allSub = _service.getListings().listen(
      (list) {
        _all = list;
        _loading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _loading = false;
        notifyListeners();
      },
    );
  }

  void setCurrentUser(String? uid) {
    if (uid == _currentUserId) return;
    _currentUserId = uid;
    debugPrint('DEBUG: setCurrentUser called with uid: $uid');
    if (uid == null) {
      _mine = [];
      _mineSub?.cancel();
      notifyListeners();
    } else {
      subscribeMine(uid);
    }
  }

  void subscribeMine(String uid) {
    _mineSub?.cancel();
    debugPrint('DEBUG: subscribeMine called with uid: $uid');
    _mineSub = _service.getUserListings(uid).listen(
      (list) {
        debugPrint('DEBUG: Received ${list.length} listings for user $uid');
        _mine = list;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('DEBUG: Error in subscribeMine: $e');
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  // ─── Search / Filter ───────────────────────────────────────────────────────

  void setSearch(String q) {
    _search = q;
    notifyListeners();
  }

  void setCategory(String c) {
    _category = c;
    notifyListeners();
  }

  // ─── Bookmarks ─────────────────────────────────────────────────────────────

  void toggleBookmark(String id) {
    if (_bookmarks.contains(id)) {
      _bookmarks.remove(id);
    } else {
      _bookmarks.add(id);
    }
    notifyListeners();
  }

  // ─── CRUD ──────────────────────────────────────────────────────────────────

  Future<bool> addListing(ListingModel listing) async {
    try {
      debugPrint('DEBUG: Adding listing with createdBy: ${listing.createdBy}');
      final addedListing = await _service.addListing(listing);
      debugPrint('DEBUG: Listing added with ID: ${addedListing.id}');

      // ✅ Add to both local lists immediately for instant UI update.
      // The Firestore stream will also sync it shortly after.
      _mine.insert(0, addedListing);
      _all.insert(0, addedListing);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('DEBUG: Error adding listing: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateListing(String id, Map<String, dynamic> data) async {
    try {
      await _service.updateListing(id, data);

      // ✅ FIX: Update local state immediately so UI reflects changes
      // without waiting for the Firestore stream to re-emit.
      final mineIdx = _mine.indexWhere((l) => l.id == id);
      if (mineIdx != -1) {
        _mine[mineIdx] = _mine[mineIdx].copyWith(
          name: data['name'],
          category: data['category'],
          address: data['address'],
          contactNumber: data['contactNumber'],
          description: data['description'],
          latitude: data['latitude'],
          longitude: data['longitude'],
        );
      }

      final allIdx = _all.indexWhere((l) => l.id == id);
      if (allIdx != -1) {
        _all[allIdx] = _all[allIdx].copyWith(
          name: data['name'],
          category: data['category'],
          address: data['address'],
          contactNumber: data['contactNumber'],
          description: data['description'],
          latitude: data['latitude'],
          longitude: data['longitude'],
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteListing(String id) async {
    try {
      await _service.deleteListing(id);

      // ✅ FIX: Remove from BOTH local lists and notify.
      // Previously this was missing entirely — the UI never updated.
      _mine.removeWhere((l) => l.id == id);
      _all.removeWhere((l) => l.id == id);
      _bookmarks.remove(id);

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ─── Reviews ───────────────────────────────────────────────────────────────

  Stream<List<ReviewModel>> reviewStream(String listingId) =>
      _service.getReviews(listingId);

  Future<bool> addReview(ReviewModel review) async {
    try {
      await _service.addReview(review);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _allSub?.cancel();
    _mineSub?.cancel();
    super.dispose();
  }
}