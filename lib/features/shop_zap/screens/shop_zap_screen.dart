import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/shopping_item.dart';
import '../providers/shop_zap_provider.dart';
import '../widgets/shop_item_tile.dart';
import '../../../theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/comic_button.dart';
import '../../../shared/widgets/comic_card.dart';
import 'barcode_scanner_screen.dart';
import 'store_locator_screen.dart';

class ShopZapScreen extends ConsumerWidget {
  const ShopZapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(shopZapProvider.notifier);
    final items = ref.watch(shopZapProvider);
    final byStore = notifier.byStore;
    final total = notifier.total;
    final checked = notifier.checked;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: HeroAppBar(
        title: 'SHOP-ZAP ⚡',
        actions: [
          IconButton(
            icon: const Icon(Icons.store_rounded, color: AppColors.neonCyan),
            tooltip: 'Magasins proches',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StoreLocatorScreen()),
            ),
          ),
          if (checked > 0)
            TextButton.icon(
              onPressed: () => notifier.clearChecked(),
              icon: const Icon(Icons.cleaning_services_rounded, color: AppColors.neonPink, size: 18),
              label: Text(
                'NETTOYER',
                style: GoogleFonts.bangers(color: AppColors.neonPink, fontSize: 14),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _ProgressHeader(total: total, checked: checked),
          Expanded(
            child: items.isEmpty
                ? _EmptyState()
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: byStore.entries.map((entry) {
                      return _StoreSection(
                        store: entry.key,
                        items: entry.value,
                        onToggle: (id) => notifier.toggleItem(id),
                        onDelete: (id) => notifier.removeItem(id),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'scan_barcode',
            mini: true,
            backgroundColor: AppColors.neonCyan,
            foregroundColor: AppColors.bgDeep,
            tooltip: 'Scanner un code-barres',
            onPressed: () async {
              final name = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
              );
              if (name != null && name.isNotEmpty) {
                ref.read(shopZapProvider.notifier).addItem(
                  ShoppingItem(name: name, store: BricoStore.libre, quantity: '1'),
                );
              }
            },
            child: const Icon(Icons.qr_code_scanner_rounded),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: () => _showAddSheet(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: Text('AJOUTER', style: GoogleFonts.bangers(fontSize: 16, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  void _showVoiceSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎤 Saisie vocale — disponible après config micro')),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: AppColors.electricYellow, width: 2),
      ),
      builder: (_) => _AddItemSheet(ref: ref),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int total;
  final int checked;

  const _ProgressHeader({required this.total, required this.checked});

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : checked / total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: ComicCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$checked / $total articles',
                  style: GoogleFonts.bangers(fontSize: 20, color: AppColors.electricYellow, letterSpacing: 1),
                ),
                Text(
                  '${(progress * 100).toInt()}% ZAPPÉ !',
                  style: GoogleFonts.bangers(fontSize: 16, color: AppColors.neonCyan),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.bgDeep,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.electricYellow),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreSection extends StatefulWidget {
  final BricoStore store;
  final List<ShoppingItem> items;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onDelete;

  const _StoreSection({
    required this.store,
    required this.items,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<_StoreSection> createState() => _StoreSectionState();
}

class _StoreSectionState extends State<_StoreSection> {
  bool _expanded = true;

  Color get _storeColor {
    switch (widget.store) {
      case BricoStore.libre: return AppColors.libre;
      case BricoStore.leroyMerlin: return AppColors.leroyMerlin;
      case BricoStore.castorama: return AppColors.castorama;
      case BricoStore.bricoDep: return AppColors.bricoDep;
      case BricoStore.autres: return AppColors.autres;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ComicCard(
        borderColor: _storeColor,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _storeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(10),
                    bottom: _expanded ? Radius.zero : const Radius.circular(10),
                  ),
                ),
                child: Row(
                  children: [
                    Text(widget.store.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.store.label.toUpperCase(),
                        style: GoogleFonts.bangers(
                          fontSize: 18,
                          color: _storeColor,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _storeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.items.length}',
                        style: GoogleFonts.bangers(
                          fontSize: 14,
                          color: AppColors.bgDeep,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: _storeColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: Column(
                  children: widget.items
                      .map((item) => ShopItemTile(
                            item: item,
                            onToggle: () => widget.onToggle(item.id),
                            onDelete: () => widget.onDelete(item.id),
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.electricYellow.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'LISTE VIDE !',
            style: GoogleFonts.bangers(fontSize: 32, color: AppColors.electricYellow.withOpacity(0.5)),
          ),
          Text(
            'Appuie sur AJOUTER pour commencer',
            style: GoogleFonts.montserrat(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _AddItemSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddItemSheet({required this.ref});

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  BricoStore _store = BricoStore.leroyMerlin;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) return;
    widget.ref.read(shopZapProvider.notifier).addItem(
          ShoppingItem(
            name: _nameCtrl.text.trim(),
            store: _store,
            quantity: _qtyCtrl.text.trim(),
          ),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NOUVEL ARTICLE ⚡',
              style: GoogleFonts.bangers(fontSize: 24, color: AppColors.electricYellow, letterSpacing: 1)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            style: GoogleFonts.montserrat(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Article', prefixIcon: Icon(Icons.inventory_2_outlined, color: AppColors.electricYellow)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _qtyCtrl,
            style: GoogleFonts.montserrat(color: AppColors.textPrimary),
            decoration: const InputDecoration(labelText: 'Quantité', prefixIcon: Icon(Icons.numbers_rounded, color: AppColors.neonCyan)),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<BricoStore>(
            value: _store,
            dropdownColor: AppColors.bgCard,
            style: GoogleFonts.montserrat(color: AppColors.textPrimary, fontSize: 14),
            decoration: const InputDecoration(labelText: 'Magasin', prefixIcon: Icon(Icons.store_rounded, color: AppColors.neonPink)),
            items: BricoStore.values.map((s) => DropdownMenuItem(
              value: s,
              child: Text('${s.emoji}  ${s.label}'),
            )).toList(),
            onChanged: (v) => setState(() => _store = v!),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ComicButton(label: 'ZAP ! AJOUTER', onPressed: _submit),
          ),
        ],
      ),
    );
  }
}
