import 'dart:convert';
import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:flutter_app/core/services/response/api_responses.dart';
import 'package:flutter_app/models/Reservation.dart';
import 'package:flutter_app/models/Sport.dart';
import 'package:flutter_app/models/SportFacility.dart';
import 'package:http/http.dart' as http;

const RESERVATION_URL = "$API_URL/api/reservation";

class ReservationResponseInit {
  final List<Sport> sports;
  final Sport defaultSport;
  final List<SportFacility> sportFacilities;

  ReservationResponseInit({
    required this.sports,
    required this.defaultSport,
    required this.sportFacilities,
  });

  factory ReservationResponseInit.fromJson(Map<String, dynamic> json) {
    return ReservationResponseInit(
      sports: List<Sport>.from(json['sports'].map((x) => Sport.fromJson(x))),
      defaultSport: Sport.fromJson(json['defaultSport']),
      sportFacilities: List<SportFacility>.from(
          json['sportFacilites'].map((x) => SportFacility.fromJson(x))),
    );
  }
}

Future<ReservationResponseInit> fetchInitReservation() async {
  print("Calling Fetch Sport Facilities");
  final url = Uri.parse("$RESERVATION_URL/init");
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return ReservationResponseInit.fromJson(data);
  }
  throw Exception("Failed to fetch sport facilities");
}

Future<ReservationResponse> saveReservation(Reservation reservation, token) async {
  try {
    final url = Uri.parse("$RESERVATION_URL");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'time_slot_id': reservation.timeSlot?.id,
        'is_match': reservation.game != null ? true : false,
        'match_type': reservation.game?.matchTypeAsString,
        'auto_confirm': reservation.autoConfirm,
        'team1_id': reservation.game?.team1.id,
        'team2_id': reservation.game?.opponentTeam?.id,
      }),
    );
    final data = jsonDecode(response.body);
    return ReservationResponse.fromJson(data);
  } catch (e) {
    return ReservationResponse(
      success: false,
      message: 'Failed to parse response',
    );
  }
}

