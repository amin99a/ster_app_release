import 'package:flutter/material.dart';
import '../widgets/floating_header.dart';

class HostApplicationStatusScreen extends StatelessWidget {
  final String status; // pending | rejected
  final String? reason;
  final VoidCallback? onResubmit;

  const HostApplicationStatusScreen({
    super.key,
    required this.status,
    this.reason,
    this.onResubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isRejected = status == 'rejected';
    return Scaffold(
      body: Column(
        children: [
          const FloatingHeader(
            child: Center(
              child: Text(
                'Host Application',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      isRejected ? Icons.cancel : Icons.hourglass_top,
                      size: 64,
                      color: isRejected ? Colors.red : Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isRejected ? 'Application Rejected' : 'Waiting for Approval',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    if (isRejected && reason != null)
                      Text('Reason: $reason'),
                    const SizedBox(height: 16),
                    if (isRejected && onResubmit != null)
                      ElevatedButton(
                        onPressed: onResubmit,
                        child: const Text('Resubmit Application'),
                      )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


