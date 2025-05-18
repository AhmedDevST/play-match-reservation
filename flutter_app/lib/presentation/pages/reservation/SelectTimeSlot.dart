import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectTimeSlot extends StatefulWidget {
  final String facilityName;
  final String price;

  const SelectTimeSlot({
    Key? key,
    required this.facilityName,
    required this.price,
  }) : super(key: key);

  @override
  State<SelectTimeSlot> createState() => _SelectTimeSlotState();
}

class _SelectTimeSlotState extends State<SelectTimeSlot> {
  int selectedDateIndex = 0;
  int selectedSlotType = 2; // 0: Morning, 1: Afternoon, 2: Evening, 3: Night
  int? selectedTimeSlotIndex;

  List<DateTime> weekDates = List.generate(7, (i) => DateTime(2024, 12, 20 + i));
  final List<String> slotTypes = ['Morning', 'Afternoon', 'Evening', 'Night'];
  final Map<String, List<Map<String, dynamic>>> slots = {
    'Morning': [
      {'time': '7.00 Am - 8.00 Am', 'available': true},
      {'time': '8.00 Am - 9.00 Am', 'available': false},
    ],
    'Afternoon': [
      {'time': '12.00 Pm - 1.00 Pm', 'available': true},
      {'time': '1.00 Pm - 2.00 Pm', 'available': true},
    ],
    'Evening': [
      {'time': '4.00 Pm - 5.00 Pm', 'available': true},
      {'time': '5.00 Pm - 6.00 Pm', 'available': true},
      {'time': '6.00 Pm - 7.00 Pm', 'available': true},
      {'time': '7.00 Pm - 8.00 Pm', 'available': false},
    ],
    'Night': [
      {'time': '9.00 Pm - 10.00 Pm', 'available': true},
      {'time': '10.00 Pm - 11.00 Pm', 'available': false},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final slotType = slotTypes[selectedSlotType];
    final slotList = slots[slotType]!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a slot'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: weekDates.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final date = weekDates[i];
                        final isSelected = i == selectedDateIndex;
                        return GestureDetector(
                          onTap: () => setState(() => selectedDateIndex = i),
                          child: Container(
                            width: 56,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat('E').format(date).toUpperCase(),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  date.day.toString(),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.blue),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: weekDates[selectedDateIndex],
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        final startOfWeek = picked.subtract(Duration(days: picked.weekday - 1));
                        setState(() {
                          weekDates = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
                          selectedDateIndex = picked.difference(startOfWeek).inDays;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Select slots', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(slotTypes.length, (i) {
                final isSelected = i == selectedSlotType;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: OutlinedButton(
                      onPressed: () => setState(() {
                        selectedSlotType = i;
                        selectedTimeSlotIndex = null;
                      }),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected ? Colors.blue : Colors.white,
                        side: BorderSide(color: isSelected ? Colors.blue : Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        slotTypes[i],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Text(
              '${slotType} slots',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...List.generate(slotList.length, (i) {
              final slot = slotList[i];
              final isBooked = !slot['available'];
              final isSelected = selectedTimeSlotIndex == i;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: isBooked
                      ? null
                      : () => setState(() => selectedTimeSlotIndex = i),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isBooked
                          ? Colors.grey.shade200
                          : isSelected
                              ? Colors.blue
                              : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isBooked
                            ? Colors.grey.shade300
                            : isSelected
                                ? Colors.blue
                                : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        slot['time'],
                        style: TextStyle(
                          color: isBooked
                              ? Colors.grey
                              : isSelected
                                  ? Colors.white
                                  : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Price ${widget.price}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedTimeSlotIndex != null ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Book now', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 