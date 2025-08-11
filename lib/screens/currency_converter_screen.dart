import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/currency_service.dart';
import '../services/settings_service.dart';
import '../widgets/localized_text.dart';
import '../widgets/floating_header.dart';
import '../widgets/floating_3d_card.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen>
    with TickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Real currency service integration
  late CurrencyService _currencyService;
  
  // Currency selection
  String _fromCurrency = 'DZD';
  String _toCurrency = 'EUR';
  double _convertedAmount = 0.0;
  bool _isLoading = false;
  String? _error;

  // Real-time exchange rates
  Map<String, double> _exchangeRates = {};
  bool _ratesLoaded = false;

  @override
  void initState() {
    super.initState();
    _currencyService = CurrencyService();
    _initializeAnimations();
    _initializeCurrencyService();
    
    _amountController.addListener(_performConversion);
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));

    _animationController.forward();
  }

  Future<void> _initializeCurrencyService() async {
    try {
      await _currencyService.initialize();
      await _loadExchangeRates();
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize currency service: $e';
      });
    }
  }

  Future<void> _loadExchangeRates() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final rates = await _currencyService.getExchangeRates(_fromCurrency);
      
      setState(() {
        _exchangeRates = rates;
        _ratesLoaded = true;
        _isLoading = false;
      });

      _performConversion();
    } catch (e) {
      setState(() {
        _error = 'Failed to load exchange rates: $e';
        _isLoading = false;
      });
    }
  }

  void _performConversion() {
    if (!_ratesLoaded) return;
    
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    
    if (amount > 0) {
      final converted = _currencyService.convertAmount(amount, _fromCurrency, _toCurrency);
    setState(() {
        _convertedAmount = converted;
    });
    } else {
        setState(() {
        _convertedAmount = 0.0;
        });
      }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    
    _loadExchangeRates();
  }

  void _refreshRates() {
    _currencyService.clearCache();
    _loadExchangeRates();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          FloatingHeader(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LocalizedText(
                    'currency_converter',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _refreshRates,
                  icon: Icon(
                    _isLoading ? Icons.hourglass_empty : Icons.refresh,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return _buildErrorState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Currency conversion card
          _buildConversionCard(),
          
          const SizedBox(height: 24),
          
          // Exchange rates card
          if (_ratesLoaded) _buildExchangeRatesCard(),
          
          const SizedBox(height: 24),
          
          // Cache status card
          _buildCacheStatusCard(),
        ],
      ),
    );
  }

  Widget _buildConversionCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
              'Currency Converter',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF353935),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Amount input
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Currency selection
            Row(
              children: [
                Expanded(
                  child: _buildCurrencyDropdown(
                    value: _fromCurrency,
                    onChanged: (value) {
                      setState(() {
                        _fromCurrency = value!;
                      });
                      _loadExchangeRates();
                    },
                    label: 'From',
                  ),
                ),
                
                const SizedBox(width: 16),
                
                IconButton(
                  onPressed: _swapCurrencies,
                  icon: const Icon(Icons.swap_horiz),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF353935),
                    foregroundColor: Colors.white,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: _buildCurrencyDropdown(
                    value: _toCurrency,
                    onChanged: (value) {
                      setState(() {
                        _toCurrency = value!;
                      });
                      _performConversion();
                    },
                    label: 'To',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Conversion result
                Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                color: const Color(0xFF353935),
                    borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Converted Amount',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                      Text(
                    '${_convertedAmount.toStringAsFixed(2)} $_toCurrency',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                        ),
                      ),
                    ],
                  ),
            ),
          ],
        ),
        ),
    );
  }

  Widget _buildCurrencyDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
    required String label,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: _currencyService.supportedCurrencies.map((currency) {
        return DropdownMenuItem(
          value: currency,
          child: Text(currency),
        );
      }).toList(),
    );
  }

  Widget _buildExchangeRatesCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
              'Exchange Rates (1 $_fromCurrency)',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF353935),
              ),
            ),
            
            const SizedBox(height: 16),
            
            ..._exchangeRates.entries.take(5).map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      entry.value.toStringAsFixed(4),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF353935),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            
            if (_exchangeRates.length > 5) ...[
              const SizedBox(height: 8),
              Text(
                '... and ${_exchangeRates.length - 5} more currencies',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
        ),
    );
  }

  Widget _buildCacheStatusCard() {
    final cacheStatus = _currencyService.getCacheStatus();
    final fromCurrencyStatus = cacheStatus[_fromCurrency];
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cache Status',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF353935),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Icon(
                  fromCurrencyStatus?['valid'] == true 
                      ? Icons.check_circle 
                      : Icons.warning,
                  color: fromCurrencyStatus?['valid'] == true 
                      ? Colors.green 
                      : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$_fromCurrency rates: ${fromCurrencyStatus?['valid'] == true ? 'Fresh' : 'Stale'}',
                    style: GoogleFonts.inter(fontSize: 16),
                  ),
                ),
              ],
            ),
            
            if (fromCurrencyStatus?['timestamp'] != null) ...[
                    const SizedBox(height: 8),
              Text(
                'Last updated: ${DateTime.parse(fromCurrencyStatus!['timestamp']).toLocal().toString().substring(0, 19)}',
                style: GoogleFonts.inter(
                        fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Currency Service Error',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF353935),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error occurred',
              style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshRates,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}