import 'package:fl_chart/fl_chart.dart';

class StockCandles {

  final String s;
  final List<num>? c;
  final List<num>? t;

  late final List<FlSpot>? chart;

  StockCandles({
    required this.s,
    this.c,
    this.t,
  }) {
    createChart();
  }

  factory StockCandles.fromJson(Map<String, dynamic> json) {
    return StockCandles(
      s: json['s'],
      c: json['s'] == 'ok' ? json['c'].cast<num>() : null,
      t: json['s'] == 'ok' ? json['t'].cast<num>() : null,
    );
  }

  bool isSuccessful() {
    return s == 'ok';
  }

  void createChart() {
    chart = [];
    if(isSuccessful()) {
      for (int index = 0; index < c!.length; index++) {
        chart?.add(
            FlSpot(
                t!.elementAt(index).toDouble(),
                c!.elementAt(index).toDouble()
            )
        );
      }
    }
  }

}