// lib/pages/history_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


  class CamaraPage extends StatefulWidget {
    const CamaraPage({super.key});
  @override
    State<CamaraPage> createState() => _CamaraPageState();
  }

  class _CamaraPageState extends State<CamaraPage> {
    final ImagePicker _picker = ImagePicker();
    XFile? _image;

    Future<void> _getImage() async {
      // final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      setState(() {
        _image = image;
      });
    }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
        appBar: AppBar(
          title: Text('Camara'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _image == null? Text('No image selected.') : Image.file(File(_image!.path)),
        ElevatedButton(
        child: Text("Take a shot"),
        onPressed: _getImage,
        style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.blue, // Text color
        ),
        ),
        ]
        )
        )
        );
      }
  }
