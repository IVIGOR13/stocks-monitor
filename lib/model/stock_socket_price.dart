class StockSocketPrice {

  final String s;
  final num p;
  final num t;

  StockSocketPrice({
    required this.p,
    required this.s,
    required this.t,
  });

  factory StockSocketPrice.fromJson(Map<String, dynamic> json) {
    return StockSocketPrice(
        s: json['s'],
        p: json['p'],
        t: json['t'],
    );
  }

}