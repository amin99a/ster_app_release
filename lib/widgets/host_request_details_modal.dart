import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/host_request.dart';

class HostRequestDetailsModal extends StatelessWidget {
  final HostRequest request;
  final VoidCallback onApprove;
  final Function(String) onReject;

  const HostRequestDetailsModal({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: request.userImage != null
                          ? NetworkImage(request.userImage!)
                          : null,
                      child: request.userImage == null
                          ? const Icon(Icons.person, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.userName,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Host Application Details',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(request.status.toString().split('.').last),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        request.statusDisplayName,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection('Contact Information', [
                    _buildDetailRow('Email', request.userEmail, Icons.email),
                    if (request.userPhone != null)
                      _buildDetailRow('Phone', request.userPhone!, Icons.phone),
                  ]),
                  
                  const SizedBox(height: 24),
                  
                  _buildDetailSection('Business Information', [
                    _buildDetailRow('Business Name', request.businessName, Icons.business),
                    if (request.businessType != null)
                      _buildDetailRow('Business Type', request.businessType!, Icons.category),
                    if (request.businessAddress != null)
                      _buildDetailRow('Address', request.businessAddress!, Icons.location_on),
                    if (request.taxId != null)
                      _buildDetailRow('Tax ID', request.taxId!, Icons.receipt),
                  ]),
                  
                  const SizedBox(height: 24),
                  
                  _buildDetailSection('Vehicle Information', [
                    _buildDetailRow('Planned Cars', request.plannedCarsCount.toString(), Icons.directions_car),
                    _buildDetailRow('Vehicle Types', request.vehicleTypesDisplay, Icons.category),
                    if (request.insuranceProvider != null)
                      _buildDetailRow('Insurance Provider', request.insuranceProvider!, Icons.security),
                  ]),
                  
                  const SizedBox(height: 24),
                  
                  _buildDetailSection('Documentation Status', [
                    _buildStatusRow('Commercial License', request.hasCommercialLicense),
                    _buildStatusRow('Insurance Coverage', request.hasInsurance),
                    _buildStatusRow('Vehicle Registration', request.hasVehicleRegistration),
                  ]),
                  
                  const SizedBox(height: 24),
                  
                  _buildDetailSection('Timeline', [
                    _buildDetailRow('Submitted', _formatDate(request.createdAt), Icons.schedule),
                    if (request.reviewedAt != null)
                      _buildDetailRow('Reviewed', _formatDate(request.reviewedAt!), Icons.rate_review),
                    if (request.reviewerName != null)
                      _buildDetailRow('Reviewer', request.reviewerName!, Icons.person),
                  ]),
                  
                  if (request.rejectionReason != null && request.rejectionReason!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildDetailSection('Rejection Reason', [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.2)),
                        ),
                        child: Text(
                          request.rejectionReason!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ]),
                  ],
                ],
              ),
            ),
          ),
          
          // Action buttons
          if (request.isPending) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showRejectDialog(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Reject',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onApprove();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Approve Host',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: isCompleted ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isCompleted ? Colors.green[700] : Colors.red[700],
              ),
            ),
          ),
          Text(
            isCompleted ? 'Complete' : 'Pending',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isCompleted ? Colors.green[600] : Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reject Host Request',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to reject ${request.userName}\'s host application?',
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onReject(reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Reject', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
