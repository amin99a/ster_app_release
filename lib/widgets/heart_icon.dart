import 'package:flutter/material.dart';
import 'dart:async';
import '../services/heart_state_service.dart';
import '../services/heart_refresh_service.dart';
import '../constants.dart';
import 'save_to_favorites_modal.dart'; // Added import for SaveToFavoritesModal

class HeartIcon extends StatefulWidget {
  final String carId;
  final String carModel;
  final String carImage;
  final double carRating;
  final int carTrips;
  final String hostName;
  final bool isAllStarHost;
  final String carPrice;
  final String carLocation;
  final VoidCallback? onHeartTapped;
  final bool showShadow;
  final double size;
  final Color? color;
  final bool cleanMode;

  const HeartIcon({
    super.key,
    required this.carId,
    required this.carModel,
    required this.carImage,
    required this.carRating,
    required this.carTrips,
    required this.hostName,
    this.isAllStarHost = false,
    required this.carPrice,
    required this.carLocation,
    this.onHeartTapped,
    this.showShadow = true,
    this.size = 16,
    this.color,
    this.cleanMode = false,
  });

  @override
  State<HeartIcon> createState() => _HeartIconState();
}

class _HeartIconState extends State<HeartIcon> with TickerProviderStateMixin {
  bool _isSaved = false;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  StreamSubscription<String>? _refreshSubscription;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _loadHeartState();
    _setupRefreshListener();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _refreshSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadHeartState() async {
    try {
      final isSaved = await HeartStateService.isCarSaved(
        widget.carId,
        AppConstants.defaultUserId,
      );
      
      print('Heart state for ${widget.carId}: $isSaved');
      
      if (mounted) {
        setState(() {
          _isSaved = isSaved;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading heart state: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Public method to refresh heart state
  Future<void> refreshHeartState() async {
    print('Refreshing heart state for ${widget.carId}');
    setState(() {
      _isLoading = true;
    });
    await _loadHeartState();
  }

  void _setupRefreshListener() {
    print('Setting up refresh listener for heart icon ${widget.carId}');
    _refreshSubscription = HeartRefreshService().refreshStream.listen((carId) {
      print('Heart icon ${widget.carId} received refresh event: $carId');
      if (carId == widget.carId || carId == 'all' || carId == 'clear') {
        print('Refreshing heart icon ${widget.carId}');
        refreshHeartState();
      }
    });
  }

  Future<void> _toggleHeartState() async {
    if (_isLoading) return;

    // Animate the heart
    await _animationController.forward();
    await _animationController.reverse();

    // Call the parent's onHeartTapped callback if provided
    if (widget.onHeartTapped != null) {
      widget.onHeartTapped!();
      // Refresh the heart state after the modal is closed
      await Future.delayed(const Duration(milliseconds: 1000));
      await _loadHeartState();
    } else {
      // Default behavior: show save to favorites modal
      _showSaveToFavoritesModal();
    }
  }

  void _showSaveToFavoritesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, controller) {
            return SaveToFavoritesModal(
              carId: widget.carId,
              carModel: widget.carModel,
              carImage: widget.carImage,
              carRating: widget.carRating,
              carTrips: widget.carTrips,
              hostName: widget.hostName,
              isAllStarHost: widget.isAllStarHost,
              carPrice: widget.carPrice,
              carLocation: widget.carLocation,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Building heart icon for ${widget.carId}, isSaved: $_isSaved, isLoading: $_isLoading, will show: ${_isSaved ? "RED FILLED" : "GREY EMPTY"}');
    
    if (_isLoading) {
      if (widget.cleanMode) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      }
      
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: widget.showShadow ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _toggleHeartState,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          if (widget.cleanMode) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Icon(
                _isSaved ? Icons.favorite : Icons.favorite_border,
                size: widget.size,
                color: _isSaved 
                    ? Colors.red
                    : (widget.color ?? Colors.white),
              ),
            );
          }
          
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: widget.showShadow ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Icon(
                _isSaved ? Icons.favorite : Icons.favorite_border,
                size: widget.size,
                color: _isSaved 
                    ? Colors.red
                    : (widget.color ?? Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
} 