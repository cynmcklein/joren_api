import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Stock Market Table',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Stock> stocks = [];

  @override
  void initState() {
    super.initState();
    fetchStockData();
  }

  Future<void> fetchStockData() async {
    const List<String> symbols = ['AAPL', 'GOOGL', 'MSFT']; 
    const apiKey = 'RUC1QONF5ONVYL5I'; 

    for (final symbol in symbols) {
      final url =
          'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$apiKey';

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final stockData = Stock.fromJson(data);

          setState(() {
            stocks.add(stockData);
          });
        } else {
          print('Failed to fetch stock data for $symbol. Error: ${response.statusCode}');
        }
      } catch (e) {
        print('Failed to fetch stock data for $symbol. Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Stock Market Table'),
      ),
      body: stocks.isNotEmpty
          ? DataTable(
              columns: const [
                DataColumn(label: Text('Symbol')),
                DataColumn(label: Text('Company')),
                DataColumn(label: Text('Price')),
              ],
              rows: stocks.map((stock) {
                return DataRow(cells: [
                  DataCell(Text(stock.symbol)),
                  DataCell(Text(stock.company)),
                  DataCell(Text(stock.price.toString())),
                ]);
              }).toList(),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class Stock {
  final String symbol;
  final String company;
  final double price;

  const Stock({
    required this.symbol,
    required this.company,
    required this.price,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    final quoteData = json['Global Quote'] as Map<String, dynamic>;
    return Stock(
      symbol: quoteData['01. symbol'],
      company: quoteData['02. open'],
      price: double.parse(quoteData['05. price']),
    );
  }
}
