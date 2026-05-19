import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/hero_post.dart';
import '../providers/hero_feed_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/comic_button.dart';
import '../../../shared/widgets/comic_card.dart';
import '../../../shared/widgets/power_badge.dart';

class HeroFeedScreen extends ConsumerWidget {
  const HeroFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(heroFilterProvider);
    ref.watch(heroFeedProvider); // rebuild on change
    final posts = ref.read(heroFeedProvider.notifier).filtered(filter);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: HeroAppBar(
        title: 'HERO-FEED 📸',
        titleColor: AppColors.neonPink,
      ),
      body: Column(
        children: [
          _FilterBar(current: filter),
          Expanded(
            child: posts.isEmpty
                ? _EmptyFeed()
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: posts.length,
                    itemBuilder: (_, i) => _PostCard(
                      post: posts[i],
                      onDelete: () => ref.read(heroFeedProvider.notifier).removePost(posts[i].id),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        backgroundColor: AppColors.neonPink,
        icon: const Icon(Icons.add_a_photo_rounded),
        label: Text('PHOTO', style: GoogleFonts.bangers(fontSize: 16, letterSpacing: 1)),
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.neonPink, width: 2),
      ),
      builder: (_) => _AddPostSheet(ref: ref),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  final PostType? current;
  const _FilterBar({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _Chip(label: 'TOUT', selected: current == null, onTap: () => ref.read(heroFilterProvider.notifier).state = null),
          const SizedBox(width: 8),
          _Chip(label: '🔴 AVANT', selected: current == PostType.before, color: AppColors.danger, onTap: () => ref.read(heroFilterProvider.notifier).state = PostType.before),
          const SizedBox(width: 8),
          _Chip(label: '🟢 APRÈS', selected: current == PostType.after, color: AppColors.success, onTap: () => ref.read(heroFilterProvider.notifier).state = PostType.after),
          const SizedBox(width: 8),
          _Chip(label: '⚡ EN COURS', selected: current == PostType.progress, color: AppColors.warning, onTap: () => ref.read(heroFilterProvider.notifier).state = PostType.progress),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.selected, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.electricYellow;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? c.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? c : AppColors.textSecondary.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: GoogleFonts.bangers(
            fontSize: 12,
            color: selected ? c : AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final HeroPost post;
  final VoidCallback onDelete;

  const _PostCard({required this.post, required this.onDelete});

  Color get _typeColor {
    switch (post.type) {
      case PostType.before: return AppColors.danger;
      case PostType.after: return AppColors.success;
      case PostType.progress: return AppColors.warning;
    }
  }

  String get _typeLabel {
    switch (post.type) {
      case PostType.before: return 'AVANT';
      case PostType.after: return 'APRÈS';
      case PostType.progress: return 'EN COURS';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ComicCard(
      borderColor: _typeColor,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(post.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.bgCard,
                child: const Icon(Icons.broken_image_outlined, color: AppColors.textSecondary, size: 40),
              ),
            ),
            // Gradient overlay
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppColors.bgDeep.withOpacity(0.9), Colors.transparent],
                  ),
                ),
                child: Text(
                  post.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            // Type badge
            Positioned(
              top: 8, left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _typeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(_typeLabel, style: GoogleFonts.bangers(fontSize: 11, color: AppColors.bgDeep)),
              ),
            ),
            // Delete
            Positioned(
              top: 6, right: 6,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: AppColors.bgDeep.withOpacity(0.7), shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, color: AppColors.danger, size: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PowerBadge(text: 'HERO-FEED', color: AppColors.neonPink, fontSize: 24),
          const SizedBox(height: 24),
          Icon(Icons.photo_library_outlined, size: 64, color: AppColors.neonPink.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('AUCUNE PHOTO !', style: GoogleFonts.bangers(fontSize: 28, color: AppColors.neonPink.withOpacity(0.5))),
          const SizedBox(height: 8),
          Text('Immortalise ton chantier ⚡', style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _AddPostSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddPostSheet({required this.ref});

  @override
  State<_AddPostSheet> createState() => _AddPostSheetState();
}

class _AddPostSheetState extends State<_AddPostSheet> {
  final _captionCtrl = TextEditingController();
  PostType _type = PostType.progress;
  String? _imagePath;

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: source, imageQuality: 80);
    if (xFile != null) setState(() => _imagePath = xFile.path);
  }

  void _submit() {
    if (_imagePath == null || _captionCtrl.text.trim().isEmpty) return;
    widget.ref.read(heroFeedProvider.notifier).addPost(HeroPost(
      imagePath: _imagePath!,
      caption: _captionCtrl.text.trim(),
      type: _type,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NOUVELLE PHOTO 📸', style: GoogleFonts.bangers(fontSize: 24, color: AppColors.neonPink, letterSpacing: 1)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickImage(ImageSource.camera),
                  child: ComicCard(
                    borderColor: AppColors.neonPink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        const Icon(Icons.camera_alt_rounded, color: AppColors.neonPink, size: 30),
                        const SizedBox(height: 6),
                        Text('CAMÉRA', style: GoogleFonts.bangers(fontSize: 14, color: AppColors.neonPink)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickImage(ImageSource.gallery),
                  child: ComicCard(
                    borderColor: AppColors.neonCyan,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        const Icon(Icons.photo_library_rounded, color: AppColors.neonCyan, size: 30),
                        const SizedBox(height: 6),
                        Text('GALERIE', style: GoogleFonts.bangers(fontSize: 14, color: AppColors.neonCyan)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_imagePath != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(File(_imagePath!), height: 120, width: double.infinity, fit: BoxFit.cover),
            ),
          ],
          const SizedBox(height: 12),
          DropdownButtonFormField<PostType>(
            value: _type,
            dropdownColor: AppColors.bgCard,
            style: GoogleFonts.montserrat(color: AppColors.textPrimary, fontSize: 14),
            decoration: const InputDecoration(labelText: 'Type de photo'),
            items: const [
              DropdownMenuItem(value: PostType.before, child: Text('🔴  AVANT')),
              DropdownMenuItem(value: PostType.after, child: Text('🟢  APRÈS')),
              DropdownMenuItem(value: PostType.progress, child: Text('⚡  EN COURS')),
            ],
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _captionCtrl,
            style: GoogleFonts.montserrat(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Légende', prefixIcon: Icon(Icons.comment_rounded, color: AppColors.neonPink)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ComicButton(
              label: 'POSTER !',
              color: AppColors.neonPink,
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }
}
