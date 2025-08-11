import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart';
import '../services/settings_service.dart';

class PriceFormatter {
  /// Formats a price string by adding spaces between every 3 digits
  /// Example: "1500" becomes "1 500", "150000" becomes "150 000"
  static String formatPrice(String price) {
    // Remove any existing spaces and non-digit characters except decimal point
    String cleanPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
    
    // Split by decimal point if exists
    List<String> parts = cleanPrice.split('.');
    String wholePart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';
    
    // Add spaces every 3 digits from right to left
    String formattedWhole = '';
    for (int i = 0; i < wholePart.length; i++) {
      if (i > 0 && (wholePart.length - i) % 3 == 0) {
        formattedWhole += ' ';
      }
      formattedWhole += wholePart[i];
    }
    
    // Combine with decimal part if exists
    if (decimalPart.isNotEmpty) {
      return '$formattedWhole.$decimalPart';
    }
    
    return formattedWhole;
  }
  
  /// Formats a price with currency symbol from SettingsService
  /// Keeps spacing rule for thousands
  static String formatWithSettings(BuildContext context, String price) {
    final settings = Provider.of<SettingsService>(context, listen: false);
    final symbol = settings.currentCurrency.symbol;
    final formatted = formatPrice(price);
    // Position symbol according to common usage (prefix for $, €, suffix for DZD symbol)
    switch (settings.currentCurrency) {
      case AppCurrency.dzd:
        return '$formatted ${symbol}';
      case AppCurrency.eur:
      case AppCurrency.usd:
        return '$symbol$formatted';
    }
  }
  
  /// Formats a price for display with currency from settings and "/day" suffix when needed
  static String formatPerDayWithSettings(BuildContext context, String price) {
    final base = formatWithSettings(context, price);
    return '$base/day';
  }

  /// Legacy helpers kept for backward compatibility (defaults to £ if used directly)
  static String formatPriceWithCurrency(String price, {String currency = '£'}) {
    String formattedPrice = formatPrice(price);
    return '$currency$formattedPrice';
  }
  
  static String formatPricePerDay(String price, {String currency = '£'}) {
    String formattedPrice = formatPrice(price);
    return '$currency$formattedPrice/day';
  }
}
