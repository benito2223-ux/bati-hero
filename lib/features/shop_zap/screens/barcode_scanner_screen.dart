import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../theme/app_colors.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final _ctrl = MobileScannerController();
  bool _scanning = true;
  bool _loading = false;
  String? _scannedCode;
  String? _productName;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_scanning) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() {
      _scanning = false;
      _loading = true;
      _scannedCode = barcode!.rawValue;
    });

    // Requête API produit
    final name = await _lookupProduct(_scannedCode!);
    setState(() {
      _loading = false;
      _productName = name;
    });
  }

  Future<String?> _lookupProduct(String code) async {
    try {
      // Open Food Facts (fonctionne pour produits grande conso)
      final res = await http
          .get(Uri.parse('https://world.openfoodfacts.org/api/v0/product/$code.json'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 1) {
          return data['product']['product_name'] ??
              data['product']['product_name_fr'];
        }
      }
    } catch (_) {}
    // Fallback UPC Item DB
    try {
      final res = await http
          .get(Uri.parse('https://api.upcitemdb.com/prod/trial/lookup?upc=$code'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final items = data['items'] as List?;
        if (items != null && items.isNotEmpty) {
          return items.first['title'];
        }
      }
    } catch (_) {}
    return null; // inconnu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        title: Text('SCAN CODE-BARRES',
            style: GoogleFonts.bangers(fontSize: 22, color: AppColors.electricYellow)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.electricYellow),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          if (_scanning)
            MobileScanner(controller: _ctrl, onDetect: _onDetect)
          else
            Container(color: AppColors.bgDeep),

          // Overlay viseur
          if (_scanning)
            Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.electricYellow, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

          // Panel résultat
          if (!_scanning)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  border: const Border(
                    top: BorderSide(color: AppColors.electricYellow, width: 2),
                  ),
                ),
                child: _loading
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: AppColors.electricYellow),
                          const SizedBox(height: 12),
                          Text('Recherche produit...',
                              style: GoogleFonts.montserrat(color: AppColors.textSecondary)),
                        ],
                      )
                    : _ResultPanel(
                        code: _scannedCode!,
                        name: _productName,
                        onConfirm: (name) => Navigator.pop(context, name),
                        onRescan: () => setState(() {
                          _scanning = true;
                          _scannedCode = null;
                          _productName = null;
                        }),
                      ),
              ),
            ),

          // Hint
          if (_scanning)
            Positioned(
              top: 24, left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.bgDeep.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Pointez le code-barres dans le cadre',
                    style: GoogleFonts.montserrat(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatefulWidget {
  final String code;
  final String? name;
  final ValueChanged<String> onConfirm;
  final VoidCallback onRescan;

  const _ResultPanel({
    required this.code,
    required this.name,
    required this.onConfirm,
    required this.onRescan,
  });

  @override
  State<_ResultPanel> createState() => _ResultPanelState();
}

class _ResultPanelState extends State<_ResultPanel> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.name ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.name != null ? '✅ Produit trouvé !' : '⚡ Code : ${widget.code}',
          style: GoogleFonts.bangers(
            fontSize: 20,
            color: widget.name != null ? AppColors.success : AppColors.electricYellow,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _ctrl,
          autofocus: widget.name == null,
          style: GoogleFonts.montserrat(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Nom de l\'article',
            hintText: 'Ex: Ciment colle flex...',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onRescan,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.textSecondary),
                ),
                child: Text('RESCANNER',
                    style: GoogleFonts.bangers(color: AppColors.textSecondary)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_ctrl.text.trim().isNotEmpty) widget.onConfirm(_ctrl.text.trim());
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.electricYellow),
                child: Text('AJOUTER',
                    style: GoogleFonts.bangers(color: AppColors.bgDeep, fontSize: 16)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
