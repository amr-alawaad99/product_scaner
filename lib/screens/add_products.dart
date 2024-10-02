import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:product_scanner/widgets/custom_button.dart';

import '../models/product.dart';

class AddProducts extends StatefulWidget {
  final Directory folder;
  const AddProducts({super.key, required this.folder});

  @override
  State<AddProducts> createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  final TextEditingController _productCode = TextEditingController();
  final TextEditingController _productQuantity = TextEditingController();
  final FocusNode _productNameFocusNode = FocusNode();  // Define a FocusNode for the product name field
  final List<Product> _products = [];

  String _scanResult = '';

  Future<void> scanQRCode() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Customizable scanner overlay color
        'Cancel', // Text for the cancel button
        true, // Show flash icon
        ScanMode.DEFAULT, // scan both qrcode and barcode
      );

      if (barcodeScanRes != '-1') {
        // '-1' means scan was cancelled
        setState(() {
          _scanResult = barcodeScanRes;
        });
      }
    } catch (e) {
      setState(() {
        _scanResult = 'Failed to scan the QR code.';
      });
    }
  }

  @override
  void dispose() {
    _productCode.dispose();
    _productQuantity.dispose();
    _productNameFocusNode.dispose(); // Dispose the focus node when the widget is disposed
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إضافة منتج"),),
      body: Padding(
        padding: EdgeInsets.all(10.r),
        child: Column(
          children: [
            /// Add product
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    focusNode: _productNameFocusNode,
                    controller: _productCode,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'كود المنتج',
                    ),
                  ),
                ),
                SizedBox(width: 10.w,),
                SizedBox(
                  width: 50.w,
                  child: TextFormField(
                    controller: _productQuantity,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'العدد',
                    ),
                    onFieldSubmitted: (value) {
                      setState(() {
                        _products.add(Product(code: int.parse(_productCode.text), quantity: int.parse(_productQuantity.text)));
                        _productCode.clear();
                        _productQuantity.clear();
                        // Request focus on the product name field
                        _productNameFocusNode.requestFocus();
                      });
                    },
                  ),
                ),
              ]
            ),
            SizedBox(height: 15.h,),
            Text(_scanResult),
            SizedBox(height: 15.h,),
            /// Added Products List
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final Product product = _products[index];
                  return Row(
                    children: [
                      Expanded(child: Text(product.code.toString(), style: TextStyle(fontSize: 15.sp),)),
                      Text(product.quantity.toString()),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _products.removeAt(index);
                            });
                          },
                          icon: const Icon(CupertinoIcons.xmark)),
                    ]
                );
                },
                separatorBuilder: (context, index) =>  const Divider(),
                itemCount: _products.length,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 50.h,
        padding: EdgeInsets.all(5.r),
        child: CustomButton(innerText: "Add Product", onPressed: () {
          setState(() {
            _products.add(Product(code: int.parse(_productCode.text), quantity: int.parse(_productQuantity.text)));
            _productCode.clear();
            _productQuantity.clear();
            // Request focus on the product name field
            _productNameFocusNode.requestFocus();
          });
        },),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () async {
          _productCode.clear();
          await scanQRCode();
          _productCode.text = _scanResult;
        },
        child: Icon(CupertinoIcons.qrcode_viewfinder, size: 30.r,),
      ),
    );
  }
}
