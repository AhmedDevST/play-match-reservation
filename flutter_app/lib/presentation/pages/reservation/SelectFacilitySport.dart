import 'package:flutter/material.dart';
import 'package:flutter_app/core/services/reservation/reservation_service.dart';
import 'package:flutter_app/core/services/facility/facility_service.dart';
import 'package:flutter_app/models/Sport.dart';
import 'package:flutter_app/models/Reservation.dart';
import 'package:flutter_app/models/SportFacility.dart';
import 'package:flutter_app/presentation/widgets/SportFacility/SportFacilityCard.dart';
import 'package:flutter_app/presentation/widgets/SportFacility/sport_filter_chip.dart';
import 'package:flutter_app/presentation/widgets/common/loading_content.dart';
import 'SelectTimeSlot.dart';
import 'package:flutter_app/presentation/pages/SportFacility/FacilityDetailsPage.dart';

class SelectFacilitySport extends StatefulWidget {
  const SelectFacilitySport({super.key});

  @override
  State<SelectFacilitySport> createState() => _SelectFacilitySportState();
}

class _SelectFacilitySportState extends State<SelectFacilitySport>
    with SingleTickerProviderStateMixin {
  late List<Sport> sports;
  late List<SportFacility> sportFacilities;
  late Sport selectedSport;
  bool isInitialLoading = false; // For initial page load
  bool isFacilityLoading = false; // For facility list filtering

  // Animation controller for smooth transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuad,
    ));

    initReservation();
    _animationController.forward();
  }

  Future<void> initReservation() async {
    setState(() {
      isInitialLoading = true;
    });

    try {
      final loadedReservationData = await fetchInitReservation();
      setState(() {
        isInitialLoading = false;
        sports = loadedReservationData.sports;
        sportFacilities = loadedReservationData.sportFacilities;
        selectedSport = loadedReservationData.defaultSport;
      });
    } catch (e) {
      setState(() {
        isInitialLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching data: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> loadSportFacilityBySport(int id) async {
    setState(() {
      isFacilityLoading = true;
    });

    try {
      List<SportFacility> loadedSportFacilityData =
          await fetchSportFacilityBySport(id);
      setState(() {
        isFacilityLoading = false;
        sportFacilities = loadedSportFacilityData;
      });
    } catch (e) {
      setState(() {
        isFacilityLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching facilities: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleFacilitySelection(SportFacility selectedFacility) {
    final newReservation = Reservation.init(
      userId: 1,
      facility: selectedFacility,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectTimeSlot(reservation: newReservation),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header - Always visible
            _buildHeader(),

            // Content with loading states
            Expanded(
              child: isInitialLoading
                  ? const LoadingContent()
                  : Column(
                      children: [
                        // Sport Selection Section
                        _buildSportSelectionSection(),

                        // Facilities List with separate loading
                        _buildFacilitiesList(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialLoadingContent() {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          // Lottie animation or loading indicator
          Container(
            width: 120,
            height: 120,
            child: const LoadingContent(
              lottieUrl:
                  "https://lottie.host/53de5d49-207d-4767-af25-9f20f6fb6415/uDd2URAR0g.json",
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Chargement des installations...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Veuillez patienter',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Color(0xFF1E88E5),
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Installations sportives',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Text(
                'Choisissez votre terrain de sport',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSportSelectionSection() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E88E5).withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.sports,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choisir un sport',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Sélectionnez votre sport préféré',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: sports.map((Sport sport) {
                      return _buildModernSportChip(sport);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernSportChip(Sport sport) {
    final isSelected = selectedSport.id == sport.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSport = sport;
          loadSportFacilityBySport(sport.id);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Text(
          sport.name,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1E88E5) : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFacilitiesList() {
    return Expanded(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Terrains disponibles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2EE59D).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              if (isFacilityLoading) ...[
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF2EE59D)),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                isFacilityLoading
                                    ? 'Recherche...'
                                    : '${sportFacilities.length} terrains',
                                style: const TextStyle(
                                  color: Color(0xFF2EE59D),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: isFacilityLoading
                          ? const LoadingContent()
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: sportFacilities.length,
                              itemBuilder: (context, index) {
                                return AnimatedContainer(
                                  duration: Duration(
                                      milliseconds: 200 + (index * 50)),
                                  child: SportFacilityCard(
                                    facility: sportFacilities[index],
                                    onTap: () {
                                      // Handle card tap (navigate to details)
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FacilityDetailsPage(
                                            sportFacility:
                                                sportFacilities[index],
                                          ),
                                        ),
                                      );
                                    },
                                    onSelect: () => _handleFacilitySelection(
                                        sportFacilities[index]),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
