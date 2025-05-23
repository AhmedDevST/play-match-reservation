class Game {
  final int id;


  Game({
    required this.id,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
    );
  }

}
