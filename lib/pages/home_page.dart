import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'detail_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Directory _directory;
  late TextEditingController _fileNameController;
  late TextEditingController _bodyController;
  late List<String> _filePaths;
  late bool _isAndroid;
  late bool _isLoading;
  late bool _isCache;
  late bool _isData;

  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController();
    _bodyController = TextEditingController();
    _filePaths = [];
    _isAndroid = false;
    _isLoading = false;
    _isCache = true;
    _isData = false;
    _getAllFiles();
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    _directory = _isCache
        ? await getTemporaryDirectory()
        : await getApplicationDocumentsDirectory();
  }

  Future<void> _createFile(
      {required String fileName, required String text}) async {
    await _getLocation();
    File file = File(
        "${_directory.path}/$fileName-${DateTime.now().toIso8601String()}.txt");
    await file.writeAsString(text);
    _fileNameController.clear();
    _bodyController.clear();
    _getAllFiles();
  }

  Future<void> _getAllFiles() async {
    setState(() {
      _isLoading = true;
      _filePaths.clear();
    });

    await _getLocation();
    Stream<FileSystemEntity> files = _directory.list();
    files.listen((event) {
      if (event.path.endsWith('.txt')) {
        setState(() {
          _filePaths.add(event.path);
        });
      }
    });

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Path Provider",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 28,
            shadows: [
              Shadow(
                color: Colors.black,
                offset: Offset(5, 3),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent.shade200,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          _isCache = true;
                          _isData = false;
                        });
                        _getAllFiles();
                      },
                      color: _isCache ? Colors.blue : Colors.grey,
                      child: const Text("Cache"),
                      elevation: 20,
                      highlightElevation: 30,
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    MaterialButton(
                      onPressed: () {
                        setState(() {
                          _isCache = false;
                          _isData = true;
                        });
                        _getAllFiles();
                      },
                      color: _isData ? Colors.blue : Colors.grey,
                      child: const Text("Data"),
                      elevation: 10,
                      highlightElevation: 30,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        itemBuilder: (_, index) {
                          return Card(
                            shadowColor: Colors.grey,
                            elevation: 7,
                            child: ListTile(
                              onLongPress: () {
                                showDialog(
                                  context: context,
                                  builder: (value) {
                                    return CupertinoAlertDialog(
                                      title: Text("Select to delete data"),
                                      actions: [
                                        CupertinoDialogAction(
                                          onPressed: () {
                                            _filePaths.removeAt(index);
                                            setState(() {});
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Delete",
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                        CupertinoDialogAction(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("Cancel"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailPage(filePath: _filePaths[index]),
                                  ),
                                );
                              },
                              title: Text(_filePaths[index]),
                            ),
                          );
                        },
                        itemCount: _filePaths.length,
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return _customDialog(
                context: context,
                isPlatform: _isAndroid,
                fileNameController: _fileNameController,
                bodyController: _bodyController,
                formKey: _formKey,
                onCreatePressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _createFile(
                      fileName: _fileNameController.text.trim().toLowerCase(),
                      text: _bodyController.text,
                    );
                    Navigator.pop(context);
                  }
                },
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

Widget _customDialog({
  required bool isPlatform,
  required BuildContext context,
  required TextEditingController fileNameController,
  required TextEditingController bodyController,
  required GlobalKey<FormState> formKey,
  required void Function() onCreatePressed,
}) {
  return CupertinoAlertDialog(
    title: const Text("Create a file"),
    content: Card(
      color: Colors.transparent,
      elevation: 0.0,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: fileNameController,
              decoration: const InputDecoration(hintText: "File name"),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  return null;
                } else {
                  return 'Please enter a file name';
                }
              },
            ),
            TextFormField(
              controller: bodyController,
              decoration: const InputDecoration(hintText: "Text"),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  return null;
                } else {
                  return 'Please write a text';
                }
              },
            ),
          ],
        ),
      ),
    ),
    actions: [
      CupertinoDialogAction(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text("Cancel"),
      ),
      CupertinoDialogAction(
        onPressed: onCreatePressed,
        child: const Text("Create"),
      )
    ],
  );
}
