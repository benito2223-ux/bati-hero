import 'package:uuid/uuid.dart';

class ChantierEvent {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String? description;
  final int? dryingMinutes;
  final String? googleEventId;

  ChantierEvent({
    String? id,
    required this.title,
    required this.start,
    required this.end,
    this.description,
    this.dryingMinutes,
    this.googleEventId,
  }) : id = id ?? const Uuid().v4();

  bool get hasDryingTime => dryingMinutes != null && dryingMinutes! > 0;

  Duration get dryingDuration =>
      Duration(minutes: dryingMinutes ?? 0);

  ChantierEvent copyWith({
    String? title,
    DateTime? start,
    DateTime? end,
    String? description,
    int? dryingMinutes,
    String? googleEventId,
  }) {
    return ChantierEvent(
      id: id,
      title: title ?? this.title,
      start: start ?? this.start,
      end: end ?? this.end,
      description: description ?? this.description,
      dryingMinutes: dryingMinutes ?? this.dryingMinutes,
      googleEventId: googleEventId ?? this.googleEventId,
    );
  }
}
