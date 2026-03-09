import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../theme.dart';

class AddEditListingScreen extends StatefulWidget {
  final ListingModel? listing;
  const AddEditListingScreen({super.key, this.listing});
  @override
  State<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(
    text: widget.listing?.name ?? '',
  );
  late final _addressCtrl = TextEditingController(
    text: widget.listing?.address ?? '',
  );
  late final _contactCtrl = TextEditingController(
    text: widget.listing?.contactNumber ?? '',
  );
  late final _descCtrl = TextEditingController(
    text: widget.listing?.description ?? '',
  );
  late final _latCtrl = TextEditingController(
    text: widget.listing != null
        ? widget.listing!.latitude.toString()
        : '-1.9441',
  );
  late final _lngCtrl = TextEditingController(
    text: widget.listing != null
        ? widget.listing!.longitude.toString()
        : '30.0619',
  );

  String _category = 'Café';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.listing != null) _category = widget.listing!.category;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _contactCtrl.dispose();
    _descCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final uid = context.read<AuthProvider>().user!.uid;
    final lp = context.read<ListingsProvider>();
    bool ok;

    if (widget.listing == null) {
      // CREATE
      ok = await lp.addListing(
        ListingModel(
          id: '', // Will be set by Firestore service
          name: _nameCtrl.text.trim(),
          category: _category,
          address: _addressCtrl.text.trim(),
          contactNumber: _contactCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          latitude: double.tryParse(_latCtrl.text) ?? -1.9441,
          longitude: double.tryParse(_lngCtrl.text) ?? 30.0619,
          createdBy: uid,
          timestamp: DateTime.now(),
        ),
      );
    } else {
      // UPDATE
      ok = await lp.updateListing(widget.listing!.id, {
        'name': _nameCtrl.text.trim(),
        'category': _category,
        'address': _addressCtrl.text.trim(),
        'contactNumber': _contactCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'latitude': double.tryParse(_latCtrl.text) ?? widget.listing!.latitude,
        'longitude':
            double.tryParse(_lngCtrl.text) ?? widget.listing!.longitude,
      });
    }

    setState(() => _loading = false);
    if (!mounted) return;

    if (ok) {
      Navigator.pop(context);
    } else if (lp.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lp.error!,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.listing != null;

    return Scaffold(
      backgroundColor: AppTheme.navyDark,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Listing' : 'Add New Listing'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildField(
              'Place Name *',
              _nameCtrl,
              Icons.storefront_outlined,
              hint: 'e.g. Kimironko Café',
              validator: (v) => v!.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            // Category dropdown
            _buildLabel('Category *'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _category,
              dropdownColor: AppTheme.navyMid,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.category_outlined,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ),
              items: kCategories
                  .where((c) => c != 'All')
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),

            _buildField(
              'Address *',
              _addressCtrl,
              Icons.location_on_outlined,
              hint: 'e.g. KN 5 Rd, Kigali',
              validator: (v) => v!.isEmpty ? 'Address is required' : null,
            ),
            const SizedBox(height: 16),

            _buildField(
              'Contact Number',
              _contactCtrl,
              Icons.phone_outlined,
              hint: '+250 788 000 000',
              type: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            _buildLabel('Description'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Describe this place or service...',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(
                    Icons.notes,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Coordinates
            _buildLabel('GPS Coordinates (tap a map to get these)'),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: const InputDecoration(hintText: 'Latitude'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lngCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: const InputDecoration(hintText: 'Longitude'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              'Default coords are Kimironko, Kigali (-1.9441, 30.0619)',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditing ? 'Save Changes' : 'Add Listing'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: AppTheme.textSecondary,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
  );

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    String hint = '',
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
          ),
        ),
      ],
    );
  }
}
