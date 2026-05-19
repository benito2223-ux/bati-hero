import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import '../providers/money_crunch_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/comic_button.dart';
import '../../../shared/widgets/comic_card.dart';

class MoneyCrunchScreen extends ConsumerStatefulWidget {
  const MoneyCrunchScreen({super.key});

  @override
  ConsumerState<MoneyCrunchScreen> createState() => _MoneyCrunchScreenState();
}

class _MoneyCrunchScreenState extends ConsumerState<MoneyCrunchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(moneyCrunchProvider);
    final notifier = ref.read(moneyCrunchProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: HeroAppBar(
        title: 'MONEY-CRUNCH 💥',
        titleColor: AppColors.neonPink,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => _showBudgetSheet(context, ref, state.budget),
          ),
        ],
      ),
      body: Column(
        children: [
          _TotalGauge(state: state),
          // Tab bar
          Container(
            color: AppColors.bgCard,
            child: TabBar(
              controller: _tabCtrl,
              indicatorColor: AppColors.neonPink,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.bangers(fontSize: 15, letterSpacing: 1),
              unselectedLabelStyle: GoogleFonts.bangers(fontSize: 14),
              labelColor: AppColors.neonPink,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [
                Tab(text: 'DÉPENSES'),
                Tab(text: 'STATS'),
                Tab(text: 'TICKETS'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                // Tab 1: Expenses list
                state.expenses.isEmpty
                    ? _EmptyExpenses()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.expenses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final exp = state.expenses.reversed.toList()[i];
                          return _ExpenseTile(
                            expense: exp,
                            onDelete: () => notifier.removeExpense(exp.id),
                          );
                        },
                      ),

                // Tab 2: Stats
                state.expenses.isEmpty
                    ? _EmptyExpenses()
                    : _StatsTab(state: state),

                // Tab 3: Receipt photos
                _ReceiptsTab(state: state),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'receipt_photo',
            mini: true,
            backgroundColor: AppColors.neonCyan,
            foregroundColor: AppColors.bgDeep,
            tooltip: 'Photo ticket de caisse',
            onPressed: () => _showAddSheetWithPhoto(context, ref),
            child: const Icon(Icons.receipt_long_rounded),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: 'add_expense',
            onPressed: () => _showAddSheet(context, ref),
            backgroundColor: AppColors.neonPink,
            icon: const Icon(Icons.add_rounded),
            label: Text('DÉPENSE', style: GoogleFonts.bangers(fontSize: 16, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  void _showBudgetSheet(BuildContext context, WidgetRef ref, double currentBudget) {
    final ctrl = TextEditingController(text: currentBudget.toStringAsFixed(0));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.neonPink, width: 2),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('BUDGET DU CHANTIER', style: GoogleFonts.bangers(fontSize: 22, color: AppColors.neonPink)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: GoogleFonts.montserrat(color: AppColors.textPrimary, fontSize: 16),
              decoration: const InputDecoration(
                labelText: 'Budget (€)',
                prefixIcon: Icon(Icons.euro_rounded, color: AppColors.neonPink),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ComicButton(
                label: 'VALIDER',
                color: AppColors.neonPink,
                onPressed: () {
                  final v = double.tryParse(ctrl.text);
                  if (v != null && v > 0) ref.read(moneyCrunchProvider.notifier).setBudget(v);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.neonPink, width: 2),
      ),
      builder: (_) => _AddExpenseSheet(ref: ref, withPhotoCapture: false),
    );
  }

  void _showAddSheetWithPhoto(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.neonCyan, width: 2),
      ),
      builder: (_) => _AddExpenseSheet(ref: ref, withPhotoCapture: true),
    );
  }
}

// ─── Total Gauge ─────────────────────────────────────────────────────────────

class _TotalGauge extends StatelessWidget {
  final MoneyCrunchState state;
  const _TotalGauge({required this.state});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    final isOver = state.isOver;
    final gaugeColor = isOver
        ? AppColors.danger
        : state.percent > 0.8
            ? AppColors.warning
            : AppColors.success;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: ComicCard(
        borderColor: isOver ? AppColors.danger : AppColors.neonPink,
        child: Column(
          children: [
            if (isOver)
              Text('⚠️ BUDGET DÉPASSÉ !',
                  style: GoogleFonts.bangers(fontSize: 18, color: AppColors.danger, letterSpacing: 1)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL DÉPENSÉ',
                        style: GoogleFonts.montserrat(
                            fontSize: 11, color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600, letterSpacing: 1)),
                    Text(
                      fmt.format(state.total),
                      style: GoogleFonts.bangers(
                        fontSize: 36, color: gaugeColor, letterSpacing: 1,
                        shadows: [Shadow(color: gaugeColor.withOpacity(0.5), blurRadius: 12)],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('BUDGET',
                        style: GoogleFonts.montserrat(
                            fontSize: 11, color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600, letterSpacing: 1)),
                    Text(fmt.format(state.budget),
                        style: GoogleFonts.bangers(fontSize: 24, color: AppColors.textSecondary)),
                    Text(
                      isOver
                          ? '-${fmt.format(state.total - state.budget)}'
                          : '${fmt.format(state.remaining)} restant',
                      style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: isOver ? AppColors.danger : AppColors.success),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: state.percent,
                backgroundColor: AppColors.bgDeep,
                valueColor: AlwaysStoppedAnimation<Color>(gaugeColor),
                minHeight: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stats Tab ────────────────────────────────────────────────────────────────

class _StatsTab extends StatelessWidget {
  final MoneyCrunchState state;
  const _StatsTab({required this.state});

  static const _catColors = {
    ExpenseCategory.materiaux: AppColors.electricYellow,
    ExpenseCategory.outillage: AppColors.neonCyan,
    ExpenseCategory.mainOeuvre: AppColors.neonPink,
    ExpenseCategory.livraison: AppColors.warning,
    ExpenseCategory.divers: AppColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0);

    // Aggregate by category
    final byCategory = <ExpenseCategory, double>{};
    for (final e in state.expenses) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
    }

    // Aggregate last 6 months
    final now = DateTime.now();
    final monthlyData = List.generate(6, (i) {
      final m = DateTime(now.year, now.month - (5 - i));
      final total = state.expenses
          .where((e) => e.date.year == m.year && e.date.month == m.month)
          .fold<double>(0, (s, e) => s + e.amount);
      return (month: m, total: total);
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pie chart
          Text('PAR CATÉGORIE',
              style: GoogleFonts.bangers(
                  fontSize: 18, color: AppColors.neonPink, letterSpacing: 1)),
          const SizedBox(height: 12),
          ComicCard(
            borderColor: AppColors.neonPink.withOpacity(0.4),
            child: SizedBox(
              height: 220,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 44,
                        sections: byCategory.entries.map((entry) {
                          final pct = (entry.value / state.total * 100);
                          return PieChartSectionData(
                            color: _catColors[entry.key] ?? AppColors.textSecondary,
                            value: entry.value,
                            title: '${pct.toStringAsFixed(0)}%',
                            radius: 60,
                            titleStyle: GoogleFonts.bangers(
                              fontSize: 14,
                              color: AppColors.bgDeep,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Legend
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: byCategory.entries.map((entry) {
                      final color = _catColors[entry.key] ?? AppColors.textSecondary;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12, height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.key.emoji,
                                    style: const TextStyle(fontSize: 12)),
                                Text(fmt.format(entry.value),
                                    style: GoogleFonts.bangers(
                                        fontSize: 13, color: color)),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Bar chart (monthly)
          Text('PAR MOIS (6 DERNIERS)',
              style: GoogleFonts.bangers(
                  fontSize: 18, color: AppColors.electricYellow, letterSpacing: 1)),
          const SizedBox(height: 12),
          ComicCard(
            borderColor: AppColors.electricYellow.withOpacity(0.4),
            child: SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: monthlyData
                            .map((d) => d.total)
                            .fold<double>(0, (a, b) => a > b ? a : b) *
                        1.2,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => AppColors.bgCard,
                        getTooltipItem: (group, gIdx, rod, rIdx) => BarTooltipItem(
                          fmt.format(rod.toY),
                          GoogleFonts.bangers(
                              color: AppColors.electricYellow, fontSize: 14),
                        ),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= monthlyData.length) return const SizedBox.shrink();
                            final m = monthlyData[i].month;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                DateFormat('MMM', 'fr_FR').format(m),
                                style: GoogleFonts.montserrat(
                                    fontSize: 10, color: AppColors.textSecondary),
                              ),
                            );
                          },
                          reservedSize: 28,
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => const FlLine(
                        color: Color(0xFF2A2A3A),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: monthlyData.asMap().entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.total,
                            color: entry.key == monthlyData.length - 1
                                ? AppColors.electricYellow
                                : AppColors.electricYellow.withOpacity(0.4),
                            width: 22,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Category breakdown
          Text('DÉTAIL PAR CATÉGORIE',
              style: GoogleFonts.bangers(
                  fontSize: 18, color: AppColors.neonCyan, letterSpacing: 1)),
          const SizedBox(height: 12),
          ...byCategory.entries.map((entry) {
            final color = _catColors[entry.key] ?? AppColors.textSecondary;
            final pct = entry.value / state.total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ComicCard(
                borderColor: color.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(entry.key.emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(entry.key.label,
                              style: GoogleFonts.bangers(
                                  fontSize: 16, color: color, letterSpacing: 1)),
                        ),
                        Text(fmt.format(entry.value),
                            style: GoogleFonts.bangers(fontSize: 18, color: color)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: AppColors.bgDeep,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Receipts Tab ─────────────────────────────────────────────────────────────

class _ReceiptsTab extends StatelessWidget {
  final MoneyCrunchState state;
  const _ReceiptsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final withReceipts = state.expenses
        .where((e) => e.receiptImagePath != null)
        .toList()
        .reversed
        .toList();

    if (withReceipts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📸', style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text('AUCUN TICKET',
                style: GoogleFonts.bangers(
                    fontSize: 26, color: AppColors.neonCyan.withOpacity(0.5))),
            const SizedBox(height: 8),
            Text('Appuie sur 📋 pour photographier un ticket',
                style: GoogleFonts.montserrat(
                    fontSize: 13, color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: withReceipts.length,
      itemBuilder: (context, i) {
        final exp = withReceipts[i];
        return GestureDetector(
          onTap: () => _showReceiptFullscreen(context, exp),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.neonCyan.withOpacity(0.4), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(exp.receiptImagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.bgCard,
                      child: const Center(child: Icon(Icons.broken_image_rounded,
                          color: AppColors.textSecondary)),
                    ),
                  ),
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      color: AppColors.bgDeep.withOpacity(0.85),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exp.description,
                            style: GoogleFonts.montserrat(
                                fontSize: 11, color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${exp.amount.toStringAsFixed(2)} €',
                            style: GoogleFonts.bangers(
                                fontSize: 14, color: AppColors.neonPink),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showReceiptFullscreen(BuildContext context, Expense exp) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.bgDeep,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(exp.description,
                        style: GoogleFonts.bangers(
                            fontSize: 18, color: AppColors.neonPink)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            InteractiveViewer(
              child: Image.file(
                File(exp.receiptImagePath!),
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: AppColors.bgCard,
                  child: const Center(child: Icon(Icons.broken_image_rounded,
                      size: 48, color: AppColors.textSecondary)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '${NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(exp.amount)}  •  ${DateFormat('d MMMM yyyy', 'fr_FR').format(exp.date)}',
                style: GoogleFonts.montserrat(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Expense Tile ─────────────────────────────────────────────────────────────

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;

  const _ExpenseTile({required this.expense, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ComicCard(
      borderColor: AppColors.neonPink.withOpacity(0.3),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // Receipt thumbnail if present
          if (expense.receiptImagePath != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  File(expense.receiptImagePath!),
                  width: 40, height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 40, height: 40,
                    color: AppColors.bgCard,
                    child: const Icon(Icons.receipt_long_rounded,
                        size: 20, color: AppColors.neonCyan),
                  ),
                ),
              ),
            )
          else
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: AppColors.neonPink.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(expense.category.emoji,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.description,
                    style: GoogleFonts.montserrat(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text(
                  '${expense.category.label} • ${DateFormat('d MMM', 'fr_FR').format(expense.date)}',
                  style: GoogleFonts.montserrat(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '${expense.amount.toStringAsFixed(2)} €',
            style: GoogleFonts.bangers(
                fontSize: 18, color: AppColors.neonPink, letterSpacing: 0.5),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close_rounded, color: AppColors.danger, size: 18),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyExpenses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64, color: AppColors.neonPink.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('AUCUNE DÉPENSE !',
              style: GoogleFonts.bangers(
                  fontSize: 28, color: AppColors.neonPink.withOpacity(0.5))),
          Text('Scanne un ticket ou ajoute manuellement',
              style: GoogleFonts.montserrat(
                  fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ─── Add Expense Sheet ────────────────────────────────────────────────────────

class _AddExpenseSheet extends StatefulWidget {
  final WidgetRef ref;
  final bool withPhotoCapture;

  const _AddExpenseSheet({required this.ref, this.withPhotoCapture = false});

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  ExpenseCategory _cat = ExpenseCategory.materiaux;
  String? _receiptPath;

  @override
  void initState() {
    super.initState();
    if (widget.withPhotoCapture) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pickReceipt());
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickReceipt({bool fromCamera = true}) async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );
    if (xfile != null) {
      setState(() => _receiptPath = xfile.path);
    }
  }

  void _submit() {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0 || _descCtrl.text.trim().isEmpty) return;
    widget.ref.read(moneyCrunchProvider.notifier).addExpense(
          Expense(
            amount: amount,
            description: _descCtrl.text.trim(),
            category: _cat,
            receiptImagePath: _receiptPath,
          ),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.withPhotoCapture ? AppColors.neonCyan : AppColors.neonPink;

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.withPhotoCapture ? 'TICKET DE CAISSE 📸' : 'NOUVELLE DÉPENSE 💥',
              style: GoogleFonts.bangers(
                  fontSize: 24, color: accentColor, letterSpacing: 1),
            ),
            const SizedBox(height: 16),

            // Receipt photo section
            if (_receiptPath != null || widget.withPhotoCapture) ...[
              Row(
                children: [
                  // Thumbnail
                  if (_receiptPath != null)
                    GestureDetector(
                      onTap: () => _pickReceipt(fromCamera: false),
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: accentColor, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(_receiptPath!), fit: BoxFit.cover),
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => _pickReceipt(fromCamera: true),
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: accentColor, width: 2),
                          color: accentColor.withOpacity(0.1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_rounded, color: accentColor),
                            const SizedBox(height: 4),
                            Text('PHOTO', style: GoogleFonts.bangers(
                                fontSize: 11, color: accentColor)),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        onPressed: () => _pickReceipt(fromCamera: true),
                        icon: Icon(Icons.camera_alt_rounded,
                            color: accentColor, size: 18),
                        label: Text('CAMÉRA',
                            style: GoogleFonts.bangers(color: accentColor)),
                      ),
                      TextButton.icon(
                        onPressed: () => _pickReceipt(fromCamera: false),
                        icon: Icon(Icons.photo_library_rounded,
                            color: accentColor, size: 18),
                        label: Text('GALERIE',
                            style: GoogleFonts.bangers(color: accentColor)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: !widget.withPhotoCapture,
              style: GoogleFonts.montserrat(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Montant (€)',
                prefixIcon: Icon(Icons.euro_rounded, color: accentColor),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              style: GoogleFonts.montserrat(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_outlined, color: AppColors.neonCyan),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ExpenseCategory>(
              value: _cat,
              dropdownColor: AppColors.bgCard,
              style: GoogleFonts.montserrat(color: AppColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(labelText: 'Catégorie'),
              items: ExpenseCategory.values.map((c) => DropdownMenuItem(
                value: c,
                child: Text('${c.emoji}  ${c.label}'),
              )).toList(),
              onChanged: (v) => setState(() => _cat = v!),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ComicButton(
                label: widget.withPhotoCapture ? 'ENREGISTRER 📸' : 'CRUNCH ! VALIDER',
                color: accentColor,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
