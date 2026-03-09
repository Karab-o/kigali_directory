import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listings_provider.dart';
import '../../theme.dart';
import '../../widgets/shared_widgets.dart';
import 'directory/listing_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});
  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  bool _bookmarksEnabled = true;

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingsProvider>();
    final bookmarked = listings.bookmarkedListings;

    return Scaffold(
      backgroundColor: AppTheme.navyDark,
      appBar: AppBar(
        title: const Text('Bookmarks'),
        actions: [
          
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Text(
                  'Bookmarks',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _bookmarksEnabled,
                  onChanged: (v) => setState(() => _bookmarksEnabled = v),
                  activeThumbColor: AppTheme.accent,
                ),
              ],
            ),
          ),
        ],
      ),
      body: !_bookmarksEnabled
          ? const EmptyState(
              icon: Icons.bookmark_outline,
              title: 'Bookmarks disabled',
              subtitle: 'Toggle the switch above to enable bookmarks',
            )
          : bookmarked.isEmpty
              ? const EmptyState(
                  icon: Icons.bookmark_outline,
                  title: 'No bookmarks yet',
                  subtitle:
                      'Tap the bookmark icon on any listing to save it here',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: bookmarked.length,
                  itemBuilder: (ctx, i) {
                    final l = bookmarked[i];
                    return ListingCard(
                      listing: l,
                      onTap: () => Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) => ListingDetailScreen(listing: l),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
