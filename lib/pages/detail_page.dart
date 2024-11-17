import 'dart:io';

import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  final String filePath;

  const DetailPage({super.key, required this.filePath});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late TextEditingController _bodyController;
  late File _file;

  @override
  void initState() {
    super.initState();
    _bodyController = TextEditingController();
    _loadFile();
  }

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _loadFile() async {
    _file = File(widget.filePath);
    String fileContent = await _file.readAsString();
    _bodyController.text = fileContent;
  }

  Future<void> _saveFile() async {
    await _file.writeAsString(_bodyController.text);
  }

  final GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Page"),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              await _saveFile();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('File saved successfully!'),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          child: Column(
            children: [
              Text("File Name:  ${widget.filePath.split('/').last}"),
              const SizedBox(height: 10),
              Text(_bodyController.text),
              TextFormField(
                controller: _bodyController,
                expands: false,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Text Editing',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    return null;
                  } else {
                    return 'nima';
                  }
                },
                onChanged: (value) {
                  if (globalKey.currentState!.validate()) {
                    setState(() {});
                  }
                },
                // validator: (value) {
                //   if (value != null && value.isNotEmpty) {
                //     return null;
                //   } else {
                //     return 'Please enter your name';
                //   }
                // },
                // onChanged: (value) {
                //   if (globalKey.currentState!.validate()) {
                //     setState(() {});
                //   }
                // },
              ),
              // onChanged: (value) async {
              //   await _file.writeAsString(value);
              // },
            ],
          ),
        ),
      ),
    );
  }
}
