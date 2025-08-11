import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EnhancedSearchBar extends StatefulWidget {
  final String hintText;
  final String? initialValue;
  final Function(String)? onSearch;
  final Function(String)? onChanged;
  final VoidCallback? onVoiceSearch;
  final VoidCallback? onFilterTap;
  final List<String>? recentSearches;
  final List<String>? searchSuggestions;
  final bool showVoiceButton;
  final bool showFilterButton;
  final bool showRecentSearches;

  const EnhancedSearchBar({
    super.key,
    this.hintText = 'Search cars...',
    this.initialValue,
    this.onSearch,
    this.onChanged,
    this.onVoiceSearch,
    this.onFilterTap,
    this.recentSearches,
    this.searchSuggestions,
    this.showVoiceButton = true,
    this.showFilterButton = true,
    this.showRecentSearches = true,
  });

  @override
  State<EnhancedSearchBar> createState() => _EnhancedSearchBarState();
}

class _EnhancedSearchBarState extends State<EnhancedSearchBar>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final bool _isExpanded = false;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
      if (_hasFocus) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      widget.onSearch?.call(query.trim());
      _focusNode.unfocus();
    }
  }

  void _onSuggestionTap(String suggestion) {
    _controller.text = suggestion;
    _onSearch(suggestion);
  }

  void _onRecentSearchTap(String search) {
    _controller.text = search;
    _onSearch(search);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main search bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                padding: EdgeInsets.all(_hasFocus ? 4 : 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _hasFocus 
                        ? const Color(0xFF593CFB) 
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    // Search icon
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        LucideIcons.search,
                        color: _hasFocus 
                            ? const Color(0xFF593CFB) 
                            : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                    
                    // Search text field
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        onChanged: widget.onChanged,
                        onSubmitted: _onSearch,
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    
                    // Voice search button
                    if (widget.showVoiceButton)
                      IconButton(
                        onPressed: widget.onVoiceSearch,
                        icon: Icon(
                          LucideIcons.mic,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        tooltip: 'Voice Search',
                      ),
                    
                    // Filter button
                    if (widget.showFilterButton)
                      IconButton(
                        onPressed: widget.onFilterTap,
                        icon: Icon(
                          LucideIcons.slidersHorizontal,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        tooltip: 'Filters',
                      ),
                    
                    // Clear button
                    if (_controller.text.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          _controller.clear();
                          widget.onChanged?.call('');
                        },
                        icon: Icon(
                          LucideIcons.x,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        tooltip: 'Clear',
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        
        // Search suggestions and recent searches
        if (_hasFocus && (_controller.text.isNotEmpty || widget.showRecentSearches))
          Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Collapse button
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            onPressed: () {
                              _focusNode.unfocus();
                            },
                            icon: Icon(
                              LucideIcons.chevronUp,
                              color: Colors.grey[700],
                              size: 18,
                            ),
                            tooltip: 'Collapse',
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Search suggestions
                    if (widget.searchSuggestions != null && 
                        widget.searchSuggestions!.isNotEmpty)
                      _buildSuggestionsSection(),
                    
                    // Recent searches
                    if (widget.showRecentSearches && 
                        widget.recentSearches != null && 
                        widget.recentSearches!.isNotEmpty)
                      _buildRecentSearchesSection(),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSuggestionsSection() {
    final suggestions = widget.searchSuggestions!
        .where((suggestion) => 
            suggestion.toLowerCase().contains(_controller.text.toLowerCase()))
        .take(5)
        .toList();

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'Suggestions',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        ...suggestions.map((suggestion) => _buildSuggestionTile(suggestion)),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildRecentSearchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Clear recent searches
                },
                child: Text(
                  'Clear',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ),
        ...widget.recentSearches!.take(3).map((search) => _buildRecentSearchTile(search)),
      ],
    );
  }

  Widget _buildSuggestionTile(String suggestion) {
    return ListTile(
      dense: true,
      leading: Icon(
        LucideIcons.search,
        size: 16,
        color: Colors.grey[600],
      ),
      title: Text(
        suggestion,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
      ),
      onTap: () => _onSuggestionTap(suggestion),
    );
  }

  Widget _buildRecentSearchTile(String search) {
    return ListTile(
      dense: true,
      leading: Icon(
        LucideIcons.history,
        size: 16,
        color: Colors.grey[600],
      ),
      title: Text(
        search,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
      ),
      trailing: IconButton(
        onPressed: () {
          // TODO: Remove from recent searches
        },
        icon: Icon(
          LucideIcons.x,
          size: 16,
          color: Colors.grey[600],
        ),
      ),
      onTap: () => _onRecentSearchTap(search),
    );
  }
}

class SearchFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  const SearchFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF593CFB) 
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF593CFB) 
                : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 