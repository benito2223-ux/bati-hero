import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/comic_card.dart';
import '../../../shared/widgets/comic_button.dart';
import '../../shop_zap/screens/barcode_scanner_screen.dart';
import '../models/price_entry.dart';
import '../providers/price_compare_provider.dart';

class PriceCompareScreen extends ConsumerWidget {
  const PriceCompareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(priceCompareProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: HeroAppBar(
        title: 'PRIX-HUNTER 🎯',
        titleColor: AppColors.warning,
      ),
      body: entries.isEmpty
          ? _EmptyState(onAdd: () => _showAddSheet(context, ref))
          : Column(
              children: [
                // Stats banner
                if (entries.isNotEmpty) _StatsBanner(entries: entries),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    itemBuilder: (context, i) => _EntryCard(
                      entry: entries[i],
                      onTap: () => _showDetailSheet(context, ref, entries[i]),
                      onDelete: () =>
                          ref.read(priceCompareProvider.notifier).removeEntry(entries[i].id),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        backgroundColor: AppColors.warning,
        icon: const Icon(Icons.add_rounded, color: AppColors.bgDeep),
        label: Text('COMPARER',
            style: GoogleFonts.bangers(color: AppColors.bgDeep, fontSize: 16)),
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddProductSheet(ref: ref),
    );
  }

  void _showDetailSheet(BuildContext context, WidgetRef ref, PriceEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(entry: entry, ref: ref),
    );
  }
}

// ─── Stats Banner ─────────────────────────────────────────────────────────────

class _StatsBanner extends StatelessWidget {
  final List<PriceEntry> entries;
  const _StatsBanner({required this.entries});

  @override
  Widget build(BuildContext context) {
    final totalSavings = entries
        .where((e) => e.savings != null)
        .fold<double>(0, (s, e) => s + e.savings!);
    final compared = entries.where((e) => e.prices.length >= 2).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1500),
        border: Border(bottom: BorderSide(color: AppColors.warning, width: 1)),
      ),
      child: Row(
        children: [
          _StatChip(
            label: 'PRODUITS',
            value: '${entries.length}',
            color: AppColors.warning,
          ),
          const SizedBox(width: 16),
          _StatChip(
            label: 'COMPARÉS',
            value: '$compared',
            color: AppColors.neonCyan,
          ),
          const SizedBox(width: 16),
          if (totalSavings > 0)
            _StatChip(
              label: 'ÉCONOMIES',
              value: '${totalSavings.toStringAsFixed(0)} €',
              color: AppColors.success,
            ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.montserrat(
                fontSize: 9, color: AppColors.textSecondary,
                fontWeight: FontWeight.w600, letterSpacing: 1)),
        Text(value,
            style: GoogleFonts.bangers(fontSize: 18, color: color, letterSpacing: 1)),
      ],
    );
  }
}

// ─── Entry Card ───────────────────────────────────────────────────────────────

