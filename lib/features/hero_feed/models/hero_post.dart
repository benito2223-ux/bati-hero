import 'package:uuid/uuid.dart';

enum PostType { before, after, progress }

class BubbleAnnotation {
  final String text;
  final double x;
  final double y;

  const BubbleAnnotation({
    required this.text,
    required this.x,
    required this.y,
  });
}

class HeroPost {
  final String id;
  final String imagePath;
  final String caption;
  final PostType type;
  final DateTime date;
  final List<BubbleAnnotation> annotations;

  HeroPost({
    String? id,
    required this.imagePath,
    required this.caption,
    required this.type,
    DateTime? date,
    List<BubbleAnnotation>? annotations,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now(),
        annotations = annotations ?? [];

  HeroPost copyWith({
    String? imagePath,
    String? caption,
    PostType? type,
    List<BubbleAnnotation>? annotations,
  }) {
    return HeroPost(
      id: id,
      imagePath: imagePath ?? this.imagePath,
      caption: caption ?? this.caption,
      type: type ?? this.type,
      date: date,
      annotations: annotations ?? this.annotations,
    );
  }
}
