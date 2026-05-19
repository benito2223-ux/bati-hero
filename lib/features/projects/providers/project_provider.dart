import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project.dart';
import '../../../shared/services/local_storage_service.dart';

class ProjectsNotifier extends StateNotifier<List<Project>> {
  ProjectsNotifier() : super(_loadOrDemo());

  static List<Project> _loadOrDemo() {
    final saved = LocalStorageService.loadJsonList(LocalStorageService.kProjects);
    if (saved.isNotEmpty) {
      try {
        return saved.map(Project.fromJson).toList();
      } catch (_) {}
    }
    // First launch: demo project
    final demo = Project(
      id: 'demo',
      name: 'Mon premier chantier',
      emoji: '🏠',
      color: const Color(0xFFFF00FF),
    );
    LocalStorageService.saveJsonList(
      LocalStorageService.kProjects,
      [demo.toJson()],
    );
    return [demo];
  }

  void _persist() {
    LocalStorageService.saveJsonList(
      LocalStorageService.kProjects,
      state.map((p) => p.toJson()).toList(),
    );
  }

  void addProject(Project project) {
    state = [...state, project];
    _persist();
  }

  void removeProject(String id) {
    state = state.where((p) => p.id != id).toList();
    _persist();
  }

  void updateProject(Project updated) {
    state = state.map((p) => p.id == updated.id ? updated : p).toList();
    _persist();
  }
}

final projectsProvider =
    StateNotifierProvider<ProjectsNotifier, List<Project>>(
  (_) => ProjectsNotifier(),
);

/// Persists the last selected project so it survives les rechargements.
final currentProjectProvider =
    StateNotifierProvider<_CurrentProjectNotifier, Project?>(
  (ref) => _CurrentProjectNotifier(ref.read(projectsProvider)),
);

class _CurrentProjectNotifier extends StateNotifier<Project?> {
  _CurrentProjectNotifier(List<Project> projects) : super(_load(projects));

  static Project? _load(List<Project> projects) {
    if (projects.isEmpty) return null;
    final savedId =
        LocalStorageService.loadString(LocalStorageService.kCurrentProjectId);
    if (savedId != null) {
      try {
        return projects.firstWhere((p) => p.id == savedId);
      } catch (_) {}
    }
    return projects.first;
  }

  @override
  set state(Project? value) {
    super.state = value;
    if (value != null) {
      LocalStorageService.saveString(
        LocalStorageService.kCurrentProjectId,
        value.id,
      );
    }
  }
}
