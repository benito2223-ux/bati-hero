import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project.dart';
import '../../../shared/services/local_storage_service.dart';
import '../../../shared/services/firestore_service.dart';
import '../../auth/providers/auth_provider.dart';

class ProjectsNotifier extends StateNotifier<List<Project>> {
  final String? _uid;
  StreamSubscription<List<Project>>? _sub;

  ProjectsNotifier(this._uid) : super(_loadLocal()) {
    if (_uid != null) unawaited(_subscribeFirestore());
  }

  static List<Project> _loadLocal() {
    final saved = LocalStorageService.loadJsonList(LocalStorageService.kProjects);
    if (saved.isNotEmpty) {
      try { return saved.map(Project.fromJson).toList(); } catch (_) {}
    }
    final demo = Project(id: 'demo', name: 'Mon premier chantier', emoji: '🏠', color: const Color(0xFFFF00FF));
    return [demo];
  }

  void _saveLocal(List<Project> projects) {
    LocalStorageService.saveJsonList(
      LocalStorageService.kProjects,
      projects.map((p) => p.toJson()).toList(),
    );
  }

  Future<void> _subscribeFirestore() async {
    // Migration locale → Firestore au premier login
    final hasData = await FirestoreService.hasAnyData(_uid!);
    if (!hasData && state.isNotEmpty) {
      await FirestoreService.migrateProjects(_uid!, state);
    }
    _sub = FirestoreService.projectsStream(_uid!).listen((projects) {
      state = projects;
      _saveLocal(projects);
    });
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }

  void _persistLocal() => _saveLocal(state);

  void addProject(Project project) {
    if (_uid != null) {
      FirestoreService.setProject(_uid!, project);
    } else {
      state = [...state, project];
      _persistLocal();
    }
  }

  void removeProject(String id) {
    if (_uid != null) {
      FirestoreService.deleteProject(_uid!, id);
    } else {
      state = state.where((p) => p.id != id).toList();
      _persistLocal();
    }
  }

  void updateProject(Project updated) {
    if (_uid != null) {
      FirestoreService.setProject(_uid!, updated);
    } else {
      state = state.map((p) => p.id == updated.id ? updated : p).toList();
      _persistLocal();
    }
  }
}

final projectsProvider = StateNotifierProvider<ProjectsNotifier, List<Project>>((ref) {
  final user = ref.watch(currentUserProvider);
  return ProjectsNotifier(user?.uid);
});

// ─── Current Project ───────────────────────────────────────────────────────

final currentProjectProvider =
    StateNotifierProvider<_CurrentProjectNotifier, Project?>(
  (ref) {
    final projects = ref.watch(projectsProvider);
    return _CurrentProjectNotifier(projects);
  },
);

class _CurrentProjectNotifier extends StateNotifier<Project?> {
  _CurrentProjectNotifier(List<Project> projects) : super(_load(projects));

  static Project? _load(List<Project> projects) {
    if (projects.isEmpty) return null;
    final id = LocalStorageService.loadString(LocalStorageService.kCurrentProjectId);
    if (id != null) {
      try { return projects.firstWhere((p) => p.id == id); } catch (_) {}
    }
    return projects.first;
  }

  @override
  set state(Project? value) {
    super.state = value;
    if (value != null) {
      LocalStorageService.saveString(LocalStorageService.kCurrentProjectId, value.id);
    }
  }
}
