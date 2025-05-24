class PontoInteresse {

  final String _nome;
  final String _descricao;
  final double _latitude;
  final double _longitude;

  String get nome => _nome;
  String get descricao => _descricao;
  double get latitude => _latitude;
  double get longitude => _longitude;

  PontoInteresse(this._nome, this._descricao, this._latitude, this._longitude);

  @override
  String toString() {
    return "Nome: $nome | Latitude: $latitude | Longitude: $longitude | Descrição: $descricao";
  }

}