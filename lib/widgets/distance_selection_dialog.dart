import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DistanceSelectionDialog extends StatefulWidget {
  final Function(double) onDistanceSelected;

  const DistanceSelectionDialog({
    Key? key,
    required this.onDistanceSelected,
  }) : super(key: key);

  @override
  State<DistanceSelectionDialog> createState() => _DistanceSelectionDialogState();
}

class _DistanceSelectionDialogState extends State<DistanceSelectionDialog> {
  double _selectedDistance = 50.0; // Default 50km
  TextEditingController? _distanceController;

  @override
  void initState() {
    super.initState();
    _distanceController = TextEditingController(text: _selectedDistance.toInt().toString());
  }

  void _updateCounter(double value) {
    if (_distanceController != null) {
      _distanceController!.text = value.toInt().toString();
    }
  }

  @override
  void dispose() {
    _distanceController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Simple header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Near by',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.close,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ],
            ),
            
                         const SizedBox(height: 12),
             
             // Distance input field with unit
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 SizedBox(
                   width: 72, // Reduced by 40% from 120
                   child: TextFormField(
                     controller: _distanceController,
                     keyboardType: TextInputType.number,
                     textAlign: TextAlign.center,
                     style: GoogleFonts.inter(
                       fontSize: 19, // Reduced by 40% from 32
                       fontWeight: FontWeight.bold,
                       color: const Color(0xFF353935),
                     ),
                     decoration: InputDecoration(
                       border: InputBorder.none,
                       contentPadding: EdgeInsets.zero,
                       isDense: true,
                     ),
                                           onChanged: (value) {
                        final newDistance = double.tryParse(value);
                        if (newDistance != null && newDistance >= 0 && newDistance <= 1000) {
                          if (newDistance != _selectedDistance) {
                            setState(() {
                              _selectedDistance = newDistance;
                            });
                          }
                        }
                      },
                      onEditingComplete: () {
                        // Ensure the value is valid when user finishes editing
                        final value = _distanceController?.text ?? '';
                        final newDistance = double.tryParse(value);
                        if (newDistance != null && newDistance >= 0 && newDistance <= 1000) {
                          setState(() {
                            _selectedDistance = newDistance;
                          });
                        } else {
                          // Reset to current value if invalid
                          _distanceController?.text = _selectedDistance.toInt().toString();
                        }
                      },
                   ),
                 ),
                 const SizedBox(width: 4),
                 Text(
                   'km',
                   style: GoogleFonts.inter(
                     fontSize: 10, // Reduced by 40% from 16
                     fontWeight: FontWeight.w500,
                     color: Colors.grey.shade600,
                   ),
                 ),
               ],
             ),
             
             const SizedBox(height: 12),
            
            // Minimal slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF353935),
                inactiveTrackColor: Colors.grey.shade300,
                thumbColor: const Color(0xFF353935),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
                                                          child: Slider(
                 value: _selectedDistance,
                 min: 0.0,
                 max: 1000.0,
                 divisions: 100,
                 onChangeStart: (value) {
                   _updateCounter(value);
                 },
                 onChanged: (value) {
                   setState(() {
                     _selectedDistance = value;
                   });
                   _updateCounter(value);
                 },
                 onChangeEnd: (value) {
                   _updateCounter(value);
                 },
               ),
                         ),
             
             const SizedBox(height: 16),
             
             // Single action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onDistanceSelected(_selectedDistance);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF353935),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Search',
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
    );
  }

  
} 