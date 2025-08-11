import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PerformanceService extends ChangeNotifier {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  // Performance metrics
  final Map<String, PerformanceMetric> _metrics = {};
  final List<PerformanceEvent> _events = [];
  final Map<String, dynamic> _cache = {};
  
  // Memory management
  final Map<String, Timer> _cacheTimers = {};
  final Map<String, int> _cacheHitCounts = {};
  
  // Image optimization
  final Map<String, ImageCacheEntry> _imageCache = {};
  
  // Performance monitoring
  Timer? _performanceTimer;
  bool _isMonitoring = false;
  
  // Configuration
  PerformanceConfig _config = const PerformanceConfig();
  
  // Getters
  Map<String, PerformanceMetric> get metrics => Map.unmodifiable(_metrics);
  List<PerformanceEvent> get events => List.unmodifiable(_events);
  PerformanceConfig get config => _config;
  bool get isMonitoring => _isMonitoring;
  
  // Cache statistics
  int get cacheSize => _cache.length;
  int get totalCacheHits => _cacheHitCounts.values.fold(0, (sum, hits) => sum + hits);
  double get cacheHitRate {
    final totalRequests = _cacheHitCounts.values.fold(0, (sum, hits) => sum + hits);
    final totalHits = totalCacheHits;
    return totalRequests > 0 ? totalHits / totalRequests : 0.0;
  }

  // Initialize performance monitoring
  Future<void> initialize({PerformanceConfig? config}) async {
    if (config != null) {
      _config = config;
    }
    
    await _setupPerformanceMonitoring();
    await _initializeImageCache();
    
    debugPrint('PerformanceService initialized');
  }

  Future<void> _setupPerformanceMonitoring() async {
    if (_config.enablePerformanceMonitoring) {
      startMonitoring();
    }
    
    // Setup memory management
    _setupMemoryManagement();
    
    // Setup cache cleanup
    _setupCacheCleanup();
  }

  Future<void> _initializeImageCache() async {
    // Pre-warm critical images if specified
    for (final imageUrl in _config.preloadImages) {
      await preloadImage(imageUrl);
    }
  }

  void _setupMemoryManagement() {
    // Periodic memory cleanup
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _performMemoryCleanup();
    });
  }

  void _setupCacheCleanup() {
    // Periodic cache cleanup
    Timer.periodic(const Duration(minutes: 10), (timer) {
      _performCacheCleanup();
    });
  }

  // Performance monitoring
  void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _performanceTimer = Timer.periodic(
      Duration(seconds: _config.monitoringInterval),
      (timer) => _collectPerformanceMetrics(),
    );
    
    debugPrint('Performance monitoring started');
  }

  void stopMonitoring() {
    if (!_isMonitoring) return;
    
    _isMonitoring = false;
    _performanceTimer?.cancel();
    _performanceTimer = null;
    
    debugPrint('Performance monitoring stopped');
  }

  void _collectPerformanceMetrics() {
    final now = DateTime.now();
    
    // Collect memory metrics
    _collectMemoryMetrics(now);
    
    // Collect cache metrics
    _collectCacheMetrics(now);
    
    // Collect frame metrics (if available)
    _collectFrameMetrics(now);
    
    // Collect network metrics
    _collectNetworkMetrics(now);
    
    // Trigger cleanup if needed
    if (_shouldPerformCleanup()) {
      _performMemoryCleanup();
    }
    
    notifyListeners();
  }

  void _collectMemoryMetrics(DateTime timestamp) {
    // Simulate memory usage collection
    final memoryUsage = _getMemoryUsage();
    
    _metrics['memory_usage'] = PerformanceMetric(
      name: 'Memory Usage',
      value: memoryUsage,
      unit: 'MB',
      timestamp: timestamp,
      threshold: _config.memoryThreshold,
    );
  }

  void _collectCacheMetrics(DateTime timestamp) {
    _metrics['cache_size'] = PerformanceMetric(
      name: 'Cache Size',
      value: cacheSize.toDouble(),
      unit: 'entries',
      timestamp: timestamp,
      threshold: _config.maxCacheSize.toDouble(),
    );
    
    _metrics['cache_hit_rate'] = PerformanceMetric(
      name: 'Cache Hit Rate',
      value: cacheHitRate * 100,
      unit: '%',
      timestamp: timestamp,
      threshold: 80.0, // 80% hit rate threshold
    );
  }

  void _collectFrameMetrics(DateTime timestamp) {
    // Simulate frame rate collection
    final fps = _getCurrentFPS();
    
    _metrics['fps'] = PerformanceMetric(
      name: 'Frame Rate',
      value: fps,
      unit: 'fps',
      timestamp: timestamp,
      threshold: 55.0, // Target 55+ FPS
    );
  }

  void _collectNetworkMetrics(DateTime timestamp) {
    // Simulate network metrics
    final networkLatency = _getNetworkLatency();
    
    _metrics['network_latency'] = PerformanceMetric(
      name: 'Network Latency',
      value: networkLatency,
      unit: 'ms',
      timestamp: timestamp,
      threshold: 500.0, // 500ms threshold
    );
  }

  // Mock methods for metrics collection
  double _getMemoryUsage() {
    // In a real app, use ProcessInfo or similar
    return 50.0 + Random().nextDouble() * 100.0; // 50-150 MB
  }

  double _getCurrentFPS() {
    // In a real app, use SchedulerBinding.instance.framesPerSecond
    return 55.0 + Random().nextDouble() * 5.0; // 55-60 FPS
  }

  double _getNetworkLatency() {
    // In a real app, measure actual network requests
    return 100.0 + Random().nextDouble() * 400.0; // 100-500ms
  }

  bool _shouldPerformCleanup() {
    final memoryMetric = _metrics['memory_usage'];
    return memoryMetric != null && memoryMetric.value > memoryMetric.threshold;
  }

  // Caching system
  T? getFromCache<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    final cacheEntry = entry as CacheEntry<T>;
    
    // Check if expired
    if (cacheEntry.isExpired) {
      removeFromCache(key);
      return null;
    }
    
    // Update hit count
    _cacheHitCounts[key] = (_cacheHitCounts[key] ?? 0) + 1;
    
    // Update access time
    cacheEntry.lastAccessed = DateTime.now();
    
    return cacheEntry.data;
  }

  void putInCache<T>(String key, T data, {Duration? ttl}) {
    final expiry = ttl != null 
        ? DateTime.now().add(ttl)
        : DateTime.now().add(_config.defaultCacheTTL);
    
    _cache[key] = CacheEntry<T>(
      data: data,
      expiry: expiry,
      lastAccessed: DateTime.now(),
    );
    
    // Set cleanup timer
    if (ttl != null) {
      _cacheTimers[key]?.cancel();
      _cacheTimers[key] = Timer(ttl, () => removeFromCache(key));
    }
    
    // Check cache size limits
    if (_cache.length > _config.maxCacheSize) {
      _performCacheCleanup();
    }
    
    _recordEvent(PerformanceEvent(
      type: PerformanceEventType.cacheWrite,
      description: 'Cached item: $key',
      timestamp: DateTime.now(),
    ));
  }

  void removeFromCache(String key) {
    _cache.remove(key);
    _cacheHitCounts.remove(key);
    _cacheTimers[key]?.cancel();
    _cacheTimers.remove(key);
  }

  void clearCache() {
    _cache.clear();
    _cacheHitCounts.clear();
    for (final timer in _cacheTimers.values) {
      timer.cancel();
    }
    _cacheTimers.clear();
    
    _recordEvent(PerformanceEvent(
      type: PerformanceEventType.cacheCleared,
      description: 'Cache cleared manually',
      timestamp: DateTime.now(),
    ));
    
    notifyListeners();
  }

  void _performCacheCleanup() {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    // Remove expired entries
    for (final entry in _cache.entries) {
      final cacheEntry = entry.value as CacheEntry;
      if (cacheEntry.isExpired) {
        keysToRemove.add(entry.key);
      }
    }
    
    // Remove least recently used entries if over limit
    if (_cache.length > _config.maxCacheSize) {
      final sortedEntries = _cache.entries.toList()
        ..sort((a, b) {
          final aEntry = a.value as CacheEntry;
          final bEntry = b.value as CacheEntry;
          return aEntry.lastAccessed.compareTo(bEntry.lastAccessed);
        });
      
      final excessCount = _cache.length - _config.maxCacheSize;
      for (int i = 0; i < excessCount && i < sortedEntries.length; i++) {
        keysToRemove.add(sortedEntries[i].key);
      }
    }
    
    // Remove identified keys
    for (final key in keysToRemove) {
      removeFromCache(key);
    }
    
    if (keysToRemove.isNotEmpty) {
      _recordEvent(PerformanceEvent(
        type: PerformanceEventType.cacheCleanup,
        description: 'Cleaned up ${keysToRemove.length} cache entries',
        timestamp: now,
      ));
    }
  }

  // Image optimization
  Future<void> preloadImage(String imageUrl) async {
    if (_imageCache.containsKey(imageUrl)) return;
    
    try {
      final startTime = DateTime.now();
      
      // In a real app, this would actually load and cache the image
      await Future.delayed(const Duration(milliseconds: 100)); // Simulate loading
      
      final loadTime = DateTime.now().difference(startTime);
      
      _imageCache[imageUrl] = ImageCacheEntry(
        url: imageUrl,
        loadTime: loadTime,
        lastAccessed: DateTime.now(),
        size: 1024 * Random().nextInt(500), // Mock size in KB
      );
      
      _recordEvent(PerformanceEvent(
        type: PerformanceEventType.imagePreloaded,
        description: 'Preloaded image: $imageUrl',
        timestamp: DateTime.now(),
        duration: loadTime,
      ));
    } catch (e) {
      _recordEvent(PerformanceEvent(
        type: PerformanceEventType.error,
        description: 'Failed to preload image: $imageUrl - $e',
        timestamp: DateTime.now(),
      ));
    }
  }

  Future<void> optimizeImage(String imageUrl, {
    int? maxWidth,
    int? maxHeight,
    int? quality,
  }) async {
    final startTime = DateTime.now();
    
    try {
      // In a real app, this would perform actual image optimization
      await Future.delayed(const Duration(milliseconds: 200)); // Simulate processing
      
      final processingTime = DateTime.now().difference(startTime);
      
      _recordEvent(PerformanceEvent(
        type: PerformanceEventType.imageOptimized,
        description: 'Optimized image: $imageUrl',
        timestamp: DateTime.now(),
        duration: processingTime,
        metadata: {
          'maxWidth': maxWidth,
          'maxHeight': maxHeight,
          'quality': quality,
        },
      ));
    } catch (e) {
      _recordEvent(PerformanceEvent(
        type: PerformanceEventType.error,
        description: 'Failed to optimize image: $imageUrl - $e',
        timestamp: DateTime.now(),
      ));
    }
  }

  // Memory management
  void _performMemoryCleanup() {
    final startTime = DateTime.now();
    
    // Clean up expired cache entries
    _performCacheCleanup();
    
    // Clean up old image cache entries
    _cleanupImageCache();
    
    // Clean up old events
    _cleanupEvents();
    
    // Force garbage collection (if needed)
    if (_config.enableGarbageCollection) {
      // In a real app, you might trigger GC here
    }
    
    final cleanupTime = DateTime.now().difference(startTime);
    
    _recordEvent(PerformanceEvent(
      type: PerformanceEventType.memoryCleanup,
      description: 'Performed memory cleanup',
      timestamp: DateTime.now(),
      duration: cleanupTime,
    ));
    
    debugPrint('Memory cleanup completed in ${cleanupTime.inMilliseconds}ms');
  }

  void _cleanupImageCache() {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    for (final entry in _imageCache.entries) {
      final timeSinceAccess = now.difference(entry.value.lastAccessed);
      if (timeSinceAccess > _config.imageCacheTTL) {
        keysToRemove.add(entry.key);
      }
    }
    
    for (final key in keysToRemove) {
      _imageCache.remove(key);
    }
  }

  void _cleanupEvents() {
    final cutoffTime = DateTime.now().subtract(_config.eventRetentionPeriod);
    _events.removeWhere((event) => event.timestamp.isBefore(cutoffTime));
  }

  // Performance measurement
  Future<T> measurePerformance<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final startTime = DateTime.now();
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await operation();
      
      stopwatch.stop();
      final duration = Duration(microseconds: stopwatch.elapsedMicroseconds);
      
      _recordEvent(PerformanceEvent(
        type: PerformanceEventType.operationCompleted,
        description: 'Operation completed: $operationName',
        timestamp: startTime,
        duration: duration,
      ));
      
      return result;
    } catch (e) {
      stopwatch.stop();
      final duration = Duration(microseconds: stopwatch.elapsedMicroseconds);
      
      _recordEvent(PerformanceEvent(
        type: PerformanceEventType.error,
        description: 'Operation failed: $operationName - $e',
        timestamp: startTime,
        duration: duration,
      ));
      
      rethrow;
    }
  }

  void measureWidgetBuild(String widgetName, Duration buildTime) {
    _recordEvent(PerformanceEvent(
      type: PerformanceEventType.widgetBuild,
      description: 'Widget built: $widgetName',
      timestamp: DateTime.now(),
      duration: buildTime,
    ));
    
    // Track slow builds
    if (buildTime.inMilliseconds > _config.slowBuildThreshold) {
      _recordEvent(PerformanceEvent(
        type: PerformanceEventType.slowBuild,
        description: 'Slow build detected: $widgetName (${buildTime.inMilliseconds}ms)',
        timestamp: DateTime.now(),
        duration: buildTime,
      ));
    }
  }

  // Event recording
  void _recordEvent(PerformanceEvent event) {
    _events.add(event);
    
    // Limit event history
    if (_events.length > _config.maxEventHistory) {
      _events.removeAt(0);
    }
    
    // Log critical events
    if (event.type == PerformanceEventType.error ||
        event.type == PerformanceEventType.slowBuild) {
      debugPrint('Performance Event: ${event.description}');
    }
  }

  // Analytics and reporting
  PerformanceReport generateReport() {
    final now = DateTime.now();
    final last24Hours = now.subtract(const Duration(hours: 24));
    
    final recentEvents = _events.where((e) => e.timestamp.isAfter(last24Hours)).toList();
    
    return PerformanceReport(
      generatedAt: now,
      metrics: Map.from(_metrics),
      events: recentEvents,
      cacheStats: CacheStatistics(
        size: cacheSize,
        hitRate: cacheHitRate,
        totalHits: totalCacheHits,
      ),
      imageStats: ImageStatistics(
        cachedImages: _imageCache.length,
        totalSize: _imageCache.values.fold(0, (sum, entry) => sum + entry.size),
        averageLoadTime: _imageCache.values.isEmpty
            ? Duration.zero
            : Duration(
                milliseconds: _imageCache.values
                    .map((e) => e.loadTime.inMilliseconds)
                    .reduce((a, b) => a + b) ~/
                    _imageCache.length,
              ),
      ),
      recommendations: _generateRecommendations(),
    );
  }

  List<PerformanceRecommendation> _generateRecommendations() {
    final recommendations = <PerformanceRecommendation>[];
    
    // Memory recommendations
    final memoryMetric = _metrics['memory_usage'];
    if (memoryMetric != null && memoryMetric.value > memoryMetric.threshold) {
      recommendations.add(PerformanceRecommendation(
        type: RecommendationType.memory,
        title: 'High Memory Usage',
        description: 'Memory usage is above threshold. Consider reducing cache size or clearing unused data.',
        priority: RecommendationPriority.high,
      ));
    }
    
    // Cache recommendations
    if (cacheHitRate < 0.7) {
      recommendations.add(PerformanceRecommendation(
        type: RecommendationType.cache,
        title: 'Low Cache Hit Rate',
        description: 'Cache hit rate is below 70%. Consider adjusting cache strategy or TTL values.',
        priority: RecommendationPriority.medium,
      ));
    }
    
    // Frame rate recommendations
    final fpsMetric = _metrics['fps'];
    if (fpsMetric != null && fpsMetric.value < fpsMetric.threshold) {
      recommendations.add(PerformanceRecommendation(
        type: RecommendationType.performance,
        title: 'Low Frame Rate',
        description: 'Frame rate is below target. Consider optimizing animations or reducing widget complexity.',
        priority: RecommendationPriority.high,
      ));
    }
    
    // Network recommendations
    final networkMetric = _metrics['network_latency'];
    if (networkMetric != null && networkMetric.value > networkMetric.threshold) {
      recommendations.add(PerformanceRecommendation(
        type: RecommendationType.network,
        title: 'High Network Latency',
        description: 'Network requests are slow. Consider implementing request caching or optimizing API calls.',
        priority: RecommendationPriority.medium,
      ));
    }
    
    return recommendations;
  }

  // Configuration
  void updateConfig(PerformanceConfig newConfig) {
    final wasMonitoring = _isMonitoring;
    
    if (wasMonitoring) {
      stopMonitoring();
    }
    
    _config = newConfig;
    
    if (wasMonitoring && newConfig.enablePerformanceMonitoring) {
      startMonitoring();
    }
    
    notifyListeners();
  }

  @override
  void dispose() {
    stopMonitoring();
    clearCache();
    for (final timer in _cacheTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }
} 

