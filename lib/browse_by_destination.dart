import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrowseByDestination extends StatefulWidget {
  final Function(String wilayaName)? onDestinationSelected;
  
  const BrowseByDestination({
    super.key,
    this.onDestinationSelected,
  });

  @override
  State<BrowseByDestination> createState() => _BrowseByDestinationState();
}

class _BrowseByDestinationState extends State<BrowseByDestination> {
  final ScrollController _scrollController = ScrollController();
  bool _showArrow = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 10) {
      if (!_showArrow) {
        setState(() {
          _showArrow = true;
        });
      }
    } else {
      if (_showArrow) {
        setState(() {
          _showArrow = false;
        });
      }
    }
  }

  // All 58 Algeria wilayas with their data
  static const List<Map<String, String>> allWilayas = [
    {'name': 'Adrar', 'code': '01', 'image': 'assets/wilayas/adrar.png'},
    {'name': 'Chlef', 'code': '02', 'image': 'assets/wilayas/chlef.png'},
    {'name': 'Laghouat', 'code': '03', 'image': 'assets/wilayas/laghouat.png'},
    {'name': 'Oum El Bouaghi', 'code': '04', 'image': 'assets/wilayas/oum_el_bouaghi.png'},
    {'name': 'Batna', 'code': '05', 'image': 'assets/wilayas/batna.png'},
    {'name': 'Béjaïa', 'code': '06', 'image': 'assets/wilayas/bejaia.png'},
    {'name': 'Biskra', 'code': '07', 'image': 'assets/wilayas/biskra.png'},
    {'name': 'Béchar', 'code': '08', 'image': 'assets/wilayas/bechar.png'},
    {'name': 'Blida', 'code': '09', 'image': 'assets/wilayas/blida.png'},
    {'name': 'Bouira', 'code': '10', 'image': 'assets/wilayas/bouira.png'},
    {'name': 'Tamanrasset', 'code': '11', 'image': 'assets/wilayas/tamanrasset.png'},
    {'name': 'Tébessa', 'code': '12', 'image': 'assets/wilayas/tebessa.png'},
    {'name': 'Tlemcen', 'code': '13', 'image': 'assets/wilayas/tlemcen.png'},
    {'name': 'Tiaret', 'code': '14', 'image': 'assets/wilayas/tiaret.png'},
    {'name': 'Tizi Ouzou', 'code': '15', 'image': 'assets/wilayas/tizi_ouzou.png'},
    {'name': 'Alger', 'code': '16', 'image': 'assets/wilayas/alger.png'},
    {'name': 'Djelfa', 'code': '17', 'image': 'assets/wilayas/djelfa.png'},
    {'name': 'Jijel', 'code': '18', 'image': 'assets/wilayas/jijel.png'},
    {'name': 'Sétif', 'code': '19', 'image': 'assets/wilayas/setif.png'},
    {'name': 'Saïda', 'code': '20', 'image': 'assets/wilayas/saida.png'},
    {'name': 'Skikda', 'code': '21', 'image': 'assets/wilayas/skikda.png'},
    {'name': 'Sidi Bel Abbès', 'code': '22', 'image': 'assets/wilayas/sidi_bel_abbes.png'},
    {'name': 'Annaba', 'code': '23', 'image': 'assets/wilayas/annaba.png'},
    {'name': 'Guelma', 'code': '24', 'image': 'assets/wilayas/guelma.png'},
    {'name': 'Constantine', 'code': '25', 'image': 'assets/wilayas/constantine.png'},
    {'name': 'Médéa', 'code': '26', 'image': 'assets/wilayas/medea.png'},
    {'name': 'Mostaganem', 'code': '27', 'image': 'assets/wilayas/mostaganem.png'},
    {'name': "M'Sila", 'code': '28', 'image': 'assets/wilayas/msila.png'},
    {'name': 'Mascara', 'code': '29', 'image': 'assets/wilayas/mascara.png'},
    {'name': 'Ouargla', 'code': '30', 'image': 'assets/wilayas/ouargla.png'},
    {'name': 'Oran', 'code': '31', 'image': 'assets/wilayas/oran.png'},
    {'name': 'El Bayadh', 'code': '32', 'image': 'assets/wilayas/el_bayadh.png'},
    {'name': 'Illizi', 'code': '33', 'image': 'assets/wilayas/illizi.png'},
    {'name': 'Bordj Bou Arréridj', 'code': '34', 'image': 'assets/wilayas/bordj_bou_arreridj.png'},
    {'name': 'Boumerdès', 'code': '35', 'image': 'assets/wilayas/boumerdes.png'},
    {'name': 'El Tarf', 'code': '36', 'image': 'assets/wilayas/el_tarf.png'},
    {'name': 'Tindouf', 'code': '37', 'image': 'assets/wilayas/tindouf.png'},
    {'name': 'Tissemsilt', 'code': '38', 'image': 'assets/wilayas/tissemsilt.png'},
    {'name': 'El Oued', 'code': '39', 'image': 'assets/wilayas/el_oued.png'},
    {'name': 'Khenchela', 'code': '40', 'image': 'assets/wilayas/khenchela.png'},
    {'name': 'Souk Ahras', 'code': '41', 'image': 'assets/wilayas/souk_ahras.png'},
    {'name': 'Tipaza', 'code': '42', 'image': 'assets/wilayas/tipaza.png'},
    {'name': 'Mila', 'code': '43', 'image': 'assets/wilayas/mila.png'},
    {'name': 'Aïn Defla', 'code': '44', 'image': 'assets/wilayas/ain_defla.png'},
    {'name': 'Naâma', 'code': '45', 'image': 'assets/wilayas/naama.png'},
    {'name': 'Aïn Témouchent', 'code': '46', 'image': 'assets/wilayas/ain_temouchent.png'},
    {'name': 'Ghardaïa', 'code': '47', 'image': 'assets/wilayas/ghardaia.png'},
    {'name': 'Relizane', 'code': '48', 'image': 'assets/wilayas/relizane.png'},
    {'name': 'El M\'Ghair', 'code': '49', 'image': 'assets/wilayas/el_mghair.png'},
    {'name': 'El Meniaa', 'code': '50', 'image': 'assets/wilayas/el_meniaa.png'},
    {'name': 'Ouled Djellal', 'code': '51', 'image': 'assets/wilayas/ouled_djellal.png'},
    {'name': 'Bordj Baji Mokhtar', 'code': '52', 'image': 'assets/wilayas/bordj_baji_mokhtar.png'},
    {'name': 'Béni Abbès', 'code': '53', 'image': 'assets/wilayas/beni_abbes.png'},
    {'name': 'Timimoun', 'code': '54', 'image': 'assets/wilayas/timimoun.png'},
    {'name': 'Touggourt', 'code': '55', 'image': 'assets/wilayas/touggourt.png'},
    {'name': 'Djanet', 'code': '56', 'image': 'assets/wilayas/djanet.png'},
    {'name': "Aïn Salah", 'code': '57', 'image': 'assets/wilayas/ain_salah.png'},
    {'name': 'Aïn Guezzam', 'code': '58', 'image': 'assets/wilayas/ain_guezzam.png'},
  ];

  void _showAllWilayasModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildWilayasModal(context),
    );
  }

  Widget _buildWilayasModal(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Algeria Wilayas',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.black),
                ),
              ],
            ),
          ),
          
          // Wilayas Chips
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: allWilayas.map((wilaya) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      widget.onDestinationSelected?.call(wilaya['name']!);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        wilaya['name']!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWilayaCard(Map<String, String> wilaya) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Full image background
            Positioned.fill(
              child: Image.asset(
                wilaya['image']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF593CFB).withValues(alpha: 0.3),
                          const Color(0xFF593CFB).withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            wilaya['code']!,
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            wilaya['name']!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Wilaya name overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  wilaya['name']!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainCities = [
      {'name': 'Alger', 'image': 'assets/wilayas/alger.png'},
      {'name': 'Oran', 'image': 'assets/wilayas/oran.png'},
      {'name': 'Constantine', 'image': 'assets/wilayas/constantine.png'},
      {'name': 'Sétif', 'image': 'assets/wilayas/setif.png'},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Browse by destination',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 14),
        
        // Main cities row with arrow
        Row(
          children: [
            Expanded(
              child: SizedBox(
          height: 210,
          child: ListView.separated(
                  controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: mainCities.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
                    final city = mainCities[index];
                    return GestureDetector(
                      onTap: () {
                        widget.onDestinationSelected?.call(city['name']!);
                      },
                      child: Container(
                width: 140,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                  children: [
                              // Full image background
                              Positioned.fill(
                      child: Image.asset(
                        city['image']!,
                        fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            const Color(0xFF593CFB).withValues(alpha: 0.3),
                                            const Color(0xFF593CFB).withValues(alpha: 0.7),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          city['name']!,
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              
                              // City name overlay at bottom
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    city['name']!,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Arrow button to show all wilayas
            if (_showArrow)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showArrow ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () => _showAllWilayasModal(context),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              Container(
                width: 60,
                height: 4,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF593CFB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF593CFB).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
