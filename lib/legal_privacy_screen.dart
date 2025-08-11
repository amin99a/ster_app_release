import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'widgets/floating_header.dart';

class LegalPrivacyScreen extends StatefulWidget {
  const LegalPrivacyScreen({super.key});

  @override
  State<LegalPrivacyScreen> createState() => _LegalPrivacyScreenState();
}

class _LegalPrivacyScreenState extends State<LegalPrivacyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Floating 3D Header
            FloatingHeader(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Legal & Privacy',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    'Privacy Policy',
                    'Last updated: December 2024',
                    [
                      _buildSubsection(
                        'Information We Collect',
                        'We collect information you provide directly to us, such as when you create an account, make a booking, or contact customer support. This may include:\n\n• Personal identification information (name, email address, phone number)\n• Driver\'s license and insurance information\n• Payment information\n• Vehicle preferences and rental history\n• Communication preferences',
                      ),
                      _buildSubsection(
                        'How We Use Your Information',
                        'We use the information we collect to:\n\n• Provide, maintain, and improve our services\n• Process bookings and payments\n• Communicate with you about your account and bookings\n• Send you marketing communications (with your consent)\n• Ensure safety and security of our platform\n• Comply with legal obligations',
                      ),
                      _buildSubsection(
                        'Information Sharing',
                        'We may share your information with:\n\n• Vehicle owners and hosts\n• Payment processors and financial institutions\n• Insurance providers\n• Law enforcement when required by law\n• Service providers who assist in our operations',
                      ),
                      _buildSubsection(
                        'Data Security',
                        'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet is 100% secure.',
                      ),
                      _buildSubsection(
                        'Your Rights',
                        'You have the right to:\n\n• Access your personal information\n• Correct inaccurate information\n• Delete your account and associated data\n• Opt-out of marketing communications\n• Request data portability\n• Lodge a complaint with supervisory authorities',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildSection(
                    'Legal Information',
                    'Important legal notices and disclaimers',
                    [
                      _buildSubsection(
                        'Terms of Service',
                        'By using our platform, you agree to our Terms of Service, which govern your use of our services, including booking vehicles, payment processing, and dispute resolution.',
                      ),
                      _buildSubsection(
                        'Liability Limitations',
                        'STER is a platform connecting vehicle owners with renters. We are not responsible for:\n\n• Vehicle condition or mechanical issues\n• Accidents or damages during rental\n• Insurance claims or disputes\n• Host or renter conduct\n• Third-party service issues',
                      ),
                      _buildSubsection(
                        'Insurance Requirements',
                        'All renters must maintain valid insurance coverage during their rental period. STER provides supplemental insurance options, but primary coverage remains the responsibility of the renter.',
                      ),
                      _buildSubsection(
                        'Dispute Resolution',
                        'Any disputes arising from the use of our platform will be resolved through:\n\n• Direct communication between parties\n• STER customer support mediation\n• Binding arbitration (if required)\n• Legal proceedings (as last resort)',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildSection(
                    'Contact Information',
                    'How to reach us',
                    [
                      _buildSubsection(
                        'Privacy Inquiries',
                        'For privacy-related questions or to exercise your rights:\n\n• Email: privacy@ster.com\n• Phone: +213 123 456 789\n• Address: 123 Tech Street, Algiers, Algeria',
                      ),
                      _buildSubsection(
                        'Legal Inquiries',
                        'For legal matters or service of process:\n\n• Email: legal@ster.com\n• Address: Legal Department, STER Inc., 123 Tech Street, Algiers, Algeria',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Footer
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          LucideIcons.shield,
                          size: 48,
                          color: Color(0xFF593CFB),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your privacy and security are our top priorities',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We are committed to protecting your personal information and ensuring transparency in how we handle your data.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF593CFB).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF593CFB).withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF593CFB),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...children,
      ],
    );
  }

  Widget _buildSubsection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
} 