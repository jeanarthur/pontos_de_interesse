import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';

class GeocodingManager {
  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      if (kIsWeb) {
        // Tratamento específico para web
        return '$latitude, $longitude';
      }

      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final List<String> addressParts = [];

        if (place.locality?.isNotEmpty ?? false) {
          addressParts.add(place.locality!);
        } else if (place.subAdministrativeArea?.isNotEmpty ?? false) {
          addressParts.add(place.subAdministrativeArea!);
        }

        if (place.administrativeArea?.isNotEmpty ?? false) {
          addressParts.add(place.administrativeArea!);
        }

        return addressParts.isEmpty
            ? 'Localização não encontrada'
            : addressParts.join(', ');
      }
      return 'Localização não encontrada';
    } catch (e) {
      debugPrint('Erro ao obter endereço: $e');
      return 'Erro ao obter localização';
    }
  }
}
