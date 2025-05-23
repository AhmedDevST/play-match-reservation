class TimeZone {
  final int id;
  final String name;
  final String startTime;
  final String endTime;

  TimeZone({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
  });

  factory TimeZone.fromJson(Map<String, dynamic> json) {
    return TimeZone(
      id: json['id'],
      name: json['name'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'start_time': startTime,
      'end_time': endTime,
    };
  } 
}
