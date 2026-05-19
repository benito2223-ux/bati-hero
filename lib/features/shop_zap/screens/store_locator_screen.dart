import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../../theme/app_colors.dart';
import '../../../shared/services/store_locator_service.dart';

class StoreLocatorScreen extends StatefulWidget {
  const StoreLocatorScreen({super.key});

  @override
  State<StoreLocatorScreen> createState() => _StoreLocatorScreenState();
}

class _StoreLocatorScreenState extends State<StoreLocatorScreen> {
  bool _locating = false;
  Position? _position;
  String? _locationLabel;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    setState(() => _locating = true);
    final pos = await StoreLocatorService.getCurrentPosition();
    setState(() {
      _locating = false;
      _position = pos;
      _locationLabel = pos != null
          ? '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}'
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        elevation: 0,
        title: Text(
          'MAGASINS PROCHES 📍',
          style: GoogleFonts.bangers(
            fontSize: 22,
            color: AppColors.neonCyan,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.neonCyan),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: _locating
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.neonCyan,
                    ),
                  )
                : const Icon(Icons.my_location_rounded, color: AppColors.neonCyan),
            onPressed: _locating ? null : _fetchLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Location strip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.neonCyan, width: 1),
              ),
              color: Color(0xFF0A1A1A),
            ),
            child: Row(
              children: [
                Icon(
                  _position != null ? Icons.location_on_rounded : Icons.location_off_rounded,
                  color: _position != null ? AppColors.neonCyan : AppColors.textSecondary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _locating
                        ? 'Localisation en cours...'
                        : _locationLabel != null
                            ? 'Position : $_locationLabel'
                            : 'Position non disponible — résultats sans coordonnées',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: _position != null ? AppColors.neonCyan : AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Stores list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: StoreLocatorService.stores.length,
              itemBuilder: (context, i) {
                final store = StoreLocatorService.stores[i];
                return _StoreCard(
                  store: store,
                  onOpen: () => StoreLocatorService.openMaps(store.name, _position),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  final BricoStore store;
  final VoidCallback onOpen;

  const _StoreCard({required this.store, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: store.color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: store.color.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: store.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: store.color.withOpacity(0.4)),
                  ),
                  child: Center(
                    child: Text(store.emoji, style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: GoogleFonts.bangers(
                          fontSize: 20,
                          color: store.color,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'Appuie pour ouvrir dans Maps',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: store.color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.directions_rounded,
                    color: store.color,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