class _EntryCard extends StatelessWidget {
  final PriceEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _EntryCard({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final best = entry.bestPrice;
    final worst = entry.worstPrice;
    final savings = entry.savings;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () {
          HapticFeedback.mediumImpact();
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: AppColors.bgCard,
              title: Text('Supprimer ?',
                  style: GoogleFonts.bangers(
                      color: AppColors.warning, fontSize: 20)),
              content: Text(entry.productName,
                  style: GoogleFonts.montserrat(
                      color: AppColors.textSecondary)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('ANNULER',
                      style: GoogleFonts.bangers(
                          color: AppColors.textSecondary)),
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
        },
        child: ComicCard(
          borderColor: AppColors.warning.withOpacity(0.4),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.productName,
                      style: GoogleFonts.bangers(
                          fontSize: 17,
                          color: AppColors.warning,
                          letterSpacing: 0.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (savings != null && savings > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.success.withOpacity(0.4)),
                      ),
                      child: Text(
                        '-${savings.toStringAsFixed(0)} €',
                        style: GoogleFonts.bangers(
                            fontSize: 13, color: AppColors.success),
                      ),
                    ),
                ],
              ),
              if (entry.ean != null)
                Text('EAN: ${entry.ean}',
                    style: GoogleFonts.montserrat(
                        fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              if (entry.prices.isEmpty)
                Text(
                  'Aucun prix renseigné — appuie pour ajouter',
                  style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic),
                )
              else ...[
                // Mini bar chart preview
                _MiniBarChart(entry: entry),
                const SizedBox(height: 8),
                // Best/worst price
                Row(
                  children: [
                    _PriceBadge(
                      label: '🏆 MEILLEUR',
                      price: best!,
                      store: entry.bestStore!,
                      color: AppColors.success,
                    ),
                    if (worst != best) ...[
                      const SizedBox(width: 10),
                      _PriceBadge(
                        label: '😬 PLUS CHER',
                        price: worst!,
                        store: entry.prices
                            .reduce((a, b) => a.price > b.price ? a : b)
                            .storeName,
                        color: AppColors.danger,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceBadge extends StatelessWidget {
  final String label;
  final double price;
  final String store;
  final Color color;

  const _PriceBadge({
    required this.label,
    required this.price,
    required this.store,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.montserrat(
                    fontSize: 9,
                    color: color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5)),
            Text('${price.toStringAsFixed(2)} €',
                style: GoogleFonts.bangers(fontSize: 16, color: color)),
            Text(store,
                style: GoogleFonts.montserrat(
                    fontSize: 10, color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _MiniBarChart extends StatelessWidget {
  final PriceEntry entry;
  const _MiniBarChart({required this.entry});

  @override
  Widget build(BuildContext context) {
    final sorted = [...entry.prices]..sort((a, b) => a.price.compareTo(b.price));
    final maxPrice = sorted.last.price * 1.15;

    return SizedBox(
      height: 64,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxPrice,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= sorted.length) return const SizedBox.shrink();
                  final name = sorted[i].storeName.split(' ').first;
                  return Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(name,
                        style: GoogleFonts.montserrat(
                            fontSize: 8, color: AppColors.textSecondary)),
                  );
                },
                reservedSize: 18,
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: sorted.asMap().entries.map((e) {
            final isBest = e.value.price == sorted.first.price;
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.price,
                  color: isBest ? AppColors.success : AppColors.warning.withOpacity(0.6),
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Detail Sheet ─────────────────────────────────────────────────────────────

class _DetailSheet extends StatefulWidget {
  final PriceEntry entry;
  final WidgetRef ref;

  const _DetailSheet({required this.entry, required this.ref});

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  late PriceEntry _entry;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  void _refresh() {
    setState(() {
      _entry = widget.ref.read(priceCompareProvider).firstWhere(
            (e) => e.id == _entry.id,
            orElse: () => _entry,
          );
    });
  }

  void _addPrice(String storeName, double price) {
    widget.ref
        .read(priceCompareProvider.notifier)
        .setStorePrice(_entry.id, storeName, price);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final maxPrice = _entry.prices.isEmpty
        ? 1.0
        : _entry.prices.map((p) => p.price).reduce((a, b) => a > b ? a : b) * 1.2;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24, left: 20, right: 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.warning, width: 2)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🎯 COMPARAISON',
                          style: GoogleFonts.bangers(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              letterSpacing: 1)),
                      Text(
                        _entry.productName,
                        style: GoogleFonts.bangers(
                            fontSize: 20, color: AppColors.warning),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondary),
                ),
              ],
            ),

            if (_entry.ean != null)
              Text('EAN: ${_entry.ean}',
                  style: GoogleFonts.montserrat(
                      fontSize: 11, color: AppColors.textSecondary)),

            const SizedBox(height: 16),

            // Full bar chart
            if (_entry.prices.length >= 2) ...[
              Text('COMPARAISON DES PRIX',
                  style: GoogleFonts.bangers(
                      fontSize: 16, color: AppColors.warning, letterSpacing: 1)),
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxPrice,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => AppColors.bgDeep,
                        getTooltipItem: (group, gIdx, rod, rIdx) {
                          final sorted = [..._entry.prices]
                            ..sort((a, b) => a.price.compareTo(b.price));
                          return BarTooltipItem(
                            '${rod.toY.toStringAsFixed(2)} €',
                            GoogleFonts.bangers(
                                color: AppColors.warning, fontSize: 14),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final sorted = [..._entry.prices]
                              ..sort((a, b) => a.price.compareTo(b.price));
                            final i = value.toInt();
                            if (i < 0 || i >= sorted.length) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                sorted[i].storeName.split(' ').first,
                                style: GoogleFonts.montserrat(
                                    fontSize: 10, color: AppColors.textSecondary),
                              ),
                            );
                          },
                          reservedSize: 24,
                        ),
                      ),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => const FlLine(
                          color: Color(0xFF2A2A3A), strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: () {
                      final sorted = [..._entry.prices]
                        ..sort((a, b) => a.price.compareTo(b.price));
                      return sorted.asMap().entries.map((e) {
                        final isBest = e.key == 0;
                        final store = comparatorStores.firstWhere(
                          (s) => s.name == e.value.storeName,
                          orElse: () => const ComparatorStore(
                              name: '', emoji: '', color: 0xFFCCFF00, searchUrl: ''),
                        );
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.price,
                              color: isBest
                                  ? AppColors.success
                                  : Color(store.color).withOpacity(0.8),
                              width: 28,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                            ),
                          ],
                        );
                      }).toList();
                    }(),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              if (_entry.savings != null && _entry.savings! > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Text(
                    '💰 Tu économises ${_entry.savings!.toStringAsFixed(2)} € en choisissant ${_entry.bestStore} !',
                    style: GoogleFonts.bangers(
                        fontSize: 15, color: AppColors.success, letterSpacing: 0.5),
                  ),
                ),
              const SizedBox(height: 16),
            ],

            // Store prices list + add/edit
            Text('PRIX PAR MAGASIN',
                style: GoogleFonts.bangers(
                    fontSize: 16, color: AppColors.neonCyan, letterSpacing: 1)),
            const SizedBox(height: 8),

            ...comparatorStores.map((store) {
              final existing = _entry.prices
                  .where((p) => p.storeName == store.name)
                  .firstOrNull;
              return _StorePriceRow(
                store: store,
                existing: existing,
                isBest: existing != null &&
                    _entry.bestPrice != null &&
                    existing.price == _entry.bestPrice,
                onSave: (price) => _addPrice(store.name, price),
                onOpenStore: () async {
                  final query = Uri.encodeComponent(_entry.productName);
                  final url = Uri.parse('${store.searchUrl}$query');
                  if (await canLaunchUrl(url)) {
                    launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StorePriceRow extends StatefulWidget {
  final ComparatorStore store;
  final StorePrice? existing;
  final bool isBest;
  final ValueChanged<double> onSave;
  final VoidCallback onOpenStore;

  const _StorePriceRow({
    required this.store,
    required this.existing,
    required this.isBest,
    required this.onSave,
    required this.onOpenStore,
  });

  @override
  State<_StorePriceRow> createState() => _StorePriceRowState();
}

class _StorePriceRowState extends State<_StorePriceRow> {
  bool _editing = false;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.existing?.price.toStringAsFixed(2) ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.store.color);
    final hasPrice = widget.existing != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasPrice ? color.withOpacity(0.06) : AppColors.bgDeep,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.isBest
                ? AppColors.success
                : hasPrice
                    ? color.withOpacity(0.4)
                    : AppColors.bgCard,
            width: widget.isBest ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(widget.store.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(widget.store.name,
                          style: GoogleFonts.bangers(
                              fontSize: 15, color: color, letterSpacing: 0.5)),
                      if (widget.isBest) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('MEILLEUR PRIX',
                              style: GoogleFonts.bangers(
                                  fontSize: 9, color: AppColors.bgDeep)),
                        ),
                      ],
                    ],
                  ),
                  if (_editing)
                    TextField(
                      controller: _ctrl,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.montserrat(
                          color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        hintText: 'Prix en €',
                        hintStyle: GoogleFonts.montserrat(
                            color: AppColors.textSecondary, fontSize: 13),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: color),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: color, width: 2),
                        ),
                      ),
                      onSubmitted: (v) {
                        final price = double.tryParse(v.replaceAll(',', '.'));
                        if (price != null && price > 0) {
                          widget.onSave(price);
                          setState(() => _editing = false);
                        }
                      },
                    )
                  else if (hasPrice)
                    Text(
                      '${widget.existing!.price.toStringAsFixed(2)} €',
                      style: GoogleFonts.bangers(
                          fontSize: 18, color: widget.isBest ? AppColors.success : color),
                    )
                  else
                    Text('Non renseigné',
                        style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            // Open store button
            IconButton(
              icon: Icon(Icons.open_in_new_rounded,
                  color: color.withOpacity(0.7), size: 18),
              tooltip: 'Chercher sur ${widget.store.name}',
              onPressed: widget.onOpenStore,
            ),
            // Edit button
            IconButton(
              icon: Icon(
                _editing ? Icons.check_rounded : Icons.edit_rounded,
                color: _editing ? AppColors.success : color.withOpacity(0.7),
                size: 18,
              ),
              onPressed: () {
                if (_editing) {
                  final price = double.tryParse(
                      _ctrl.text.replaceAll(',', '.'));
                  if (price != null && price > 0) {
                    widget.onSave(price);
                  }
                }
                setState(() => _editing = !_editing);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add Product Sheet ────────────────────────────────────────────────────────

class _AddProductSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddProductSheet({required this.ref});

  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet> {
  final _nameCtrl = TextEditingController();
  String? _ean;
  bool _searching = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _nameCtrl.text = result);
    }
  }

  Future<void> _lookupEan(String ean) async {
    setState(() => _searching = true);
    try {
      final res = await http
          .get(Uri.parse(
              'https://world.openfoodfacts.org/api/v0/product/$ean.json'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 1) {
          final name = data['product']['product_name'] as String?;
          if (name != null && name.isNotEmpty) {
            setState(() => _nameCtrl.text = name);
          }
        }
      }
    } catch (_) {}
    setState(() => _searching = false);
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final entry = PriceEntry(productName: name, ean: _ean);
    widget.ref.read(priceCompareProvider.notifier).addEntry(entry);
    Navigator.pop(context);
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
        border: Border(top: BorderSide(color: AppColors.warning, width: 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NOUVEAU PRODUIT 🎯',
              style: GoogleFonts.bangers(
                  fontSize: 22, color: AppColors.warning, letterSpacing: 1)),
          const SizedBox(height: 16),

          // Scan or type
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _scanBarcode,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.neonCyan),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.qr_code_scanner_rounded,
                      color: AppColors.neonCyan, size: 18),
                  label: Text('SCANNER',
                      style: GoogleFonts.bangers(
                          color: AppColors.neonCyan, fontSize: 15)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _nameCtrl,
            autofocus: true,
            style: GoogleFonts.montserrat(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Nom du produit',
              hintText: 'Ex: Ciment colle flex C2...',
              prefixIcon: _searching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.warning),
                      ),
                    )
                  : const Icon(Icons.search_rounded, color: AppColors.warning),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ComicButton(
              label: 'CRÉER LA COMPARAISON',
              color: AppColors.warning,
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('AUCUNE COMPARAISON',
              style: GoogleFonts.bangers(
                  fontSize: 24,
                  color: AppColors.warning,
                  letterSpacing: 2)),
          const SizedBox(height: 8),
          Text(
            'Scanne un produit et compare\nles prix entre magasins',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
                color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning),
            icon: const Icon(Icons.add_rounded, color: AppColors.bgDeep),
            label: Text('PREMIÈRE COMPARAISON',
                style: GoogleFonts.bangers(
                    color: AppColors.bgDeep, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
