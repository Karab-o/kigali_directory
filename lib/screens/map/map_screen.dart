import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/listings_provider.dart';
import '../../theme.dart';
import '../directory/listing_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  // Kigali city center
  static const _kigali = LatLng(-1.9441, 30.0619);

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingsProvider>();

    // Build markers from all listings
    final markers = listings.allListings
        .map(
          (l) => Marker(
            markerId: MarkerId(l.id),
            position: LatLng(l.latitude, l.longitude),
            infoWindow: InfoWindow(
              title: l.name,
              snippet: l.category,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListingDetailScreen(listing: l),
                ),
              ),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _categoryHue(l.category),
            ),
          ),
        )
        .toSet();

    return Scaffold(
      backgroundColor: AppTheme.navyDark,
      appBar: AppBar(title: const Text('Map View')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _kigali,
              zoom: 13,
            ),
            markers: markers,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (c) => _mapController = c,
            mapType: MapType.normal,
          ),

          // Legend
          Positioned(
            bottom: 20,
            right: 16,
            child: Column(
              children: [
                _mapButton(Icons.my_location, () {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(_kigali, 13),
                  );
                }),
                const SizedBox(height: 8),
                _mapButton(Icons.zoom_in, () {
                  _mapController?.animateCamera(CameraUpdate.zoomIn());
                }),
                const SizedBox(height: 8),
                _mapButton(Icons.zoom_out, () {
                  _mapController?.animateCamera(CameraUpdate.zoomOut());
                }),
              ],
            ),
          ),

          // Listing count badge
          Positioned(
            top: 12,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.navyMid.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.place, color: AppTheme.accent, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${listings.allListings.length} places',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapButton(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppTheme.navyMid,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Icon(icon, color: AppTheme.textPrimary, size: 20),
    ),
  );

  double _categoryHue(String category) {
    switch (category) {
      case 'Hospital':
        return BitmapDescriptor.hueRed;
      case 'Pharmacy':
        return BitmapDescriptor.hueRose;
      case 'Police Station':
        return BitmapDescriptor.hueBlue;
      case 'Library':
        return BitmapDescriptor.hueCyan;
      case 'Restaurant':
        return BitmapDescriptor.hueOrange;
      case 'Café':
        return BitmapDescriptor.hueYellow;
      case 'Park':
        return BitmapDescriptor.hueGreen;
      case 'Tourist Attraction':
        return BitmapDescriptor.hueMagenta;
      default:
        return BitmapDescriptor.hueAzure;
    }
  }
}
