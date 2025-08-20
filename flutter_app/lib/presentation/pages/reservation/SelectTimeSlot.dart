import 'package:flutter/material.dart';
import 'package:flutter_app/models/Reservation.dart';
import 'package:flutter_app/models/TimeSlot.dart';
import 'package:flutter_app/models/TimeZone.dart';
import 'package:flutter_app/core/services/timeSlots/time_slot_service.dart';
import 'package:flutter_app/presentation/pages/match/create_match.dart';
import 'package:flutter_app/presentation/pages/reservation/BookingSummary.dart';
import 'package:flutter_app/presentation/widgets/SelectTimeSlot/date_selector.dart';
import 'package:flutter_app/presentation/widgets/SelectTimeSlot/timezone_selector.dart';
import 'package:flutter_app/presentation/widgets/SelectTimeSlot/slot_filter.dart';
import 'package:flutter_app/presentation/widgets/SelectTimeSlot/time_slot_list.dart';
import 'package:flutter_app/presentation/widgets/SelectTimeSlot/select_button.dart';
import 'package:flutter_app/presentation/widgets/common/loading_content.dart';
import 'package:flutter_app/presentation/widgets/dialog/CreateMatchDialog.dart';

class SelectTimeSlot extends StatefulWidget {
  final Reservation reservation;

  const SelectTimeSlot({
    Key? key,
    required this.reservation,
  }) : super(key: key);

  @override
  State<SelectTimeSlot> createState() => _SelectTimeSlotState();
}

class _SelectTimeSlotState extends State<SelectTimeSlot>
    with SingleTickerProviderStateMixin {
  int selectedDateIndex = 0;
  late TimeZone selectedTimeZone;
  TimeSlot? selectedTimeSlot;
  bool isInitialLoading = false; // For initial page load
  bool isSlotsLoading = false;
  late List<TimeZone> timeZones;
  late List<TimeSlot> timeSlots;
  late List<DateTime> customDates;
  String slotFilter = 'available';

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
      duration: const Duration(milliseconds: 1000),
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
      curve: Curves.easeOutCubic,
    ));

    initTimeSlots();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> initTimeSlots() async {
    try {
      setState(() => isInitialLoading = true);
      final loadedTimeSlots =
          await fetchInitTimeSlots(widget.reservation.facility.id);

      setState(() {
        timeSlots = loadedTimeSlots.timeSlots;
        timeZones = loadedTimeSlots.timeZones;
        customDates = loadedTimeSlots.dates;
        selectedTimeZone = timeZones.first;
        isInitialLoading = false;
      });
    } catch (e) {
      setState(() => isInitialLoading = false);
      print("Error loading time slots: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load time slots"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> loadTimeSlots() async {
    try {
      if (customDates.isEmpty) return;
      setState(() => isSlotsLoading = true);
      List<TimeSlot> loadedTimeSlots = await fetchTimeSlots(
          widget.reservation.facility.id, customDates[selectedDateIndex]);
      setState(() {
        isSlotsLoading = false;
        timeSlots = loadedTimeSlots;
        selectedTimeSlot = null; // Reset selected time slot on date change
      });
   } catch (e) {
      setState(() => isSlotsLoading = false);
      print("Error loading time slots: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load time slots"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _onDateSelected(int index) {
    if (index < customDates.length) {
      setState(() => selectedDateIndex = index);
      loadTimeSlots();
    }
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
      widget.reservation.timeSlot = selectedTimeSlot;
      widget.reservation.game = null;

      final result = await showDialog<bool>(
        context: context,
        builder: (context) => const CreateMatchDialog(),
      );

      if (result == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateMatch(reservation: widget.reservation),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BookingSummaryScreen(reservation: widget.reservation),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.reservation.facility.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isInitialLoading
          ? const LoadingContent()
          : RefreshIndicator(
              onRefresh: initTimeSlots,
              color: const Color(0xFF1E88E5),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header section
                            _buildHeaderSection(),
                            const SizedBox(height: 25),

                            // Date selector card
                            _buildAnimatedCard(
                              child: DateSelector(
                                      dates: customDates,
                                      selectedIndex: selectedDateIndex,
                                      onDateSelected: _onDateSelected,
                                    ),
                            ),
                            const SizedBox(height: 20),

                            // Timezone selector card
                            _buildAnimatedCard(
                              child: TimeZoneSelector(
                                      timeZones: timeZones,
                                      selectedTimeZone: selectedTimeZone,
                                      onTimeZoneSelected: _onTimeZoneSelected,
                                    ),
                            ),
                            const SizedBox(height: 20),

                            // Slot filter card
                            _buildAnimatedCard(
                              child:SlotFilter(
                                      selectedTimeZone: selectedTimeZone,
                                      slotFilter: slotFilter,
                                      onFilterChanged: _onSlotFilterChanged,
                                    ),
                            ),
                            const SizedBox(height: 20),

                            // Time slots list card
                            _buildAnimatedCard(
                              height: 400,
                              child: isSlotsLoading
                                  ? const LoadingContent()
                                  : TimeSlotsList(
                                      timeSlots: timeSlots,
                                      selectedTimeZone: selectedTimeZone,
                                      slotFilter: slotFilter,
                                      selectedTimeSlot: selectedTimeSlot,
                                      onTimeSlotSelected: _onTimeSlotSelected,
                                    ),
                            ),
                            const SizedBox(height: 30),

                            // Select button
                            SelectButton(
                              isEnabled: selectedTimeSlot != null,
                              onPressed: _onSelectPressed,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Your Time Slot',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Choose the perfect time for your booking',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard({required Widget child, double? height}) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
