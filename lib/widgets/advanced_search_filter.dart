import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdvancedSearchFilter extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersApplied;

  const AdvancedSearchFilter({
    super.key,
    required this.onFiltersApplied,
  });

  @override
  State<AdvancedSearchFilter> createState() => _AdvancedSearchFilterState();
}

class _AdvancedSearchFilterState extends State<AdvancedSearchFilter> {
  final List<String> _categories = [
    'All',
    'SUV',
    'Sedan',
    'Sports',
    'Luxury',
    'Electric',
    'Family',
    'Business',
  ];

  final List<String> _transmissions = [
    'All',
    'Automatic',
    'Manual',
  ];

  final List<String> _fuelTypes = [
    'All',
    'Essence',
    'Diesel',
    'GPL',
    'Electric',
  ];

  String _selectedCategory = 'All';
  String _selectedTransmission = 'All';
  String _selectedFuelType = 'All';
  bool _instantBooking = false;
  bool _freeCancellation = false;
  RangeValues _priceRange = const RangeValues(0, 1000);
  RangeValues _ratingRange = const RangeValues(0, 5);

  void _applyFilters() {
    final filters = {
      'category': _selectedCategory,
      'transmission': _selectedTransmission,
      'fuelType': _selectedFuelType,
      'instantBooking': _instantBooking,
      'freeCancellation': _freeCancellation,
      'priceRange': _priceRange,
      'ratingRange': _ratingRange,
    };

    widget.onFiltersApplied(filters);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Advanced Filters',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = 'All';
                _selectedTransmission = 'All';
                _selectedFuelType = 'All';
                _instantBooking = false;
                _freeCancellation = false;
                _priceRange = const RangeValues(0, 1000);
                _ratingRange = const RangeValues(0, 5);
              });
            },
            child: Text(
              'Reset',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF353935), // Updated to Onyx
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Price Range
            const Text(
              'Price Range',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 1000,
              divisions: 20,
              labels: RangeLabels(
                '£${_priceRange.start.round()}',
                '£${_priceRange.end.round()}',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _priceRange = values;
                });
              },
              activeColor: const Color(0xFF353935), // Updated to Onyx
            ),
            const SizedBox(height: 16),

            // Rating Range
            const Text(
              'Rating',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            RangeSlider(
              values: _ratingRange,
              min: 0,
              max: 5,
              divisions: 10,
              labels: RangeLabels(
                '${_ratingRange.start.toStringAsFixed(1)}★',
                '${_ratingRange.end.toStringAsFixed(1)}★',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _ratingRange = values;
                });
              },
              activeColor: const Color(0xFF353935), // Updated to Onyx
            ),
            const SizedBox(height: 16),

            // Transmission
            const Text(
              'Transmission',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedTransmission,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _transmissions.map((transmission) {
                return DropdownMenuItem(
                  value: transmission,
                  child: Text(transmission),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedTransmission = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Fuel Type
            const Text(
              'Fuel Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedFuelType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _fuelTypes.map((fuelType) {
                return DropdownMenuItem(
                  value: fuelType,
                  child: Text(fuelType),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedFuelType = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Instant Booking
            SwitchListTile(
              title: const Text(
                'Instant Booking',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              subtitle: const Text(
                'Book without host approval',
                style: TextStyle(fontSize: 12),
              ),
              value: _instantBooking,
              onChanged: (bool value) {
                setState(() {
                  _instantBooking = value;
                });
              },
              activeColor: const Color(0xFF593CFB),
            ),

            // Free Cancellation
            SwitchListTile(
              title: const Text(
                'Free Cancellation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              subtitle: const Text(
                'Cancel up to 24 hours before',
                style: TextStyle(fontSize: 12),
              ),
              value: _freeCancellation,
              onChanged: (bool value) {
                setState(() {
                  _freeCancellation = value;
                });
              },
              activeColor: const Color(0xFF593CFB),
            ),

            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF593CFB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
  