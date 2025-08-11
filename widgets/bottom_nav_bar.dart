import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF353935), // Onyx color
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              // Primary shadow - closest to the surface
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 15,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              // Secondary shadow - medium depth
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              // Tertiary shadow - deepest layer
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 50,
                offset: const Offset(0, 16),
                spreadRadius: 0,
              ),
              // Ambient shadow - subtle overall depth
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 80,
                offset: const Offset(0, 25),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: LucideIcons.home,
                label: 'Home',
                isSelected: selectedIndex == 0,
                onTap: () => onItemTapped(0),
              ),
              _buildNavItem(
                icon: LucideIcons.search,
                label: 'Search',
                isSelected: selectedIndex == 1,
                onTap: () => onItemTapped(1),
              ),
              _buildNavItem(
                icon: LucideIcons.heart,
                label: 'Saved',
                isSelected: selectedIndex == 2,
                onTap: () => onItemTapped(2),
              ),
              _buildNavItem(
                icon: LucideIcons.moreHorizontal,
                label: 'More',
                isSelected: selectedIndex == 3,
                onTap: () => onItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isSelected ? [
                  // Primary shadow for selected state
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                  // Secondary shadow for depth
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ] : null,
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF353935) : Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
