import 'dart:convert';
import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:flutter_app/models/SportFacility.dart';
import 'package:http/http.dart' as http;

const FACILITY_URL = "$API_URL/api/sport-facilities";

Future<List<SportFacility>> fetchSportFacilityBySport(int id) async {
  print("Fetching Sport Facility by Sport ID: $id");
  final url = Uri.parse("$FACILITY_URL?sport_id=$id");
  print(url);
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return (data['sportFacilites'] as List)
        .map((item) => SportFacility.fromJson(item))
        .toList();
  }
  throw Exception("Failed to fetch sport facilities: ${response.statusCode}");
}

void main() async {
  final facilities = await fetchSportFacilityBySport(4);
  print(facilities);
}

