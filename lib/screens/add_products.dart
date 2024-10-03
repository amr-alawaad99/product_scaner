import 'dart:developer';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:product_scanner/widgets/custom_button.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../models/product.dart';

class AddProducts extends StatefulWidget {
  final File file;
  final File storeFile;
  const AddProducts({super.key, required this.file, required this.storeFile});

  @override
  State<AddProducts> createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  final TextEditingController _productCode = TextEditingController();
  final TextEditingController _productQuantity = TextEditingController();
  final FocusNode _productNameFocusNode = FocusNode();  // Define a FocusNode for the product name field
  final List<Product> _products = [];
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? scannerController;
  AudioPlayer audioPlayer = AudioPlayer();
  bool newItem = false;
  File storeFile = File("/data/data/com.example.product_scanner/app_flutter/StoreData/store_file.txt");
  List<String> storeFileContent = [];
  String? itemDescription;

  @override
  void initState() {
    super.initState();
    getMainStoreFileProductDetails();
  }

  getMainStoreFileProductDetails() async {
    // Read the file contents as a string
    String fileContent = await widget.storeFile.readAsString();

    // Split the file content by lines
    List<String> lines = fileContent.split('\n');
    storeFileContent = lines;
  }


  void _onQRViewCreated(QRViewController controller) {
    scannerController = controller;
    bool isScanning = false; // A flag to prevent continuous scanning
    controller.scannedDataStream.listen((scanData) async {
      newItem = false;
      if (!isScanning) {
        int code = int.parse(scanData.code!);
        setState(() {
          if(_products.where((element) => element.code == code,).isNotEmpty){
            int t = _products.where((element) => element.code == code,).first.quantity!;
            _products.where((element) => element.code == code,).first.quantity = t+1;
          } else {
            _products.add(Product(code: int.parse(scanData.code!), quantity: 1, isNew: newItem));
            print(_products.last.code);
          }
          for(String line in storeFileContent){
            if(line.split(",").first == scanData.code!){
              newItem = false;
              itemDescription = line;
              return;
            }
            newItem = true;
          }
          _products.last.isNew = newItem;
        });

        isScanning = true; // Disable further scans temporarily

        // Play the scanning sound
        await audioPlayer.play(AssetSource('scan_sound.mp3'));

        // Wait for 1 second before allowing another scan
        await Future.delayed(const Duration(seconds: 1));

        isScanning = false; // Re-enable scanning after the delay
      }
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    if (scannerController != null) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        scannerController!.pauseCamera();
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        scannerController!.resumeCamera();
      }
    }
  }

  // Read products from the file
  Future<List<Product>> readProductsFromFile() async {
    try {
      File file = widget.file;


      // Read the file as a list of strings, where each line is a product
      List<String> lines = await file.readAsLines();

      // Convert each line back into a Product object
      List<Product> products = lines.map((line) => Product.fromFormattedString(line)).toList();
      return products;
    } catch (e) {
      print('Error reading products from file: $e');
      return [];
    }
  }

// Write the updated list of products back to the file
  Future<void> writeProductsToFile(List<Product> products) async {
    try {
      File file = widget.file;

      // Convert each product to the formatted string and join them with new lines
      List<String> lines = products.map((product) => product.toFormattedString()).toList();

      // Write the list of lines to the file
      await file.writeAsString(lines.join('\n'), flush: true);
      print('Products saved to: ${file.path}');
    } catch (e) {
      print('Error writing products to file: $e');
    }
  }

// Add or update product in the file
  Future<void> addOrUpdateProduct(Product newProduct) async {
    List<Product> products = await readProductsFromFile();

    // Check if the product exists
    int existingIndex = products.indexWhere((product) => product.code == newProduct.code);
    print(existingIndex);

    if (existingIndex != -1) {
      int newQuantity = newProduct.quantity!;
      int oldQuantity = products[existingIndex].quantity!;
      // If product exists, update its quantity
      products[existingIndex].quantity =  oldQuantity + newQuantity;
    } else {
      // If product does not exist, add it to the list
      products.add(newProduct);
    }

    // Write the updated list back to the file
    await writeProductsToFile(products);
  }

  @override
  void dispose() {
    _productCode.dispose();
    _productQuantity.dispose();
    _productNameFocusNode.dispose();
    scannerController?.dispose();
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
            if(newItem)
              Container(
                color: Colors.redAccent,
                width: double.infinity,
                alignment: Alignment.center,
                height: 50.h,
                child: Text("منتج جديد: كود ${_products.last.code}"),
              )
            else
              Container(
                color: CupertinoColors.systemYellow,
                width: double.infinity,
                alignment: Alignment.center,
                height: 50.h,
                child: Text(itemDescription?? ""),
              ),
            SizedBox(height: 10.h,),
            /// Camera Scanner
            SizedBox(
              width: double.infinity,
              height: 100.h,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(borderColor: Colors.red),
              ),
            ),
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
                        try {
                          _products.add(Product(code: int.parse(_productCode.text), quantity: int.parse(_productQuantity.text)));
                          _productCode.clear();
                          _productQuantity.clear();
                          // Request focus on the product name field
                          _productNameFocusNode.requestFocus();
                        } on Exception catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("برجاء إدخال البياتات بشكل صحيح"), backgroundColor: Colors.redAccent,),
                          );
                        }
                      });
                    },
                  ),
                ),
              ]
            ),
            SizedBox(height: 15.h,),
            /// Added Products List
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final Product product = _products[index];
                  return Container(
                    color: product.isNew!? Colors.redAccent : Colors.transparent,
                    child: Row(
                      children: [
                        Expanded(child: Text(product.code.toString(), style: TextStyle(fontSize: 15.sp),)),
                        SizedBox(
                          width: 50.w,
                          child: TextFormField(
                            controller: TextEditingController(text: product.quantity.toString()),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            onChanged: (value) {
                              if(value.isEmpty){
                                value = 0.toString();
                              }
                              product.quantity = int.parse(value);
                            },
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                _products.removeAt(index);
                              });
                            },
                            icon: const Icon(CupertinoIcons.xmark)),
                      ]
                    ),
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
        child: CustomButton(innerText: "اضافة المنتجات", onPressed: () async {

            for(Product product in _products){
              print("${product.code}   ${_products.length}");
              // Add or update the product in the file
              await addOrUpdateProduct(product);
            }
            setState(() {
              _products.clear();
              itemDescription = '';
            });
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("تم إضافة المنتجات"))
            );

        },),
      ),
    );
  }
}
