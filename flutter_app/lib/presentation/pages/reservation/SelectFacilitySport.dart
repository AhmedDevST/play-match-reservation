import 'package:flutter/material.dart';
import 'package:flutter_app/core/services/reservation/reservation_service.dart';
import 'package:flutter_app/core/services/facility/facility_service.dart';
import 'package:flutter_app/models/Sport.dart';
import 'package:flutter_app/models/Reservation.dart';
import 'package:flutter_app/models/SportFacility.dart';
import 'package:flutter_app/presentation/widgets/SportFacility/SportFacilityCard.dart';
import 'package:flutter_app/presentation/widgets/SportFacility/sport_filter_chip.dart';
import 'SelectTimeSlot.dart';
import 'package:flutter_app/presentation/pages/SportFacility/FacilityDetailsPage.dart';

class SelectFacilitySport extends StatefulWidget {
  const SelectFacilitySport({Key? key}) : super(key: key);

  @override
  State<SelectFacilitySport> createState() => _SelectFacilitySportState();
}

class _SelectFacilitySportState extends State<SelectFacilitySport> {
  late List<Sport> sports;
  late List<SportFacility> sportFacilities;
  late Sport selectedSport;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    initReservation();
  }

  Future<void> initReservation() async {
    isLoading = true;
    final loadedReservationData = await fetchInitReservation();
    setState(() {
      isLoading = false;
      sports = loadedReservationData.sports;
      sportFacilities = loadedReservationData.sportFacilities;
      selectedSport = loadedReservationData.defaultSport;
    });
  }

  Future<void> loadSportFacilityBySport(int id) async {
    isLoading = true;
    List<SportFacility> loadedSportFacilityData =
        await fetchSportFacilityBySport(id);
    setState(() {
      isLoading = false;
      sportFacilities = loadedSportFacilityData;
    });
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sports Facilities',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Sport',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: sports.map((Sport sport) {
                            return SportFilterChip(
                              label: sport.name,
                              isSelected: selectedSport.id == sport.id,
                              onSelected: (bool selected) {
                                setState(() {
                                  selectedSport = sport;
                                  loadSportFacilityBySport(sport.id);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sportFacilities.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SportFacilityCard(
                          sportFacility: sportFacilities[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FacilityDetailsPage(
                                  sportFacility: sportFacilities[index],
                                ),
                              ),
                            );
                          },
                          onSelectTap: () {
                            _handleFacilitySelection(sportFacilities[index]);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
