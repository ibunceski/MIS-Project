class Issuer {
  final String symbol;

  Issuer({required this.symbol});

  factory Issuer.fromJson(String symbol) {
    return Issuer(symbol: symbol);
  }
}
