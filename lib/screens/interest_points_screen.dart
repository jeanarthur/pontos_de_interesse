import 'package:flutter/material.dart';
import '../components/header.dart';
import '../models/ponto_interesse.dart';
import '../services/geolocator_manager.dart';
import 'package:geolocator/geolocator.dart';
import '../services/interest_points_manager.dart';
import '../screens/register_point_screen.dart';

class InterestPointsScreen extends StatefulWidget {
  const InterestPointsScreen({super.key});

  @override
  State<InterestPointsScreen> createState() => _InterestPointsScreenState();
}

class _InterestPointsScreenState extends State<InterestPointsScreen> {
  final GeolocatorManager _geolocatorManager = GeolocatorManager();
  InterestPointsManager? _pointsManager;
  Position? _currentPosition;
  List<PontoInteresse> _pontos = [];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _initializeManagers();
    await _getCurrentLocation();
  }

  Future<void> _initializeManagers() async {
    _pointsManager = await InterestPointsManager.create();
    await _loadPontos();
  }

  Future<void> _loadPontos() async {
    if (_pointsManager == null) {
      debugPrint('PointsManager é nulo em loadPontos!');
      return;
    }
    final pontos = await _pointsManager!.getPontos();
    debugPrint('Pontos carregados: ${pontos.length}');
    setState(() {
      _pontos = pontos;
    });
  }

  Future<void> _addPonto(PontoInteresse ponto) async {
    debugPrint('Tentando adicionar ponto: ${ponto.toString()}');
    if (_pointsManager == null) {
      debugPrint('PointsManager é nulo!');
      return;
    }
    final success = await _pointsManager!.addPonto(ponto);
    debugPrint('Resultado do addPonto: $success');
    if (success) {
      await _loadPontos();
    }
  }

  Future<void> _removePonto(PontoInteresse ponto) async {
    if (_pointsManager == null) return;
    final success = await _pointsManager!.removePonto(ponto);
    if (success) {
      await _loadPontos();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _geolocatorManager.determinePosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      debugPrint('Erro ao obter localização: $e');
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        titlePlaceholder: 'Pontos de Interesse',
        onLocationUpdate: (Position position) {
          setState(() {
            _currentPosition = position;
          });
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                if (_pointsManager == null) {
                  await _initializeManagers();
                }

                final result = await showDialog<PontoInteresse>(
                  context: context,
                  builder:
                      (context) => Dialog(
                        child: RegisterPointScreen(
                          currentPosition: _currentPosition,
                        ),
                      ),
                );

                if (result != null) {
                  await _addPonto(result);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.lerp(Colors.red, Colors.black, 0.2)!,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 8),
                  Text(
                    'Adicionar Ponto',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _pontos.length,
              itemBuilder: (context, index) {
                final ponto = _pontos[index];
                return Dismissible(
                  key: Key(ponto.toString()),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => _removePonto(ponto),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  ponto.nome,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removePonto(ponto),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                splashRadius: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Latitude: ${ponto.latitude}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Longitude: ${ponto.longitude}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ponto.descricao,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Distância: ${_formatDistance(ponto)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
