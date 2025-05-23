

import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app/models/Team.dart';


const GAME_URL = "$API_URL/api/sport-facilities";



Future<List<Team>> initGame(int facilityId) async {
  print("Calling Fetch  ");
  final url = Uri.parse("$GAME_URL/$facilityId/init-game");
 final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
     return (data['user_teams'] as List)
        .map((item) => Team.fromJson(item))
        .toList();
  }
  throw Exception("Failed to fetch");
}

