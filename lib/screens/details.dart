import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:volga_1/model/stock.dart';
import 'package:volga_1/model/stock_candles.dart';
import 'package:volga_1/widgets/button_period.dart';
import 'package:volga_1/widgets/chart.dart';

import '../api/stocks_api.dart';
import '../model/periods.dart';
import '../model/stock_price.dart';
import '../model/stock_socket_price.dart';
import '../model/stock_socket_price_request.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({
    Key? key,
    required this.stock,
  }) : super(key: key);

  final Stock stock;

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {

  StocksApi stocksApi = StocksApi();
  late Future<StockPrice> futurePrice;
  late Future<void> _initSpotsData;
  late StockCandles _stockCandles;
  late Stream _stream;
  int _currentPeriod = 3;
  double? price;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _stream = stocksApi.getStreamWebSocket();
    futurePrice = stocksApi.getStockPrice(symbol: widget.stock.symbol);
    _initSpotsData = _initSpots();
    stocksApi.subscribeWebSocket(widget.stock.symbol);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        titleSpacing: 27,
        title: Text(
          widget.stock.symbol,
          style: const TextStyle(fontSize: 24.0),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: (streamContext, streamSnapshot) {

          StockSocketPrice? socketData;
          if(streamSnapshot.hasData) {
            final priceRequest = StockSocketPriceRequest.fromJson(jsonDecode(streamSnapshot.data.toString()));
            socketData = priceRequest.getBySymbol(widget.stock.symbol);
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    FutureBuilder<StockPrice>(
                      future: futurePrice,
                      builder: (context, snapshot) {

                        if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        if (snapshot.hasData) {
                          price = socketData != null
                              ? socketData.p.toDouble()
                              : price ?? snapshot.data!.getPrice();

                          return Text(
                              price.toString() + ' ' +
                                  (widget.stock.currency == 'USD'
                                      ? "\$"
                                      : widget.stock.currency),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              )
                          );
                        }
                        return const Text('loading...');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              FutureBuilder(
                future: _initSpotsData,
                builder: (context, snapshot) {
                  switch(snapshot.connectionState) {
                    case ConnectionState.done:
                      {
                        if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }

                        if(!_stockCandles.isSuccessful()) {
                          return Center(
                            child: Column(
                              children: <Widget> [
                                const SizedBox(
                                  height: 53+32+6,
                                ),
                                SizedBox(
                                  height: MediaQuery
                                      .of(context)
                                      .size
                                      .height * 0.35,
                                  child: const Center(
                                      child: Text(
                                        'No data for this period',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 20.0
                                        ),
                                      ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        double percent = ((_stockCandles.chart!.last.y / _stockCandles.chart!.first.y - 1.0)*10000).round()/100;

                        return Column(
                          children: <Widget> [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                '${percent >= 0.0 ? '+' : ''} $percent %',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: percent >= 0.0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 70,
                            ),
                            SizedBox(
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.35,
                              child: SpotsChart(
                                  listSpots: _stockCandles.chart!,
                                  currency: widget.stock.currency == 'USD'
                                      ? '\$'
                                      : widget.stock.currency,
                              ),
                            ),
                          ],
                        );
                      }
                    default:
                      return Center(
                        child: Column(
                          children: <Widget> [
                            const SizedBox(
                              height: 53+32+6,
                            ),
                            SizedBox(
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.35,
                              child: const Center(
                                  child: CircularProgressIndicator()
                              ),
                            ),
                          ],
                        ),
                      );
                  }
                },
              ),
              const SizedBox(
                height: 38,
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var index = 0; index < Periods.values.length; index++)
                      ButtonPeriod(
                        onTap: () {
                          _currentPeriod = index;
                          _initSpots();
                        },
                        active: _currentPeriod == index,
                        text: Periods.values[index].name,
                      )
                  ],
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Future<void> _initSpots() async {
    final result = await stocksApi.getSpots(
      symbol: widget.stock.symbol,
      resolution: Periods.values[_currentPeriod].resolution,
      from: DateTime.now().millisecondsSinceEpoch~/1000 - Periods.values[_currentPeriod].timeInterval,
      to: DateTime.now().millisecondsSinceEpoch~/1000,
    );
    setState(() {
      _stockCandles = result;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

}