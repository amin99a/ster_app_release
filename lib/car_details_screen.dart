import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/car.dart';
import 'widgets/floating_header.dart';
import 'widgets/heart_icon.dart';
import 'utils/price_formatter.dart';
import 'screens/car_booking_screen.dart';
import 'debug/section_toggles.dart';

class CarDetailsScreen extends StatefulWidget {
  final Car car;
  const CarDetailsScreen({super.key, required this.car});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  int _currentImageIndex = 0;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _pickupLocation;
  String? _dropoffLocation;

  @override
  void initState() {
    super.initState();
    _pickupLocation = (widget.car.pickupLocations.isNotEmpty
            ? widget.car.pickupLocations.first
            : widget.car.location)
        .toString();
    _dropoffLocation = (widget.car.dropoffLocations.isNotEmpty
            ? widget.car.dropoffLocations.first
            : widget.car.location)
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 120,
                      ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          if (CarDetailsVisibility.showImageSection) ...[
                            _buildImageGallery(),
                            const SizedBox(height: 8),
                          ],
                          if (CarDetailsVisibility.showHostDetailsSection) ...[
                            _buildHostSection(),
                            const SizedBox(height: 8),
                          ],
                          if (CarDetailsVisibility.showDatePickupSection) ...[
                            _buildDatePickupSection(),
                            const SizedBox(height: 8),
                          ],
                          if (CarDetailsVisibility.showCarDetailsSection) ...[
                            _buildSpecsSection(),
                            const SizedBox(height: 8),
                          ],
                          if (CarDetailsVisibility.showRequirementsSection) ...[
                            _buildRequirementsSection(),
                            const SizedBox(height: 8),
                          ],
                      ],
                    ),
                  ),
                ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 10,
              right: 10,
              child: _buildAppBar(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CarDetailsVisibility.showConfirmBar
          ? SafeArea(top: false, child: _buildConfirmBar())
          : null,
    );
  }

  Widget _buildAppBar() {
    return FloatingHeader(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
          const SizedBox(width: 12),
              Expanded(
              child: Text(
              widget.car.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
               style: GoogleFonts.inter(
                  fontSize: 18,
                            fontWeight: FontWeight.w600,
                  color: Colors.white,
               ),
                ),
              ),
              const SizedBox(width: 12),
          HeartIcon(
        carId: widget.car.id,
        carModel: widget.car.name,
        carImage: widget.car.image,
        carRating: widget.car.rating,
        carTrips: widget.car.trips,
        hostName: widget.car.hostName,
            isAllStarHost: widget.car.hostRating >= 4.8,
        carPrice: widget.car.price,
        carLocation: widget.car.location,
                  showShadow: false,
            color: Colors.white,
            cleanMode: true,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    final images = <String>{
      if (widget.car.image.isNotEmpty && !widget.car.image.contains('via.placeholder.com'))
        widget.car.image,
      ...widget.car.images.where((s) => s.isNotEmpty && !s.contains('via.placeholder.com')),
    }.toList();

    final double status = MediaQuery.of(context).padding.top;
    final double h = MediaQuery.of(context).size.height * 0.35 + status;

    return SizedBox(
      height: h,
      width: double.infinity,
          child: Stack(
                children: [
            PageView.builder(
            itemCount: images.isEmpty ? 1 : images.length,
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
                      itemBuilder: (context, index) {
              final src = images.isEmpty ? '' : images[index];
              final isNet = src.startsWith('http');
              return ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: isNet
                      ? Image.network(
                        src,
                                fit: BoxFit.cover,
                          width: double.infinity,
                        height: h,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(h),
                      )
                    : _imagePlaceholder(h),
                            );
                          },
                          ),
            if (images.length > 1)
                  Positioned(
                bottom: 16,
                    left: 0,
                    right: 0,
                child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                    images.length,
                  (i) => Container(
                      width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      color: _currentImageIndex == i ? Colors.white : Colors.white54,
                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
      ),
    );
  }

  Widget _imagePlaceholder(double h) {
    return Container(
      width: double.infinity,
      height: h,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(Icons.directions_car, color: Colors.grey.shade500, size: 48),
    );
  }

  Widget _buildHostSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecor(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hosted by', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, color: Colors.white),
              ),
          const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(widget.car.hostName, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(widget.car.hostRating.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 14)),
                      ],
              ),
            ],
          ),
          ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.message, size: 16),
                label: Text('Contact', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF353935),
                    foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickupSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(20),
      decoration: _cardDecor(shadowLight: true),
          child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Plan your trip', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_month, size: 14, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text('Flexible', style: GoogleFonts.inter(fontSize: 12, color: Colors.blue)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          // Dates
            Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width - 20*2 - 12) / 2,
                child: _actionField(
                  icon: Icons.event,
                  label: 'Start Date',
                  value: _startDate != null ? _fmt(_startDate!) : 'Select date',
                  onTap: _pickStartDate,
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 20*2 - 12) / 2,
                child: _actionField(
                  icon: Icons.event_available,
                  label: 'End Date',
                  value: _endDate != null ? _fmt(_endDate!) : 'Select date',
                  onTap: _pickEndDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Locations
          Wrap(
            spacing: 12,
            runSpacing: 12,
      children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width - 20*2 - 12) / 2,
                child: _actionField(
                  icon: Icons.location_on,
                  label: 'Pickup',
                  value: _pickupLocation ?? widget.car.location,
                  onTap: () => _selectLocation(
                    title: 'Pickup location',
                    options: widget.car.pickupLocations.isNotEmpty
                        ? widget.car.pickupLocations
                        : <String>[widget.car.location],
                    onSelected: (v) => setState(() => _pickupLocation = v),
                      ),
                    ),
                  ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 20*2 - 12) / 2,
                child: _actionField(
                  icon: Icons.place,
                  label: 'Drop-off',
                  value: _dropoffLocation ?? widget.car.location,
                  onTap: () => _selectLocation(
                    title: 'Drop-off location',
                    options: widget.car.dropoffLocations.isNotEmpty
                        ? widget.car.dropoffLocations
                        : <String>[widget.car.location],
                    onSelected: (v) => setState(() => _dropoffLocation = v),
                          ),
                        ),
                        ),
                      ],
                    ),
        ],
      ),
    );
  }

  Widget _actionField({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
            child: Container(
        padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
              ),
        constraints: const BoxConstraints(minHeight: 56),
      child: Row(
        children: [
            Icon(icon, size: 18, color: Colors.grey.shade700),
            const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 2),
                Text(
                    value,
                    maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF353935)),
                ),
              ],
            ),
          ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ],
      ),
            ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    // Prevent nested rebuild issues by scheduling after frame
    await Future<void>.delayed(Duration.zero);
    final picked = await showDatePicker(
                      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (!mounted) return;
    if (picked != null) {
                      setState(() {
        _startDate = picked;
        if (_endDate != null && !_endDate!.isAfter(_startDate!)) {
          _endDate = _startDate!.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
                    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select start date first')));
                      return;
                    }
    final now = DateTime.now();
    await Future<void>.delayed(Duration.zero);
    final picked = await showDatePicker(
                      context: context,
      initialDate: _endDate ?? _startDate!.add(const Duration(days: 1)),
                      firstDate: _startDate!.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 366)),
    );
    if (!mounted) return;
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _selectLocation({
    required String title,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return SafeArea(
              top: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                title,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        controller: controller,
                        itemCount: options.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final item = options[i];
                          return ListTile(
                            title: Text(item),
                            onTap: () {
                              Navigator.pop(context);
                              onSelected(item);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSpecsSection() {
    final entries = widget.car.specs.entries.toList();
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecor(),
                    child: Column(
        mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
              Text('Car Details', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
              _useBadge(widget.car.useType),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.car.features.isNotEmpty) ...[
            Text('Features', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.car.features.take(6).map((f) => _chip(f)).toList(),
            ),
            const SizedBox(height: 12),
          ],
          if (entries.isNotEmpty) ...[
            Text('Specifications', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length > 12 ? 12 : entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final e = entries[i];
                return Row(
        children: [
                    Expanded(
                      flex: 2,
                      child: Text(e.key, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600)),
                    ),
              Expanded(
                      flex: 3,
                      child: Text(e.value.toString(), maxLines: 3, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: GoogleFonts.inter(fontSize: 12)),
    );
  }

  Widget _buildRequirementsSection() {
    final req = widget.car.requirements;
    if (req.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(20),
        decoration: _cardDecor(),
        child: Text('No specific requirements provided by the host.', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600)),
      );
    }
    final groups = <MapEntry<String, dynamic>>[];
    // Common grouping keys if present
    for (final k in ['driver_requirements', 'policies', 'financial_terms']) {
      if (req[k] != null) groups.add(MapEntry(k, req[k]));
    }
    // Add any remaining keys
    req.forEach((k, v) {
      if (!['driver_requirements', 'policies', 'financial_terms'].contains(k)) {
        groups.add(MapEntry(k, v));
      }
    });

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.rule, color: Color(0xFF353935), size: 20),
              const SizedBox(width: 8),
              Text('Requirements & Conditions', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          ...groups.map((e) => _reqGroupTile(_titleCase(e.key), e.value)).toList(),
        ],
      ),
    );
  }

  Widget _reqGroupTile(String title, dynamic data) {
    final List<Widget> items = [];
    if (data is Map) {
      data.forEach((k, v) => items.add(_reqRow(k.toString(), v?.toString() ?? '')));
    } else if (data is List) {
      for (final v in data) {
        items.add(_reqRow('•', v?.toString() ?? ''));
      }
    } else {
      items.add(_reqRow('', data?.toString() ?? ''));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF353935))),
          const SizedBox(height: 8),
          ...items,
        ],
      ),
    );
  }

  Widget _reqRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty && label != '•')
            SizedBox(
              width: 140,
              child: Text(label, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
            )
          else if (label == '•')
            const Text('• ', style: TextStyle(fontSize: 14, color: Colors.black87)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _titleCase(String s) {
    if (s.isEmpty) return s;
    return s
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : (w[0].toUpperCase() + w.substring(1)))
        .join(' ');
  }

  Widget _buildConfirmBar() {
    final int days = (_startDate != null && _endDate != null)
        ? _endDate!.difference(_startDate!).inDays
        : 0;
    final double perDay = _extractDailyRate();
    final double total = days > 0 ? perDay * days : perDay;
    final String price = PriceFormatter.formatWithSettings(context, total.toString());
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 8)),
      ]),
      child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
              Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
        children: [
                Text(
                  days > 0 ? 'Total for $days day${days == 1 ? '' : 's'}' : 'Per day',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
                ),
                      const SizedBox(height: 4),
                Text(price, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
              ],
                          ),
                        ),
                        const SizedBox(width: 12),
              SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
                child: ElevatedButton(
              onPressed: (_startDate != null && _endDate != null)
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CarBookingScreen(car: widget.car)),
                      )
                  : null,
              style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF353935),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                (_startDate != null && _endDate != null) ? 'Confirm' : 'Select Dates',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
              ),
                ),
              ),
            ],
      ),
    );
  }

  BoxDecoration _cardDecor({bool shadowLight = false}) {
    return BoxDecoration(
                  color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(shadowLight ? 0.06 : 0.08), blurRadius: shadowLight ? 14 : 16, offset: const Offset(0, 6)),
        if (!shadowLight) BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.04), blurRadius: 32, offset: const Offset(0, 16)),
      ],
    );
  }

  Widget _useBadge(dynamic useType) {
    String label;
    Color color;
    switch (useType) {
      case 'business':
      case CarUseType.business:
        label = 'Business';
        color = const Color(0xFF0EA5E9);
        break;
      case 'event':
      case CarUseType.event:
        label = 'Events';
        color = const Color(0xFFF59E0B);
        break;
      case 'daily':
      case CarUseType.daily:
      default:
        label = 'Daily use';
        color = const Color(0xFF22C55E);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.35))),
      child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }

  double _extractDailyRate() {
    try {
      final dynamic candidate = (widget.car as dynamic).dailyRate;
      if (candidate is num) return candidate.toDouble();
    } catch (_) {}
    final match = RegExp(r"[-+]?[0-9]*\.?[0-9]+").firstMatch(widget.car.price);
    if (match != null) {
      final v = double.tryParse(match.group(0) ?? '');
      if (v != null) return v;
    }
    return 0.0;
  }
}


