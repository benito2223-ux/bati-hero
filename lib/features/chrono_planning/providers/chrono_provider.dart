import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chantier_event.dart';

class ChronoNotifier extends StateNotifier<List<ChantierEvent>> {
  ChronoNotifier() : super(_demo);

  static final _now = DateTime.now();
  static final _demo = [
    ChantierEvent(
      title: 'Pose carrelage salle de bain',
      start: DateTime(_now.year, _now.month, _now.day + 1, 8),
      end: DateTime(_now.year, _now.month, _now.day + 1, 18),
      description: 'Commencer par le centre, poser les croisillons',
      dryingMinutes: 1440,
    ),
    ChantierEvent(
      title: 'Peinture plafond couloir',
      start: DateTime(_now.year, _now.month, _now.day + 3, 9),
      end: DateTime(_now.year, _now.month, _now.day + 3, 14),
      description: '2 couches, laisser sécher 4h entre les couches',
      dryingMinutes: 240,
    ),
    ChantierEvent(
      title: 'Livraison parquet flottant',
      start: DateTime(_now.year, _now.month, _now.day + 5, 10),
      end: DateTime(_now.year, _now.month, _now.day + 5, 12),
      description: 'Laisser le parquet s\'acclimater 48h avant pose',
      dryingMinutes: 2880,
    ),
  ];

  void addEvent(ChantierEvent event) => state = [...state, event];

  void removeEvent(String id) => state = state.where((e) => e.id != id).toList();

  void updateEvent(ChantierEvent updated) {
    state = state.map((e) => e.id == updated.id ? updated : e).toList();
  }

  List<ChantierEvent> get upcoming {
    final now = DateTime.now();
    return (state..sort((a, b) => a.start.compareTo(b.start)))
        .where((e) => e.end.isAfter(now))
        .toList();
  }

  List<ChantierEvent> eventsForDay(DateTime day) {
    return state.where((e) {
      final d = DateTime(day.year, day.month, day.day);
      final eDay = DateTime(e.start.year, e.start.month, e.start.day);
      return d == eDay;
    }).toList();
  }
}

final chronoProvider =
    StateNotifierProvider<ChronoNotifier, List<ChantierEvent>>(
  (_) => ChronoNotifier(),
);
