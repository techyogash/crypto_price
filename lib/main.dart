import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(CryptoTrackerApp());
}

class CryptoTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crypto Tracker',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: CryptoListScreen(),
    );
  }
}

class CryptoListScreen extends StatefulWidget {
  @override
  _CryptoListScreenState createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> {
  late Future<List<CryptoCurrency>> cryptoList;

  @override
  void initState() {
    super.initState();
    cryptoList = fetchCryptoData();
  }

  Future<List<CryptoCurrency>> fetchCryptoData() async {
    final url = Uri.parse(
      'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => CryptoCurrency.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load crypto data');
      }
    } catch (e) {
      throw Exception('No Internet or API error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Crypto Prices'), centerTitle: true),
      body: FutureBuilder<List<CryptoCurrency>>(
        future: cryptoList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        cryptoList = fetchCryptoData();
                      });
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            final cryptos = snapshot.data!;
            return ListView.builder(
              itemCount: cryptos.length,
              itemBuilder: (context, index) {
                final crypto = cryptos[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  child: ListTile(
                    leading: Image.network(
                      crypto.imageUrl,
                      width: 40,
                      height: 40,
                    ),
                    title: Text(crypto.name),
                    subtitle: Text(crypto.symbol.toUpperCase()),
                    trailing: Text(
                      '\$${crypto.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class CryptoCurrency {
  final String name;
  final String symbol;
  final double price;
  final String imageUrl;

  CryptoCurrency({
    required this.name,
    required this.symbol,
    required this.price,
    required this.imageUrl,
  });

  factory CryptoCurrency.fromJson(Map<String, dynamic> json) {
    return CryptoCurrency(
      name: json['name'],
      symbol: json['symbol'],
      price: json['current_price'].toDouble(),
      imageUrl: json['image'],
    );
  }
}
