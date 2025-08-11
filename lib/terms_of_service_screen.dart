import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/floating_header.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
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
                    'Terms of Service',
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
                    'Acceptance of Terms',
                    'Last updated: December 2024',
                    [
                      _buildSubsection(
                        'Agreement to Terms',
                        'By accessing and using the STER car rental platform, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
                      ),
                      _buildSubsection(
                        'Modifications to Terms',
                        'STER reserves the right to modify these terms at any time. We will notify users of any material changes via email or through the app. Your continued use of the service constitutes acceptance of the modified terms.',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildSection(
                    'User Accounts',
                    'Account creation and responsibilities',
                    [
                      _buildSubsection(
                        'Account Registration',
                        'To use our services, you must:\n\n• Be at least 18 years old\n• Provide accurate and complete information\n• Maintain the security of your account credentials\n• Notify us immediately of any unauthorized use\n• Accept responsibility for all activities under your account',
                      ),
                      _buildSubsection(
                        'Account Suspension',
                        'We may suspend or terminate your account if:\n\n• You violate these terms\n• You engage in fraudulent activity\n• You fail to pay fees or charges\n• You provide false information\n• You misuse the platform or services',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildSection(
                    'Vehicle Rentals',
                    'Rules and requirements for renting',
                    [
                      _buildSubsection(
                        'Eligibility Requirements',
                        'To rent a vehicle through STER, you must:\n\n• Hold a valid driver\'s license for at least 2 years\n• Be at least 21 years old (25 for luxury vehicles)\n• Have a clean driving record\n• Provide valid insurance information\n• Pass identity verification',
                      ),
                      _buildSubsection(
                        'Booking and Payment',
                        '• All bookings must be confirmed and paid in advance\n• Prices include base rental, insurance, and service fees\n• Additional charges may apply for damages, fuel, or late returns\n• Payment is processed securely through our platform\n• Cancellation policies vary by host',
                      ),
                      _buildSubsection(
                        'Vehicle Use and Care',
                        'During your rental period, you agree to:\n\n• Use the vehicle only for its intended purpose\n• Operate the vehicle safely and legally\n• Return the vehicle in the same condition\n• Report any accidents or damages immediately\n• Not exceed the agreed mileage limits',
                      ),
                      _buildSubsection(
                        'Insurance and Liability',
                        '• STER provides basic insurance coverage for all rentals\n• Additional coverage options are available\n• You remain responsible for deductibles and uncovered damages\n• Personal insurance may provide additional protection\n• Review all insurance terms before booking',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildSection(
                    'Host Responsibilities',
                    'Requirements for vehicle owners',
                    [
                      _buildSubsection(
                        'Vehicle Requirements',
                        'Hosts must ensure their vehicles:\n\n• Are in safe, roadworthy condition\n• Have valid registration and insurance\n• Meet all legal requirements\n• Are clean and well-maintained\n• Have accurate descriptions and photos',
                      ),
                      _buildSubsection(
                        'Host Obligations',
                        'As a host, you agree to:\n\n• Provide accurate vehicle information\n• Respond promptly to booking requests\n• Maintain vehicle safety standards\n• Handle disputes professionally\n• Comply with all applicable laws',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildSection(
                    'Prohibited Activities',
                    'Activities not allowed on our platform',
                    [
                      _buildSubsection(
                        'General Prohibitions',
                        'You may not:\n\n• Use the service for illegal activities\n• Provide false or misleading information\n• Interfere with the platform\'s operation\n• Attempt to gain unauthorized access\n• Harass or discriminate against other users\n• Violate any applicable laws or regulations',
                      ),
                      _buildSubsection(
                        'Vehicle-Related Prohibitions',
                        'You may not:\n\n• Use vehicles for racing or stunts\n• Transport illegal substances\n• Exceed vehicle capacity limits\n• Smoke in non-smoking vehicles\n• Transport pets without permission\n• Use vehicles for commercial purposes without approval',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildSection(
                    'Fees and Payments',
                    'Costs associated with our services',
                    [
                      _buildSubsection(
                        'Service Fees',
                        'STER charges the following fees:\n\n• Booking fee: 10% of rental cost\n• Insurance fee: Varies by vehicle and coverage\n• Processing fee: 2.5% of total transaction\n• Late return fee: \$25 per hour\n• Cleaning fee: \$50 if vehicle is returned dirty',
                      ),
                      _buildSubsection(
                        'Payment Methods',
                        'We accept:\n\n• Credit and debit cards\n• Digital wallets (Apple Pay, Google Pay)\n• Bank transfers (for business accounts)\n• All payments are processed securely\n• Refunds are processed within 5-7 business days',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildSection(
                    'Dispute Resolution',
                    'How we handle conflicts',
                    [
                      _buildSubsection(
                        'Customer Support',
                        'For most issues, our customer support team can help resolve disputes between users. Contact us through:\n\n• In-app chat support\n• Email: support@ster.com\n• Phone: +213 123 456 789\n• Response time: Within 24 hours',
                      ),
                      _buildSubsection(
                        'Escalation Process',
                        'If disputes cannot be resolved through support:\n\n• Mediation through STER representatives\n• Binding arbitration (if required)\n• Legal proceedings (as last resort)\n• All disputes governed by Algerian law',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildSection(
                    'Limitation of Liability',
                    'Our liability limitations',
                    [
                      _buildSubsection(
                        'STER\'s Liability',
                        'STER is a platform connecting vehicle owners with renters. Our liability is limited to:\n\n• Direct damages up to the amount of fees paid\n• Refunds for service failures\n• We are not liable for:\n  - Vehicle accidents or damages\n  - Personal injury or property damage\n  - Third-party service issues\n  - Acts of nature or force majeure',
                      ),
                      _buildSubsection(
                        'User Indemnification',
                        'You agree to indemnify and hold harmless STER from any claims arising from:\n\n• Your use of the platform\n• Your violation of these terms\n• Your interactions with other users\n• Your vehicle rental activities',
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
                          Icons.description,
                          size: 48,
                          color: Color(0xFF593CFB),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Thank you for choosing STER',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'By using our platform, you agree to these terms and our commitment to providing safe, reliable car rental services.',
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