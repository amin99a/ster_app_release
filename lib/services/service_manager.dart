import 'network_service.dart';
import 'offline_storage_service.dart';
import 'favorite_service.dart';
import 'view_history_service.dart';
import 'heart_state_service.dart';
import '../constants.dart';

class ServiceManager {
  static final ServiceManager _instance = ServiceManager._internal();
  factory ServiceManager() => _instance;
  ServiceManager._internal();

  bool _isInitialized = false;
  bool _isInitializing = false;

  // Initialize all services
  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) {
      return;
    }

    _isInitializing = true;

    try {
      print('Initializing services...');

      // Initialize core services first
      await NetworkService().initialize();
      await OfflineStorageService().initialize();

      // Initialize feature services
      await FavoriteService.initialize();
      await ViewHistoryService.initialize();

      // Initialize heart state service
      await HeartStateService.initialize();

      // Set up periodic sync
      _setupPeriodicSync();

      _isInitialized = true;
      print('All services initialized successfully');
    } catch (e) {
      print('Error initializing services: $e');
      _isInitializing = false;
      rethrow;
    }
  }

  // Setup periodic sync for offline operations
  void _setupPeriodicSync() {
    // Sync every 5 minutes when app is active
    Future.delayed(AppConstants.syncRetryDelay, () async {
      if (_isInitialized) {
        await _performSync();
        _setupPeriodicSync(); // Schedule next sync
      }
    });
  }

  // Perform sync of pending operations
  Future<void> _performSync() async {
    try {
      if (!NetworkService().isOnline) {
        return;
      }

      final offlineStorage = OfflineStorageService();
      
      if (offlineStorage.hasPendingOperations) {
        print('Syncing ${offlineStorage.pendingOperationsCount} pending operations...');
        
        await FavoriteService.syncPendingOperations();
        await ViewHistoryService.syncPendingOperations();
        
        print('Sync completed successfully');
      }
    } catch (e) {
      print('Error during sync: $e');
    }
  }

  // Manual sync trigger
  Future<void> syncNow() async {
    if (!_isInitialized) {
      await initialize();
    }
    await _performSync();
  }

  // Check if services are ready
  bool get isReady => _isInitialized;

  // Get network status
  bool get isOnline => NetworkService().isOnline;

  // Get pending operations count
  int get pendingOperationsCount => OfflineStorageService().pendingOperationsCount;

  // Check if sync is needed
  bool get isSyncNeeded => OfflineStorageService().isSyncNeeded();

  // Get last sync time
  DateTime? get lastSyncTime => OfflineStorageService().getLastSyncTime();

  // Clear all cached data
  Future<void> clearAllCache() async {
    try {
      await OfflineStorageService().clearCache();
      await HeartStateService.clearCache();
      print('All cache cleared');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Clear pending operations
  Future<void> clearPendingOperations() async {
    try {
      await OfflineStorageService().clearPendingOperations();
      print('Pending operations cleared');
    } catch (e) {
      print('Error clearing pending operations: $e');
    }
  }

  // Dispose all services
  void dispose() {
    NetworkService().dispose();
    _isInitialized = false;
    _isInitializing = false;
  }

  // Get service status for debugging
  Map<String, dynamic> getServiceStatus() {
    return {
      'isInitialized': _isInitialized,
      'isOnline': isOnline,
      'pendingOperations': pendingOperationsCount,
      'isSyncNeeded': isSyncNeeded,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'cacheExpirationMinutes': AppConstants.cacheExpirationMinutes,
      'syncRetryDelay': AppConstants.syncRetryDelay.inMinutes,
    };
  }
}

// Global service manager instance
final serviceManager = ServiceManager(); 