import 'package:flutter/material.dart';
import '../models/favorite_list.dart';
import '../services/favorite_service.dart';
import 'create_list_modal.dart';
import '../constants.dart';
import '../services/heart_state_service.dart';
import '../services/heart_refresh_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/notification_service.dart';

class SaveToFavoritesModal extends StatefulWidget {
  final String carId;
  final String carModel;
  final String carImage;
  final double carRating;
  final int carTrips;
  final String hostName;
  final bool isAllStarHost;
  final String? carPrice;
  final String? carLocation;

  const SaveToFavoritesModal({
    super.key,
    required this.carId,
    required this.carModel,
    required this.carImage,
    required this.carRating,
    required this.carTrips,
    required this.hostName,
    this.isAllStarHost = false,
    this.carPrice,
    this.carLocation,
  });

  @override
  State<SaveToFavoritesModal> createState() => _SaveToFavoritesModalState();
}

class _SaveToFavoritesModalState extends State<SaveToFavoritesModal> {
  List<FavoriteList> _favoriteLists = [];
  List<String> _selectedListIds = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteLists();
  }

  Future<void> _loadFavoriteLists() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final lists = await FavoriteService.getUserFavoriteLists(AppConstants.defaultUserId);
      
      setState(() {
        _favoriteLists = lists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading favorite lists: $e');
    }
  }

  void _toggleListSelection(String listId) {
    setState(() {
      if (_selectedListIds.contains(listId)) {
        _selectedListIds.remove(listId);
      } else {
        _selectedListIds.add(listId);
      }
    });
  }

  Future<void> _createNewList() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateListModal(
        carImage: widget.carImage,
        carModel: widget.carModel,
      ),
    );

    if (result != null) {
      // Refresh lists after creating new one
      await _loadFavoriteLists();
      
      // Auto-select the newly created list
      if (_favoriteLists.isNotEmpty) {
        final newList = _favoriteLists.first;
        setState(() {
          _selectedListIds = [newList.id];
        });
      }
    }
  }

  Future<void> _saveToFavorites() async {
    if (_selectedListIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one list'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isSaving = true;
      });

      // Save to all selected lists
      for (final listId in _selectedListIds) {
        await FavoriteService.addToFavorites(
          userId: AppConstants.defaultUserId,
          listId: listId,
          carId: widget.carId,
          carModel: widget.carModel,
          carImage: widget.carImage,
          carRating: widget.carRating,
          carTrips: widget.carTrips,
          hostName: widget.hostName,
          isAllStarHost: widget.isAllStarHost,
          carPrice: widget.carPrice ?? 'Price not available',
          carLocation: widget.carLocation ?? 'Location not available',
        );
      }

      // Update heart state to reflect that car is now saved
      await HeartStateService.updateHeartState(widget.carId, true);
      print('Updated heart state for ${widget.carId} to true');

      // Trigger heart refresh across the app
      HeartRefreshService().refreshHeartState(widget.carId);
      
      // Also trigger a global refresh to ensure all hearts update
      await Future.delayed(const Duration(milliseconds: 500));
      HeartRefreshService().refreshHeartStates(['all']);

      // Send notification to current user
      final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? AppConstants.defaultUserId;
      await NotificationService().sendNotification(
        userId: currentUserId,
        title: 'Saved to Favorites',
        message: '${widget.carModel} saved to ${_selectedListIds.length} list${_selectedListIds.length != 1 ? 's' : ''}.',
        type: 'favorites',
        metadata: {
          'car_id': widget.carId,
          'lists_count': _selectedListIds.length,
        },
      );

      // Close modal and show success message
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.carModel} saved to ${_selectedListIds.length} list${_selectedListIds.length != 1 ? 's' : ''}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'View Saved',
            textColor: Colors.white,
            onPressed: () {
              // Navigate to saved screen
              Navigator.of(context).pushNamed('/saved');
            },
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving to favorites: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 24),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Save to favorites',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Balance the layout
              ],
            ),
          ),

          // Content
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_favoriteLists.isEmpty)
            _buildEmptyState()
          else
            _buildListsContent(),

          // Save button
          if (!_isLoading && _favoriteLists.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveToFavorites,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF593CFB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Saving...'),
                          ],
                        )
                      : Text('Save to ${_selectedListIds.length} list${_selectedListIds.length != 1 ? 's' : ''}'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No favorite lists yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first list to save ${widget.carModel}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _createNewList,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF593CFB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Create New List'),
          ),
        ],
      ),
    );
  }

  Widget _buildListsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Car preview
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (widget.carImage.startsWith('http') || widget.carImage.startsWith('https'))
                    ? Image.network(
                        widget.carImage,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      )
                    : Image.asset(
                        widget.carImage,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.carModel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          widget.carRating.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Color(0xFF593CFB),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${widget.carTrips} trips)',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Lists section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose lists to save to:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              ..._favoriteLists.map((list) => _buildListTile(list)),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _createNewList,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Create new list'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF593CFB),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(FavoriteList list) {
    final isSelected = _selectedListIds.contains(list.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF593CFB).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF593CFB) : Colors.grey[300]!,
        ),
      ),
      child: ListTile(
        onTap: () => _toggleListSelection(list.id),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: list.coverImage != null
                ? DecorationImage(
                    image: (list.coverImage!.startsWith('http') || list.coverImage!.startsWith('https'))
                        ? NetworkImage(list.coverImage!)
                        : AssetImage(list.coverImage!) as ImageProvider,
                    fit: BoxFit.cover,
                  )
                : null,
            color: list.coverImage == null ? Colors.grey[200] : null,
          ),
          child: list.coverImage == null
              ? const Icon(Icons.favorite, color: Colors.grey)
              : null,
        ),
        title: Text(
          list.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          '${list.itemCount} vehicle${list.itemCount != 1 ? 's' : ''}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        trailing: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? const Color(0xFF593CFB) : Colors.transparent,
            border: Border.all(
              color: isSelected ? const Color(0xFF593CFB) : Colors.grey[400]!,
            ),
          ),
          child: isSelected
              ? const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                )
              : null,
        ),
      ),
    );
  }
} 