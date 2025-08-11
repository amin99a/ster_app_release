import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/search_filter.dart';
import '../utils/animations.dart';

class AdvancedFilterPanel extends StatefulWidget {
  final SearchFilter initialFilter;
  final Function(SearchFilter) onFilterChanged;
  final VoidCallback onClose;

  const AdvancedFilterPanel({
    super.key,
    required this.initialFilter,
    required this.onFilterChanged,
    required this.onClose,
  });

  @override
  State<AdvancedFilterPanel> createState() => _AdvancedFilterPanelState();
}

class _AdvancedFilterPanelState extends State<AdvancedFilterPanel>
    with TickerProviderStateMixin {
  late SearchFilter _currentFilter;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter;
    
    _slideController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppAnimations.smoothCurve,
    ));
    
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _updateFilter(SearchFilter newFilter) {
    setState(() {
      _currentFilter = newFilter;
    });
  }

  void _applyFilters() {
    widget.onFilterChanged(_currentFilter);
    _closePanel();
  }

  void _clearFilters() {
    final clearedFilter = SearchFilter();
    setState(() {
      _currentFilter = clearedFilter;
    });
    widget.onFilterChanged(clearedFilter);
  }

  void _closePanel() {
    _slideController.reverse().then((_) {
      widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(-5, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Filter Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price Range
                    AnimatedListItem(
                      index: 0,
                      child: _buildPriceRangeSection(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Location
                    AnimatedListItem(
                      index: 1,
                      child: _buildLocationSection(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Car Type
                    AnimatedListItem(
                      index: 2,
                      child: _buildCarTypeSection(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Brand
                    AnimatedListItem(
                      index: 3,
                      child: _buildBrandSection(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Transmission & Fuel
                    AnimatedListItem(
                      index: 4,
                      child: _buildTransmissionFuelSection(),
                    ),
                    const SizedBox(height: 24),

                    // Car Use
                    AnimatedListItem(
                      index: 5,
                      child: _buildUseTypeSection(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Features
                    AnimatedListItem(
                      index: 6,
                      child: _buildFeaturesSection(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Rating & Reviews
                    AnimatedListItem(
                      index: 7,
                      child: _buildRatingSection(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Host Preferences
                    AnimatedListItem(
                      index: 8,
                      child: _buildHostPreferencesSection(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Sorting
                    AnimatedListItem(
                      index: 9,
                      child: _buildSortingSection(),
                    ),
                    const SizedBox(height: 100), // Space for buttons
                  ],
                ),
              ),
            ),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF593CFB),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedButton(
            onPressed: _closePanel,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filters',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (_currentFilter.activeFilterCount > 0)
                  Text(
                    '${_currentFilter.activeFilterCount} active',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
          if (_currentFilter.activeFilterCount > 0)
            AnimatedButton(
              onPressed: _clearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Clear All',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF593CFB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF593CFB),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Price Range', Icons.attach_money),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Min Price',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'UK£${_currentFilter.minPrice.toInt()}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF593CFB),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Max Price',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'UK£${_currentFilter.maxPrice.toInt()}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF593CFB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              RangeSlider(
                values: RangeValues(_currentFilter.minPrice, _currentFilter.maxPrice),
                min: 0,
                max: 2000,
                divisions: 40,
                activeColor: const Color(0xFF593CFB),
                inactiveColor: Colors.grey.shade300,
                onChanged: (RangeValues values) {
                  _updateFilter(_currentFilter.copyWith(
                    minPrice: values.start,
                    maxPrice: values.end,
                  ));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Location', Icons.location_on),
        const SizedBox(height: 16),
        _buildDropdown(
          'Select Wilaya',
          _currentFilter.selectedWilaya,
          FilterData.wilayas,
          (value) => _updateFilter(_currentFilter.copyWith(selectedWilaya: value)),
        ),
      ],
    );
  }

  Widget _buildCarTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Car Type', Icons.directions_car),
        const SizedBox(height: 16),
        _buildChipGroup(
          FilterData.carTypes,
          _currentFilter.carTypes,
          (selectedTypes) => _updateFilter(_currentFilter.copyWith(carTypes: selectedTypes)),
        ),
      ],
    );
  }

  Widget _buildBrandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Brand', Icons.branding_watermark),
        const SizedBox(height: 16),
        _buildChipGroup(
          FilterData.brands,
          _currentFilter.brands,
          (selectedBrands) => _updateFilter(_currentFilter.copyWith(brands: selectedBrands)),
        ),
      ],
    );
  }

  Widget _buildTransmissionFuelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Transmission & Fuel', Icons.settings),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transmission',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildChipGroup(
                    FilterData.transmissions,
                    _currentFilter.transmissions,
                    (selected) => _updateFilter(_currentFilter.copyWith(transmissions: selected)),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fuel Type',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildChipGroup(
                    FilterData.fuelTypes,
                    _currentFilter.fuelTypes,
                    (selected) => _updateFilter(_currentFilter.copyWith(fuelTypes: selected)),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUseTypeSection() {
    final options = const ['Daily', 'Business', 'Event'];
    final values = const ['daily', 'business', 'event'];
    final selected = _currentFilter.useType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Car Use', Icons.style),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(options.length, (i) {
            final isSelected = selected == values[i];
            return GestureDetector(
              onTap: () {
                final newValue = isSelected ? null : values[i];
                _updateFilter(_currentFilter.copyWith(useType: newValue));
              },
              child: AnimatedContainer(
                duration: AppAnimations.fast,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF593CFB) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF593CFB) : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  options[i],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Features', Icons.star),
        const SizedBox(height: 16),
        _buildChipGroup(
          FilterData.features,
          _currentFilter.features,
          (selectedFeatures) => _updateFilter(_currentFilter.copyWith(features: selectedFeatures)),
          maxLines: 6,
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Rating & Reviews', Icons.star_rate),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Minimum Rating',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (index) {
                            final rating = index + 1.0;
                            final isSelected = _currentFilter.minRating != null && 
                                             _currentFilter.minRating! >= rating;
                            return GestureDetector(
                              onTap: () {
                                final newRating = _currentFilter.minRating == rating ? null : rating;
                                _updateFilter(_currentFilter.copyWith(minRating: newRating));
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.star,
                                  size: 28,
                                  color: isSelected ? Colors.amber : Colors.grey.shade300,
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Minimum Trips',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [5, 10, 20, 50, 100].map((trips) {
                            final isSelected = _currentFilter.minTrips == trips;
                            return GestureDetector(
                              onTap: () {
                                final newTrips = isSelected ? null : trips;
                                _updateFilter(_currentFilter.copyWith(minTrips: newTrips));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF593CFB) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF593CFB) : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  '$trips+',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: isSelected ? Colors.white : Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHostPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Host Preferences', Icons.person_pin),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildSwitchTile(
                'All-Star Hosts Only',
                'Hosts with 4.8+ rating',
                _currentFilter.allStarHostsOnly,
                (value) => _updateFilter(_currentFilter.copyWith(allStarHostsOnly: value)),
              ),
              const SizedBox(height: 16),
              _buildSwitchTile(
                'Instant Book Only',
                'Cars you can book immediately',
                _currentFilter.instantBookOnly,
                (value) => _updateFilter(_currentFilter.copyWith(instantBookOnly: value)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSortingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Sort By', Icons.sort),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: SortOption.values.map((option) {
              final isSelected = _currentFilter.sortBy == option;
              return GestureDetector(
                onTap: () => _updateFilter(_currentFilter.copyWith(sortBy: option)),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF593CFB).withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF593CFB) : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        option.icon,
                        size: 20,
                        color: isSelected ? const Color(0xFF593CFB) : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option.displayName,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? const Color(0xFF593CFB) : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          size: 20,
                          color: Color(0xFF593CFB),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String hint,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            hint,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          value: value,
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(
              item,
              style: GoogleFonts.inter(fontSize: 14),
            ),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildChipGroup(
    List<String> items,
    Set<String> selectedItems,
    Function(Set<String>) onChanged, {
    int maxLines = 4,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.take(maxLines * 3).map((item) {
        final isSelected = selectedItems.contains(item);
        return GestureDetector(
          onTap: () {
            final newSelection = Set<String>.from(selectedItems);
            if (isSelected) {
              newSelection.remove(item);
            } else {
              newSelection.add(item);
            }
            onChanged(newSelection);
          },
          child: AnimatedContainer(
            duration: AppAnimations.fast,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF593CFB) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFF593CFB) : Colors.grey.shade300,
              ),
            ),
            child: Text(
              item,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF593CFB),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Results count
          if (_currentFilter.activeFilterCount > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF593CFB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_currentFilter.activeFilterCount} filter${_currentFilter.activeFilterCount != 1 ? 's' : ''} applied',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF593CFB),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          
          // Apply button
          AnimatedButton(
            onPressed: _applyFilters,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF593CFB),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF593CFB).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Apply Filters',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}