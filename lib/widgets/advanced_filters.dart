import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'animated_widgets.dart';

class AdvancedFilters extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;
  final VoidCallback? onApply;
  final VoidCallback? onReset;

  const AdvancedFilters({
    super.key,
    this.initialFilters = const {},
    required this.onFiltersChanged,
    this.onApply,
    this.onReset,
  });

  @override
  State<AdvancedFilters> createState() => _AdvancedFiltersState();
}

class _AdvancedFiltersState extends State<AdvancedFilters> {
  late Map<String, dynamic> _filters;
  bool _isLoading = false;

  // Filter categories
  final List<FilterCategory> _filterCategories = [
    FilterCategory(
      name: 'Price Range',
      key: 'priceRange',
      type: FilterType.range,
      options: [
        FilterOption(label: 'Under \$50', value: '0-50'),
        FilterOption(label: '\$50-\$100', value: '50-100'),
        FilterOption(label: '\$100-\$200', value: '100-200'),
        FilterOption(label: 'Over \$200', value: '200+'),
      ],
    ),
    FilterCategory(
      name: 'Car Type',
      key: 'carType',
      type: FilterType.multiple,
      options: [
        FilterOption(label: 'SUV', value: 'suv'),
        FilterOption(label: 'Luxury', value: 'luxury'),
        FilterOption(label: 'Electric', value: 'electric'),
        FilterOption(label: 'Sports', value: 'sports'),
        FilterOption(label: 'Mini', value: 'mini'),
        FilterOption(label: 'Convertible', value: 'convertible'),
      ],
    ),
    FilterCategory(
      name: 'Features',
      key: 'features',
      type: FilterType.multiple,
      options: [
        FilterOption(label: 'GPS Navigation', value: 'gps'),
        FilterOption(label: 'Bluetooth Audio', value: 'bluetooth'),
        FilterOption(label: 'Backup Camera', value: 'backup_camera'),
        FilterOption(label: 'Leather Seats', value: 'leather_seats'),
        FilterOption(label: 'Automatic Transmission', value: 'automatic'),
        FilterOption(label: 'Climate Control', value: 'climate_control'),
        FilterOption(label: 'Sunroof', value: 'sunroof'),
        FilterOption(label: 'All-Wheel Drive', value: 'awd'),
      ],
    ),
    FilterCategory(
      name: 'Host Rating',
      key: 'hostRating',
      type: FilterType.single,
      options: [
        FilterOption(label: '4.5+ Stars', value: '4.5'),
        FilterOption(label: '4.0+ Stars', value: '4.0'),
        FilterOption(label: '3.5+ Stars', value: '3.5'),
        FilterOption(label: 'Any Rating', value: 'any'),
      ],
    ),
    FilterCategory(
      name: 'Distance',
      key: 'distance',
      type: FilterType.single,
      options: [
        FilterOption(label: 'Within 5 km', value: '5'),
        FilterOption(label: 'Within 10 km', value: '10'),
        FilterOption(label: 'Within 25 km', value: '25'),
        FilterOption(label: 'Any Distance', value: 'any'),
      ],
    ),
    FilterCategory(
      name: 'Availability',
      key: 'availability',
      type: FilterType.dateRange,
      options: [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.initialFilters);
  }

  void _updateFilter(String categoryKey, dynamic value) {
    setState(() {
      _filters[categoryKey] = value;
    });
    widget.onFiltersChanged(_filters);
  }

  void _clearFilter(String categoryKey) {
    setState(() {
      _filters.remove(categoryKey);
    });
    widget.onFiltersChanged(_filters);
  }

  void _resetAllFilters() {
    setState(() {
      _filters.clear();
    });
    widget.onFiltersChanged(_filters);
    widget.onReset?.call();
  }

  void _applyFilters() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoading = false;
      });
      widget.onApply?.call();
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text('Advanced Filters'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _filters.isNotEmpty ? _resetAllFilters : null,
            child: Text(
              'Reset',
              style: TextStyle(
                color: _filters.isNotEmpty ? Colors.red : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Active filters summary
          if (_filters.isNotEmpty) _buildActiveFiltersSummary(),
          
          // Filter categories
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filterCategories.length,
              itemBuilder: (context, index) {
                final category = _filterCategories[index];
                return _buildFilterCategory(category);
              },
            ),
          ),
          
          // Apply button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: AnimatedLoadingButton(
              text: 'Apply Filters (${_filters.length})',
              isLoading: _isLoading,
              onPressed: _filters.isNotEmpty ? _applyFilters : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF593CFB).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF593CFB).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.filter,
                color: Color(0xFF593CFB),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Active Filters (${_filters.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF593CFB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _filters.entries.map((entry) {
              final category = _filterCategories.firstWhere(
                (cat) => cat.key == entry.key,
                orElse: () => FilterCategory(name: entry.key, key: entry.key, type: FilterType.single, options: []),
              );
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF593CFB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${category.name}: ${_formatFilterValue(entry.value)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _clearFilter(entry.key),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCategory(FilterCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getCategoryIcon(category.name),
                  color: const Color(0xFF593CFB),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_filters.containsKey(category.key))
                  GestureDetector(
                    onTap: () => _clearFilter(category.key),
                    child: const Icon(
                      Icons.clear,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildFilterOptions(category),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOptions(FilterCategory category) {
    switch (category.type) {
      case FilterType.single:
        return _buildSingleSelectOptions(category);
      case FilterType.multiple:
        return _buildMultipleSelectOptions(category);
      case FilterType.range:
        return _buildRangeOptions(category);
      case FilterType.dateRange:
        return _buildDateRangeOptions(category);
    }
  }

  Widget _buildSingleSelectOptions(FilterCategory category) {
    final selectedValue = _filters[category.key];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: category.options.map((option) {
        final isSelected = selectedValue == option.value;
        
        return GestureDetector(
          onTap: () {
            if (isSelected) {
              _clearFilter(category.key);
            } else {
              _updateFilter(category.key, option.value);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFF593CFB) 
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                    ? const Color(0xFF593CFB) 
                    : Colors.grey[300]!,
              ),
            ),
            child: Text(
              option.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultipleSelectOptions(FilterCategory category) {
    final selectedValues = _filters[category.key] as List<dynamic>? ?? [];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: category.options.map((option) {
        final isSelected = selectedValues.contains(option.value);
        
        return GestureDetector(
          onTap: () {
            final newValues = List<dynamic>.from(selectedValues);
            if (isSelected) {
              newValues.remove(option.value);
            } else {
              newValues.add(option.value);
            }
            
            if (newValues.isEmpty) {
              _clearFilter(category.key);
            } else {
              _updateFilter(category.key, newValues);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFF593CFB) 
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                    ? const Color(0xFF593CFB) 
                    : Colors.grey[300]!,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                const SizedBox(width: 4),
                Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRangeOptions(FilterCategory category) {
    // Simplified range implementation
    return _buildSingleSelectOptions(category);
  }

  Widget _buildDateRangeOptions(FilterCategory category) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        children: [
          Text(
            'Date range picker coming soon',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'price range':
        return LucideIcons.dollarSign;
      case 'car type':
        return LucideIcons.car;
      case 'features':
        return LucideIcons.settings;
      case 'host rating':
        return LucideIcons.star;
      case 'distance':
        return LucideIcons.mapPin;
      case 'availability':
        return LucideIcons.calendar;
      default:
        return LucideIcons.filter;
    }
  }

  String _formatFilterValue(dynamic value) {
    if (value is List) {
      return value.join(', ');
    }
    return value.toString();
  }
}

class FilterCategory {
  final String name;
  final String key;
  final FilterType type;
  final List<FilterOption> options;

  FilterCategory({
    required this.name,
    required this.key,
    required this.type,
    required this.options,
  });
}

class FilterOption {
  final String label;
  final String value;

  FilterOption({
    required this.label,
    required this.value,
  });
}

enum FilterType {
  single,
  multiple,
  range,
  dateRange,
} 