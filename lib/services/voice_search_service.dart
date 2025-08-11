import 'dart:async';
import 'package:flutter/material.dart';

class VoiceSearchService {
  static final VoiceSearchService _instance = VoiceSearchService._internal();
  factory VoiceSearchService() => _instance;
  VoiceSearchService._internal();

  final StreamController<String> _searchResultsController = StreamController<String>.broadcast();
  final StreamController<bool> _isListeningController = StreamController<bool>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();
  final StreamController<double> _confidenceController = StreamController<double>.broadcast();

  Stream<String> get searchResults => _searchResultsController.stream;
  Stream<bool> get isListening => _isListeningController.stream;
  Stream<String> get errors => _errorController.stream;
  Stream<double> get confidence => _confidenceController.stream;

  bool _isInitialized = false;
  bool _isListening = false;
  Timer? _listeningTimer;
  Timer? _confidenceTimer;

  // Voice commands and their processing
  final Map<String, List<String>> _voiceCommands = {
    'search': ['search for', 'find', 'look for', 'show me'],
    'car_types': ['luxury cars', 'electric vehicles', 'suv', 'sedan', 'sports car'],
    'brands': ['bmw', 'tesla', 'audi', 'mercedes', 'range rover'],
    'locations': ['london', 'manchester', 'birmingham', 'edinburgh'],
    'filters': ['under', 'over', 'between', 'price', 'rating'],
  };

  Future<void> initialize() async {
    try {
      // Check for speech recognition permissions
      await _checkPermissions();
      
      // Initialize speech recognition (mock for now)
      await Future.delayed(const Duration(milliseconds: 500));
      _isInitialized = true;
      debugPrint('VoiceSearchService: Initialization completed');
    } catch (e) {
      _errorController.add('Failed to initialize voice search: $e');
      debugPrint('VoiceSearchService: Initialization failed - $e');
    }
  }

