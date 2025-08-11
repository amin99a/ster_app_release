import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? label;
  final String? hint;
  final bool isSemanticButton;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.label,
    this.hint,
    this.isSemanticButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: isSemanticButton,
      label: label,
      hint: hint,
      enabled: onPressed != null,
      child: GestureDetector(
        onTap: onPressed,
        child: child,
      ),
    );
  }
}

class AccessibleImage extends StatelessWidget {
  final String imagePath;
  final String altText;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;

  const AccessibleImage({
    super.key,
    required this.imagePath,
    required this.altText,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
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
              color: Colors.grey[300],
              child: Icon(
                Icons.image_not_supported,
                color: Colors.grey[600],
                size: 32,
              ),
            );
          },
        ),
      ),
    );
  }
}

class AccessibleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticLabel;

  const AccessibleText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? text,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? hint;
  final VoidCallback? onTap;
  final bool isTappable;

  const AccessibleCard({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.onTap,
    this.isTappable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: isTappable,
      label: label,
      hint: hint,
      enabled: isTappable && onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: child,
      ),
    );
  }
}

class HighContrastText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const HighContrastText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Text(
      text,
      style: style?.copyWith(
        color: isDarkMode ? Colors.white : Colors.black,
      ) ?? TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
        fontSize: 16,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class LargeTouchTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double minSize;

  const LargeTouchTarget({
    super.key,
    required this.child,
    this.onTap,
    this.minSize = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(
          minWidth: minSize,
          minHeight: minSize,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class FocusableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool autofocus;

  const FocusableWidget({
    super.key,
    required this.child,
    this.onTap,
    this.autofocus = false,
  });

  @override
  State<FocusableWidget> createState() => _FocusableWidgetState();
}

class _FocusableWidgetState extends State<FocusableWidget> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.space) {
            widget.onTap?.call();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _focusNode.hasFocus 
                  ? const Color(0xFF593CFB) 
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class ScreenReaderAnnouncement extends StatelessWidget {
  final String message;
  final bool announce;

  const ScreenReaderAnnouncement({
    super.key,
    required this.message,
    this.announce = true,
  });

  @override
  Widget build(BuildContext context) {
    if (announce) {
      // SemanticsService.announce(message, TextDirection.ltr);
      // TODO: Implement proper screen reader announcement
    }
    return const SizedBox.shrink();
  }
}

class AccessibilitySettings {
  static bool isScreenReaderEnabled = false;
  static bool isHighContrastEnabled = false;
  static bool isLargeTextEnabled = false;
  static double textScaleFactor = 1.0;

  static void updateSettings({
    bool? screenReader,
    bool? highContrast,
    bool? largeText,
    double? textScale,
  }) {
    isScreenReaderEnabled = screenReader ?? isScreenReaderEnabled;
    isHighContrastEnabled = highContrast ?? isHighContrastEnabled;
    isLargeTextEnabled = largeText ?? isLargeTextEnabled;
    textScaleFactor = textScale ?? textScaleFactor;
  }

  static TextStyle getAccessibleTextStyle(TextStyle baseStyle) {
    double fontSize = baseStyle.fontSize ?? 16.0;
    
    if (isLargeTextEnabled) {
      fontSize *= 1.2;
    }
    
    fontSize *= textScaleFactor;
    
    return baseStyle.copyWith(
      fontSize: fontSize,
      color: isHighContrastEnabled 
          ? (baseStyle.color?.computeLuminance() ?? 0.5) > 0.5 
              ? Colors.black 
              : Colors.white
          : baseStyle.color,
    );
  }
}

class AccessibilitySettingsManager {
  static bool isScreenReaderEnabled = false;
  static bool isHighContrastEnabled = false;
  static bool isLargeTextEnabled = false;
  static double textScaleFactor = 1.0;

  static void updateSettings({
    bool? screenReader,
    bool? highContrast,
    bool? largeText,
    double? textScale,
  }) {
    isScreenReaderEnabled = screenReader ?? isScreenReaderEnabled;
    isHighContrastEnabled = highContrast ?? isHighContrastEnabled;
    isLargeTextEnabled = largeText ?? isLargeTextEnabled;
    textScaleFactor = textScale ?? textScaleFactor;
  }

  static TextStyle getAccessibleTextStyle(TextStyle baseStyle) {
    double fontSize = baseStyle.fontSize ?? 16.0;
    
    if (isLargeTextEnabled) {
      fontSize *= 1.2;
    }
    
    fontSize *= textScaleFactor;
    
    return baseStyle.copyWith(
      fontSize: fontSize,
      color: isHighContrastEnabled 
          ? (baseStyle.color?.computeLuminance() ?? 0.5) > 0.5 
              ? Colors.black 
              : Colors.white
          : baseStyle.color,
    );
  }
}

class AccessibilityAwareBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, AccessibilitySettingsManager settings) builder;

  const AccessibilityAwareBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, AccessibilitySettingsManager());
  }
} 