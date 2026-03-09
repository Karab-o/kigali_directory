import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listings_provider.dart';
import '../../theme.dart';
import '../../widgets/shared_widgets.dart';
import 'add_edit_listing_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Use Consumer instead of context.watch so rebuilds are scoped
    // correctly and the outer context stays valid for dialogs.
    return Consumer<ListingsProvider>(
      builder: (context, listings, _) {
        final mine = listings.myListings;
        debugPrint('DEBUG: MyListingsScreen building with ${mine.length} listings');

        return Scaffold(
          backgroundColor: AppTheme.navyDark,
          appBar: AppBar(
            title: const Text('My Listings'),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddEditListingScreen(),
                  ),
                ),
                icon: const Icon(Icons.add, color: AppTheme.accent),
                label:
                    const Text('Add', style: TextStyle(color: AppTheme.accent)),
              ),
            ],
          ),
          body: mine.isEmpty
              ? EmptyState(
                  icon: Icons.list_alt_outlined,
                  title: 'No listings yet',
                  subtitle: 'Tap the + button to add your first listing',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: mine.length,
                  itemBuilder: (ctx, i) {
                    final l = mine[i];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.navyMid,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.navyLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            kCategoryIcons[l.category] ?? Icons.place,
                            color: AppTheme.accent,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          l.name,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(
                              l.category,
                              style: const TextStyle(
                                color: AppTheme.accent,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              l.address,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                StarRating(rating: l.rating, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  '${l.reviewCount} reviews',
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: AppTheme.textSecondary,
                                size: 20,
                              ),
                              // ✅ FIX: Use outer `context` not `ctx`
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddEditListingScreen(listing: l),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              // ✅ FIX: Use outer `context` not `ctx`
                              onPressed: () => _confirmDelete(
                                context,
                                listings,
                                l.id,
                                l.name,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    ListingsProvider lp,
    String id,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.navyMid,
        title: const Text(
          'Delete Listing',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "$name"?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              lp.deleteListing(id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}