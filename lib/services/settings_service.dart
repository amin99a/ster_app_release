import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  english('en', 'English', '🇺🇸'),
  french('fr', 'Français', '🇫🇷'),
  arabic('ar', 'العربية', '🇩🇿');

  const AppLanguage(this.code, this.name, this.flag);
  
  final String code;
  final String name;
  final String flag;
}

enum AppCurrency {
  dzd('DZD', 'Algerian Dinar', 'DA'),
  eur('EUR', 'Euro', '€'),
  usd('USD', 'US Dollar', '\$');

  const AppCurrency(this.code, this.name, this.symbol);
  
  final String code;
  final String name;
  final String symbol;
}

class SettingsService extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  static const String _currencyKey = 'app_currency';
  static const String _themeKey = 'app_theme';
  static const String _notificationsKey = 'app_notifications';
  static const String _locationKey = 'app_location';
  static const String _analyticsKey = 'app_analytics';

  // Current settings
  AppLanguage _currentLanguage = AppLanguage.english;
  AppCurrency _currentCurrency = AppCurrency.dzd;
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _analyticsEnabled = true;

  // Getters
  AppLanguage get currentLanguage => _currentLanguage;
  AppCurrency get currentCurrency => _currentCurrency;
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get locationEnabled => _locationEnabled;
  bool get analyticsEnabled => _analyticsEnabled;

  // Singleton pattern
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  /// Initialize settings from SharedPreferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load language
      final languageCode = prefs.getString(_languageKey);
      if (languageCode != null) {
        _currentLanguage = AppLanguage.values.firstWhere(
          (lang) => lang.code == languageCode,
          orElse: () => AppLanguage.english,
        );
      }
      
      // Load currency
      final currencyCode = prefs.getString(_currencyKey);
      if (currencyCode != null) {
        _currentCurrency = AppCurrency.values.firstWhere(
          (currency) => currency.code == currencyCode,
          orElse: () => AppCurrency.dzd,
        );
      }
      
      // Load other settings
      _isDarkMode = prefs.getBool(_themeKey) ?? false;
      _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
      _locationEnabled = prefs.getBool(_locationKey) ?? true;
      _analyticsEnabled = prefs.getBool(_analyticsKey) ?? true;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing settings: $e');
    }
  }

  /// Set app language
  Future<void> setLanguage(AppLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language.code);
      
      _currentLanguage = language;
      notifyListeners();
      
      debugPrint('Language set to: ${language.name}');
    } catch (e) {
      debugPrint('Error setting language: $e');
    }
  }

  /// Set app currency
  Future<void> setCurrency(AppCurrency currency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currencyKey, currency.code);
      
      _currentCurrency = currency;
      notifyListeners();
      
      debugPrint('Currency set to: ${currency.name}');
    } catch (e) {
      debugPrint('Error setting currency: $e');
    }
  }

  /// Set dark mode
  Future<void> setDarkMode(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, enabled);
      
      _isDarkMode = enabled;
      notifyListeners();
      
      debugPrint('Dark mode set to: $enabled');
    } catch (e) {
      debugPrint('Error setting dark mode: $e');
    }
  }

  /// Set notifications enabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsKey, enabled);
      
      _notificationsEnabled = enabled;
      notifyListeners();
      
      debugPrint('Notifications set to: $enabled');
    } catch (e) {
      debugPrint('Error setting notifications: $e');
    }
  }

  /// Set location enabled
  Future<void> setLocationEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_locationKey, enabled);
      
      _locationEnabled = enabled;
      notifyListeners();
      
      debugPrint('Location set to: $enabled');
    } catch (e) {
      debugPrint('Error setting location: $e');
    }
  }

  /// Set analytics enabled
  Future<void> setAnalyticsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_analyticsKey, enabled);
      
      _analyticsEnabled = enabled;
      notifyListeners();
      
      debugPrint('Analytics set to: $enabled');
    } catch (e) {
      debugPrint('Error setting analytics: $e');
    }
  }

  /// Format price with current currency
  String formatPrice(double amount) {
    switch (_currentCurrency) {
      case AppCurrency.dzd:
        return '${amount.toStringAsFixed(0)} ${_currentCurrency.symbol}';
      case AppCurrency.eur:
      case AppCurrency.usd:
        return '${_currentCurrency.symbol}${amount.toStringAsFixed(2)}';
    }
  }

  /// Convert price between currencies (simplified conversion)
  double convertPrice(double amount, AppCurrency from, AppCurrency to) {
    if (from == to) return amount;
    
    // Simplified conversion rates (in a real app, use real-time rates)
    const rates = {
      'DZD_EUR': 0.0075,
      'DZD_USD': 0.0075,
      'EUR_DZD': 133.33,
      'EUR_USD': 1.1,
      'USD_DZD': 133.33,
      'USD_EUR': 0.91,
    };
    
    final key = '${from.code}_${to.code}';
    final rate = rates[key] ?? 1.0;
    
    return amount * rate;
  }

  /// Get localized text (simplified localization)
  String getLocalizedText(String key) {
    final texts = {
      'en': {
        'app_name': 'STER',
        'settings': 'Settings',
        'language': 'Language',
        'currency': 'Currency',
        'notifications': 'Notifications',
        'location': 'Location Services',
        'analytics': 'Analytics & Data',
        'theme': 'Theme',
        'dark_mode': 'Dark Mode',
        'privacy': 'Privacy',
        'about': 'About',
        'version': 'Version',
        'save': 'Save',
        'cancel': 'Cancel',
        'ok': 'OK',
        'car_rental': 'Car Rental',
        'book_now': 'Book Now',
        'search': 'Search',
        'favorites': 'Favorites',
        'profile': 'Profile',
        'home': 'Home',
      },
      'fr': {
        'app_name': 'STER',
        'settings': 'Paramètres',
        'language': 'Langue',
        'currency': 'Devise',
        'notifications': 'Notifications',
        'location': 'Services de localisation',
        'analytics': 'Analyses et données',
        'theme': 'Thème',
        'dark_mode': 'Mode sombre',
        'privacy': 'Confidentialité',
        'about': 'À propos',
        'version': 'Version',
        'save': 'Enregistrer',
        'cancel': 'Annuler',
        'ok': 'OK',
        'car_rental': 'Location de voiture',
        'book_now': 'Réserver maintenant',
        'search': 'Recherche',
        'favorites': 'Favoris',
        'profile': 'Profil',
        'home': 'Accueil',
      },
      'ar': {
        'app_name': 'ستار',
        'settings': 'الإعدادات',
        'language': 'اللغة',
        'currency': 'العملة',
        'notifications': 'الإشعارات',
        'location': 'خدمات الموقع',
        'analytics': 'التحليلات والبيانات',
        'theme': 'المظهر',
        'dark_mode': 'الوضع الليلي',
        'privacy': 'الخصوصية',
        'about': 'حول',
        'version': 'الإصدار',
        'save': 'حفظ',
        'cancel': 'إلغاء',
        'ok': 'موافق',
        'car_rental': 'تأجير السيارات',
        'book_now': 'احجز الآن',
        'search': 'بحث',
        'favorites': 'المفضلة',
        'profile': 'الملف الشخصي',
        'home': 'الرئيسية',
      },
    };
    
    return texts[_currentLanguage.code]?[key] ?? key;
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      _currentLanguage = AppLanguage.english;
      _currentCurrency = AppCurrency.dzd;
      _isDarkMode = false;
      _notificationsEnabled = true;
      _locationEnabled = true;
      _analyticsEnabled = true;
      
      notifyListeners();
      
      debugPrint('Settings reset to defaults');
    } catch (e) {
      debugPrint('Error resetting settings: $e');
    }
  }

  /// Get app info
  Map<String, String> getAppInfo() {
    return {
      'version': '1.0.0',
      'build': '1',
      'developer': 'STER Team',
      'website': 'https://ster.app',
      'support': 'support@ster.app',
    };
  }
}