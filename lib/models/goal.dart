class Goal {
  final String type;
  final String? targetId;
  final String? from;
  final String? to;
  final int? r;  // row position
  final int? c;  // column position

  Goal({
    required this.type,
    this.targetId,
    this.from,
    this.to,
    this.r,
    this.c,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      type: json['type'] as String,
      targetId: json['targetId'] as String?,
      from: json['from'] as String?,
      to: json['to'] as String?,
      r: json['r'] != null ? json['r'] as int : null,
      c: json['c'] != null ? json['c'] as int : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (targetId != null) 'targetId': targetId,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (r != null) 'r': r,
      if (c != null) 'c': c,
    };
  }
}
