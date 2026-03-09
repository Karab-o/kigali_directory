import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/listing_model.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../theme.dart';
import '../../widgets/shared_widgets.dart';

class ListingDetailScreen extends StatefulWidget {
  final ListingModel listing;
  const ListingDetailScreen({super.key, required this.listing});
  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  bool _showReviewForm = false;
  double _myRating = 5.0;
  final _reviewCtrl = TextEditingController();

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  void _launchNavigation() async {
    final l = widget.listing;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${l.latitude},${l.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _submitReview() async {
    if (_reviewCtrl.text.trim().isEmpty) return;
    final auth = context.read<AuthProvider>();
    final review = ReviewModel(
      id: '',
      listingId: widget.listing.id,
      authorName: auth.profile?['displayName'] ?? 'Anonymous',
      authorUid: auth.user?.uid ?? '',
      body: _reviewCtrl.text.trim(),
      rating: _myRating,
      timestamp: DateTime.now(),
    );
    final ok = await context.read<ListingsProvider>().addReview(review);
    if (ok && mounted) {
      _reviewCtrl.clear();
      setState(() => _showReviewForm = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.listing;
    final position = LatLng(l.latitude, l.longitude);
    final lp = context.watch<ListingsProvider>();
    final bookmarked = lp.isBookmarked(l.id);

    return Scaffold(
      backgroundColor: AppTheme.navyDark,
      body: CustomScrollView(
        slivers: [
          // ── App Bar with Map ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppTheme.navyDark,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.navyMid.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () =>
                    context.read<ListingsProvider>().toggleBookmark(l.id),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.navyMid.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      bookmarked ? Icons.bookmark : Icons.bookmark_outline,
                      color: bookmarked
                          ? AppTheme.accent
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: position,
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('loc'),
                    position: position,
                    infoWindow: InfoWindow(title: l.name),
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + category chip
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.name,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.accent.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          l.category,
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Rating row
                  Row(
                    children: [
                      StarRating(rating: l.rating, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${l.rating.toStringAsFixed(1)}  •  ${l.reviewCount} reviews',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Info cards
                  _infoRow(Icons.location_on_outlined, l.address),
                  const SizedBox(height: 10),
                  _infoRow(
                    Icons.phone_outlined,
                    l.contactNumber.isEmpty
                        ? 'No contact provided'
                        : l.contactNumber,
                  ),
                  const SizedBox(height: 10),
                  _infoRow(
                    Icons.info_outline,
                    l.description.isEmpty
                        ? 'No description available.'
                        : l.description,
                  ),

                  const SizedBox(height: 20),

                  // Directions button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _launchNavigation,
                      icon: const Icon(Icons.navigation_outlined, size: 20),
                      label: const Text('Get Directions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Reviews ─────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reviews',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            setState(() => _showReviewForm = !_showReviewForm),
                        child: Text(
                          _showReviewForm ? 'Cancel' : 'Rate this service',
                          style: const TextStyle(color: AppTheme.accent),
                        ),
                      ),
                    ],
                  ),

                  // Review form
                  if (_showReviewForm) _buildReviewForm(),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Review list ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: StreamBuilder<List<ReviewModel>>(
              stream: context.read<ListingsProvider>().reviewStream(l.id),
              builder: (ctx, snap) {
                if (!snap.hasData) return const SizedBox.shrink();
                final reviews = snap.data!;
                if (reviews.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      'No reviews yet. Be the first!',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  itemBuilder: (_, i) => _reviewTile(reviews[i]),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: AppTheme.textSecondary, size: 18),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    ],
  );

  Widget _reviewTile(ReviewModel r) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.navyLight,
              child: Text(
                r.authorName[0].toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.authorName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  StarRating(rating: r.rating, size: 13),
                ],
              ),
            ),
            Text(
              _timeAgo(r.timestamp),
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          r.body,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const Divider(color: AppTheme.navyLight, height: 24),
      ],
    ),
  );

  Widget _buildReviewForm() => Container(
    margin: const EdgeInsets.symmetric(vertical: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.navyMid,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Rating',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(
            5,
            (i) => GestureDetector(
              onTap: () => setState(() => _myRating = (i + 1).toDouble()),
              child: Icon(
                i < _myRating ? Icons.star : Icons.star_border,
                color: AppTheme.accent,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _reviewCtrl,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Write your review...'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitReview,
            child: const Text('Submit Review'),
          ),
        ),
      ],
    ),
  );

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 7) return '${diff.inDays ~/ 7}w ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }
}
