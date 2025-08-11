import 'package:flutter/material.dart';
import '../services/voice_search_service.dart';

class VoiceSearchWidget extends StatefulWidget {
  final Function(String)? onSearch;
  final Function(Map<String, dynamic>)? onVoiceCommand;
  final String? initialText;
  final bool showTips;

  const VoiceSearchWidget({
    super.key,
    this.onSearch,
    this.onVoiceCommand,
    this.initialText,
    this.showTips = true,
  });

  @override
  State<VoiceSearchWidget> createState() => _VoiceSearchWidgetState();
}

class _VoiceSearchWidgetState extends State<VoiceSearchWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late AnimationController _tipController;
  late Animation<double> _tipAnimation;
  
  String _transcription = '';
  bool _isListening = false;
  double _confidence = 0.0;
  final List<String> _suggestions = [];
  bool _showTips = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    _tipController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _tipAnimation = CurvedAnimation(
      parent: _tipController,
      curve: Curves.easeInOut,
    );

    _initializeVoiceSearch();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _tipController.dispose();
    super.dispose();
  }

  Future<void> _initializeVoiceSearch() async {
    await VoiceSearchService().initialize();
    
    VoiceSearchService().searchResults.listen((transcription) {
      setState(() {
        _transcription = transcription;
      });
      
      if (transcription.isNotEmpty && !transcription.startsWith('Error')) {
        _processTranscription(transcription);
      }
    });

    VoiceSearchService().isListening.listen((isListening) {
      setState(() {
        _isListening = isListening;
      });
      
      if (isListening) {
        _pulseController.repeat(reverse: true);
        _waveController.repeat();
      } else {
        _pulseController.stop();
        _waveController.stop();
      }
    });

    VoiceSearchService().confidence.listen((confidence) {
      setState(() {
        _confidence = confidence;
      });
    });

    VoiceSearchService().errors.listen((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  Future<void> _processTranscription(String transcription) async {
    final command = await VoiceSearchService().processVoiceCommand(transcription);
    
    if (widget.onVoiceCommand != null) {
      widget.onVoiceCommand!(command);
    } else {
      widget.onSearch?.call(transcription);
    }
  }

  Future<void> _startVoiceSearch() async {
    await VoiceSearchService().startListening();
  }

  Future<void> _stopVoiceSearch() async {
    await VoiceSearchService().stopListening();
  }

  void _toggleTips() {
    setState(() {
      _showTips = !_showTips;
    });
    
    if (_showTips) {
      _tipController.forward();
    } else {
      _tipController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Voice button with confidence indicator
          GestureDetector(
            onTap: _isListening ? _stopVoiceSearch : _startVoiceSearch,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _isListening ? Colors.red : const Color(0xFF593CFB),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isListening ? Colors.red : const Color(0xFF593CFB))
                                  .withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                _isListening ? Icons.mic : Icons.mic_none,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            if (_isListening)
                              ...List.generate(3, (index) {
                                return AnimatedBuilder(
                                  animation: _waveAnimation,
                                  builder: (context, child) {
                                    return Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.red.withOpacity(
                                              0.3 - (index * 0.1),
                                            ),
                                            width: 2,
                                          ),
                                        ),
                                        transform: Matrix4.identity()
                                          ..scale(1.0 + (_waveAnimation.value * 0.5) + (index * 0.2)),
                                      ),
                                    );
                                  },
                                );
                              }),
                          ],
                        ),
                      ),
                      // Confidence indicator
                      if (_isListening)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${(_confidence * 100).round()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Status text
          Text(
            _isListening ? 'Listening...' : 'Tap to start voice search',
            style: TextStyle(
              fontSize: 16,
              color: _isListening ? Colors.red : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          
          if (_transcription.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You said:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _transcription,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (_suggestions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suggestions:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _suggestions.map((suggestion) => 
                    GestureDetector(
                      onTap: () => widget.onSearch?.call(suggestion),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF593CFB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF593CFB).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          suggestion,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF593CFB),
                          ),
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ],
            ),
          ],
          
          // Tips section
          if (widget.showTips) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _toggleTips,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Voice search tips',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            if (_showTips)
              AnimatedBuilder(
                animation: _tipAnimation,
                builder: (context, child) {
                  return SizeTransition(
                    sizeFactor: _tipAnimation,
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: VoiceSearchService().getVoiceSearchTips().map((tip) => 
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('• ', style: TextStyle(color: Colors.blue[700])),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).toList(),
                      ),
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }
}