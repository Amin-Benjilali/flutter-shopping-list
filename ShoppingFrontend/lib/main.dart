// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Product>> fetchProducts() async {
  final response = await http
      .get(Uri.parse('https://shoppinglist-amin.azurewebsites.net/api/Items'));

  if (response.statusCode == 200) {
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();

    return parsed.map<Product>((json) => Product.fromMap(json)).toList();
  } else {
    throw Exception('Failed to load products');
  }
}

class Product {
  final String id;
  final String name;
  final String quantity;
  final bool bought;

  const Product({
    required this.id,
    required this.name,
    required this.quantity,
    required this.bought,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        id: json['id'],
        name: json['name'],
        quantity: json['quantity'],
        bought: json['bought']);
  }

  factory Product.fromMap(Map<String, dynamic> json) => Product(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      bought: json['bought']);
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Product>> futureProduct;

  @override
  void initState() {
    super.initState();
    futureProduct = fetchProducts();
  }

  final _biggerFont = const TextStyle(fontSize: 18.0);
  final _bought = <Product>{};

  Widget _buildRow(Product product) {
    final alreadyBought = _bought.contains(product);
    return ListTile(
      title: Text(
        product.name + ' (' + product.quantity + ')',
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadyBought || product.bought ? Icons.favorite : Icons.favorite_border,
        color: alreadyBought || product.bought ? Colors.red : null,
        semanticLabel: alreadyBought || product.bought ? 'Remove from saved' : 'Save',
      ),
      onTap: () {
        setState(() {
          if (alreadyBought) {
            _bought.remove(product);
          } else {
            _bought.add(product);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Shopping list',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Shopping list'),
            actions: [
              IconButton(
                icon: const Icon(Icons.list),
                onPressed: _pushSaved,
                tooltip: 'Saved Suggestions',
              ),
            ],
          ),
          body: Center(
            child: FutureBuilder<List<Product>>(
              future: futureProduct,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return _buildRow(snapshot.data![index]);
                    });
              },
            ),
          ),
        ));
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _bought.map(
            (product) {
              return ListTile(
                title: Text(
                  product.name + ' (' + product.quantity + ')',
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
                  context: context,
                  tiles: tiles,
                ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }
}
