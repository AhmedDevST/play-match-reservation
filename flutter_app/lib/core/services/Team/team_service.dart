

import 'package:flutter_app/core/config/apiConfig.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app/models/Team.dart';


const TEAMS_URL = "$API_URL/api/teams";


Future<List<Team>> fetchTeamsByNameAndSport(String name,int IdSport, int excludeTeamId) async {
  print("Calling Fetch  team ");
  final url = Uri.parse("$TEAMS_URL/search?name=$name&sport=$IdSport&exclude=$excludeTeamId");
 final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
     return (data['teams'] as List)
        .map((item) => Team.fromJson(item))
        .toList();
  }
  throw Exception("Failed to fetch");
}
void main() async {
  final teams = await fetchTeamsByNameAndSport("tea",2,1);
  print(teams.length);
}
