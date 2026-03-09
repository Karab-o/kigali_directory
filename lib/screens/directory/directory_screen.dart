import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../theme.dart';
import '../../widgets/shared_widgets.dart';
import '../my_listings/add_edit_listing_screen.dart';
import 'listing_detail_screen.dart';

class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingsProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.navyDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App Bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kigali City',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Hello, ${auth.profile?['displayName'] ?? 'there'} 👋',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddEditListingScreen(),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Category Chips ────────────────────────────────────────
            CategoryFilterBar(
              categories: kCategories,
              selected: listings.category,
              onSelected: (c) =>
                  context.read<ListingsProvider>().setCategory(c),
            ),

            const SizedBox(height: 12),

            // ── Search Bar ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => context.read<ListingsProvider>().setSearch(v),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  hintText: 'Search for a service',
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  suffixIcon: Icon(
                    Icons.tune,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Listings ─────────────────────────────────────────────
            Expanded(
              child: listings.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.accent),
                    )
                  : listings.filtered.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off,
                      title: 'No results found',
                      subtitle: 'Try a different search or category',
                    )
                  : CustomScrollView(
                      slivers: [
                        // "Near You" header
                        SliverToBoxAdapter(
                          child: SectionHeader(
                            title: 'Near You',
                            action: 'See all',
                          ),
                        ),

                        // Listing rows
                        SliverList(
                          delegate: SliverChildBuilderDelegate((ctx, i) {
                            final l = listings.filtered[i];
                            return ListingCard(
                              listing: l,
                              onTap: () => Navigator.push(
                                ctx,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ListingDetailScreen(listing: l),
                                ),
                              ),
                            );
                          }, childCount: listings.filtered.length),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
