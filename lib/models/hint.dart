import 'position.dart'; // Position class with r,c

class Hint {
  final String type;
  final List<Position>? path;

  Hint({
    required this.type,
    this.path,
  });

  factory Hint.fromJson(Map<String, dynamic> json) {
    return Hint(
      type: json['type'] as String,
      path: (json['path'] as List<dynamic>?)
          ?.map((e) => Position.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (path != null)
        'path': path!.map((p) => p.toJson()).toList(),
    };
  }
}
