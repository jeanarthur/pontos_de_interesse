import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/geolocator_manager.dart';
import '../services/geocoding_manager.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  final String titlePlaceholder;
  final Function(Position)? onLocationUpdate;

  const Header({
    super.key,
    this.titlePlaceholder = 'Pontos de interesse',
    this.onLocationUpdate,
  });

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  Position? currentPosition;
  String currentAddress = '';
  final GeolocatorManager _geolocatorManager = GeolocatorManager();
  final GeocodingManager _geocodingManager = GeocodingManager();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      debugPrint('Obtendo localização...');
      final position = await _geolocatorManager.determinePosition();
      final address = await _geocodingManager.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      setState(() {
        currentPosition = position;
        currentAddress = address;
      });
      widget.onLocationUpdate?.call(position);
    } catch (e) {
      // Você pode adicionar um tratamento de erro mais específico aqui se desejar
      debugPrint('Erro ao obter localização: $e');
    }
  }

  String _formatLocation() {
    if (currentPosition == null) {
      return 'Obtendo localização...';
    }
    return 'Latitude: ${currentPosition!.latitude.toStringAsFixed(4)}, Longitude: ${currentPosition!.longitude.toStringAsFixed(4)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.lerp(Colors.red, Colors.black, 0.5)!,
            Color.lerp(Colors.red, Colors.black, 0.2)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Text(
              widget.titlePlaceholder,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    currentAddress.isEmpty
                        ? 'Buscando localização...'
                        : currentAddress,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0.5, 0.5),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _getCurrentLocation,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 22,
                  splashRadius: 24,
                  tooltip: 'Atualizar localização',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
