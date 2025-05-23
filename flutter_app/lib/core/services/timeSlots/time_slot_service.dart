import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:flutter_app/models/TimeSlot.dart';
import 'package:flutter_app/models/TimeZone.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


const TIME_SLOT_URL = "$API_URL/api/sport-facilities";

class TimeSlotResponse {
  final List<DateTime> dates;
  final List<TimeSlot> timeSlots;
  final List<TimeZone> timeZones;

  TimeSlotResponse({
    required this.dates,
    required this.timeSlots,
    required this.timeZones,
  });

  factory TimeSlotResponse.fromJson(Map<String, dynamic> json) {
    return TimeSlotResponse(
      dates: List<DateTime>.from(json['dates'].map((date) => DateTime.parse(date))),
      timeSlots: (json['time_slots'] as List)
          .map((slot) => TimeSlot.fromJson(slot))
          .toList(),
      timeZones: (json['time_zones'] as List)
          .map((zone) => TimeZone.fromJson(zone))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dates': dates,
      'time_slots': timeSlots.map((slot) => slot.toJson()).toList(),
      'time_zones': timeZones.map((zone) => zone.toJson()).toList(),
    };
  }
}

Future<TimeSlotResponse> fetchInitTimeSlots(int facilityId) async {
  print("Calling Fetch  time slots of Sport Facilities");
  final url = Uri.parse("$TIME_SLOT_URL/$facilityId/init-time-slots");
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return TimeSlotResponse.fromJson(data);
  }
  throw Exception("Failed to fetch sport facilities");
}


Future<List<TimeSlot>> fetchTimeSlots(int facilityId, DateTime date) async {
  print("Calling Fetch  time slots of Sport Facilities");
  final url = Uri.parse("$TIME_SLOT_URL/$facilityId/available-time-slots?date=${date.toIso8601String()}");
  
 final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print(data);
     return (data['time_slots'] as List)
        .map((item) => TimeSlot.fromJson(item))
        .toList();
  }
  throw Exception("Failed to fetch  time slots of sport facilities");
}

void main() async {
  final timeSlots = await fetchTimeSlots(1, DateTime(2025, 5, 23));
  print(timeSlots.length);
}


