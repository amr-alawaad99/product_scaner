import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:product_scanner/screens/add_products.dart';

import '../models/product.dart';

class FolderDetailsScreen extends StatefulWidget {
  final Directory folder;

  const FolderDetailsScreen({super.key, required this.folder});

  @override
  State<FolderDetailsScreen> createState() => _FolderDetailsScreenState();
}

class _FolderDetailsScreenState extends State<FolderDetailsScreen> {
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final productFile = File('${widget.folder.path}/products.json');
    if (productFile.existsSync()) {
      final content = await productFile.readAsString();
      final List<Product> productList = (content.isNotEmpty)
          ? (content as List).map((e) => Product.fromJson(e)).toList()
          : [];
      setState(() {
        _products = productList;
      });
    }
  }

  Future<void> _saveProducts() async {
    final productFile = File('${widget.folder.path}/products.json');
    final productJson = _products.map((e) => e.toMap()).toList();
    await productFile.writeAsString(productJson.toString());
  }

  void _addProduct() {
    int code = 0;
    int quantity = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Product Name'),
                onChanged: (value) {
                  code = int.parse(value);
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  quantity = int.tryParse(value) ?? 0;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _products.add(Product(code: code, quantity: quantity));
                });
                _saveProducts();
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showProducts() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Products'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return ListTile(
                  title: Text(product.code.toString()),
                  subtitle: Text('Quantity: ${product.quantity}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.folder.path.split('/').last)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddProducts(folder: widget.folder,),));
              },
              child: const Text('إضافة منتج'),
            ),
            SizedBox(height: 50.h,),
            ElevatedButton(
              onPressed: _showProducts,
              child: const Text('عرض المنتجات'),
            ),
          ],
        ),
      ),
    );
  }
}
