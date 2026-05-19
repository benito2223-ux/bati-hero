import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../../theme/app_colors.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        elevation: 0,
        title: Text(
          'MES CHANTIERS',
          style: GoogleFonts.bangers(
            fontSize: 28,
            color: AppColors.electricYellow,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
        ),
        actions: [
          if (user != null)
            PopupMenuButton(
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.electricYellow.withOpacity(0.2),
                backgroundImage: user.photoURL != null
                    ? NetworkImage(user.photoURL!)
                    : null,
                child: user.photoURL == null
                    ? Text(
                        (user.displayName ?? user.email ?? '?')[0].toUpperCase(),
                        style: GoogleFonts.bangers(
                            color: AppColors.electricYellow, fontSize: 14),
                      )
                    : null,
              ),
              color: AppColors.bgCard,
              itemBuilder: (_) => <PopupMenuEntry>[
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.displayName ?? '',
                          style: GoogleFonts.bangers(
                              color: AppColors.electricYellow, fontSize: 15)),
                      Text(user.email ?? '',
                          style: GoogleFonts.montserrat(
                              color: AppColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  onTap: () async {
                    await AuthService.signOut();
                    // router redirige vers /login automatiquement
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.logout_rounded,
                          color: AppColors.danger, size: 18),
                      const SizedBox(width: 8),
                      Text('Déconnexion',
                          style: GoogleFonts.montserrat(
                              color: AppColors.danger, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Header strip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.electricYellow, width: 2),
              ),
            ),
            child: Text(
              '${projects.length} chantier${projects.length > 1 ? 's' : ''} en cours',
              style: GoogleFonts.montserrat(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),

          // Projects grid
          Expanded(
            child: projects.isEmpty
                ? _EmptyState(onAdd: () => _showAddSheet(context, ref))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: projects.length,
                    itemBuilder: (context, i) => _ProjectCard(
                      project: projects[i],
                      onTap: () {
                        ref.read(currentProjectProvider.notifier).state = projects[i];
                        context.go('/shop-zap');
                      },
                      onDelete: () {
                        ref.read(projectsProvider.notifier).removeProject(projects[i].id);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        backgroundColor: AppColors.electricYellow,
        icon: const Icon(Icons.add_rounded, color: AppColors.bgDeep),
        label: Text(
          'NOUVEAU',
          style: GoogleFonts.bangers(color: AppColors.bgDeep, fontSize: 16),
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddProjectSheet(
        onAdd: (project) {
          ref.read(projectsProvider.notifier).addProject(project);
          // Auto-select the new project
          ref.read(currentProjectProvider.notifier).state = project;
        },
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.project,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _confirmDelete(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: project.color, width: 2),
          boxShadow: [
            BoxShadow(
              color: project.color.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Halftone corner decoration
            Positioned(
              top: -10, right: -10,
              child: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: project.color.withOpacity(0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(project.emoji, style: const TextStyle(fontSize: 32)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: GoogleFonts.bangers(
                          fontSize: 16,
                          color: project.color,
                          letterSpacing: 1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: project.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: project.color.withOpacity(0.4)),
                        ),
                        child: Text(
                          'OUVRIR →',
                          style: GoogleFonts.bangers(
                            fontSize: 12,
                            color: project.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text(
          'Supprimer ?',
          style: GoogleFonts.bangers(color: AppColors.electricYellow, fontSize: 22),
        ),
        content: Text(
          'Supprimer "${project.name}" et toutes ses données ?',
          style: GoogleFonts.montserrat(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ANNULER',
                style: GoogleFonts.bangers(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: Text('SUPPRIMER',
                style: GoogleFonts.bangers(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🏗️', style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'AUCUN CHANTIER',
            style: GoogleFonts.bangers(
              fontSize: 26,
              color: AppColors.electricYellow,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lance ton premier projet !',
            style: GoogleFonts.montserrat(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.electricYellow),
            icon: const Icon(Icons.add_rounded, color: AppColors.bgDeep),
            label: Text('CRÉER UN CHANTIER',
                style: GoogleFonts.bangers(color: AppColors.bgDeep, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _AddProjectSheet extends StatefulWidget {
  final ValueChanged<Project> onAdd;
  const _AddProjectSheet({required this.onAdd});

  @override
  State<_AddProjectSheet> createState() => _AddProjectSheetState();
}

class _AddProjectSheetState extends State<_AddProjectSheet> {
  final _ctrl = TextEditingController();
  Color _selectedColor = Project.availableColors[0];
  String _selectedEmoji = Project.availableEmojis[0];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24, left: 24, right: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.electricYellow, width: 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NOUVEAU CHANTIER',
              style: GoogleFonts.bangers(
                  fontSize: 24, color: AppColors.electricYellow, letterSpacing: 2)),
          const SizedBox(height: 20),

          // Emoji selector
          Text('Icône', style: GoogleFonts.montserrat(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Project.availableEmojis.map((e) => GestureDetector(
              onTap: () => setState(() => _selectedEmoji = e),
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _selectedEmoji == e
                        ? AppColors.electricYellow
                        : AppColors.bgDeep,
                    width: 2,
                  ),
                  color: _selectedEmoji == e
                      ? AppColors.electricYellow.withOpacity(0.1)
                      : AppColors.bgDeep,
                ),
                child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
              ),
            )).toList(),
          ),

          const SizedBox(height: 16),

          // Color selector
          Text('Couleur', style: GoogleFonts.montserrat(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: Project.availableColors.map((c) => GestureDetector(
              onTap: () => setState(() => _selectedColor = c),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c,
                  border: Border.all(
                    color: _selectedColor == c ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: _selectedColor == c
                      ? [BoxShadow(color: c.withOpacity(0.6), blurRadius: 8)]
                      : null,
                ),
              ),
            )).toList(),
          ),

          const SizedBox(height: 16),

          // Name field
          TextField(
            controller: _ctrl,
            autofocus: true,
            style: GoogleFonts.montserrat(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Nom du chantier',
              hintText: 'Ex: Rénovation cuisine...',
              prefixText: '$_selectedEmoji  ',
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final name = _ctrl.text.trim();
                if (name.isEmpty) return;
                final project = Project(
                  id: const Uuid().v4(),
                  name: name,
                  emoji: _selectedEmoji,
                  color: _selectedColor,
                );
                widget.onAdd(project);
                Navigator.pop(context);
                // Navigate to main app
                GoRouter.of(context).go('/shop-zap');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text('LANCER LE CHANTIER !',
                  style: GoogleFonts.bangers(
                      color: AppColors.bgDeep, fontSize: 18, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}
