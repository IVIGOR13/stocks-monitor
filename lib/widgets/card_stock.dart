import 'package:flutter/material.dart';
import 'package:volga_1/api/stocks_api.dart';
import 'package:volga_1/model/stock.dart';
import 'package:volga_1/model/stock_socket_price.dart';

import '../model/stock_price.dart';

class StockCard extends StatefulWidget {

  const StockCard({
    Key? key,
    required this.stock,
    required this.subscribe,
    required this.unsubscribe,
    this.socketData,
    required this.onTap,
  }) : super(key: key);

  final Stock stock;
  final Function subscribe;
  final Function unsubscribe;
  final Function onTap;

  final StockSocketPrice? socketData;

  @override
  State<StatefulWidget> createState() => _StockCardState();
}

class _StockCardState extends State<StockCard> {

  late StocksApi stocksApi = StocksApi();
  late Future<StockPrice> futurePrice;
  double? price;

  @override
  void initState() {
    super.initState();
    futurePrice = stocksApi.getStockPrice(symbol: widget.stock.symbol);
    widget.subscribe();
  }

  String getPrice(double? snapshot) {
    price = widget.socketData != null
        ? widget.socketData!.p.toDouble()
        : price ?? snapshot;

    return price.toString() + ' ' +
        (widget.stock.currency == 'USD'
            ? "\$"
            : widget.stock.currency);
  }

  String getPercent(double? snapshot) {
    return (snapshot! > 0 ? '+' : '') + ((snapshot*100).round()/100).toString() + "%";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0, left: 27.0, right: 27.0),
      color: const Color(0xFF201E27),
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
        onTap: () {
          widget.onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      widget.stock.symbol,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child:Text(
                      widget.stock.description,
                      style: const TextStyle(fontSize: 10.0),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FutureBuilder<StockPrice>(
                future: futurePrice,
                builder: (context, snapshot) {
                  if(snapshot.hasError) {
                    if(snapshot.error == 'API limit') {
                      return Text("${snapshot.error}");
                    } else {
                      return const Text("error");
                    }
                    /*return Flexible(
                      child:Text(
                        "${snapshot.error}",
                        overflow: TextOverflow.ellipsis,
                      ),
                    );*/
                  }
                  if(snapshot.hasData) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            getPrice(snapshot.data!.getPrice()),
                            style: const TextStyle(
                              fontSize: 13.0,
                            ),
                        ),
                        Visibility(
                          visible: snapshot.data!.getPercent() != 0.0,
                          child: Text(
                            getPercent(snapshot.data!.getPercent()),
                            style: TextStyle(
                                fontSize: 11.0,
                                color: snapshot.data!.getPercent() >= 0.0
                                    ? Colors.green
                                    : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return const Text('loading...');
                }
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    widget.unsubscribe();
    super.dispose();
  }

}