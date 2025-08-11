import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EnhancedAccessibilityWidgets {
  // Build accessible button with proper semantics
  static Widget buildAccessibleButton({
    required String label,
    required String hint,
    required VoidCallback onPressed,
    required Widget child,
    bool isEnabled = true,
    String? tooltip,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: isEnabled,
      tooltip: tooltip,
      child: GestureDetector(
        onTap: isEnabled ? onPressed : null,
        child: AbsorbPointer(
          child: child,
        ),
      ),
    );
  }

  // Build accessible image with proper alt text
  static Widget buildAccessibleImage({
    required String imagePath,
    required String altText,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    return Semantics(
      label: altText,
      image: true,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image.asset(
          imagePath,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: borderRadius ?? BorderRadius.zero,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.image,
                      size: 32,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Image not available',
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Build accessible card with proper semantics
  static Widget buildAccessibleCard({
    required String title,
    required String description,
    required Widget child,
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return Semantics(
      label: title,
      hint: description,
      button: onTap != null,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: child,
        ),
      ),
    );
  }

  // Build accessible list item
  static Widget buildAccessibleListItem({
    required String title,
    required String subtitle,
    required Widget leading,
    Widget? trailing,
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return Semantics(
      label: title,
      hint: subtitle,
      button: onTap != null,
      selected: isSelected,
      child: ListTile(
        leading: leading,
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            color: Colors.grey.shade600,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  // Build accessible search field
  static Widget buildAccessibleSearchField({
    required String hintText,
    required String label,
    required ValueChanged<String> onChanged,
    VoidCallback? onTap,
    TextEditingController? controller,
    bool readOnly = false,
  }) {
    return Semantics(
      label: label,
      hint: hintText,
      textField: true,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            color: Colors.grey.shade400,
          ),
          prefixIcon: const Icon(
            LucideIcons.search,
            color: Color(0xFF593CFB),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF593CFB), width: 2),
          ),
        ),
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
      ),
    );
  }

  // Build accessible category chip
  static Widget buildAccessibleCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? selectedColor,
    Color? unselectedColor,
  }) {
    return Semantics(
      label: '$label category',
      hint: isSelected ? 'Selected' : 'Not selected',
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? (selectedColor ?? const Color(0xFF593CFB)) : (unselectedColor ?? Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? (selectedColor ?? const Color(0xFF593CFB)) : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // Build accessible loading indicator
  static Widget buildAccessibleLoadingIndicator({
    required String message,
    Color? color,
  }) {
    return Semantics(
      label: message,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? const Color(0xFF593CFB),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.inter(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build accessible error widget
  static Widget buildAccessibleErrorWidget({
    required String title,
    required String message,
    required VoidCallback onRetry,
    IconData? icon,
  }) {
    return Semantics(
      label: title,
      hint: message,
      button: true,
      child: GestureDetector(
        onTap: onRetry,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon ?? LucideIcons.alertCircle,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF593CFB),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build accessible navigation item
  static Widget buildAccessibleNavigationItem({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: label,
      hint: isSelected ? 'Current page' : 'Navigate to $label',
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build accessible carousel indicator
  static Widget buildAccessibleCarouselIndicator({
    required int currentIndex,
    required int totalItems,
    required ValueChanged<int> onPageChanged,
  }) {
    return Semantics(
      label: 'Page ${currentIndex + 1} of $totalItems',
      hint: 'Swipe to navigate between pages',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalItems, (index) {
          return GestureDetector(
            onTap: () => onPageChanged(index),
            child: Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == currentIndex
                    ? const Color(0xFF593CFB)
                    : Colors.grey.shade300,
              ),
            ),
          );
        }),
      ),
    );
  }

  // Build accessible rating widget
  static Widget buildAccessibleRatingWidget({
    required double rating,
    required int maxRating,
    required String label,
  }) {
    return Semantics(
      label: '$label: $rating out of $maxRating stars',
      child: Row(
        children: [
          ...List.generate(maxRating, (index) {
            final isFilled = index < rating;
            return Icon(
              isFilled ? LucideIcons.star : LucideIcons.star,
              size: 16,
              color: isFilled ? const Color(0xFF593CFB) : Colors.grey.shade300,
            );
          }),
          const SizedBox(width: 4),
          Text(
            rating.toString(),
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Build accessible price widget
  static Widget buildAccessiblePriceWidget({
    required String price,
    required String currency,
    String? originalPrice,
    bool showDiscount = false,
  }) {
    return Semantics(
      label: showDiscount && originalPrice != null
          ? 'Price: $price, original price: $originalPrice'
          : 'Price: $price',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showDiscount && originalPrice != null) ...[
            Text(
              originalPrice,
              style: GoogleFonts.inter(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
          ],
          Text(
            price,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: const Color(0xFF593CFB),
            ),
          ),
        ],
      ),
    );
  }
}