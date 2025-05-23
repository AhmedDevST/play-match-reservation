import 'package:flutter/material.dart';
import 'package:flutter_app/models/SportFacility.dart';
import 'package:flutter_app/models/TimeSlot.dart';
import 'package:flutter_app/models/TimeZone.dart';
import 'package:flutter_app/core/services/timeSlots/time_slot_service.dart';
import 'package:flutter_app/presentation/pages/match/create_match.dart';
import 'package:flutter_app/presentation/widgets/SelectTimeSlot/date_selector.dart';
import 'package:flutter_app/presentation/widgets/SelectTimeSlot/timezone_selector.dart';
import 'package:flutter_app/presentation/widgets/SelectTimeSlot/slot_filter.dart';
import 'package:flutter_app/presentation/widgets/SelectTimeSlot/time_slot_list.dart';
import 'package:flutter_app/presentation/widgets/SelectTimeSlot/select_button.dart';
import 'package:flutter_app/presentation/widgets/match/CreateMatchDialog.dart';

class SelectTimeSlot extends StatefulWidget {
  final SportFacility facility;

  const SelectTimeSlot({
    super.key,
    required this.facility,
  });

  @override
  State<SelectTimeSlot> createState() => _SelectTimeSlotState();
}

class _SelectTimeSlotState extends State<SelectTimeSlot> {
  int selectedDateIndex = 0;
  late TimeZone selectedTimeZone;
  TimeSlot? selectedTimeSlot;
  bool isLoading = false;
  late List<TimeZone> timeZones;
  late List<TimeSlot> timeSlots;
  late List<DateTime> customDates;

  String slotFilter = 'available';

  @override
  void initState() {
    super.initState();
    initTimeSlots();
  }

  Future<void> initTimeSlots() async {
    setState(() => isLoading = true);
    final loadedTimeSlots = await fetchInitTimeSlots(widget.facility.id);
    setState(() {
      isLoading = false;
      timeSlots = loadedTimeSlots.timeSlots;
      timeZones = loadedTimeSlots.timeZones;
      customDates = loadedTimeSlots.dates;
      selectedTimeZone = timeZones.first;
    });
  }

  Future<void> loadTimeSlots() async {
    setState(() => isLoading = true);
    List<TimeSlot> loadedTimeSlots = await fetchTimeSlots(
        widget.facility.id, customDates[selectedDateIndex]);
    setState(() {
      isLoading = false;
      timeSlots = loadedTimeSlots;
    });
  }

  void _onDateSelected(int index) {
    setState(() => selectedDateIndex = index);
    loadTimeSlots();
  }

  void _onTimeZoneSelected(TimeZone timeZone) {
    setState(() {
      selectedTimeZone = timeZone;
      selectedTimeSlot = null;
    });
  }

  void _onSlotFilterChanged(String filter) {
    setState(() => slotFilter = filter);
  }

  void _onTimeSlotSelected(TimeSlot timeSlot) {
    setState(() => selectedTimeSlot = timeSlot);
  }

  void _onSelectPressed() async {
    if (selectedTimeSlot != null) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => const CreateMatchDialog(),
      );

      if (result == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateMatch(facility: widget.facility),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.facility.name,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: initTimeSlots,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DateSelector(
                        dates: customDates,
                        selectedIndex: selectedDateIndex,
                        onDateSelected: _onDateSelected,
                      ),
                      const SizedBox(height: 20),
                      TimeZoneSelector(
                        timeZones: timeZones,
                        selectedTimeZone: selectedTimeZone,
                        onTimeZoneSelected: _onTimeZoneSelected,
                      ),
                      const SizedBox(height: 20),
                      SlotFilter(
                        selectedTimeZone: selectedTimeZone,
                        slotFilter: slotFilter,
                        onFilterChanged: _onSlotFilterChanged,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TimeSlotsList(
                          timeSlots: timeSlots,
                          selectedTimeZone: selectedTimeZone,
                          slotFilter: slotFilter,
                          selectedTimeSlot: selectedTimeSlot,
                          onTimeSlotSelected: _onTimeSlotSelected,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SelectButton(
                        isEnabled: selectedTimeSlot != null,
                        onPressed: _onSelectPressed,
                      ),
                    ]),
              ),
            ),
    );
  }
}
