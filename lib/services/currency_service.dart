import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService extends ChangeNotifier {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // Cache for exchange rates
  final Map<String, Map<String, double>> _exchangeRatesCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  // Cache duration (15 minutes)
  static const Duration _cacheDuration = Duration(minutes: 15);
  
  // API configuration
  static const String _apiUrl = 'https://api.exchangerate-api.com/v4/latest/';
  static const String _fallbackApiUrl = 'https://api.frankfurter.app/latest';
  
  // Supported currencies
  static const List<String> _supportedCurrencies = [
    'DZD', 'EUR', 'USD', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY', 'SEK'
  ];

  // Get exchange rates for a base currency
  Future<Map<String, double>> getExchangeRates(String baseCurrency) async {
    try {
      // Check cache first
      if (_isCacheValid(baseCurrency)) {
        debugPrint('📊 Using cached exchange rates for $baseCurrency');
        return _exchangeRatesCache[baseCurrency]!;
      }

      // Fetch from API
      debugPrint('🌐 Fetching exchange rates for $baseCurrency');
      final rates = await _fetchFromAPI(baseCurrency);
      
      // Cache the results
      _cacheExchangeRates(baseCurrency, rates);
      
      // Store in Supabase for backup
      await _storeRatesInSupabase(baseCurrency, rates);
      
      return rates;
    } catch (e) {
      debugPrint('❌ Error fetching exchange rates: $e');
      
      // Try to get from Supabase cache
      final cachedRates = await _getRatesFromSupabase(baseCurrency);
      if (cachedRates.isNotEmpty) {
        debugPrint('📊 Using Supabase cached rates for $baseCurrency');
        return cachedRates;
      }
      
      // Return fallback rates
      return _getFallbackRates(baseCurrency);
    }
  }

  // Fetch rates from external API
  Future<Map<String, double>> _fetchFromAPI(String baseCurrency) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl$baseCurrency'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = Map<String, double>.from(data['rates']);
        
        // Filter to supported currencies
        final filteredRates = <String, double>{};
        for (final currency in _supportedCurrencies) {
          if (rates.containsKey(currency)) {
            filteredRates[currency] = rates[currency]!;
          }
        }
        
        return filteredRates;
      } else {
        throw Exception('API returned status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Primary API failed, trying fallback: $e');
      return await _fetchFromFallbackAPI(baseCurrency);
    }
  }

  // Fetch from fallback API
  Future<Map<String, double>> _fetchFromFallbackAPI(String baseCurrency) async {
    try {
      final response = await http.get(
        Uri.parse('$_fallbackApiUrl?from=$baseCurrency'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Map<String, double>.from(data['rates']);
      } else {
        throw Exception('Fallback API returned status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Fallback API also failed: $e');
      rethrow;
    }
  }

  // Check if cache is valid
  bool _isCacheValid(String baseCurrency) {
    if (!_exchangeRatesCache.containsKey(baseCurrency)) return false;
    
    final timestamp = _cacheTimestamps[baseCurrency];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheDuration;
  }

  // Cache exchange rates
  void _cacheExchangeRates(String baseCurrency, Map<String, double> rates) {
    _exchangeRatesCache[baseCurrency] = rates;
    _cacheTimestamps[baseCurrency] = DateTime.now();
    notifyListeners();
  }

  // Store rates in Supabase
  Future<void> _storeRatesInSupabase(String baseCurrency, Map<String, double> rates) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      
      // Clear old rates for this base currency
      await client
          .from('currency_rates')
          .delete()
          .eq('base_currency', baseCurrency);
      
      // Insert new rates
      final rateData = rates.entries.map((entry) => {
        'base_currency': baseCurrency,
        'target_currency': entry.key,
        'rate': entry.value,
        'updated_at': timestamp,
      }).toList();
      
      await client
          .from('currency_rates')
          .insert(rateData);
      
      debugPrint('💾 Stored exchange rates in Supabase for $baseCurrency');
    } catch (e) {
      debugPrint('❌ Failed to store rates in Supabase: $e');
    }
  }

  // Get rates from Supabase
  Future<Map<String, double>> _getRatesFromSupabase(String baseCurrency) async {
    try {
      final response = await client
          .from('currency_rates')
          .select('target_currency, rate')
          .eq('base_currency', baseCurrency)
          .order('updated_at', ascending: false);

      final rates = <String, double>{};
      for (final row in response) {
        rates[row['target_currency']] = (row['rate'] as num).toDouble();
      }
      
      return rates;
    } catch (e) {
      debugPrint('❌ Failed to get rates from Supabase: $e');
      return {};
    }
  }

  // Get fallback rates (1:1 for same currency, estimates for others)
  Map<String, double> _getFallbackRates(String baseCurrency) {
    final fallbackRates = <String, double>{};
    
    for (final currency in _supportedCurrencies) {
      if (currency == baseCurrency) {
        fallbackRates[currency] = 1.0;
      } else {
        // Provide reasonable fallback rates
        switch (baseCurrency) {
          case 'DZD':
            switch (currency) {
              case 'EUR':
                fallbackRates[currency] = 0.007;
                break;
              case 'USD':
                fallbackRates[currency] = 0.0074;
                break;
              default:
                fallbackRates[currency] = 0.01; // Generic fallback
            }
            break;
          case 'EUR':
            switch (currency) {
              case 'DZD':
                fallbackRates[currency] = 142.0;
                break;
              case 'USD':
                fallbackRates[currency] = 1.08;
                break;
              default:
                fallbackRates[currency] = 1.0; // Generic fallback
            }
            break;
          case 'USD':
            switch (currency) {
              case 'DZD':
                fallbackRates[currency] = 135.0;
                break;
              case 'EUR':
                fallbackRates[currency] = 0.92;
                break;
              default:
                fallbackRates[currency] = 1.0; // Generic fallback
            }
            break;
          default:
            fallbackRates[currency] = 1.0; // Generic fallback
        }
      }
    }
    
    return fallbackRates;
  }

  // Convert amount between currencies
  double convertAmount(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) return amount;
    
    // Get rates for from currency
    final rates = _exchangeRatesCache[fromCurrency];
    if (rates == null || !rates.containsKey(toCurrency)) {
      debugPrint('⚠️ No exchange rate available for $fromCurrency to $toCurrency');
      return amount; // Return original amount if conversion not possible
    }
    
    return amount * rates[toCurrency]!;
  }

  // Get supported currencies
  List<String> get supportedCurrencies => List.unmodifiable(_supportedCurrencies);

  // Clear cache
  void clearCache() {
    _exchangeRatesCache.clear();
    _cacheTimestamps.clear();
    notifyListeners();
    debugPrint('🗑️ Currency cache cleared');
  }

  // Get cache status
  Map<String, dynamic> getCacheStatus() {
    final status = <String, dynamic>{};
    
    for (final currency in _supportedCurrencies) {
      if (_exchangeRatesCache.containsKey(currency)) {
        final timestamp = _cacheTimestamps[currency];
        final isValid = timestamp != null && 
            DateTime.now().difference(timestamp) < _cacheDuration;
        
        status[currency] = {
          'cached': true,
          'valid': isValid,
          'timestamp': timestamp?.toIso8601String(),
          'rates_count': _exchangeRatesCache[currency]?.length ?? 0,
        };
      } else {
        status[currency] = {
          'cached': false,
          'valid': false,
          'timestamp': null,
          'rates_count': 0,
        };
      }
    }
    
    return status;
  }

  // Initialize the service
  Future<void> initialize() async {
    debugPrint('🚀 Initializing CurrencyService...');
    
    // Pre-load rates for common currencies
    await Future.wait([
      getExchangeRates('DZD'),
      getExchangeRates('EUR'),
      getExchangeRates('USD'),
    ]);
    
    debugPrint('✅ CurrencyService initialized');
  }
} 