import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FallbackUI extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;
  final String? retryText;
  final String? goBackText;

  const FallbackUI({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
    this.iconColor,
    this.onRetry,
    this.onGoBack,
    this.retryText,
    this.goBackText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: iconColor ?? Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null || onGoBack != null) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (onGoBack != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onGoBack,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF593CFB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        goBackText ?? 'Go Back',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF593CFB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  if (onRetry != null) const SizedBox(width: 12),
                ],
                if (onRetry != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF593CFB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text(
                        retryText ?? 'Retry',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// Specific fallback UI widgets for common scenarios
class NetworkErrorFallback extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;

  const NetworkErrorFallback({
    super.key,
    this.onRetry,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return FallbackUI(
      title: 'Network Error',
      message: 'Unable to connect to the server. Please check your internet connection and try again.',
      icon: Icons.wifi_off,
      iconColor: Colors.orange[400],
      onRetry: onRetry,
      onGoBack: onGoBack,
      retryText: 'Try Again',
    );
  }
}

class DataErrorFallback extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;

  const DataErrorFallback({
    super.key,
    this.onRetry,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return FallbackUI(
      title: 'Data Error',
      message: 'Unable to load the requested data. Please try again or contact support if the problem persists.',
      icon: Icons.data_usage,
      iconColor: Colors.blue[400],
      onRetry: onRetry,
      onGoBack: onGoBack,
      retryText: 'Reload',
    );
  }
}

class ServerErrorFallback extends StatelessWidget {
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;

  const ServerErrorFallback({
    super.key,
    this.onRetry,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return FallbackUI(
      title: 'Server Error',
      message: 'The server is experiencing issues. Please try again later or contact support.',
      icon: Icons.cloud_off,
      iconColor: Colors.red[400],
      onRetry: onRetry,
      onGoBack: onGoBack,
      retryText: 'Try Again',
    );
  }
}

class MaintenanceFallback extends StatelessWidget {
  final VoidCallback? onGoBack;

  const MaintenanceFallback({
    super.key,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return FallbackUI(
      title: 'Under Maintenance',
      message: 'We\'re currently performing maintenance to improve your experience. Please try again later.',
      icon: Icons.build,
      iconColor: Colors.orange[400],
      onGoBack: onGoBack,
      goBackText: 'Go Back',
    );
  }
} 