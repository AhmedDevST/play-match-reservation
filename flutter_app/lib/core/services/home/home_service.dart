import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:flutter_app/core/services/response/HomeResponse.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const HOME_URL = "$API_URL/api/home";


Future<HomeResponse> loadHome(String token, {int publicMatchLimit = 4}) async {
  print("Calling Fetch");
  final url = Uri.parse(HOME_URL).replace(
    queryParameters: {
      'public_match_limit': publicMatchLimit.toString(),
    },
  );
  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return HomeResponse.fromJson(data);
  }
  throw Exception("Failed to fetch");
}

void main() async {
  final response =
      await loadHome("49|JDr6iU1oVEZilaR86fjoLqdB69DtUECoc1lKdainec1dbc70");
  if (response.success) {
    for (var game in response.publicGames!) {
      print(game.timeSlot.startTime);
      print(game.facility.name);
      print(game.invitation?.id);
    }
  }
}
