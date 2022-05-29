import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:volga_1/api/stocks_api.dart';
import 'package:volga_1/model/stock_socket_price.dart';
import 'package:volga_1/widgets/card_stock.dart';
import 'package:volga_1/model/stock.dart';

import 'package:animations/animations.dart';

import '../model/stock_socket_price_request.dart';
import 'details.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  final String title = 'Finnhub';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  StocksApi stocksApi = StocksApi();
  late List<Stock> _stocks = [];
  late List<Stock> _stockList = [];
  late Future<void> _initStockData;

  late Icon customIcon;
  late Widget customSearchBar;
  String searchSymbol = '';

  late Stream _stream;

  final ContainerTransitionType _transitionType = ContainerTransitionType.fade;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    stocksApi.connectWebSocket();
    _stream = stocksApi.getStreamWebSocket();

    _initStockData = _initStocks();

    customIcon = const Icon(Icons.search);
    customSearchBar = Text(
      widget.title,
      style: const TextStyle(fontSize: 24.0),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        titleSpacing: 16,
        title: customSearchBar,
        centerTitle: true,
        actions: [
          Container(
            child: IconButton(
              onPressed: () {
                setState(() {
                  if (customIcon.icon == Icons.search) {
                    customIcon = const Icon(Icons.cancel);
                    customSearchBar = ListTile(
                      title: TextField(
                        controller: TextEditingController(text: searchSymbol),
                        decoration: const InputDecoration(
                          hintText: 'enter symbol',
                          hintStyle: TextStyle(
                            color: Colors.white54,
                            fontSize: 18,
                          ),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        onChanged: (text) {
                          searchSymbol = text.toString().toUpperCase();
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          customIcon = const Icon(Icons.search);
                          customSearchBar = Text(
                            widget.title,
                            style: const TextStyle(fontSize: 24.0),
                          );
                          setState(() {
                            _initStockData = _initStocks();
                          });
                        },
                      ),
                    );
                  } else {
                    customIcon = const Icon(Icons.search);
                    customSearchBar = Text(
                      widget.title,
                      style: const TextStyle(fontSize: 24.0),
                    );
                  }
                });
              },
              icon: customIcon,
            ),
            margin: const EdgeInsets.only(right: 24.0)
          )
        ],
      ),
      body: FutureBuilder(
          future: _initStockData,
          builder: (context, snapshot) {
            switch(snapshot.connectionState) {
              case ConnectionState.done:
                {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "${snapshot.error}",
                        style: const TextStyle(
                          fontSize: 20.0,
                      ),
                      )
                    );
                  }
                  if(_stockList.isEmpty) {
                    return const Center(
                      child: Text(
                        'Stocks not found',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 20.0
                        ),
                      )
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshStocks,
                    child: StreamBuilder(
                      stream: _stream,
                      builder: (streamContext, streamSnapshot) {
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                          padding: const EdgeInsets.only(bottom: 8.0, top: 0),
                          itemCount: _stockList.length,
                          itemBuilder: (BuildContext contextList, int index) {

                            StockSocketPrice? socketData;
                            if(streamSnapshot.hasData) {
                              final priceRequest = StockSocketPriceRequest.fromJson(jsonDecode(streamSnapshot.data.toString()));
                              socketData = priceRequest.getBySymbol(_stockList[index].symbol);
                            }

                            return OpenContainer(
                              transitionType: _transitionType,
                              closedColor: const Color(0xFF191720),
                              openColor: const Color(0xFF191720),
                              openBuilder: (context, openContainer) {
                                //_streamSubscription.pause();
                                return DetailsPage(
                                  stock: _stockList[index],
                                );
                              },
                              closedBuilder: (context, closedContainer) {
                                //_streamSubscription.resume();
                                return StockCard(
                                  stock: _stockList[index],
                                  subscribe: () async => stocksApi.subscribeWebSocket(_stockList[index].symbol),
                                  unsubscribe: () async => stocksApi.unsubscribeWebSocket(_stockList[index].symbol),
                                  socketData: socketData,
                                  onTap: () => closedContainer(),
                                );
                              },
                              tappable: false,
                            );

                          },
                        );
                      },
                    ),
                  );
                }
              default:
                return const Center(
                  child: CircularProgressIndicator()
                );
            }
          },
        ),
    );
  }

  Future<void> _initStocks() async {
    final result = await stocksApi.getAllStocks(symbol: searchSymbol);
    _stocks = result;
    _stockList = _stocks;
  }

  Future<void> _refreshStocks() async {
    final result = await stocksApi.getAllStocks(symbol: searchSymbol);
    setState(() {
      _stocks = result;
      _stockList = _stocks;
    });
  }

  @override
  void dispose() {
    stocksApi.closeWebSocket();
    super.dispose();
  }

}