import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:product_scanner/shared/constants.dart';
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
  bool allProductsFileExists = false;
  DateTime? lastModified;

  @override
  void initState() {
    super.initState();
    _getAppDirectory();
  }


  Future<void> _getAppDirectory() async {
    Directory temp = await getApplicationDocumentsDirectory();
    if(await Directory("${temp.path}/StoreData").exists()){
      _appDir = Directory("${temp.path}/StoreData");
      print(_appDir.path);
      _loadFolders();
    } else {
      Directory("${temp.path}/StoreData").create().then((value) {
        _appDir = value;
        print(_appDir.path);
        _loadFolders();
      },);
    }
    if(await File("${_appDir.path}/store_file.txt").exists()){
      setState(() {
        allProductsFileExists = true;
      });
      lastModified = await File("${_appDir.path}/store_file.txt").lastModified();
    } else {
      allProductsFileExists = false;
    }
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
                  child: const Text('إنشاء متجر جديد'),
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
      String newFilePath = '${_appDir.path}/store_file.txt';

      // Step 4: Save the file to the app directory
      File newFile = File(newFilePath);
      await newFile.writeAsString(fileContent);
      lastModified = await File("${_appDir.path}/store_file.txt").lastModified();

      setState(() {
        _importedFileContent = fileContent; // Update UI with file content if needed
        allProductsFileExists = true;
      });

      // Optionally show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفع الملف بنجاح')),
      );
    } else {
      // User canceled the file picker
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم تحديد ملف')),
      );
    }
  }

  Future<void> deleteDirectory(Directory dir) async {
    if (await dir.exists()) {
      try {
        // List all the files and directories in the directory
        List<FileSystemEntity> contents = dir.listSync();

        // Iterate over all the files and directories and delete them
        for (FileSystemEntity entity in contents) {
          if (entity is File) {
            await entity.delete(); // Delete the file
          } else if (entity is Directory) {
            await deleteDirectory(entity); // Recursively delete subdirectories
          }
        }
        // Now, delete the directory itself
        await dir.delete();
        print('Directory deleted: ${dir.path}');
      } catch (e) {
        print('Error while deleting directory: $e');
      }
    } else {
      print('Directory does not exist');
    }
  }

  @override
  Widget build(BuildContext context) {
    print(_importedFileContent);
print(_folders.isEmpty);
    return Scaffold(
      appBar: AppBar(title: const Text('المتاجر')),
      body: ListView.separated(
        itemCount: _folders.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final folder = _folders[index];
          if(_folders.isEmpty) {
            return const Center(child: Text("قم بإنشاء ملف متجر جديد\nإضغظ على علامة +"),);
          } else {
            return ListTile(
            title: Text(folder.path.split('/').last),
            onTap: () async {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FolderDetailsScreen(folder: folder, storeFile: File("${_appDir.path}/store_file.txt"),),
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
                                        child: const Text("نعم"), onPressed: () async {
                                        await deleteDirectory(Directory(folder.path));

                                        setState(() {
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
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateFolderDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Container(
        height: 80.h,
        padding: EdgeInsets.all(20.r),
        child: allProductsFileExists?
        Container(
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("اخر تعديل ${DateFormat.yMd("ar").add_jm().format(lastModified!)}"),
                ],
              ),
              SizedBox(width: 20.w,),
              IconButton(
                onPressed: _importAndSaveFile,
                icon: const Icon(Icons.folder, color: Colors.white,
                ),
              ),
            ],
          ),),
        ) :
        CustomButton(
          innerText: "تحميل ملف المنتجات",
          onPressed: _importAndSaveFile,
          borderRadius: 0,
          suffixIcon: const Icon(Icons.folder, color: Colors.white,),
        ),
      ),
    );
  }
}