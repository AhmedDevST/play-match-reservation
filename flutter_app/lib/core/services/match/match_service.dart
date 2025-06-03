import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app/models/Team.dart';
import 'package:flutter_app/models/Game.dart';
import 'package:flutter_app/models/Sport.dart';
import 'package:flutter_app/models/SportFacility.dart';
import 'package:flutter_app/models/TimeSlot.dart';

const GAME_FACILITY_URL = "$API_URL/api/sport-facilities";
const GAME_URL = "$API_URL/api/games";

class GameResponse {
  final Game game;
  final TimeSlot timeSlot;
  final SportFacility facility;

  GameResponse({
    required this.game,
    required this.timeSlot,
    required this.facility,
  });

  factory GameResponse.fromJson(Map<String, dynamic> json) {
    return GameResponse(
      game: Game.fromJson(json['game']),
      timeSlot: TimeSlot.fromJson(json['time_slot']),
      facility: SportFacility.fromJson(json['facility']),
    );
  }
}

Future<List<Team>> initGame(int facilityId, token) async {
  print("Calling Fetch  ");
  final url = Uri.parse("$GAME_FACILITY_URL/$facilityId/init-game");
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
    return (data['user_teams'] as List)
        .map((item) => Team.fromJson(item))
        .toList();
  }
  throw Exception("Failed to fetch");
}

Future<GameResponse> fetchGame(int id) async {
  print("Calling Fetch Game");
  final url = Uri.parse("$GAME_URL/$id");
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return GameResponse.fromJson(data);
  }
  throw Exception("Failed to fetch sport facilities");
}

void main() async {
  final game = await fetchGame(15);
  print(game.game.id);
  print(game.timeSlot.startTime);
  print(game.facility.name);
}
