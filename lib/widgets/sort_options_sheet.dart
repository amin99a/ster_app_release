import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/search_filter.dart';
import '../utils/animations.dart';

class SortOptionsSheet extends StatelessWidget {
  final SortOption currentSort;
  final Function(SortOption) onSortChanged;

  const SortOptionsSheet({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  static void show(
    BuildContext context, {
    required SortOption currentSort,
    required Function(SortOption) onSortChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SortOptionsSheet(
        currentSort: currentSort,
        onSortChanged: onSortChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.sort,
                  color: const Color(0xFF593CFB),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Sort By',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          // Sort options
          ...SortOption.values.map((option) {
            final isSelected = currentSort == option;
            return AnimatedListItem(
              index: SortOption.values.indexOf(option),
              child: AnimatedButton(
                onPressed: () {
                  onSortChanged(option);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFF593CFB).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFF593CFB)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFF593CFB)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          option.icon,
                          size: 20,
                          color: isSelected 
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.displayName,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: isSelected 
                                    ? FontWeight.w600 
                                    : FontWeight.w500,
                                color: isSelected 
                                    ? const Color(0xFF593CFB)
                                    : Colors.black87,
                              ),
                            ),
                            Text(
                              _getSortDescription(option),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF593CFB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          
          // Bottom padding
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _getSortDescription(SortOption option) {
    switch (option) {
      case SortOption.relevance:
        return 'Best match for your search';
      case SortOption.priceAsc:
        return 'Cheapest cars first';
      case SortOption.priceDesc:
        return 'Most expensive cars first';
      case SortOption.ratingDesc:
        return 'Best rated cars first';
      case SortOption.tripsDesc:
        return 'Most booked cars first';
      case SortOption.newest:
        return 'Recently added cars first';
      case SortOption.distance:
        return 'Closest cars first';
    }
  }
}