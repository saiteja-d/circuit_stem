class Goal {
  final String type;
  final String? targetId;
  final String? from;
  final String? to;

  Goal({
    required this.type,
    this.targetId,
    this.from,
    this.to,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      type: json['type'] as String,
      targetId: json['targetId'] as String?,
      from: json['from'] as String?,
      to: json['to'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (targetId != null) 'targetId': targetId,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    };
  }
}

