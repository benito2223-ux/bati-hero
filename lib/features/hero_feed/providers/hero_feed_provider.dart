import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hero_post.dart';

class HeroFeedNotifier extends StateNotifier<List<HeroPost>> {
  HeroFeedNotifier() : super([]);

  void addPost(HeroPost post) => state = [post, ...state];

  void removePost(String id) => state = state.where((p) => p.id != id).toList();

  void addAnnotation(String postId, BubbleAnnotation annotation) {
    state = state.map((p) {
      if (p.id != postId) return p;
      return p.copyWith(annotations: [...p.annotations, annotation]);
    }).toList();
  }

  List<HeroPost> filtered(PostType? type) {
    if (type == null) return state;
    return state.where((p) => p.type == type).toList();
  }
}

final heroFeedProvider =
    StateNotifierProvider<HeroFeedNotifier, List<HeroPost>>(
  (_) => HeroFeedNotifier(),
);

final heroFilterProvider = StateProvider<PostType?>((ref) => null);