  Future<void> _checkPermissions() async {
    // In real implementation, check for microphone permissions
    // For now, simulate permission check
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<bool> startListening() async {
    if (!_isInitialized) {
      _errorController.add('Voice search not initialized');
      return false;
    }

    try {
      _isListening = true;
      _isListeningController.add(true);
      
      // Start confidence monitoring
      _startConfidenceMonitoring();
      
      // Set up listening timeout
      _listeningTimer = Timer(const Duration(seconds: 10), () {
        if (_isListening) {
          stopListening();
          _errorController.add('Listening timeout - please try again');
        }
      });
      
      debugPrint('VoiceSearchService: Listening started');
      
      // Simulate voice input after a delay
      Timer(const Duration(seconds: 2), () {
        _processMockVoiceInput();
      });
      
      return true;
    } catch (e) {
      _isListening = false;
      _isListeningController.add(false);
      _errorController.add('Failed to start listening: $e');
      debugPrint('VoiceSearchService: Start listening failed - $e');
      return false;
    }
  }

  Future<void> stopListening() async {
    try {
      _isListening = false;
      _isListeningController.add(false);
      
      _listeningTimer?.cancel();
      _confidenceTimer?.cancel();
      
      debugPrint('VoiceSearchService: Listening stopped');
    } catch (e) {
      _errorController.add('Failed to stop listening: $e');
      debugPrint('VoiceSearchService: Stop listening failed - $e');
    }
  }

  void _startConfidenceMonitoring() {
    _confidenceTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isListening) {
        // Simulate confidence level (0.0 to 1.0)
        final confidence = 0.7 + (DateTime.now().millisecond % 300) / 1000;
        _confidenceController.add(confidence);
      } else {
        timer.cancel();
      }
    });
  }

  void _processMockVoiceInput() {
    // Enhanced mock voice processing with realistic commands
    const mockCommands = [
      'search for luxury cars in London',
      'find electric vehicles under 100 pounds',
      'show me BMW models with high rating',
      'filter by SUV category',
      'search for cars with GPS navigation',
      'find available cars in Manchester',
      'show me sports cars with automatic transmission',
      'search for family cars with 5 seats',
    ];
    
    final randomCommand = mockCommands[DateTime.now().millisecond % mockCommands.length];
    
    // Simulate processing delay
    Timer(const Duration(milliseconds: 500), () {
      _searchResultsController.add(randomCommand);
    stopListening();
    });
  }

  // Enhanced voice command processing
  Future<Map<String, dynamic>> processVoiceCommand(String command) async {
    try {
      debugPrint('VoiceSearchService: Processing command - $command');
      
      // Simulate processing delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Parse the command
      final parsedCommand = _parseVoiceCommand(command);
      
      // Return structured data
      return {
        'originalCommand': command,
        'parsedCommand': parsedCommand,
        'confidence': 0.85,
        'timestamp': DateTime.now(),
      };
    } catch (e) {
      _errorController.add('Failed to process command: $e');
      debugPrint('VoiceSearchService: Command processing failed - $e');
      return {
        'originalCommand': command,
        'error': e.toString(),
        'confidence': 0.0,
        'timestamp': DateTime.now(),
      };
    }
  }

  Map<String, dynamic> _parseVoiceCommand(String command) {
    final commandLower = command.toLowerCase();
    final result = <String, dynamic>{
      'action': 'search',
      'query': command,
      'filters': <String, dynamic>{},
    };

    // Extract search action
    for (final action in _voiceCommands['search']!) {
      if (commandLower.contains(action)) {
        result['action'] = 'search';
        break;
      }
    }

    // Extract car types
    for (final carType in _voiceCommands['car_types']!) {
      if (commandLower.contains(carType)) {
        result['filters']['category'] = carType;
        break;
      }
    }

    // Extract brands
    for (final brand in _voiceCommands['brands']!) {
      if (commandLower.contains(brand)) {
        result['filters']['brand'] = brand;
        break;
      }
    }

    // Extract locations
    for (final location in _voiceCommands['locations']!) {
      if (commandLower.contains(location)) {
        result['filters']['location'] = location;
        break;
      }
    }

    // Extract price filters
    if (commandLower.contains('under')) {
      final priceMatch = RegExp(r'under (\d+)').firstMatch(commandLower);
      if (priceMatch != null) {
        result['filters']['maxPrice'] = double.parse(priceMatch.group(1)!);
      }
    }

    // Extract rating filters
    if (commandLower.contains('high rating') || commandLower.contains('good rating')) {
      result['filters']['minRating'] = 4.5;
    }

    return result;
  }

  List<String> getVoiceCommands() {
    return [
      'Search for [car type]',
      'Find [brand] cars',
      'Filter by price under [amount]',
      'Search in [location]',
      'Show [category] vehicles',
      'Find cars with [feature]',
      'Show me [brand] models',
      'Search for available cars',
    ];
  }

  List<String> getSearchSuggestions(String query) {
    // Enhanced search suggestions based on query
    final suggestions = <String>[];
    
    if (query.toLowerCase().contains('luxury')) {
      suggestions.addAll(['BMW X6', 'Mercedes S-Class', 'Audi A8', 'Tesla Model S']);
    } else if (query.toLowerCase().contains('electric')) {
      suggestions.addAll(['Tesla Model 3', 'Tesla Model S', 'BMW i3', 'Nissan Leaf']);
    } else if (query.toLowerCase().contains('bmw')) {
      suggestions.addAll(['BMW X6', 'BMW X5', 'BMW 3 Series', 'BMW i3']);
    } else if (query.toLowerCase().contains('price')) {
      suggestions.addAll(['Under £50/day', 'Under £100/day', 'Under £150/day', 'Premium cars']);
    } else if (query.toLowerCase().contains('london')) {
      suggestions.addAll(['Cars in London', 'London luxury cars', 'London electric cars']);
    } else {
      suggestions.addAll(['Luxury cars', 'Electric vehicles', 'Sports cars', 'Family cars']);
    }
    
    return suggestions;
  }

  // Get voice search tips
  List<String> getVoiceSearchTips() {
    return [
      'Speak clearly and at a normal pace',
      'Use specific car types like "luxury cars" or "electric vehicles"',
      'Mention location like "cars in London"',
      'Add price filters like "under 100 pounds"',
      'Include features like "with GPS" or "automatic transmission"',
    ];
  }

  bool get isInitialized => _isInitialized;
  bool get isCurrentlyListening => _isListening;

  void dispose() {
    _searchResultsController.close();
    _isListeningController.close();
    _errorController.close();
    _confidenceController.close();
    _listeningTimer?.cancel();
    _confidenceTimer?.cancel();
  }
} 