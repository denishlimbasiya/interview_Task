// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product {
  final int id;
  final String title;
  final String description;
  final int price;
  final String featuredImage;
  final String createdAt;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.featuredImage,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      featuredImage: json['featured_image'],
      createdAt: json['created_at'],
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Product> products = [];
  int page = 1;
  bool isLoading = false;
  List<Product> cart = [];

  @override
  void initState() {
    super.initState();
    fetchProducts(page);
  }

  Future<void> fetchProducts(int page) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    final Map<String, String> headers = {
      'token': 'eyJhdWQiOiI1IiwianRpIjoiMDg4MmFiYjlmNGU1MjIyY2MyNjc4Y2FiYTQwOGY2MjU4Yzk5YTllN2ZkYzI0NWQ4NDMxMTQ4ZWMz',
    };

    final response = await http.get(
      Uri.parse(
          'http://209.182.213.242/~mobile/MtProject/public/api/product_list.php?page=$page'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<Product> productList = (jsonData['data'] as List)
          .map((item) => Product.fromJson(item))
          .toList();
      setState(() {
        products.addAll(productList);
        page++;
        isLoading = false;
      });
    }
  }

  void addToCart(Product product) {
    setState(() {
      cart.add(product);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product List',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Product List'),
        ),
        body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: products.length + 1, // Add 1 for the "Load More" button
          itemBuilder: (context, index) {
            if (index < products.length) {
              final product = products[index];
              return GestureDetector(
                onTap: () {
                  addToCart(product);
                },
                child: Card(
                  color: Colors.cyan,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CachedNetworkImage(
                        imageUrl: product.featuredImage,
                        width: 100,
                        placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20, left: 1),
                            child: Text(product.title),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else if (isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
