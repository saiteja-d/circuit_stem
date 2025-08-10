class Position {
  final int r;
  final int c;

  Position({required this.r, required this.c});

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      r: json['r'] as int,
      c: json['c'] as int,
    );
  }

  Map<String, dynamic> toJson() => {'r': r, 'c': c};
}