// Data classes
class PerformanceMetric {
  final String name;
  final double value;
  final String unit;
  final DateTime timestamp;
  final double threshold;

  const PerformanceMetric({
    required this.name,
    required this.value,
    required this.unit,
    required this.timestamp,
    required this.threshold,
  });

  bool get isAboveThreshold => value > threshold;
  String get formattedValue => '${value.toStringAsFixed(1)} $unit';
}

class PerformanceEvent {
  final PerformanceEventType type;
  final String description;
  final DateTime timestamp;
  final Duration? duration;
  final Map<String, dynamic>? metadata;

  const PerformanceEvent({
    required this.type,
    required this.description,
    required this.timestamp,
    this.duration,
    this.metadata,
  });
}

enum PerformanceEventType {
  operationCompleted,
  widgetBuild,
  slowBuild,
  cacheWrite,
  cacheCleanup,
  cacheCleared,
  memoryCleanup,
  imagePreloaded,
  imageOptimized,
  error,
}

class CacheEntry<T> {
  final T data;
  final DateTime expiry;
  DateTime lastAccessed;

  CacheEntry({
    required this.data,
    required this.expiry,
    required this.lastAccessed,
  });

  bool get isExpired => DateTime.now().isAfter(expiry);
}

class ImageCacheEntry {
  final String url;
  final Duration loadTime;
  DateTime lastAccessed;
  final int size; // Size in bytes

