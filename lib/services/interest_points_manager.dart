import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ponto_interesse.dart';
import 'package:flutter/foundation.dart';

class InterestPointsManager {
  static const String _storageKey = 'pontos_interesse';
  final SharedPreferences _prefs;

  InterestPointsManager(this._prefs);

  static Future<InterestPointsManager> create() async {
    final prefs = await SharedPreferences.getInstance();
    return InterestPointsManager(prefs);
  }

  Future<List<PontoInteresse>> getPontos() async {
    try {
      final String? pontosJson = _prefs.getString(_storageKey);
      if (pontosJson == null) return [];

      final List<dynamic> decodedList = json.decode(pontosJson);
      return decodedList
          .map(
            (item) => PontoInteresse(
              item['nome'],
              item['descricao'],
              item['latitude'],
              item['longitude'],
            ),
          )
          .toList();
    } catch (e) {
      print('Erro ao carregar pontos: $e');
      return [];
    }
  }

  Future<bool> addPonto(PontoInteresse ponto) async {
    try {
      final pontos = await getPontos();
      debugPrint('Pontos existentes: ${pontos.length}');
      pontos.add(ponto);

      final List<Map<String, dynamic>> encodedList =
          pontos
              .map(
                (ponto) => {
                  'nome': ponto.nome,
                  'descricao': ponto.descricao,
                  'latitude': ponto.latitude,
                  'longitude': ponto.longitude,
                },
              )
              .toList();

      final result = await _prefs.setString(
        _storageKey,
        json.encode(encodedList),
      );
      debugPrint('Resultado do save: $result');
      return result;
    } catch (e) {
      debugPrint('Erro ao salvar ponto: $e');
      return false;
    }
  }

  Future<bool> removePonto(PontoInteresse ponto) async {
    try {
      final pontos = await getPontos();
      pontos.removeWhere(
        (p) =>
            p.nome == ponto.nome &&
            p.latitude == ponto.latitude &&
            p.longitude == ponto.longitude,
      );

      final List<Map<String, dynamic>> encodedList =
          pontos
              .map(
                (ponto) => {
                  'nome': ponto.nome,
                  'descricao': ponto.descricao,
                  'latitude': ponto.latitude,
                  'longitude': ponto.longitude,
                },
              )
              .toList();

      return await _prefs.setString(_storageKey, json.encode(encodedList));
    } catch (e) {
      print('Erro ao remover ponto: $e');
      return false;
    }
  }

  Future<bool> clearPontos() async {
    try {
      return await _prefs.remove(_storageKey);
    } catch (e) {
      print('Erro ao limpar pontos: $e');
      return false;
    }
  }
}
