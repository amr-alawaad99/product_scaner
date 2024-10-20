
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

class ProductsDetails extends StatefulWidget {
  final File file;

  const ProductsDetails({super.key, required this.file});

  @override
  State<ProductsDetails> createState() => _ProductsDetailsState();
}

class _ProductsDetailsState extends State<ProductsDetails> {
  List<String> fileContents = [];

  Future<void> _loadFileContents() async {
    final File file = widget.file;

    if (await file.exists()) {
      List<String> lines = await file.readAsLines();
      setState(() {
        fileContents = lines;
      });
    } else {
      setState(() {
        fileContents = [];
      });
    }
  }

  Future<void> _exportFile() async {
    // Request permission before proceeding
    await _requestPermission();

    Uint8List fileBytes = await widget.file.readAsBytes();
    // Open a directory picker to choose where to save the file
    String? selectedPath = await FilePicker.platform.saveFile(
      type: FileType.custom,
      bytes: fileBytes,
      allowedExtensions: ['txt'], // Specify allowed file types
      fileName: "file.txt"
    );
  }

  Future<void> _requestPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<String?> _showFileNameDialog() async {
    TextEditingController fileNameController = TextEditingController();
    String? fileName;

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter File Name'),
          content: TextField(
            controller: fileNameController,
            decoration: InputDecoration(hintText: "File name"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                fileName = fileNameController.text.trim();
                Navigator.of(context).pop(fileName);
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadFileContents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المنتجات'),
        actions: [
          GestureDetector(
            onTap: _exportFile,
            child: Padding(
              padding: EdgeInsets.all(5.r),
              child: Row(
                children: [
                  const Text("حفظ الملف"),
                  SizedBox(width: 5.w,),
                  const Icon(Icons.save_alt),
                ],
              ),
            ),
          ),
        ],
      ),
      body: fileContents.isEmpty
          ? Container()
          : ListView.builder(
              itemCount: fileContents.length,
              itemBuilder: (context, index) {
                List<String> reversed = fileContents.reversed.toList();
                return ListTile(
                  title: Text(reversed[index]),
                );
              },
            ),
    );
  }
}
