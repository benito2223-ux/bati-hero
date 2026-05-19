import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/chantier_event.dart';
import '../providers/chrono_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/comic_button.dart';
import '../../../shared/widgets/comic_card.dart';

class ChronoPlanningScreen extends ConsumerStatefulWidget {
  const ChronoPlanningScreen({super.key});

  @override
  ConsumerState<ChronoPlanningScreen> createState() => _ChronoPlanningScreenState();
}

class _ChronoPlanningScreenState extends ConsumerState<ChronoPlanningScreen> {
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(chronoProvider.notifier);
    final upcoming = notifier.upcoming;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: HeroAppBar(
        title: 'CHRONO-PLANNING ⏱️',
        titleColor: AppColors.neonCyan,
        actions: [
          TextButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('📅 Sync Google Agenda — config OAuth requise')),
            ),
            icon: const Icon(Icons.sync_rounded, color: AppColors.neonCyan, size: 18),
            label: Text('GOOGLE', style: GoogleFonts.bangers(color: AppColors.neonCyan, fontSize: 14)),
          ),
        ],
      ),
      body: Column(
        children: [
          _WeekStrip(
            selected: _selectedDay,
            onDayTap: (d) => setState(() => _selectedDay = d),
            events: ref.watch(chronoProvider),
          ),
          Expanded(
            child: upcoming.isEmpty
                ? _EmptyPlanning()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: upcoming.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _EventCard(
                      event: upcoming[i],
                      onDelete: () => notifier.removeEvent(upcoming[i].id),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppColors.neonCyan,
        foregroundColor: AppColors.bgDeep,
        icon: const Icon(Icons.add_rounded),
        label: Text('CRÉNEAU', style: GoogleFonts.bangers(fontSize: 16, letterSpacing: 1)),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.neonCyan, width: 2),
      ),
      builder: (_) => _AddEventSheet(ref: ref, initialDay: _selectedDay),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onDayTap;
  final List<ChantierEvent> events;

  const _WeekStrip({required this.selected, required this.onDayTap, required this.events});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) => today.add(Duration(days: i - today.weekday + 1)));

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: days.map((day) {
          final isSelected = day.day == selected.day && day.month == selected.month;
          final isToday = day.day == today.day && day.month == today.month;
          final hasEvent = events.any((e) =>
              e.start.day == day.day && e.start.month == day.month);

          return Expanded(
            child: GestureDetector(
              onTap: () => onDayTap(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.neonCyan : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isToday ? AppColors.electricYellow : AppColors.neonCyan.withOpacity(0.3),
                    width: isToday ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('E', 'fr_FR').format(day).toUpperCase(),
                      style: GoogleFonts.bangers(
                        fontSize: 11,
                        color: isSelected ? AppColors.bgDeep : AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${day.day}',
                      style: GoogleFonts.bangers(
                        fontSize: 18,
                        color: isSelected ? AppColors.bgDeep : AppColors.textPrimary,
                      ),
                    ),
                    if (hasEvent)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.bgDeep : AppColors.neonCyan,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final ChantierEvent event;
  final VoidCallback onDelete;

  const _EventCard({required this.event, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');
    final dateFmt = DateFormat('EEE d MMM', 'fr_FR');

    return ComicCard(
      borderColor: AppColors.neonCyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: GoogleFonts.bangers(fontSize: 20, color: AppColors.neonCyan, letterSpacing: 0.5),
                ),
              ),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.close_rounded, color: AppColors.danger, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${dateFmt.format(event.start)}  ${timeFmt.format(event.start)} → ${timeFmt.format(event.end)}',
                style: GoogleFonts.montserrat(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          if (event.description != null) ...[
            const SizedBox(height: 4),
            Text(event.description!, style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.textPrimary)),
          ],
          if (event.hasDryingTime) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.warning, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.hourglass_bottom_rounded, color: AppColors.warning, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Séchage : ${_formatDuration(event.dryingDuration)}',
                    style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warning),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours >= 24) return '${d.inDays}j';
    if (d.inHours > 0) return '${d.inHours}h';
    return '${d.inMinutes}min';
  }
}

class _EmptyPlanning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.neonCyan.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('PLANNING VIDE !', style: GoogleFonts.bangers(fontSize: 28, color: AppColors.neonCyan.withOpacity(0.5))),
          Text('Ajoute ton premier créneau', style: GoogleFonts.montserrat(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _AddEventSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final DateTime initialDay;
  const _AddEventSheet({required this.ref, required this.initialDay});

  @override
  ConsumerState<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends ConsumerState<_AddEventSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dryCtrl = TextEditingController();
  late DateTime _start;
  late DateTime _end;

  @override
  void initState() {
    super.initState();
    _start = DateTime(widget.initialDay.year, widget.initialDay.month, widget.initialDay.day, 8);
    _end = _start.add(const Duration(hours: 4));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _dryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? _start : _end),
    );
    if (t == null) return;
    setState(() {
      if (isStart) {
        _start = DateTime(_start.year, _start.month, _start.day, t.hour, t.minute);
      } else {
        _end = DateTime(_end.year, _end.month, _end.day, t.hour, t.minute);
      }
    });
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty) return;
    widget.ref.read(chronoProvider.notifier).addEvent(ChantierEvent(
      title: _titleCtrl.text.trim(),
      start: _start,
      end: _end,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      dryingMinutes: int.tryParse(_dryCtrl.text),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NOUVEAU CRÉNEAU ⏱️', style: GoogleFonts.bangers(fontSize: 24, color: AppColors.neonCyan, letterSpacing: 1)),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            autofocus: true,
            style: GoogleFonts.montserrat(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Titre du chantier'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickTime(true),
                  child: ComicCard(
                    borderColor: AppColors.neonCyan.withOpacity(0.5),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DÉBUT', style: GoogleFonts.bangers(fontSize: 12, color: AppColors.textSecondary)),
                        Text(timeFmt.format(_start), style: GoogleFonts.bangers(fontSize: 22, color: AppColors.neonCyan)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickTime(false),
                  child: ComicCard(
                    borderColor: AppColors.neonCyan.withOpacity(0.5),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('FIN', style: GoogleFonts.bangers(fontSize: 12, color: AppColors.textSecondary)),
                        Text(timeFmt.format(_end), style: GoogleFonts.bangers(fontSize: 22, color: AppColors.neonCyan)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            style: GoogleFonts.montserrat(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Notes (optionnel)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dryCtrl,
            keyboardType: TextInputType.number,
            style: GoogleFonts.montserrat(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Temps de séchage (minutes)',
              prefixIcon: Icon(Icons.hourglass_bottom_rounded, color: AppColors.warning),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ComicButton(label: 'PLANIFIER !', color: AppColors.neonCyan, onPressed: _submit),
          ),
        ],
      ),
    );
  }
}
