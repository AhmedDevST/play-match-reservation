import 'user.dart';

class TeamPlayer {
  final User user;
  final bool isCaptain;

  TeamPlayer({
    required this.user,
    this.isCaptain = false,
  });

  factory TeamPlayer.fromJson(Map<String, dynamic> json) {
    return TeamPlayer(
      user: User.fromJson(json['user']),
       isCaptain: json['is_captain'] == 1 ,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'is_captain': isCaptain,
    };
  }
}
