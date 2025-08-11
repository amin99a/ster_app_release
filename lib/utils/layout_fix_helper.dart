import 'package:flutter/material.dart';
import '../widgets/overflow_safe_row.dart';

/// Helper class containing methods to quickly fix common layout overflow issues
class LayoutFixHelper {
  
  /// Wraps any widget to prevent overflow issues
  static Widget preventOverflow(Widget child, {
    bool useScrollView = false,
    bool useFlex = true,
  }) {
    if (useScrollView) {
      return SingleChildScrollView(
        child: child,
      );
    }
    
    if (useFlex && child is Row) {
      // Convert Row to OverflowSafeRow
      final row = child;
      return OverflowSafeRow(
        mainAxisAlignment: row.mainAxisAlignment,
        crossAxisAlignment: row.crossAxisAlignment,
        children: row.children,
      );
    }
    
    if (useFlex && child is Column) {
      // Wrap Column in Flexible if needed
      return Flexible(child: child);
    }
    
    return child;
  }

  /// Quick fix for text overflow in any widget tree
  static Widget fixTextOverflow(Widget widget) {
    if (widget is Text) {
      return OverflowSafeText(
        widget.data ?? '',
        style: widget.style,
        textAlign: widget.textAlign,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
    return widget;
  }

  /// Creates a safe container that won't cause overflow
  static Widget safeContainer({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Decoration? decoration,
    BoxConstraints? constraints,
  }) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration,
      constraints: constraints ?? const BoxConstraints(
        maxWidth: double.infinity,
      ),
      child: child,
    );
  }

  /// Creates a safe card widget that handles overflow properly
  static Widget safeCard({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    double borderRadius = 8.0,
    List<BoxShadow>? boxShadow,
    Color backgroundColor = Colors.white,
  }) {
    return Container(
      width: width,
      height: height,
      constraints: const BoxConstraints(
        maxWidth: double.infinity,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  /// Wraps ListView to prevent overflow issues
  static Widget safeListView({
    required List<Widget> children,
    Axis scrollDirection = Axis.vertical,
    EdgeInsetsGeometry? padding,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
  }) {
    return ListView(
      scrollDirection: scrollDirection,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const ClampingScrollPhysics(),
      children: children,
    );
  }

  /// Creates a responsive grid that adapts to screen size
  static Widget responsiveGrid({
    required List<Widget> children,
    double childAspectRatio = 1.0,
    double maxCrossAxisExtent = 200.0,
    double mainAxisSpacing = 8.0,
    double crossAxisSpacing = 8.0,
    EdgeInsetsGeometry? padding,
  }) {
    return GridView.builder(
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  /// Creates a flexible row that handles different screen sizes
  static Widget responsiveRow({
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    bool wrapOnSmallScreen = true,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (wrapOnSmallScreen && constraints.maxWidth < 600) {
          return OverflowSafeColumn(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );
        }
        
        return OverflowSafeRow(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        );
      },
    );
  }

  /// Quick fixes for common layout problems
  static BoxConstraints safeConstraints({
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    return BoxConstraints(
      minWidth: minWidth ?? 0.0,
      maxWidth: maxWidth ?? double.infinity,
      minHeight: minHeight ?? 0.0,
      maxHeight: maxHeight ?? double.infinity,
    );
  }

  /// Helper to create properly sized images that won't cause overflow
  static Widget safeImage({
    required String imagePath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    double borderRadius = 0.0,
    Widget? errorWidget,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(
              Icons.broken_image,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }
}

/// Extension to add overflow protection to any widget
extension OverflowProtection on Widget {
  
  /// Wraps the widget to prevent overflow
  Widget preventOverflow({bool useScrollView = false}) {
    return LayoutFixHelper.preventOverflow(this, useScrollView: useScrollView);
  }
  
  /// Makes the widget flexible to adapt to available space
  Widget makeFlexible({int flex = 1}) {
    return Flexible(flex: flex, child: this);
  }
  
  /// Makes the widget expanded to fill available space
  Widget makeExpanded({int flex = 1}) {
    return Expanded(flex: flex, child: this);
  }
  
  /// Adds safe constraints to prevent overflow
  Widget withSafeConstraints({
    double? maxWidth,
    double? maxHeight,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? double.infinity,
        maxHeight: maxHeight ?? double.infinity,
      ),
      child: this,
    );
  }
}

/// Quick debugging widget to visualize layout boundaries
class LayoutDebugger extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final String? label;

  const LayoutDebugger({
    super.key,
    required this.child,
    this.borderColor = Colors.red,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Stack(
        children: [
          child,
          if (label != null)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                color: borderColor,
                child: Text(
                  label!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}