  ImageCacheEntry({
    required this.url,
    required this.loadTime,
    required this.lastAccessed,
    required this.size,
  });
}

class PerformanceConfig {
  final bool enablePerformanceMonitoring;
  final int monitoringInterval; // seconds
  final double memoryThreshold; // MB
  final int maxCacheSize;
  final Duration defaultCacheTTL;
  final Duration imageCacheTTL;
  final Duration eventRetentionPeriod;
  final int maxEventHistory;
  final int slowBuildThreshold; // milliseconds
  final bool enableGarbageCollection;
  final List<String> preloadImages;

  const PerformanceConfig({
    this.enablePerformanceMonitoring = true,
    this.monitoringInterval = 30,
    this.memoryThreshold = 150.0,
    this.maxCacheSize = 1000,
    this.defaultCacheTTL = const Duration(hours: 1),
    this.imageCacheTTL = const Duration(hours: 24),
    this.eventRetentionPeriod = const Duration(days: 7),
    this.maxEventHistory = 1000,
    this.slowBuildThreshold = 16, // 16ms for 60fps
    this.enableGarbageCollection = false,
    this.preloadImages = const [],
  });
}

class PerformanceReport {
  final DateTime generatedAt;
  final Map<String, PerformanceMetric> metrics;
  final List<PerformanceEvent> events;
  final CacheStatistics cacheStats;
  final ImageStatistics imageStats;
  final List<PerformanceRecommendation> recommendations;

  const PerformanceReport({
    required this.generatedAt,
    required this.metrics,
    required this.events,
    required this.cacheStats,
    required this.imageStats,
    required this.recommendations,
  });
}

class CacheStatistics {
  final int size;
  final double hitRate;
  final int totalHits;

  const CacheStatistics({
    required this.size,
    required this.hitRate,
    required this.totalHits,
  });
}

class ImageStatistics {
  final int cachedImages;
  final int totalSize;
  final Duration averageLoadTime;

  const ImageStatistics({
    required this.cachedImages,
    required this.totalSize,
    required this.averageLoadTime,
  });
}

class PerformanceRecommendation {
  final RecommendationType type;
  final String title;
  final String description;
  final RecommendationPriority priority;

  const PerformanceRecommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
  });
}

enum RecommendationType {
  memory,
  cache,
  performance,
  network,
  ui,
}

enum RecommendationPriority {
  low,
  medium,
  high,
  critical,
} 