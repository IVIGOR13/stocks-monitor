import 'package:volga_1/model/stock_socket_price.dart';

class StockSocketPriceRequest {

  final String type;
  final List<StockSocketPrice> data;

  StockSocketPriceRequest({
    required this.type,
    required this.data,
  });

  factory StockSocketPriceRequest.fromJson(Map<String, dynamic> json) {
    return StockSocketPriceRequest(
      type: json['type'],
      data: json['type'] == 'trade' ?
      json['data']
          .map<StockSocketPrice>((element) {
        return StockSocketPrice.fromJson(element);
      })
          .toList()
          : [],
    );
  }

  bool hasData() {
    return type == 'trade';
  }

  StockSocketPrice? getBySymbol(String symbol) {
    if(hasData()) {
      for (var elem in data.reversed) {
        if (elem.s == symbol) {
          return elem;
        }
      }
      return null;
    } else {
      return null;
    }
  }

}