import 'dart:convert';
import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:flutter_app/models/Sport.dart';
import 'package:flutter_app/models/SportFacility.dart';
import 'package:http/http.dart' as http;

const RESERVATION_URL = "$API_URL/api/reservation";

class ReservationResponse {
  final List<Sport> sports;
  final Sport defaultSport;
  final List<SportFacility> sportFacilities;

  ReservationResponse({
    required this.sports,
    required this.defaultSport,
    required this.sportFacilities,
  });

  factory ReservationResponse.fromJson(Map<String, dynamic> json) {
    return ReservationResponse(
      sports: List<Sport>.from(json['sports'].map((x) => Sport.fromJson(x))),
      defaultSport: Sport.fromJson(json['defaultSport']),
      sportFacilities: List<SportFacility>.from(
          json['sportFacilites'].map((x) => SportFacility.fromJson(x))),
    );
  }
}


Future<ReservationResponse> fetchInitReservation() async {
  print("Calling Fetch Sport Facilities");
  final url = Uri.parse("$RESERVATION_URL/init");
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return ReservationResponse.fromJson(data);
  }
  throw Exception("Failed to fetch sport facilities");
}

