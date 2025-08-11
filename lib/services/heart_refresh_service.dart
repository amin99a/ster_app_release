import 'dart:async';
import 'heart_state_service.dart';
import '../constants.dart';

class HeartRefreshService {
  static final HeartRefreshService _instance = HeartRefreshService._internal();
  factory HeartRefreshService() => _instance;
  HeartRefreshService._internal();

  // Stream controller for heart state refresh events
  final StreamController<String> _refreshController = StreamController<String>.broadcast();
  
  // Stream for listening to heart state refresh events
  Stream<String> get refreshStream => _refreshController.stream;

  // Refresh heart state for a specific car
  void refreshHeartState(String carId) {
    print('Refreshing heart state for car: $carId');
    _refreshController.add(carId);
  }

  // Refresh heart state for multiple cars
  void refreshHeartStates(List<String> carIds) {
    for (final carId in carIds) {
      _refreshController.add(carId);
    }
  }

  // Refresh all heart states (useful for pull-to-refresh)
  Future<void> refreshAllHeartStates() async {
    try {
      await HeartStateService.refreshHeartStates(AppConstants.defaultUserId);
      _refreshController.add('all');
    } catch (e) {
      print('Error refreshing all heart states: $e');
    }
  }

  // Clear heart state cache
  Future<void> clearHeartStateCache() async {
    try {
      await HeartStateService.clearHeartStateCache();
      _refreshController.add('clear');
    } catch (e) {
      print('Error clearing heart state cache: $e');
    }
  }

  // Dispose the stream controller
  void dispose() {
    _refreshController.close();
  }
} 