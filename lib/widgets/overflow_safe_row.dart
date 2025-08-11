import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// A Row widget that automatically handles overflow by wrapping content
/// and providing safe sizing for text elements
class OverflowSafeRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final EdgeInsetsGeometry? padding;
  final bool wrapOnOverflow;

  const OverflowSafeRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.padding,
    this.wrapOnOverflow = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget rowWidget;

    if (wrapOnOverflow) {
      // Use Wrap for overflow handling
      rowWidget = Wrap(
        direction: Axis.horizontal,
        alignment: _convertMainAxisAlignment(mainAxisAlignment),
        crossAxisAlignment: _convertCrossAxisAlignment(crossAxisAlignment),
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        spacing: 4.0, // Small spacing between wrapped elements
        runSpacing: 2.0,
        children: children,
      );
    } else {
      // Use traditional Row but with Flexible/Expanded for text widgets
      rowWidget = Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        textBaseline: textBaseline,
        children: _makeChildrenFlexible(children),
      );
    }

    if (padding != null) {
      return Padding(
        padding: padding!,
        child: rowWidget,
      );
    }

    return rowWidget;
  }

  List<Widget> _makeChildrenFlexible(List<Widget> children) {
    return children.map((child) {
      // Wrap Text widgets in Flexible to prevent overflow
      if (child is Text) {
        return Flexible(
          child: child,
        );
      }
      // Wrap other widgets that might contain text
      if (child is RichText || child is SelectableText) {
        return Flexible(
          child: child,
        );
      }
      return child;
    }).toList();
  }

  WrapAlignment _convertMainAxisAlignment(MainAxisAlignment alignment) {
    switch (alignment) {
      case MainAxisAlignment.start:
        return WrapAlignment.start;
      case MainAxisAlignment.end:
        return WrapAlignment.end;
      case MainAxisAlignment.center:
        return WrapAlignment.center;
      case MainAxisAlignment.spaceBetween:
        return WrapAlignment.spaceBetween;
      case MainAxisAlignment.spaceAround:
        return WrapAlignment.spaceAround;
      case MainAxisAlignment.spaceEvenly:
        return WrapAlignment.spaceEvenly;
    }
  }

  WrapCrossAlignment _convertCrossAxisAlignment(CrossAxisAlignment alignment) {
    switch (alignment) {
      case CrossAxisAlignment.start:
        return WrapCrossAlignment.start;
      case CrossAxisAlignment.end:
        return WrapCrossAlignment.end;
      case CrossAxisAlignment.center:
        return WrapCrossAlignment.center;
      case CrossAxisAlignment.stretch:
        return WrapCrossAlignment.start; // Wrap doesn't have stretch
      case CrossAxisAlignment.baseline:
        return WrapCrossAlignment.start; // Wrap doesn't have baseline
    }
  }
}

/// A Column widget that automatically handles overflow by adding scrolling
class OverflowSafeColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final EdgeInsetsGeometry? padding;
  final bool scrollOnOverflow;
  final ScrollPhysics? physics;

  const OverflowSafeColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.padding,
    this.scrollOnOverflow = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    Widget columnWidget = Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: children,
    );

    if (scrollOnOverflow) {
      columnWidget = SingleChildScrollView(
        physics: physics,
        child: columnWidget,
      );
    }

    if (padding != null) {
      return Padding(
        padding: padding!,
        child: columnWidget,
      );
    }

    return columnWidget;
  }
}

/// A Text widget that automatically handles overflow with safe defaults
class OverflowSafeText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow overflow;
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final ui.TextHeightBehavior? textHeightBehavior;

  const OverflowSafeText(
    this.text, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow = TextOverflow.ellipsis, // Safe default
    this.textScaleFactor,
    this.maxLines = 2, // Safe default
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}

