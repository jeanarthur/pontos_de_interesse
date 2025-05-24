# Capturas de telas

## Exibição da latitude e longitude atual
![image](https://github.com/user-attachments/assets/406cf976-36b7-4e3c-8784-dc4e50865a64)

## Adição de pontos de interesse
![image](https://github.com/user-attachments/assets/d0d308f9-7193-4d37-9b33-4c54be720eef)

## Exibição da distância da posição atual para os pontos de interesse
![image](https://github.com/user-attachments/assets/26ed5595-dc97-42a1-9005-97a7d7904222)

# Lógica de implementação

## Localização

- Uso do pacote `geolocator`, em `lib\services\geolocator_manager.dart`. Captura do local atual através do método `determinePosition`.
```dart
Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  return await Geolocator.getCurrentPosition();
}
```

- O método é utilizado no componente `header.dart`, em `lib\components`, na função `_getCurrentLocation`. O método é executado no initState() e também pode ser chamado através do botão de recarregar.
```dart
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
```

## Distância

- Uso do pacote `geolocator`, em `lib\services\geolocator_manager.dart`. Captura do local atual através do método `distanceBetween`.
```dart
double distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude){
  return Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
}
```

- O método é utilizado no componente `interest_points_screen.dart`, em `lib\screens`, na função `_formatDistance`. O método é utilizado na construção do card que aparece na listagem de pontos de interesse, no momento de definir a distância.
```dart
String _formatDistance(PontoInteresse ponto) {
  if (_currentPosition == null) {
    return 'Calculando...';
  }

  final distance = _geolocatorManager.distanceBetween(
    _currentPosition!.latitude,
    _currentPosition!.longitude,
    ponto.latitude,
    ponto.longitude,
  );

  if (distance < 1000) {
    return '${distance.toStringAsFixed(0)} m';
  } else {
    return '${(distance / 1000).toStringAsFixed(1)} km';
  }
}
```
