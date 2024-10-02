import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:product_scanner/widgets/custom_button.dart';
import 'folder_details.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Directory _appDir;
  List<Directory> _folders = [];
  final TextEditingController folderName = TextEditingController();
  String? _importedFileContent;

  @override
  void initState() {
    super.initState();
    _getAppDirectory();
  }

  Future<void> _getAppDirectory() async {
    _appDir = (Platform.isAndroid
        ? await getExternalStorageDirectory() //FOR ANDROID
        : await getApplicationSupportDirectory())!; //FOR IOS
    print(_appDir.path);
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final List<Directory> folders = _appDir.listSync().whereType<Directory>().toList();
    setState(() {
      _folders = folders;
    });
  }

  Future<void> _createFolder(String folderName) async {
    final newFolder = Directory('${_appDir.path}/$folderName');
    if ((await newFolder.exists())) {
    } else {
      await newFolder.create();
      _loadFolders(); // Reload folders
    }
  }

  void _openCreateFolderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: EdgeInsets.all(15.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'أسم المتجر'),
                  controller: folderName,
                ),
                SizedBox(height: 150.h),
                ElevatedButton(
                  onPressed: () {
                    _createFolder(folderName.text);
                    Navigator.pop(context);
                    folderName.clear();
                  },
                  child: const Text('إنشاء ملف المتجر'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  Future<void> _importAndSaveFile() async {
    // Step 1: Pick the .txt file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null && result.files.single.path != null) {
      // Step 2: Read the file content
      File importedFile = File(result.files.single.path!);
      String fileContent = await importedFile.readAsString();

      // Step 3: Get the app directory to save the file
      Directory appDir = await getApplicationDocumentsDirectory(); // For Android & iOS
      String newFilePath = '${appDir.path}/store_file.txt';

      // Step 4: Save the file to the app directory
      File newFile = File(newFilePath);
      await newFile.writeAsString(fileContent);

      setState(() {
        _importedFileContent = fileContent; // Update UI with file content if needed
      });

      // Optionally show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم رفع الملف: $newFilePath')),
      );
    } else {
      // User canceled the file picker
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم تحديد ملف')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المتاجر')),
      body: ListView.separated(
        itemCount: _folders.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final folder = _folders[index];
          return ListTile(
            title: Text(folder.path.split('/').last),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FolderDetailsScreen(folder: folder),
                ),
              );
            },
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                child: Padding(
                  padding: EdgeInsets.all(15.r),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Rename Folder
                      ElevatedButton(
                        onPressed: () {
                          folderName.text = folder.path.split('/').last;
                          Navigator.pop(context);
                          showDialog(context: context, builder: (context) => Dialog(
                            child: Padding(
                              padding: EdgeInsets.all(20.r),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: folderName,
                                  ),
                                  SizedBox(height: 30.h,),
                                  ElevatedButton(
                                    onPressed: () {
                                      String newName = "${folder.parent.path}/${folderName.text}";
                                      folder.rename(newName);
                                      print(newName);
                                      Navigator.pop(context);
                                      _loadFolders();
                                    },
                                    child: const Text("إعادة تسمية"),
                                  ),
                                ],
                              ),
                            ),
                          ),);
                        },
                        child: const Text("إعادة تسمية"),
                      ),
                      SizedBox(height: 20.h,),
                      /// Delete Folder
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog(context: context, builder: (context) => Dialog(
                            child: Padding(
                              padding: EdgeInsets.all(20.r),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "هل انت متأكد من رغبتك في حذف ملف متجر ${folder.path.split('/').last}؟",
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 30.h,),
                                  Row(
                                    children: [
                                      ElevatedButton(child: const Text("لا"), onPressed: () => Navigator.pop(context)),
                                      const Spacer(),
                                      ElevatedButton(
                                        child: const Text("نعم"), onPressed: () {
                                        setState(() {
                                          folder.delete();
                                          Navigator.pop(context);
                                          _loadFolders();
                                        });
                                      },),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),);
                        },
                        child: const Text("حذف المتجر"),
                      ),
                    ],
                  ),
                ),
              ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateFolderDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Container(
        height: 80.h,
        padding: EdgeInsets.all(20.r),
        child: CustomButton(
          innerText: "تحميل ملف المنتجات",
          onPressed: _importAndSaveFile,
        ),
      ),
    );
  }
}