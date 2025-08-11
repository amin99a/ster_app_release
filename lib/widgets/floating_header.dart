import 'package:flutter/material.dart';

class FloatingHeader extends StatelessWidget {
  final Widget child;
  final double height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const FloatingHeader({
    super.key,
    required this.child,
    this.height = 60,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin ?? EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        right: 10,
        bottom: 10,
      ),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF353935),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          // Primary shadow - closest to the surface
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            blurRadius: 15,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
          // Secondary shadow - medium depth
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.15),
            blurRadius: 30,
            offset: Offset(0, 8),
            spreadRadius: 0,
          ),
          // Tertiary shadow - deepest layer
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            blurRadius: 50,
            offset: Offset(0, 16),
            spreadRadius: 0,
          ),
          // Ambient shadow - subtle overall depth
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 80,
            offset: Offset(0, 25),
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}