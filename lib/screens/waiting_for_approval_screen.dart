import 'package:flutter/material.dart';
import '../widgets/floating_header.dart';

class WaitingForApprovalScreen extends StatelessWidget {
  const WaitingForApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.hourglass_top, size: 64, color: Colors.orange),
                  SizedBox(height: 16),
                  Text('Waiting for approval', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text('We are reviewing your application. You will be notified once a decision is made.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


