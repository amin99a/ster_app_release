import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'car_details_screen.dart';
import 'models/car.dart';
import 'models/search_filter.dart';
import 'services/availability_service.dart';
import 'services/advanced_search_service.dart';
import 'package:provider/provider.dart';
import 'widgets/save_to_favorites_modal.dart';
import 'widgets/heart_icon.dart';
import 'widgets/advanced_filter_panel.dart';
import 'widgets/sort_options_sheet.dart';
import 'services/search_cache_service.dart';
import 'services/image_loading_service.dart';
import 'services/car_service.dart';
import 'utils/animations.dart';
import 'screens/enhanced_booking_confirmation_screen.dart';
import 'utils/price_formatter.dart';

class SearchScreen extends StatefulWidget {
  final String? preSelectedWilaya;
  
  const SearchScreen({
    super.key,
    this.preSelectedWilaya,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final AdvancedSearchService _searchService = AdvancedSearchService();
  
  bool _isLoading = false;
  List<Car> _searchResults = [];
  String? _error;
  
  // Filter states
  bool _isSidebarOpen = false;
  SearchFilter _currentFilter = SearchFilter();
  
  // Animation controllers
  late AnimationController _filterBadgeController;
  late Animation<double> _filterBadgeAnimation;
  
  // Legacy filter states (kept for compatibility)
  bool _isWilayasListExpanded = false;
  bool _isCarTypeListExpanded = false;
  bool _isBrandListExpanded = false;
  bool _isTransmissionListExpanded = false;
  bool _isEnergieListExpanded = false;
  
  String? _preSelectedWilaya;
  final Set<String> _selectedWilayas = {};

  // Performance optimized properties
  final ScrollController _scrollController = ScrollController();
  List<Car> _displayedCars = [];
  List<Car> _allCars = []; // Cache all cars for performance
  bool _isLoadingCars = false;
  bool _hasMoreData = true;
  
  // Search suggestions
  List<String> _searchSuggestions = [];
  bool _showSuggestions = false;

  // Scroll detection for floating filter button
  bool _showFloatingFilter = false;
  bool _isFilterSidebarOpen = false;
  
  // Filter state management
  String? _selectedSortOption;
  RangeValues _priceRange = const RangeValues(0, 1000);
  String? _selectedLocation;
  Set<String> _selectedCarTypes = {};
  Set<String> _selectedBrands = {};
  String? _selectedTransmission;
  String? _selectedFuelType;
  bool _isFiltering = false;
  
  // Performance optimization
  static const int _itemsPerPage = 10;
  int _currentPage = 0;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupSearchService();
    _preSelectedWilaya = widget.preSelectedWilaya;
    if (_preSelectedWilaya != null) {
      _currentFilter = _currentFilter.copyWith(selectedWilaya: _preSelectedWilaya);
    }
    // Handle preselected useType passed via route arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['useType'] is String) {
        _currentFilter = _currentFilter.copyWith(useType: args['useType'] as String);
        _performFilteredSearch();
      }
    });
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    _loadInitialData();
    _initializeCarService();
  }

  void _initializeAnimations() {
    _filterBadgeController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    
    _filterBadgeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _filterBadgeController,
      curve: AppAnimations.bounceCurve,
    ));
  }

  void _setupSearchService() {
    _searchService.addListener(() {
      if (mounted) {
        setState(() {
          _searchResults = _searchService.searchResults;
          _isLoading = _searchService.isLoading;
          _error = _searchService.error;
          _currentFilter = _searchService.currentFilter;
        });
        
        // Animate filter badge when filters are applied
        if (_currentFilter.activeFilterCount > 0) {
          _filterBadgeController.forward();
        } else {
          _filterBadgeController.reverse();
        }
      }
    });
  }

  void _onScroll() {
    final showFloating = _scrollController.offset > 100;
    if (showFloating != _showFloatingFilter) {
      setState(() {
        _showFloatingFilter = showFloating;
      });
    }
    
    // Infinite scrolling for performance
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreCars();
    }
  }
  
  void _loadMoreCars() {
    if (_isLoadingCars || !_hasMoreData) return;
    
    setState(() {
      _isLoadingCars = true;
    });
    
    // Simulate loading delay and add more cars from cache
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        final startIndex = (_currentPage + 1) * _itemsPerPage;
        final endIndex = (startIndex + _itemsPerPage).clamp(0, _searchResults.length);
        
        if (startIndex < _searchResults.length) {
          final newCars = _searchResults.sublist(startIndex, endIndex);
        setState(() {
            _displayedCars.addAll(newCars);
            _currentPage++;
            _hasMoreData = endIndex < _searchResults.length;
            _isLoadingCars = false;
      });
    } else {
    setState(() {
            _hasMoreData = false;
            _isLoadingCars = false;
          });
        }
      }
    });
  }

  Future<void> _initializeCarService() async {
    try {
      final carService = Provider.of<CarService>(context, listen: false);
      await carService.initialize();
      
      // Load and cache all cars for performance
      final cars = await carService.getCars();
      if (cars != null && mounted) {
    setState(() {
          _allCars = cars;
          _displayedCars = cars.take(_itemsPerPage).toList();
          _searchResults = cars;
          _currentPage = 0;
          _hasMoreData = cars.length > _itemsPerPage;
        });
      }
    } catch (e) {
      print('Error initializing car service: $e');
    }
  }

  @override
  void dispose() {
    _filterBadgeController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _scrollController.removeListener(_onScroll);
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    _updateSearchSuggestions(query);
    
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Debounced search with improved performance
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text == query && mounted) {
        _onSearch(query);
      }
    });
  }

  // Performance optimized search functionality
  void _onSearch(String query) async {
    if (query.trim().isEmpty) {
      // If empty query, show all cars
      await _loadAllCars();
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Use cached data for client-side filtering (much faster)
      if (_allCars.isNotEmpty) {
        final filteredResults = _allCars.where((car) {
          final matchesQuery = car.name.toLowerCase().contains(query.toLowerCase()) ||
              car.category.toLowerCase().contains(query.toLowerCase()) ||
              car.location.toLowerCase().contains(query.toLowerCase()) ||
              car.hostName.toLowerCase().contains(query.toLowerCase()) ||
              car.description.toLowerCase().contains(query.toLowerCase());
          
          final matchesLocation = _currentFilter.selectedWilaya == null ||
              car.location.toLowerCase().contains(_currentFilter.selectedWilaya!.toLowerCase());
          
          final matchesCategory = _currentFilter.carTypes.isEmpty ||
              _currentFilter.carTypes.contains(car.category);
          
          return matchesQuery && matchesLocation && matchesCategory;
        }).toList();
        
        if (mounted) {
    setState(() {
            _searchResults = filteredResults;
            _displayedCars = filteredResults.take(_itemsPerPage).toList();
            _currentPage = 0;
            _hasMoreData = filteredResults.length > _itemsPerPage;
            _isLoading = false;
          });
        }
      } else {
        // Fallback to server search if no cached data
        final carService = Provider.of<CarService>(context, listen: false);
        final results = await carService.searchCars(
          query: query,
          location: _currentFilter.selectedWilaya,
          category: _currentFilter.carTypes.isNotEmpty ? _currentFilter.carTypes.first : null,
          minPrice: _currentFilter.minPrice != null && _currentFilter.minPrice! > 0 ? _currentFilter.minPrice : null,
          maxPrice: _currentFilter.maxPrice != null && _currentFilter.maxPrice! < double.infinity ? _currentFilter.maxPrice : null,
        );
        
        if (mounted) {
          setState(() {
            _searchResults = results ?? [];
            _displayedCars = (results ?? []).take(_itemsPerPage).toList();
            _currentPage = 0;
            _hasMoreData = (results?.length ?? 0) > _itemsPerPage;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Search error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Search failed: $e';
        });
      }
    }
    
    _updateSearchSuggestions(query);
  }
  
  Future<void> _loadAllCars() async {
      setState(() {
      _isLoading = true;
    });

    try {
      // Use cached data for better performance
      if (_allCars.isNotEmpty) {
      setState(() {
          _searchResults = _allCars;
          _displayedCars = _allCars.take(_itemsPerPage).toList();
          _currentPage = 0;
          _hasMoreData = _allCars.length > _itemsPerPage;
          _isLoading = false;
        });
        return;
      }
      
      // Fallback to service if cache is empty
      final carService = Provider.of<CarService>(context, listen: false);
      final cars = await carService.getCars();
      
      if (mounted) {
      setState(() {
          _allCars = cars ?? [];
          _searchResults = cars ?? [];
          _displayedCars = (cars ?? []).take(_itemsPerPage).toList();
          _currentPage = 0;
          _hasMoreData = (cars?.length ?? 0) > _itemsPerPage;
        _isLoading = false;
      });
      }
    } catch (e) {
      print('Load cars error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load cars: $e';
        });
      }
    }
  }

  void _updateSearchSuggestions(String query) {
    if (query.isEmpty) {
    setState(() {
        _searchSuggestions = ['BMW', 'Mercedes', 'SUV', 'Luxury', 'Electric', 'Sports Car'];
        _showSuggestions = false;
      });
    } else {
      // Generate suggestions from real car data
      final suggestions = <String>{};
      
      // Add matching car names, categories, and locations from displayedCars
      for (final car in _displayedCars) {
        if (car.name.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(car.name);
        }
        if (car.category.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(car.category);
        }
        if (car.location.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(car.location);
        }
        if (car.hostName.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(car.hostName);
        }
    }

    setState(() {
        _searchSuggestions = suggestions.take(8).toList();
        _showSuggestions = _searchSuggestions.isNotEmpty;
      });
    }
  }

  void _selectSearchSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _searchFocusNode.unfocus();
    setState(() {
      _showSuggestions = false;
    });
    _onSearch(suggestion);
  }

  void _onFilterChanged(SearchFilter newFilter) async {
    setState(() {
      _currentFilter = newFilter;
      _isLoading = true;
    });

    try {
      final carService = Provider.of<CarService>(context, listen: false);
      final results = await carService.searchCars(
        query: _searchController.text.isNotEmpty ? _searchController.text : null,
        location: newFilter.selectedWilaya,
        category: newFilter.carTypes.isNotEmpty ? newFilter.carTypes.first : null,
        minPrice: newFilter.minPrice != null && newFilter.minPrice! > 0 ? newFilter.minPrice : null,
        maxPrice: newFilter.maxPrice != null && newFilter.maxPrice! < double.infinity ? newFilter.maxPrice : null,
      );
      
      if (mounted) {
        setState(() {
        _searchResults = results ?? [];
          _displayedCars = results ?? [];
          _isLoading = false;
      });
      }
    } catch (e) {
      print('Filter error: $e');
      if (mounted) {
      setState(() {
        _isLoading = false;
          _error = 'Filter failed: $e';
      });
    }
  }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load all cars initially
      await _loadAllCars();
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToCarDetails(Car car) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CarDetailsScreen(car: car),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _handleInstantBooking(Car car) {
    // Navigate to booking confirmation screen with default dates
    final now = DateTime.now();
    final startDate = now.add(const Duration(days: 1));
    final endDate = now.add(const Duration(days: 2));
    const rentalDays = 2;
    final dailyRate = double.tryParse(car.price.replaceAll('UK£', '').replaceAll(' total', '').replaceAll(',', '')) ?? 100.0;
    final totalPrice = dailyRate * rentalDays;
    
    // Apply discount for 2+ days
    final discountedPrice = totalPrice * 0.95; // 5% discount for 2+ days
    
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => EnhancedBookingConfirmationScreen(
          car: car,
          startDate: startDate,
          endDate: endDate,
          totalPrice: discountedPrice,
          rentalDays: rentalDays,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showAdvancedFilters() {
    setState(() {
      _isSidebarOpen = true;
    });
  }

  void _hideAdvancedFilters() {
    setState(() {
      _isSidebarOpen = false;
    });
  }

  void _showSaveToFavoritesModal(Car car) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SaveToFavoritesModal(
        carId: car.id,
        carModel: car.name,
        carImage: car.image,
        carRating: car.rating,
        carTrips: car.trips,
        hostName: car.hostName,
        isAllStarHost: car.hostRating >= 4.8,
        carPrice: car.price,
        carLocation: car.location,
      ),
    );
  }

  String _getHostInitial(String hostName) {
    if (hostName.isEmpty) {
      return '?';
    }
    return hostName[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // Scrollable content with header
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // Enhanced Header with Status Bar Integration
                      Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 20,
                          left: 20,
                          right: 20,
                        ),
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF353935), // Onyx color
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              // Primary shadow - closest to the surface
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                                spreadRadius: 0,
                              ),
                              // Secondary shadow - medium depth
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 8),
                                spreadRadius: 0,
                              ),
                              // Tertiary shadow - deepest layer
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 50,
                                offset: const Offset(0, 16),
                                spreadRadius: 0,
                              ),
                              // Ambient shadow - subtle overall depth
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 80,
                                offset: const Offset(0, 25),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Search icon
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Icon(
                                  Icons.search,
                                  color: Colors.white70,
                                  size: 24,
                                ),
                              ),
                              
                              // Search text field
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  onChanged: _onSearch,
                                  decoration: InputDecoration(
                                    hintText: 'Search cars, brands, or locations...',
                                    hintStyle: GoogleFonts.inter(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              
                              // Filter button
                              GestureDetector(
                                onTap: _showFilterSidebar,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  margin: const EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.tune,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Title Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Find What Suits Your Need',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 14),
                      
                      // Car listings
                      Semantics(
                        label: 'Car search results',
                        child: (_isLoading || _isLoadingCars || _isFiltering) && _displayedCars.isEmpty
                            ? _buildLoadingState()
                            : _displayedCars.isEmpty && !_isLoading && !_isLoadingCars && !_isFiltering
                                ? _buildEmptyState()
                                : _displayedCars.isNotEmpty && !_isLoading && !_isFiltering
                                    ? Column(
                                        children: [
                                          // Create a local copy to prevent race conditions
                                          ...(() {
                                            final carsToDisplay = List<Car>.from(_displayedCars);
                                            // Final safety check
                                            if (carsToDisplay.isEmpty) {
                                              return <Widget>[];
                                            }
                                            return List.generate(carsToDisplay.length, (index) {
                                              // Safety check to prevent RangeError
                                              if (index >= carsToDisplay.length) {
                                                return const SizedBox.shrink();
                                              }
                                              final car = carsToDisplay[index];
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: Column(
                                                  children: [
                                                    _buildModernCarCard(car, index),
                                                    if (index < carsToDisplay.length - 1)
                                                      const SizedBox(height: 16),
                                                  ],
                                                ),
                                              );
                                            });
                                          })(),
                                          // Loading indicator at the bottom
                                          if (_hasMoreData)
                                            Semantics(
                                              label: 'Loading more cars',
                                              child: const Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      Color(0xFF593CFB),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      )
                                    : _buildLoadingState(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Filter Sidebar Backdrop
        if (_isFilterSidebarOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideFilterSidebar,
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
        
        // Filter Sidebar
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          right: _isFilterSidebarOpen ? 0 : -350,
          top: 0,
          bottom: 0,
          width: 350,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.125,
              bottom: MediaQuery.of(context).size.height * 0.125,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF353935),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(-5, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF353935),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                    ),
                  ),
                                      child: Row(
                      children: [
                        const Icon(
                          Icons.tune,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Filters',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _hideFilterSidebar,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                ),
                
                // Filter Form Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sort By Section - Horizontal Scrollable Chips
                        _buildEnhancedFilterSection(
                          'Sort By',
                          Icons.sort,
                          [_buildHorizontalSortChips()],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Price Range Section
                        _buildEnhancedFilterSection(
                          'Price Range (per day)',
                          Icons.attach_money,
                          [_buildPriceRangeSlider()],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Location Section - Horizontal Scrollable Chips
                        _buildEnhancedFilterSection(
                          'Location',
                          Icons.location_on,
                          [_buildHorizontalLocationChips()],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Car Type Section - Horizontal Scrollable Chips
                        _buildEnhancedFilterSection(
                          'Car Type',
                          Icons.directions_car,
                          [_buildHorizontalCarTypeChips()],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Brand Section - Horizontal Scrollable Chips
                        _buildEnhancedFilterSection(
                          'Brand',
                          Icons.branding_watermark,
                          [_buildHorizontalBrandChips()],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Transmission Section - Horizontal Scrollable Chips
                        _buildEnhancedFilterSection(
                          'Transmission',
                          Icons.settings,
                          [_buildHorizontalTransmissionChips()],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Fuel Type Section - Horizontal Scrollable Chips
                        _buildEnhancedFilterSection(
                          'Fuel Type',
                          Icons.local_gas_station,
                          [_buildHorizontalFuelTypeChips()],
                        ),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                
                // Action Buttons
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF353935),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearAllFilters,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Clear All',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF353935),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Apply Filters',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(0xFF353935), // Updated to Onyx
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isFiltering ? 'Applying filters...' : 
            _isLoading ? 'Searching for cars...' : 'Loading cars from database...',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
                          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
                            children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
                              Text(
            'No cars found',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
                                ),
                              ),
          const SizedBox(height: 8),
                              Text(
            'Try adjusting your search criteria',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
              color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
    );
  }

  Widget _buildModernCarCard(Car car, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Semantics(
        label: '${car.name} car card',
        button: true,
        child: GestureDetector(
          onTap: () => _navigateToCarDetails(car),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                  spreadRadius: 0,
                        ),
                      ],
                    ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Image Section
                Stack(
                  children: [
                    // Main car image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: ImageLoadingService.loadImage(
                          imagePath: car.image,
                          width: double.infinity,
                          height: 200,
                        ),
                      ),
                    ),
                    
                    // Available badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Available',
                              style: GoogleFonts.inter(
                            fontSize: 10,
                                fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    // Heart icon
                    Positioned(
                      top: 12,
                      right: 12,
                      child: HeartIcon(
                        carId: car.id,
                        carModel: car.name,
                        carImage: car.image,
                        carRating: car.rating,
                        carTrips: car.trips,
                        hostName: car.hostName,
                        isAllStarHost: car.hostRating >= 4.8,
                        carPrice: car.price,
                        carLocation: car.location,
                        onHeartTapped: () => _showSaveToFavoritesModal(car),
                      ),
                    ),
                    
                    // Price badge
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          PriceFormatter.formatPerDayWithSettings(context, car.price),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Enhanced Content Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Car name and rating
                      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
                          Expanded(
                            child: Text(
                              car.name,
            style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
          Text(
                                car.rating.toString(),
            style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
            ),
          ),
        ],
      ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Category and location
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF353935).withValues(alpha: 0.1), // Updated to Onyx
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              car.category,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF353935), // Updated to Onyx
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
            child: Text(
                                    car.location,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
            ),
          ),
        ],
      ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Host info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey[200],
                            child: Text(
                              _getHostInitial(car.hostName),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  car.hostName,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  '${car.trips} trips',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Instant book button
                          GestureDetector(
                            onTap: () => _handleInstantBooking(car),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF353935), // Updated to Onyx
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Book Now',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
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
                  ),
                ),
    );
  }

  // Filter sidebar methods
  void _showFilterSidebar() {
                setState(() {
      _isFilterSidebarOpen = true;
    });
  }

    void _hideFilterSidebar() {
    setState(() {
      _isFilterSidebarOpen = false;
    });
  }

  // Filter UI Helper Methods
  Widget _buildEnhancedFilterSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF353935),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
            Icon(
              icon,
                color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
                                style: GoogleFonts.inter(
                fontSize: 16,
                                  fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildHorizontalSortChips() {
    final sortOptions = ['Relevance', 'Price: Low to High', 'Price: High to Low', 'Rating', 'Most Trips', 'Newest'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: sortOptions.map((option) {
          final isSelected = _selectedSortOption == option;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                _selectedSortOption = isSelected ? null : option;
                        });
                      },
                                      child: Container(
              margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFF353935),
                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
                              child: Text(
                option,
                                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                                fontWeight: FontWeight.w500,
                  color: isSelected ? const Color(0xFF353935) : Colors.white,
                                ),
                                        ),
                                      ),
                                    );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceRangeSlider() {
    return Column(
      children: [
        RangeSlider(
          values: _priceRange,
          min: 0,
          max: 1000,
          divisions: 20,
          activeColor: Colors.white,
          inactiveColor: Colors.grey.shade300,
          onChanged: (RangeValues values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${_priceRange.start.round()}',
                style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                  color: Colors.white,
                  ),
                ),
            Text(
              '\$${_priceRange.end.round()}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                                                ),
                                              ),
          ],
        ),
      ],
    );
  }

  Widget _buildHorizontalLocationChips() {
    final locations = ['Algiers', 'Oran', 'Constantine', 'Annaba', 'Blida', 'Batna'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: locations.map((location) {
          final isSelected = _selectedLocation == location;
                    return GestureDetector(
                      onTap: () {
              setState(() {
                _selectedLocation = isSelected ? null : location;
              });
                      },
                      child: Container(
              margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFF353935),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
                              child: Text(
                location,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                  color: isSelected ? const Color(0xFF353935) : Colors.white,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHorizontalCarTypeChips() {
    final carTypes = ['SUV', 'Sedan', 'Hatchback', 'Luxury', 'Sports', 'Electric'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: carTypes.map((type) {
          final isSelected = _selectedCarTypes.contains(type);
          return GestureDetector(
              onTap: () {
                setState(() {
                if (isSelected) {
                  _selectedCarTypes.remove(type);
                } else {
                  _selectedCarTypes.add(type);
                }
              });
                      },
                      child: Container(
              margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFF353935),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
                              child: Text(
                type,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                  color: isSelected ? const Color(0xFF353935) : Colors.white,
                                ),
                        ),
                      ),
                    );
        }).toList(),
      ),
    );
  }

  Widget _buildHorizontalBrandChips() {
    final brands = ['BMW', 'Mercedes', 'Audi', 'Toyota', 'Honda', 'Ford', 'Volkswagen'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: brands.map((brand) {
          final isSelected = _selectedBrands.contains(brand);
          return GestureDetector(
              onTap: () {
                setState(() {
                if (isSelected) {
                  _selectedBrands.remove(brand);
                } else {
                  _selectedBrands.add(brand);
                }
              });
                      },
                      child: Container(
              margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFF353935),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
                              child: Text(
                brand,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                  color: isSelected ? const Color(0xFF353935) : Colors.white,
                                ),
                        ),
                      ),
                    );
        }).toList(),
      ),
    );
  }

  Widget _buildHorizontalTransmissionChips() {
    final transmissions = ['Automatic', 'Manual'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: transmissions.map((transmission) {
          final isSelected = _selectedTransmission == transmission;
          return GestureDetector(
              onTap: () {
                setState(() {
                _selectedTransmission = isSelected ? null : transmission;
              });
                      },
              child: Container(
              margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFF353935),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Text(
                transmission,
                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                  color: isSelected ? const Color(0xFF353935) : Colors.white,
                ),
                        ),
                      ),
                    );
        }).toList(),
      ),
    );
  }

  Widget _buildHorizontalFuelTypeChips() {
    final fuelTypes = ['Gasoline', 'Diesel', 'Electric', 'Hybrid'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: fuelTypes.map((fuelType) {
          final isSelected = _selectedFuelType == fuelType;
    return GestureDetector(
                onTap: () {
              setState(() {
                _selectedFuelType = isSelected ? null : fuelType;
              });
                },
                child: Container(
              margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFF353935),
                    borderRadius: BorderRadius.circular(20),
          border: Border.all(
                  color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Text(
                fuelType,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
                  color: isSelected ? const Color(0xFF353935) : Colors.white,
          ),
        ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Filter logic methods
  Future<void> _clearAllFilters() async {
    setState(() {
      _selectedSortOption = null;
      _priceRange = const RangeValues(0, 1000);
      _selectedLocation = null;
      _selectedCarTypes.clear();
      _selectedBrands.clear();
      _selectedTransmission = null;
      _selectedFuelType = null;
      _currentFilter = SearchFilter();
      _isFiltering = true;
    });
    // Close sidebar first for immediate visual feedback
    _hideFilterSidebar();
    // Reset results to full dataset and refresh UI
    await _loadAllCars();
    if (mounted) {
      setState(() {
        _isFiltering = false;
        _error = null;
      });
      // Scroll to top after refresh for clarity
      unawaited(_scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      ));
    }
  }

  void _applyFilters() {
    _hideFilterSidebar();
    _performFilteredSearch();
  }

  void _performFilteredSearch() async {
    setState(() {
      _isFiltering = true;
      _isLoadingCars = true;
    });

    try {
      // Build filter query
      final filteredCars = await _buildFilteredQuery();
      
      if (mounted) {
        setState(() {
          _displayedCars = filteredCars;
          _searchResults = filteredCars;
          _isFiltering = false;
          _isLoadingCars = false;
          _currentPage = 0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFiltering = false;
          _isLoadingCars = false;
        });
        // Handle error - could show snackbar or error message
      }
    }
  }

  Future<List<Car>> _buildFilteredQuery() async {
    // Start with all cars
    List<Car> filteredCars = List.from(_allCars);
    
    // Apply location filter
    if (_selectedLocation != null) {
      filteredCars = filteredCars.where((car) => 
        car.location.toLowerCase().contains(_selectedLocation!.toLowerCase())
      ).toList();
    }
    
    // Apply price range filter
    filteredCars = filteredCars.where((car) {
      try {
        final price = double.tryParse(car.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
        return price >= _priceRange.start && price <= _priceRange.end;
      } catch (e) {
        return false;
      }
    }).toList();
    
    // Apply car type filter
    if (_selectedCarTypes.isNotEmpty) {
      filteredCars = filteredCars.where((car) => 
        _selectedCarTypes.any((type) => 
          car.name.toLowerCase().contains(type.toLowerCase())
        )
      ).toList();
    }
    
    // Apply brand filter
    if (_selectedBrands.isNotEmpty) {
      filteredCars = filteredCars.where((car) => 
        _selectedBrands.any((brand) => 
          car.name.toLowerCase().contains(brand.toLowerCase())
        )
      ).toList();
    }
    
    // Apply transmission filter
    if (_selectedTransmission != null) {
      filteredCars = filteredCars.where((car) => 
        car.transmission.toLowerCase() == _selectedTransmission!.toLowerCase()
      ).toList();
    }
    
    // Apply fuel type filter
    if (_selectedFuelType != null) {
      filteredCars = filteredCars.where((car) => 
        car.fuelType.toLowerCase() == _selectedFuelType!.toLowerCase()
      ).toList();
    }
    
    // Apply sorting
    if (_selectedSortOption != null) {
      filteredCars = _applySorting(filteredCars, _selectedSortOption!);
    }
    
    return filteredCars;
  }

  List<Car> _applySorting(List<Car> cars, String sortOption) {
    switch (sortOption) {
      case 'Price: Low to High':
        cars.sort((a, b) {
          final priceA = double.tryParse(a.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
          final priceB = double.tryParse(b.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
          return priceA.compareTo(priceB);
        });
        break;
      case 'Price: High to Low':
        cars.sort((a, b) {
          final priceA = double.tryParse(a.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
          final priceB = double.tryParse(b.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
          return priceB.compareTo(priceA);
        });
        break;
      case 'Rating':
        cars.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Most Trips':
        cars.sort((a, b) => b.trips.compareTo(a.trips));
        break;
      case 'Newest':
        // Assuming cars have a date field, sort by newest first
        // For now, keep original order
        break;
      case 'Relevance':
      default:
        // Keep original order for relevance
        break;
    }
    return cars;
  }

} 