class BlockedCell {
  final int r;
  final int c;

  BlockedCell({required this.r, required this.c});

  factory BlockedCell.fromJson(Map<String, dynamic> json) {
    return BlockedCell(
      r: json['r'] as int,
      c: json['c'] as int,
    );
  }

  Map<String, dynamic> toJson() => {'r': r, 'c': c};
}
