class Stock {

  final String currency;
  final String description;
  final String displaySymbol;
  final String figi;
  final String mic;
  final String symbol;
  final String type;

  Stock({
    required this.currency,
    required this.description,
    required this.displaySymbol,
    required this.figi,
    required this.mic,
    required this.symbol,
    required this.type
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      currency: json['currency'],
      description: json['description'],
      displaySymbol: json['displaySymbol'],
      figi: json['figi'],
      mic: json['mic'],
      symbol: json['symbol'],
      type: json['type'],
    );
  }

}