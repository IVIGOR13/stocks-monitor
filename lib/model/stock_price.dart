class StockPrice {

  final num c;
  final num? d;
  final num dp;
  final num? h;
  final num? l;
  final num? o;
  final num? pc;

  StockPrice({
    required this.c,
    required this.d,
    required this.dp,
    required this.h,
    required this.l,
    required this.o,
    required this.pc,
  });

  factory StockPrice.fromJson(Map<String, dynamic> json) {
    return StockPrice(
      c: json['c'],
      d: json['d'],
      dp: json['dp'],
      h: json['h'],
      l: json['l'],
      o: json['o'],
      pc: json['pc']
    );
  }

  double getPrice() {
    return ((c*100).round()/100).toDouble();
  }

  double getPercent()  {
    return ((dp*100).round()/100).toDouble();
  }

}