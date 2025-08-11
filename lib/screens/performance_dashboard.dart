import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/performance_service.dart';
import '../utils/animations.dart';

class PerformanceDashboard extends StatefulWidget {
  const PerformanceDashboard({super.key});

  @override
  State<PerformanceDashboard> createState() => _PerformanceDashboardState();
}

class _PerformanceDashboardState extends State<PerformanceDashboard>
    with TickerProviderStateMixin {
  final PerformanceService _performanceService = PerformanceService();
  
  PerformanceReport? _report;
  bool _isLoading = true;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializePerformanceService();
    _setupListeners();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppAnimations.smoothCurve,
    ));
    
    _fadeController.forward();
  }

  void _initializePerformanceService() async {
    await _performanceService.initialize();
    await _generateReport();
  }

  void _setupListeners() {
    _performanceService.addListener(() {
      if (mounted) {
        _generateReport();
      }
    });
  }

  Future<void> _generateReport() async {
    setState(() => _isLoading = true);
    
    // Simulate report generation time
    await Future.delayed(const Duration(milliseconds: 500));
    
    final report = _performanceService.generateReport();
    
    if (mounted) {
      setState(() {
        _report = report;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Custom App Bar
          _buildCustomAppBar(),
          
          // Content
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _isLoading ? _buildLoadingState() : _buildDashboard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF593CFB), Color(0xFF7C5CFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF593CFB).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedButton(
            onPressed: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                Text(
                  'Performance Dashboard',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Monitor app performance metrics',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                      ],
                    ),
                  ),
          
          Row(
            children: [
              AnimatedButton(
                onPressed: _generateReport,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              AnimatedButton(
                onPressed: _showSettings,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
                ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF593CFB)),
          ),
          SizedBox(height: 16),
          Text('Generating performance report...'),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    if (_report == null) {
      return const Center(child: Text('No performance data available'));
    }

    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Overview Cards
          AnimatedListItem(
            index: 0,
            child: _buildOverviewSection(),
          ),
          
          const SizedBox(height: 24),
          
          // Performance Metrics
          AnimatedListItem(
            index: 1,
            child: _buildMetricsSection(),
          ),
          
          const SizedBox(height: 24),
          
          // Cache Statistics
          AnimatedListItem(
            index: 2,
            child: _buildCacheSection(),
          ),
          
          const SizedBox(height: 24),
          
          // Image Statistics
          AnimatedListItem(
            index: 3,
            child: _buildImageSection(),
          ),
          
          const SizedBox(height: 24),
          
          // Recommendations
          if (_report!.recommendations.isNotEmpty)
            AnimatedListItem(
              index: 4,
              child: _buildRecommendationsSection(),
            ),
          
          const SizedBox(height: 24),
          
          // Recent Events
          AnimatedListItem(
            index: 5,
            child: _buildEventsSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
              Icon(
                Icons.dashboard,
                color: const Color(0xFF593CFB),
                size: 24,
              ),
              
              const SizedBox(width: 12),
              
              Text(
                  'Performance Overview',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  'App Health',
                  _getOverallHealthScore(),
                  _getHealthColor(),
                  Icons.favorite,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: _buildOverviewCard(
                  'Monitoring',
                  _performanceService.isMonitoring ? 'Active' : 'Inactive',
                  _performanceService.isMonitoring ? Colors.green : Colors.orange,
                  Icons.monitor_heart,
                ),
              ),
            ],
          ),
          
            const SizedBox(height: 16),
          
            Row(
              children: [
                Expanded(
                child: _buildOverviewCard(
                  'Cache Size',
                  '${_performanceService.cacheSize} items',
                  Colors.blue,
                    Icons.storage,
                  ),
                ),
              
                const SizedBox(width: 16),
              
                Expanded(
                child: _buildOverviewCard(
                  'Last Updated',
                  _formatTime(_report!.generatedAt),
                  Colors.grey,
                  Icons.update,
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }

  Widget _buildOverviewCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection() {
    return Container(
        padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
              Icon(
                Icons.analytics,
                color: const Color(0xFF593CFB),
                size: 24,
              ),
              
              const SizedBox(width: 12),
              
              Text(
                  'Performance Metrics',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 20),
          
          ..._report!.metrics.values.map((metric) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildMetricItem(metric),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMetricItem(PerformanceMetric metric) {
    final progress = (metric.value / metric.threshold).clamp(0.0, 1.0);
    final color = metric.isAboveThreshold ? Colors.red : Colors.green;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              metric.name,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            
            Text(
              metric.formattedValue,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        
        const SizedBox(height: 4),
        
        Text(
          'Threshold: ${metric.threshold.toStringAsFixed(1)} ${metric.unit}',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildCacheSection() {
    final cacheStats = _report!.cacheStats;
    
    return Container(
        padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
              Icon(
                Icons.storage,
                color: const Color(0xFF593CFB),
                size: 24,
              ),
              
              const SizedBox(width: 12),
              
              Text(
                'Cache Statistics',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              
              const Spacer(),
              
              AnimatedButton(
                onPressed: _clearCache,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Clear Cache',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 20),
          
            Row(
              children: [
                Expanded(
                child: _buildStatCard(
                  'Cache Size',
                  '${cacheStats.size}',
                  'items',
                  Colors.blue,
                ),
              ),
              
              const SizedBox(width: 16),
              
                Expanded(
                child: _buildStatCard(
                  'Hit Rate',
                  '${(cacheStats.hitRate * 100).toInt()}%',
                  'efficiency',
                  cacheStats.hitRate > 0.7 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 16),
          
          _buildStatCard(
            'Total Hits',
            '${cacheStats.totalHits}',
            'requests served from cache',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    final imageStats = _report!.imageStats;
    
    return Container(
        padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                Icons.image,
                color: const Color(0xFF593CFB),
                size: 24,
                ),
              
              const SizedBox(width: 12),
              
                Text(
                'Image Statistics',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 20),
          
            Row(
              children: [
                Expanded(
                child: _buildStatCard(
                  'Cached Images',
                  '${imageStats.cachedImages}',
                  'images',
                  Colors.green,
                ),
              ),
              
                const SizedBox(width: 16),
              
                Expanded(
                child: _buildStatCard(
                  'Total Size',
                  '${(imageStats.totalSize / 1024).toStringAsFixed(1)} MB',
                  'storage used',
                  Colors.orange,
                  ),
                ),
              ],
            ),
          
              const SizedBox(height: 16),
          
          _buildStatCard(
            'Average Load Time',
            '${imageStats.averageLoadTime.inMilliseconds}ms',
            'per image',
            imageStats.averageLoadTime.inMilliseconds < 500 ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Container(
        padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
              Icon(
                Icons.lightbulb,
                color: const Color(0xFF593CFB),
                size: 24,
              ),
              
              const SizedBox(width: 12),
              
              Text(
                'Performance Recommendations',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 20),
          
          ..._report!.recommendations.map((recommendation) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildRecommendationItem(recommendation),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(PerformanceRecommendation recommendation) {
    final color = _getRecommendationColor(recommendation.priority);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            _getRecommendationIcon(recommendation.type),
            color: color,
            size: 20,
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(
              children: [
                Expanded(
                      child: Text(
                        recommendation.title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        recommendation.priority.name.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            ),
                
                const SizedBox(height: 4),
                
                Text(
                  recommendation.description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection() {
    final recentEvents = _report!.events.take(10).toList();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event,
                color: const Color(0xFF593CFB),
                size: 24,
              ),
              
              const SizedBox(width: 12),
              
              Text(
                'Recent Events',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          if (recentEvents.isEmpty)
            Center(
              child: Text(
                'No recent events',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            )
          else
            ...recentEvents.map((event) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildEventItem(event),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildEventItem(PerformanceEvent event) {
    final color = _getEventColor(event.type);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getEventIcon(event.type),
            color: color,
            size: 16,
          ),
          
          const SizedBox(width: 8),
          
          Expanded(
      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
                  event.description,
                  style: GoogleFonts.inter(
              fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
            ),
          ),
                
                Row(
                  children: [
          Text(
                      _formatTime(event.timestamp),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    
                    if (event.duration != null) ...[
                      Text(
                        ' • ',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      
                      Text(
                        '${event.duration!.inMilliseconds}ms',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Utility methods
  String _getOverallHealthScore() {
    final metrics = _report!.metrics.values;
    if (metrics.isEmpty) return 'Unknown';
    
    final healthyCount = metrics.where((m) => !m.isAboveThreshold).length;
    final percentage = (healthyCount / metrics.length * 100).round();
    
    if (percentage >= 80) return 'Excellent';
    if (percentage >= 60) return 'Good';
    if (percentage >= 40) return 'Fair';
    return 'Poor';
  }

  Color _getHealthColor() {
    final score = _getOverallHealthScore();
    switch (score) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.blue;
      case 'Fair':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  Color _getRecommendationColor(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.low:
        return Colors.blue;
      case RecommendationPriority.medium:
        return Colors.orange;
      case RecommendationPriority.high:
        return Colors.red;
      case RecommendationPriority.critical:
        return Colors.purple;
    }
  }

  IconData _getRecommendationIcon(RecommendationType type) {
    switch (type) {
      case RecommendationType.memory:
        return Icons.memory;
      case RecommendationType.cache:
        return Icons.storage;
      case RecommendationType.performance:
        return Icons.speed;
      case RecommendationType.network:
        return Icons.network_check;
      case RecommendationType.ui:
        return Icons.widgets;
    }
  }

  Color _getEventColor(PerformanceEventType type) {
    switch (type) {
      case PerformanceEventType.error:
        return Colors.red;
      case PerformanceEventType.slowBuild:
        return Colors.orange;
      case PerformanceEventType.operationCompleted:
        return Colors.green;
      case PerformanceEventType.cacheWrite:
      case PerformanceEventType.cacheCleanup:
        return Colors.blue;
      case PerformanceEventType.memoryCleanup:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventIcon(PerformanceEventType type) {
    switch (type) {
      case PerformanceEventType.error:
        return Icons.error;
      case PerformanceEventType.slowBuild:
        return Icons.warning;
      case PerformanceEventType.operationCompleted:
        return Icons.check_circle;
      case PerformanceEventType.cacheWrite:
        return Icons.save;
      case PerformanceEventType.cacheCleanup:
        return Icons.cleaning_services;
      case PerformanceEventType.memoryCleanup:
        return Icons.memory;
      case PerformanceEventType.imagePreloaded:
        return Icons.image;
      default:
        return Icons.info;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear Cache',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will clear all cached data. Are you sure?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () {
              _performanceService.clearCache();
              Navigator.pop(context);
              _generateReport();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Cache cleared successfully',
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF593CFB),
                ),
              );
            },
            child: Text(
              'Clear',
              style: GoogleFonts.inter(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Text(
              'Performance Settings',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 20),
            
            _buildSettingOption(
              'Enable Monitoring',
              _performanceService.isMonitoring ? 'On' : 'Off',
              Icons.monitor_heart,
              () {
                if (_performanceService.isMonitoring) {
                  _performanceService.stopMonitoring();
                } else {
                  _performanceService.startMonitoring();
                }
                Navigator.pop(context);
                setState(() {});
              },
            ),
            
            _buildSettingOption(
              'Clear All Data',
              'Reset performance data',
              Icons.delete_forever,
              () {
                Navigator.pop(context);
                _clearCache();
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingOption(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return AnimatedButton(
      onPressed: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey.shade600,
              size: 20,
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
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
} 