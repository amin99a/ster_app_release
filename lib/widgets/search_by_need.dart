import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../search_screen.dart';

class SearchByNeed extends StatelessWidget {
  const SearchByNeed({super.key});

  void _openSearch(BuildContext context, String useType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchScreen(),
        settings: RouteSettings(arguments: {'useType': useType}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Search by your need',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _NeedCard(
                title: 'Daily use',
                subtitle: 'Budget-friendly',
                color: const Color(0xFF22C55E),
                icon: LucideIcons.calendarDays,
                onTap: () => _openSearch(context, 'daily'),
              ),
              const SizedBox(width: 12),
              _NeedCard(
                title: 'Business',
                subtitle: 'Premium & comfort',
                color: const Color(0xFF0EA5E9),
                icon: LucideIcons.briefcase,
                onTap: () => _openSearch(context, 'business'),
              ),
              const SizedBox(width: 12),
              _NeedCard(
                title: 'Events',
                subtitle: 'Stylish & XL',
                color: const Color(0xFFF59E0B),
                icon: LucideIcons.partyPopper,
                onTap: () => _openSearch(context, 'event'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NeedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _NeedCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


