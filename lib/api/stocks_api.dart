import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:volga_1/model/stock.dart';
import 'package:volga_1/model/stock_candles.dart';
import 'package:volga_1/model/stock_price.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class StocksApi {

  static final StocksApi _instance = StocksApi._internal();

  factory StocksApi() {
    return _instance;
  }

  StocksApi._internal();

  final String token = 'c8l4s7qad3icvur3n7fg';
  final String _baseAPIUrl = 'https://finnhub.io/api/v1';

  late WebSocketChannel _channel;
  late Stream _channelStream;


  void connectWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://ws.finnhub.io?token=$token'),
    );
    _channelStream = _channel.stream.asBroadcastStream();
  }

  Stream getStreamWebSocket() {
    return StreamController.broadcast().stream;
  }

  void subscribeWebSocket(String symbol) {

    _channel.sink.add('{"type":"subscribe","symbol":"$symbol"}');
  }

  void unsubscribeWebSocket(String symbol) {
    _channel.sink.add('{"type":"unsubscribe","symbol":"$symbol"}');

  }

  void closeWebSocket() => _channel.sink.close();

  Future<List<Stock>> getAllStocks({String symbol = ''}) async {
    final response = await http
      .get(Uri.parse(
        '$_baseAPIUrl/stock/symbol?'
        'exchange=US'
        '&token=$token'
    ));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((stock) => Stock.fromJson(stock))
          .where((stock) => stock.symbol.contains(symbol) || stock.description.contains(symbol))
          .toList();
    } if (response.statusCode == 429) {
      throw 'API limit on requests per minute reached';
    } else {
      throw Exception('sc ' + response.statusCode.toString());
    }
  }

  Future<StockPrice> getStockPrice({String symbol = ''}) async {
    final response = await http
      .get(Uri.parse(
        '$_baseAPIUrl/quote?'
        'symbol=$symbol'
        '&token=$token'
    ));

    if (response.statusCode == 200) {
      return StockPrice.fromJson(jsonDecode(response.body));
    } if (response.statusCode == 429) {
      throw 'API limit';
    } else {
      throw Exception('sc ' + response.statusCode.toString());
    }
  }

  Future<StockCandles> getSpots({
    String symbol = '',
    required String resolution,
    required num from,
    required num to
  }) async {
    final response = await http
      .get(Uri.parse(
        '$_baseAPIUrl/stock/candle?'
        'symbol=$symbol'
        '&resolution=$resolution'
        '&from=$from'
        '&to=$to'
        '&token=$token'
    ));

    if (response.statusCode == 200) {
      return StockCandles.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('sc ' + response.statusCode.toString());
    }
  }

}