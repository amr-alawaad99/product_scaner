import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:product_scanner/screens/add_products.dart';
import 'package:product_scanner/screens/products_details.dart';

import '../models/product.dart';

class FolderDetailsScreen extends StatefulWidget {
  final Directory folder;
  final File storeFile;

  const FolderDetailsScreen({super.key, required this.folder, required this.storeFile});

  @override
  State<FolderDetailsScreen> createState() => _FolderDetailsScreenState();
}

class _FolderDetailsScreenState extends State<FolderDetailsScreen> {
  File? file;

  @override
  void initState() {
    super.initState();
    _getProductsFile();
  }

  Future<void> _getProductsFile() async {
    List<FileSystemEntity> list = Directory(widget.folder.path).listSync();
    if(list.isNotEmpty){
      file = File(list.first.path);
    } else {
      await File("${widget.folder.path}/جدول 1.txt").create();
      file = File("${widget.folder.path}/جدول 1.txt");
    }
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddProducts(file: file!, storeFile: widget.storeFile,),));
              },
              child: const Text('إضافة منتج'),
            ),
            SizedBox(height: 50.h,),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProductsDetails(file: file!,),));
              },
              child: const Text('عرض المنتجات'),
            ),
          ],
        ),
      ),
    );
  }
}
